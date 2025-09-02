import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/imageEditor/components/paint_layer_preview.dart';
import 'package:pro_image_editor/core/models/layers/emoji_layer.dart';
import 'package:pro_image_editor/core/models/layers/paint_layer.dart';
import 'package:pro_image_editor/core/models/layers/text_layer.dart';
import 'package:pro_image_editor/core/models/layers/widget_layer.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/constants/app_color.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_keys.dart';
import '../../utils/constants/app_strings.dart';
import '../image_editor_view_model.dart';

class AllLayer extends GetWidget<ImageEditorViewModel> {
  const AllLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.chineseBlack,
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(spacerSize8),
        ),
        child: Obx(() {
          final layers = controller.activeLayersList ?? [];
          if (controller.isLoading.value || layers.isEmpty) {
            return buildLayerHistory(context);
          }

          return Column(
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
                  itemCount: layers.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: spacerSize10,
                    vertical: spacerSize5,
                  ),
                  onReorder: (oldIndex, newIndex) {
                    controller.updateDragLayer(newIndex, oldIndex);
                  },
                  buildDefaultDragHandles: false,
                  itemBuilder: (context, index) {
                    if (index >= layers.length) {
                      return const SizedBox();
                    }
                    final layer = layers[index];
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
                          color: Colors.transparent,
                          padding: EdgeInsets.all(spacerSize4),
                          child: Row(
                            children: [
                              Column(
                                spacing: spacerSize5,
                                children: [
                                  IconButton(
                                    tooltip: AppStrings.move,
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    onPressed: () {
                                      controller.restoreLayer(index);
                                    },
                                    icon: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
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
                                  ),
                                  IconButton(
                                    tooltip: AppStrings.hide,
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    onPressed: () {
                                      controller.restoreLayer(index);
                                    },
                                    icon: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              AppColors.violet,
                                              AppColors.brightCyan,
                                              AppColors.antiqueWhite,
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ).createShader(bounds),
                                      child: Icon(
                                        (index <
                                                    controller
                                                        .selectedItems
                                                        .length &&
                                                controller.selectedItems[index])
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white,
                                        size: spacerSize18,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: AppStrings.delete,
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                    ),
                                    onPressed: () {
                                      if (index < layers.length) {
                                        showCommonDialog(
                                          context: context,
                                          onNo: () => Get.back(),
                                          onYes: () {
                                            controller.activeLayersList!
                                                .removeAt(index);
                                            controller
                                                .editorKey
                                                .currentState!
                                                .activeLayers
                                                .removeAt(index);
                                            controller.activeLayersList!
                                                .refresh();
                                            controller.editorKey.currentState!
                                                .setState(() {});
                                            Get.back();
                                          },
                                          title: AppStrings.deleteLayer,
                                          subtitle:AppStrings.areYouSureWantTo+AppStrings.deleteThisLayer,
                                        );
                                      }
                                    },
                                    icon: ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
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
                                  ),
                                  SizedBox(height: spacerSize5),
                                ],
                              ),

                              SizedBox(width: spacerSize10),
                              Expanded(
                                child: SizedBox(
                                  height: spacerSize75,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      spacerSize4,
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.memory(
                                          controller.imageFile.value ??
                                              Uint8List(0),
                                          fit: BoxFit.cover,
                                        ),
                                        Center(
                                          child: () {
                                            if (layer is WidgetLayer) {
                                              return SizedBox(
                                                child: layer.widget,
                                              );
                                            } else if (layer is TextLayer) {
                                              return Text(
                                                layer.text,
                                                style: TextStyle(
                                                  color: layer.color,
                                                  backgroundColor:
                                                      layer.background,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              );
                                            } else if (layer is EmojiLayer) {
                                              return Text(
                                                layer.emoji,
                                                style: const TextStyle(
                                                  fontSize: spacerSize20,
                                                ),
                                              );
                                            } else if (layer is PaintLayer) {
                                              final paintData = layer.toMap();
                                              final offsets =
                                                  (paintData[AppKeys
                                                              .item][AppKeys
                                                              .offsets]
                                                          as List)
                                                      .map(
                                                        (p) => Offset(
                                                          (p['x'] as num)
                                                              .toDouble(),
                                                          (p['y'] as num)
                                                              .toDouble(),
                                                        ),
                                                      )
                                                      .toList();

                                              final color = Color(
                                                paintData[AppKeys.item][AppKeys
                                                    .color],
                                              );
                                              final strokeWidth =
                                                  (paintData[AppKeys
                                                              .item][AppKeys
                                                              .strokeWidth]
                                                          as num)
                                                      .toDouble();

                                              return CustomPaint(
                                                size: Size(
                                                  spacerSize20,
                                                  spacerSize20,
                                                ),
                                                painter: PaintLayerPreview(
                                                  points: offsets,
                                                  color: color,
                                                  strokeWidth: strokeWidth,
                                                ),
                                              );
                                            } else {
                                              return const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                              );
                                            }
                                          }(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildLayerHistory(BuildContext context) {
    return Column(
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
          child: controller.isLoading.value
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacerSize10,
                    vertical: spacerSize10,
                  ),
                  itemCount: 10,
                  itemBuilder: (context, index) => buildShimmerItem(),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: spacerSize10),
                )
              : const Center(
                  child: BaseText(
                    text: AppStrings.noLayers,
                    textColor: Colors.white,
                    fontSize: spacerSize12,
                  ),
                ),
        ),
      ],
    );
  }

  Widget buildShimmerItem() {
    return Shimmer(
      color: AppColors.lightGrey,
      colorOpacity: 0.16,
      enabled: true,
      direction: const ShimmerDirection.fromLTRB(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: spacerSize8,
          horizontal: spacerSize8,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkJungleGreen,
          borderRadius: BorderRadius.circular(spacerSize8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              spacing: spacerSize12,
              children: [
                Container(
                  width: spacerSize12,
                  height: spacerSize12,
                  decoration: BoxDecoration(
                    color: AppColors.chineseBlack,
                    borderRadius: BorderRadius.circular(spacerSize4),
                  ),
                ),
                Container(
                  width: spacerSize12,
                  height: spacerSize12,
                  decoration: BoxDecoration(
                    color: AppColors.chineseBlack,
                    borderRadius: BorderRadius.circular(spacerSize4),
                  ),
                ),
                Container(
                  width: spacerSize12,
                  height:spacerSize12 ,
                  decoration: BoxDecoration(
                    color: AppColors.chineseBlack,
                    borderRadius: BorderRadius.circular(spacerSize4),
                  ),
                ),
              ],
            ),
            const SizedBox(width: spacerSize8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(spacerSize4),
                child: Container(
                  height: spacerSize65,
                  color: AppColors.chineseBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
