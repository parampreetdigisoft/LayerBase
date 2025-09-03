import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/imageEditor/components/paint_layer_preview.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/constants/app_color.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_keys.dart';
import '../../utils/constants/app_strings.dart';
import '../image_editor_view_model.dart';

class SidLayerList extends StatelessWidget {
  final ImageEditorViewModel controller;

  const SidLayerList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spacerSize8),
                topRight: Radius.circular(spacerSize8),
              ),
              color: AppColors.darkJungleGreen,
            ),
            child: const BaseText(
              text: AppStrings.layerHistory,
              textColor: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: controller.activeLayersList!.length,
              padding: EdgeInsets.symmetric(
                horizontal: spacerSize10,
                vertical: spacerSize5,
              ),
              onReorder: (oldIndex, newIndex) {
                controller.updateDragLayer(newIndex, oldIndex);
              },
              buildDefaultDragHandles: false,
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(spacerSize8),
                      elevation: 0,
                      child: child,
                    );
                  },
              itemBuilder: (context, index) {
                if (index >= controller.activeLayersList!.length) {
                  return const SizedBox();
                }
                final layer = controller.activeLayersList![index];
                return ReorderableDelayedDragStartListener(
                  key: ValueKey(layer ?? index),
                  index: index,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: spacerSize5),
                    decoration: BoxDecoration(
                      color: AppColors.darkJungleGreen,
                      borderRadius: BorderRadius.circular(spacerSize8),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Container(
                      color: AppColors.darkJungleGreen,
                      padding: EdgeInsets.all(spacerSize4),
                      child: Row(
                        children: [
                          Column(
                            spacing: spacerSize5,
                            children: [
                              dragButton(index),
                              hideAndShowBtn(index),
                              deleteButton(context, index),
                              SizedBox(height: spacerSize5),
                            ],
                          ),
                          SizedBox(width: spacerSize10),
                          showImageWithLayer(layer),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  dragButton(int index) {
    return IconButton(
      //tooltip: AppStrings.holdToDrag,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
      ),
      onPressed: () {
        controller.restoreLayer(index);
      },
      icon: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppColors.violet,
            AppColors.brightCyan,
            AppColors.antiqueWhite,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: ReorderableDragStartListener(
          index: index,
          child: Icon(
            Icons.drag_handle_sharp,
            color: AppColors.antiqueWhite,
            size: spacerSize20,
          ),
        ),
      ),
    );
  }

  hideAndShowBtn(int index) {
    return IconButton(
      /*  tooltip: controller.selectedItems[index]?
                                    AppStrings.hide:
                                    AppStrings.show,*/
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
      ),
      onPressed: () {
        controller.restoreLayer(index);
      },
      icon: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppColors.violet,
            AppColors.brightCyan,
            AppColors.antiqueWhite,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Icon(
          (index < controller.selectedItems.length &&
                  controller.selectedItems[index])
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.white,
          size: spacerSize18,
        ),
      ),
    );
  }

  deleteButton(BuildContext context, int index) {
    return IconButton(
      // tooltip: AppStrings.delete,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 0),
      ),
      onPressed: () {
        if (index < controller.activeLayersList!.length) {
          showCommonDialog(
            context: context,
            onNo: () => Get.back(),
            onYes: () {
              if (index >= 0 && index < controller.activeLayersList!.length) {
                controller.activeLayersList!.removeAt(index);
              }
              if (index >= 0 &&
                  index <
                      controller.editorKey.currentState!.activeLayers.length) {
                controller.editorKey.currentState!.activeLayers.removeAt(index);
              }
              controller.activeLayersList!.refresh();
              controller.editorKey.currentState!.setState(() {});
              Get.back();
            },
            title: AppStrings.deleteLayer,
            subtitle: AppStrings.areYouSureWantTo + AppStrings.deleteThisLayer,
          );
        }
      },
      icon: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            AppColors.violet,
            AppColors.brightCyan,
            AppColors.antiqueWhite,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: spacerSize20,
        ),
      ),
    );
  }

  showImageWithLayer(Layer layer) {
    return Expanded(
      child: SizedBox(
        height: spacerSize75,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(spacerSize4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                controller.imageFile.value ?? Uint8List(0),
                fit: BoxFit.cover,
              ),
              Center(
                child: () {
                  if (layer is WidgetLayer) {
                    return SizedBox(child: layer.widget);
                  } else if (layer is TextLayer) {
                    return Text(
                      layer.text,
                      style: TextStyle(
                        color: layer.color,
                        backgroundColor: layer.background,
                      ),
                      overflow: TextOverflow.ellipsis,
                    );
                  } else if (layer is EmojiLayer) {
                    return Text(
                      layer.emoji,
                      style: const TextStyle(fontSize: spacerSize20),
                    );
                  } else if (layer is PaintLayer) {
                    final paintData = layer.toMap();
                    final offsets =
                        (paintData[AppKeys.item][AppKeys.offsets] as List)
                            .map(
                              (p) => Offset(
                                (p['x'] as num).toDouble(),
                                (p['y'] as num).toDouble(),
                              ),
                            )
                            .toList();

                    final color = Color(paintData[AppKeys.item][AppKeys.color]);
                    final strokeWidth =
                        (paintData[AppKeys.item][AppKeys.strokeWidth] as num)
                            .toDouble();

                    return CustomPaint(
                      size: Size(spacerSize20, spacerSize20),
                      painter: PaintLayerPreview(
                        points: offsets,
                        color: color,
                        strokeWidth: strokeWidth,
                      ),
                    );
                  } else {
                    return const Icon(Icons.image, color: Colors.grey);
                  }
                }(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
