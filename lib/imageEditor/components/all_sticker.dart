import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/models/layers/widget_layer.dart';

import '../../utils/constants/app_constants.dart';
import '../image_editor_view_model.dart';

class AllSticker extends StatelessWidget {
  final ImageEditorViewModel controller;

  const AllSticker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: controller.stickersList.length,
        itemBuilder: (context, index) {
          final path = controller.stickersList[index];
          return GestureDetector(
            onTap: () {
              final path = controller.stickersList[index];
              controller.editorKey.currentState!.addLayer(
                WidgetLayer(
                  exportConfigs: WidgetLayerExportConfigs(assetPath: path),
                  widget: Image.asset(
                    path,
                    fit: BoxFit.contain,
                    width: spacerSize30,
                    height: spacerSize30,
                  ),
                ),
              );
              controller.selectedItems.add(true);

              Navigator.of(context).pop();
            },
            child: Padding(
              padding: EdgeInsets.all(spacerSize5),
              child: Image.asset(path, fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
