import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/image_editor/components/paint_layer_preview.dart';
import 'package:pro_image_editor/core/models/layers/layer.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/base/widgets/base_shader_mask.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBlack,
        borderRadius: BorderRadius.circular(spacerSize5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spacerSize5),
                topRight: Radius.circular(spacerSize5),
              ),
              color: AppColors.lightGrey,
            ),
            child: const BaseText(
              text: AppStrings.layerHistory,
              textColor: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize13,
            ),
          ),
          Expanded(child: reorderableList()),
        ],
      ),
    );
  }

  Widget reorderableList() {
    return Obx(
      () => ReorderableListView.builder(
        itemCount: controller.activeLayersList!.length,
        reverse: true,
        padding: EdgeInsets.symmetric(horizontal: spacerSize10, vertical: spacerSize5),
        onReorder: (oldIndex, newIndex) {
          controller.updateDragLayerAndShuffle(newIndex, oldIndex);
        },
        buildDefaultDragHandles: false,
        proxyDecorator: proxyDecorateWidget(),
        itemBuilder: (context, index) {
          return index >= controller.activeLayersList!.length
              ? const SizedBox()
              : ReorderableDelayedDragStartListener(
                  key: ValueKey(index),
                  index: index,
                  child: layerItems(index, context),
                );
        },
      ),
    );
  }

  Widget layerItems(int index, BuildContext context) {
    return InkWell(
      onTap: () {
        controller.onSideLayerTapped(index);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: spacerSize3),
        padding: EdgeInsets.all(spacerSize5),
        decoration: baseBoxDecoration(
          color: AppColors.lightGrey1,
          radius: spacerSize8,
          borderColor:
              controller.editorKey.currentState!.selectedLayers.any(
                (element) => element.id == controller.activeLayersList![index].id,
              )
              ? AppColors.lightPurple
              : AppColors.lightGrey1,
        ),
        child: Row(
          spacing: spacerSize10,
          children: [
            dragButton(index),
            showImageWithLayer(index),
            SizedBox(width: spacerSize15),
            hideAndShowBtn(index),
            deleteButton(context, index),
          ],
        ),
      ),
    );
  }

  Widget Function(Widget, int, Animation<double>) proxyDecorateWidget() {
    return (Widget child, int index, Animation<double> animation) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 1.0,
          end: 1.07,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(spacerSize8),
          child: child,
        ),
      );
    };
  }

  Widget dragButton(int index) {
    return iconLayout(
      index,
      tooltipText: AppStrings.holdToDrag,
      icon: Icons.drag_indicator_sharp,
      onPressed: () {},
    );
  }

  Widget hideAndShowBtn(int index) {
    return iconLayout(
      index,
      tooltipText: !controller.selectedItems[index] ? AppStrings.show : AppStrings.hide,
      icon: (index < controller.selectedItems.length && controller.selectedItems[index])
          ? Icons.visibility
          : Icons.visibility_off,
      onPressed: () {
        controller.hideShowRestoreLayer(index);
      },
    );
  }

  Widget deleteButton(BuildContext context, int index) {
    return iconLayout(
      index,
      tooltipText: AppStrings.delete,
      icon: Icons.delete_rounded,
      onPressed: () {
        showBaseDialog(
          context: context,
          onNo: () => Get.back(),
          onYes: () {
            controller.deleteSideLayer(index);
          },
          title: AppStrings.deleteLayer,
          subtitle: AppStrings.areYouSureWantTo + AppStrings.deleteThisLayer,
        );
      },
    );
  }

  Widget iconLayout(int index, {String? tooltipText, IconData? icon, VoidCallback? onPressed}) {
    return IconButton(
      tooltip: tooltipText,
      style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
      onPressed: () {
        onPressed!();
      },
      icon: Icon(icon, color: AppColors.antiqueWhite, size: spacerSize18),
    );
  }

  Widget showImageWithLayer(int index) {
    return Expanded(
      child: SizedBox(
        height: spacerSize45,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(spacerSize4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(controller.imageFile.value ?? Uint8List(0), fit: BoxFit.cover),
              Center(child: getLayers(index)),
            ],
          ),
        ),
      ),
    );
  }

  Widget getLayers(int index) {
    Layer layer = controller.activeLayersList![index];
    switch (layer) {
      case (WidgetLayer _):
        return SizedBox(child: layer.widget);
      case (TextLayer _):
        return Text(
          layer.text,
          style: TextStyle(color: layer.color, backgroundColor: layer.background),
          overflow: TextOverflow.ellipsis,
        );

      case (EmojiLayer _):
        return BaseText(text: layer.emoji, fontSize: spacerSize15);
      case (PaintLayer _):
        final paintData = layer.toMap();
        final offsets = (paintData[AppKeys.item][AppKeys.offsets] as List)
            .map((p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()))
            .toList();

        final color = Color(paintData[AppKeys.item][AppKeys.color]);
        final strokeWidth = (paintData[AppKeys.item][AppKeys.strokeWidth] as num).toDouble();

        return CustomPaint(
          size: Size(spacerSize20, spacerSize20),
          painter: PaintLayerPreview(points: offsets, color: color, strokeWidth: strokeWidth),
        );

      default:
        return const Icon(Icons.image, color: Colors.grey);
    }
  }
}
