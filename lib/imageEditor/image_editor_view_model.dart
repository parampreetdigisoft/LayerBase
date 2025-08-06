import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '../utils/constants/app_keys.dart';

class ImageEditorViewModel extends GetxController {
  Box<dynamic>? hiveBox;
  final editorKey = GlobalKey<ProImageEditorState>();
  var layerData="".obs;

  @override
  void onInit() {
    super.onInit();
    hiveBox = Hive.box<dynamic>(AppKeys.imageLayerBox);
  }

  Future<void> saveImageToHive(
    Uint8List thumbNailBytes,
    Uint8List imageBytes,
    int? imageIndex,
    var layerJson,
  ) async {
    if (imageIndex != null) {
      await hiveBox!.putAt(imageIndex, {
        AppKeys.image: imageBytes,
        AppKeys.layerJson: layerJson,
        AppKeys.imageThumbnail: thumbNailBytes,
      });
    } else {
      await hiveBox!.add({
        AppKeys.imageThumbnail: thumbNailBytes,
        AppKeys.image: imageBytes,
        AppKeys.layerJson: layerJson,
      });
    }
  }
  void applyFiltersToReferences(Map<String, dynamic> data, List<List<double>> filters) {
    final references = data['references'] as Map<String, dynamic>;
    int index = 0;

    for (final entry in references.entries) {
      if (index >= filters.length) break;

      final ref = entry.value as Map<String, dynamic>;
      ref['f'] = filters[index];

      index++;
    }
  }

}
