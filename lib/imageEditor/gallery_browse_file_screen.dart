import 'package:ecrumedia/imageEditor/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'gallery_screen_view_model.dart';

class GalleryBrowseFileScreen extends GetWidget<GalleryScreenViewModel> {
  const GalleryBrowseFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 1, child: GalleryScreen()),
        Expanded(
          flex: 3,
          child: Center(
            child: ElevatedButton(
              onPressed: controller.pickImage,
              child: const Text('Browse Image'),
            ),
          ),
        ),
      ],
    );
  }
}
