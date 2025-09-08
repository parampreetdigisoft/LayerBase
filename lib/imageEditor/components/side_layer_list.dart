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
              fontSize: fontSize13,
            ),
          ),

          Expanded(child: reorderableList()),
        ],
      ),
    );
  }

  reorderableList() {
    return Obx(
      () => ReorderableListView.builder(
        itemCount: controller.activeLayersList!.length,
        padding: EdgeInsets.symmetric(horizontal: spacerSize10, vertical: spacerSize5),
        onReorder: (oldIndex, newIndex) {
          controller.updateDragLayer(newIndex, oldIndex);
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

  layerItems(int index, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: spacerSize5),
      padding: EdgeInsets.all(spacerSize4),
      decoration: BoxDecoration(
        color: AppColors.darkJungleGreen,
        borderRadius: BorderRadius.circular(spacerSize8),
        border: Border.all(color: AppColors.lightGrey),
      ),
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
          showImageWithLayer(index),
        ],
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

  dragButton(int index) {
    return iconLayout(
      index,
      tooltipText: AppStrings.holdToDrag,
      icon: Icons.drag_handle_sharp,
      onPressed: () {},
    );
  }

  hideAndShowBtn(int index) {
    return iconLayout(
      index,
      tooltipText: controller.selectedItems[index] ? AppStrings.show : AppStrings.hide,
      icon: (index < controller.selectedItems.length && controller.selectedItems[index])
          ? Icons.visibility_outlined
          : Icons.visibility_off_outlined,
      onPressed: () {
        controller.restoreLayer(index);
      },
    );
  }

  deleteButton(BuildContext context, int index) {
    return iconLayout(
      index,
      tooltipText: AppStrings.delete,
      icon: Icons.delete_forever,
      onPressed: () {
        showBaseDialog(
          context: context,
          onNo: () => Get.back(),
          onYes: () {
            controller.deleteLayer(index);
          },
          title: AppStrings.deleteLayer,
          subtitle: AppStrings.areYouSureWantTo + AppStrings.deleteThisLayer,
        );
      },
    );
  }

  iconLayout(int index, {String? tooltipText, IconData? icon, VoidCallback? onPressed}) {
    return IconButton(
      tooltip: tooltipText,
      style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),
      onPressed: () {
        onPressed!();
      },
      icon: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [AppColors.violet, AppColors.brightCyan, AppColors.antiqueWhite],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(bounds),
        child: Icon(icon, color: Colors.white, size: spacerSize18),
      ),
    );
  }

  showImageWithLayer(int index) {
    return Expanded(
      child: SizedBox(
        height: spacerSize75,
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

  getLayers(int index) {
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
        return Text(layer.emoji, style: const TextStyle(fontSize: spacerSize20));

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
