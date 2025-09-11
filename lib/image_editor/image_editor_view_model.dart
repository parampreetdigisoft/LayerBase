import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../utils/base/dialogs/base_dialog.dart';
import '../utils/constants/app_keys.dart';
import '../utils/constants/app_strings.dart';
import '../utils/shared_prefs_service.dart';

class ImageEditorViewModel extends GetxController {
  Box<dynamic>? hiveBox;
  late SharedPrefsService sharedPrefsService;
  RxList<dynamic>? activeLayersList = <dynamic>[].obs;
  final editorKey = GlobalKey<ProImageEditorState>();
  final Map<int, Layer> removedLayers = {};
  final Map<String, Layer> removedLayersNew = {};
  String userDisplayName = "";
  var layerData = "".obs,
      stickersList = <String>[].obs,
      imageData = Rx<dynamic>(null),
      imageIndex = Rx<int?>(null),
      imageFile = Rx<Uint8List?>(null),
      selectedItems = <bool>[].obs,
      isLoading = true.obs;
  Map<String, dynamic>? exportJsonMap = {};

  @override
  void onInit() {
    super.onInit();
    sharedPrefsService = SharedPrefsService.instance;
    userDisplayName = sharedPrefsService.getString(AppKeys.displayName) ?? "";
    loadStickers();
    initHiveData();
    Future.delayed(Duration(seconds: 2), () {
      initializeLayer();
    });
  }

  @override
  void onClose() {
    layerData.close();
    stickersList.close();
    activeLayersList?.close();
    imageData.close();
    imageIndex.close();
    imageFile.close();
    super.onClose();
  }

  @override
  void dispose() {
    editorKey.currentState?.dispose();
    super.dispose();
  }

  void initializeLayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (editorKey.currentState != null && editorKey.currentState!.stateHistory.isNotEmpty) {
        activeLayersList!.assignAll(editorKey.currentState!.stateHistory.last.layers);
      } else {
        activeLayersList!.value = [];
      }

      activeLayersList!.refresh();

      initSelection();
    });
  }

  void initHiveData() {
    if (Get.arguments[AppKeys.imageIndex] != null) {
      hiveBox = Hive.box<dynamic>(AppKeys.imageLayerBox);
      imageIndex.value = Get.arguments[AppKeys.imageIndex];
      var data = hiveBox!.getAt(Get.arguments[AppKeys.imageIndex]);
      final img = data[AppKeys.image];
      if (img is Uint8List) {
        imageFile.value = img;
      }
      layerData.value = data[AppKeys.layerJson] ?? "";
    } else {
      hiveBox = Hive.box<dynamic>(AppKeys.imageLayerBox);
      imageData.value = Get.arguments[AppKeys.imageData];
      imageFile.value = imageData.value[AppKeys.image];
      imageIndex.value = Get.arguments[AppKeys.imageIndex];
    }
  }

  void initSelection() {
    selectedItems.value = List.filled(activeLayersList!.length, true, growable: true);
    isLoading.value = false;
  }

  void deleteLayer(int index) {
    if (index >= 0 && index < activeLayersList!.length) {
      activeLayersList!.removeAt(index);
    }
    if (index >= 0 && index < editorKey.currentState!.activeLayers.length) {
      editorKey.currentState!.activeLayers.removeAt(index);
    }
    activeLayersList!.refresh();
    editorKey.currentState!.setState(() {});
    Get.back();
  }

  void applyFiltersToReferences(Map<String, dynamic> data, List<List<double>> filters) {
    final references = data[AppKeys.references] as Map<String, dynamic>;
    int index = 0;
    for (final entry in references.entries) {
      if (index >= filters.length) break;
      final ref = entry.value as Map<String, dynamic>;
      ref['f'] = filters[index];
      index++;
    }
  }

  Future<void> saveImageToHive(Uint8List thumbNailBytes,
      Uint8List imageBytes,
      int? imageIndex,
      dynamic layerJson,) async {
    try {
      await exportImageAndSaveInHive(thumbNailBytes, imageBytes, imageIndex, layerJson);
    } catch (e) {
      await saveImageCatchError(e.toString(), thumbNailBytes, imageBytes, layerJson);
    } finally {
      // downloadImage(imageBytes);
      AppToast.show(
        title: AppStrings.savedSuccessfully,
        "${AppStrings.image}\t${AppStrings.savedSuccessfully}",
        backgroundColor: Colors.green,
      );
    }
  }

  exportImageAndSaveInHive(Uint8List thumbNailBytes,
      Uint8List imageBytes,
      int? imageIndex,
      dynamic layerJson,) async {
    final box = Hive.box<dynamic>(AppKeys.imageLayerBox);
    if (imageIndex != null && imageIndex >= 0 && imageIndex < box.length) {
      if (removedLayers.isNotEmpty) {
        removedLayers.forEach((index, layer) {
          if (index >= 0 && index <= editorKey.currentState!.stateHistory.last.layers.length) {
            editorKey.currentState!.stateHistory.last.layers.insert(index, layer);
          }
        });
      }
      final export = await editorKey.currentState?.exportStateHistory(
        configs: ExportEditorConfigs(
          exportBlur: true,
          enableMinify: false,
          exportCropRotate: true,
          exportEmoji: true,
          exportFilter: true,
          exportPaint: true,
          exportText: true,
          exportTuneAdjustments: true,
          exportWidgets: true,
          historySpan: ExportHistorySpan.all,
        ),
      );
      Map<String, dynamic>? jsonMap = await export?.toMap();
      final layerJson = jsonEncode(jsonMap);
      await box.putAt(imageIndex, {
        AppKeys.imageThumbnail: thumbNailBytes,
        AppKeys.image: imageBytes,
        AppKeys.layerJson: layerJson,
      });
    } else {
      await box.add({
        AppKeys.imageThumbnail: thumbNailBytes,
        AppKeys.image: imageBytes,
        AppKeys.layerJson: layerJson,
      });
    }
  }

  saveImageCatchError(String errorMsg,
      Uint8List thumbNailBytes,
      Uint8List imageBytes,
      dynamic layerJson,) async {
    if (errorMsg.toString().contains("Unexpected error")) {
      await Hive.deleteBoxFromDisk(AppKeys.imageLayerBox);
      final box = await Hive.openBox<dynamic>(
        AppKeys.imageLayerBox,
        compactionStrategy: (entries, deletedEntries) => false,
      );
      await box.add({
        AppKeys.imageThumbnail: thumbNailBytes,
        AppKeys.image: imageBytes,
        AppKeys.layerJson: layerJson,
      });
    }
  }

  void removeLayer(int index) {
    if (index >= 0 && index < editorKey.currentState!.activeLayers.length) {
      editorKey.currentState!.activeLayers.removeAt(index);
      selectedItems.removeAt(index);
      editorKey.currentState!.setState(() {});
    }
  }

  Future<void> hideShowRestoreLayer(int index) async {
    final editorState = editorKey.currentState;
    if (editorState == null) return;
    if (index < 0 || index >= selectedItems.length) return;

    final layer = activeLayersList![index];
    final layerId = layer.id;
    final newValue = !selectedItems[index];
    selectedItems[index] = newValue;

    var layers = editorState.stateHistory.last.layers;

    if (!newValue) {
      final layerToRemove = layers
          .where((l) => l.id == layerId)
          .isNotEmpty
          ? layers.firstWhere((l) => l.id == layerId)
          : null;

      if (layerToRemove != null) {
        removedLayersNew[layerToRemove.id] = layerToRemove;
        layers.remove(layerToRemove);
      }
    } else {
      if (removedLayersNew.containsKey(layerId)) {
        final toRestore = removedLayersNew[layerId]!;
        int insertIndex = index.clamp(0, layers.length);
        bool alreadyPresent = layers.any((l) => l.id == toRestore.id);
        if (!alreadyPresent) {
          layers.insert(insertIndex, toRestore);
        }
        removedLayersNew.remove(layerId);
      }
    }
    activeLayersList?.refresh();
    selectedItems.refresh();
    editorState.setState(() {});
  }

  void updateDragLayerAndShuffle(int newIndex, int oldIndex) {
    if (newIndex > oldIndex) newIndex -= 1;

    final len = activeLayersList!.length;
    if (oldIndex < 0 || oldIndex >= len || newIndex < 0 || newIndex >= len) return;
    final movedLayer = activeLayersList!.removeAt(oldIndex);
    activeLayersList!.insert(newIndex, movedLayer);

    if (editorKey.currentState != null &&
        editorKey.currentState!.activeLayers.isNotEmpty &&
        activeLayersList!.length == editorKey.currentState!.activeLayers.length) {
      final movedCanvasLayer = editorKey.currentState!.activeLayers.removeAt(oldIndex);
      editorKey.currentState!.activeLayers.insert(newIndex, movedCanvasLayer);
    }
    final movedSelected = selectedItems.removeAt(oldIndex);
    selectedItems.insert(newIndex, movedSelected);
    activeLayersList?.refresh();
    selectedItems.refresh();
    editorKey.currentState?.setState(() {});
  }

  Future<void> loadStickers() async {
    final String response = await rootBundle.loadString(AppAssets.stickersJson);
    final List<dynamic> data = json.decode(response);
    stickersList.value = List<String>.from(data);
    if (editorKey.currentState != null && editorKey.currentState!.stateHistory.isNotEmpty) {
      List<Layer> newLayers = [];
      for (Layer originalLayer in editorKey.currentState!.stateHistory.last.layers) {
        Layer newLayer = Layer(
          flipY: originalLayer.flipY,
          flipX: originalLayer.flipX,
          scale: originalLayer.scale,
          rotation: originalLayer.rotation,
          boxConstraints: originalLayer.boxConstraints,
          groupId: originalLayer.groupId,
          id: originalLayer.id,
          interaction: originalLayer.interaction,
          key: originalLayer.key,
          meta: originalLayer.meta,
          offset: originalLayer.offset,
        );
        newLayers.add(newLayer);
      }
      activeLayersList!.assignAll(newLayers);
      activeLayersList!.refresh();
    }
  }

  Future<void> downloadImage(bytes) async {
    bool isSuccess = false;
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return;
      }
      final timestamp =
          "${DateTime
          .now()
          .year}${DateTime
          .now()
          .month
          .toString()
          .padLeft(2, '0')}${DateTime
          .now()
          .day
          .toString()
          .padLeft(2, '0')}_${DateTime
          .now()
          .hour}${DateTime
          .now()
          .minute}${DateTime
          .now()
          .second}";
      final filePath = "$selectedDirectory/layer_base_img_$timestamp.png";
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      isSuccess = true;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (isSuccess) {
        AppToast.show(
          title: AppStrings.downloadSuccessfully,
          "${AppStrings.file}\t ${AppStrings.downloadSuccessfully}",
          backgroundColor: Colors.green,
        );
      }
    }
  }
}
