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
  late SharedPrefsService sharedPrefsService;
  Box<dynamic>? hiveBox;
  final editorKey = GlobalKey<ProImageEditorState>();
  final Map<int, Layer> removedLayers = {};
  final Map<String, Layer> removedLayersNew = {};
  RxList<dynamic>? activeLayersList = <dynamic>[].obs;
  RxString userDisplayName = "".obs;
  RxString userEmail = "".obs;
  RxBool isLoading = true.obs;
  var layerData = "".obs;
  var stickersList = <String>[].obs;
  var imageData = Rx<dynamic>(null);
  var imageIndex = Rx<int?>(null);
  var imageFile = Rx<Uint8List?>(null);
  var selectedItems = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();
    sharedPrefsService = SharedPrefsService.instance;
    userDisplayName.value = sharedPrefsService.getString(AppKeys.displayName) ?? "";
    userEmail.value = sharedPrefsService.getString(AppKeys.email) ?? "";
    loadStickers();
    initHiveData();
    Future.delayed(Duration(seconds: 2), () {
      initializeLayer();
    });
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

  void deleteSideLayer(int index) {
    if (index < 0 || index >= activeLayersList!.length) return;
    final layerToDelete = activeLayersList![index];
    final layerId = layerToDelete.id;
    activeLayersList!.removeAt(index);
    selectedItems.removeAt(index);
    editorKey.currentState?.activeLayers.removeWhere((layer) => layer.id == layerId);
    editorKey.currentState?.stateHistory.last.layers.removeWhere((layer) => layer.id == layerId);
    activeLayersList!.refresh();
    editorKey.currentState!.setState(() {});
    Get.back();
  }

  void onAddLayer(Layer layer) {
    activeLayersList!.add(layer);
    selectedItems.value = List<bool>.from(selectedItems)..add(true);
    activeLayersList!.refresh();
  }

  void onRemoveLayer(Layer layer) {
    int index = activeLayersList!.indexWhere((activeLayer) => activeLayer.id == layer.id);
    if (index != -1) {
      activeLayersList!.removeAt(index);
      selectedItems.removeAt(index);
      activeLayersList!.refresh();
      selectedItems.refresh();
    }
  }

  void onUndoAddRedoLayer() {
    if (editorKey.currentState != null) {
      editorKey.currentState!.setState(() {
        activeLayersList!.assignAll(editorKey.currentState!.activeLayers);
        selectedItems.value = List.filled(activeLayersList!.length, true, growable: true);
        activeLayersList!.refresh();
        selectedItems.refresh();
        editorKey.currentState!.stateHistory.last.layers.assignAll(
          editorKey.currentState!.activeLayers,
        );
      });
    }
  }

  void onSideLayerTapped(int index) {
    editorKey.currentState!.setState(() {
      editorKey.currentState!.selectLayerById(activeLayersList![index].id);
    });
    activeLayersList!.refresh();
  }

  void onSelectLayerTapped(String selectedLayer) {
    int index = activeLayersList!.indexWhere((element) => element.id == selectedLayer);
    if (index != -1) activeLayersList![index].id = selectedLayer;
    activeLayersList!.refresh();
  }

  void applyFiltersToReferences(List<List<double>> filters) {
    final Map<String, dynamic> jsonData = jsonDecode(layerData.value);
    final references = jsonData[AppKeys.references] as Map<String, dynamic>;
    int index = 0;
    for (final entry in references.entries) {
      if (index >= filters.length) break;
      final ref = entry.value as Map<String, dynamic>;
      ref['f'] = filters[index];
      index++;
    }
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

  Future<void> saveImageToHive(
    Uint8List thumbNailBytes,
    Uint8List imageBytes,
    int? imageIndex,
    String type,
  ) async {
    try {
      await exportImageAndSaveInHive(thumbNailBytes, imageBytes, imageIndex);
    } catch (e) {
      debugPrint("Exception:::::::$e");
    } finally {
      if (type != AppStrings.export) {
        AppToast.show(
          title: AppStrings.savedSuccessfully,
          "${AppStrings.image}\t${AppStrings.savedSuccessfully}",
          backgroundColor: Colors.green,
        );
      }
    }
  }

  Future<void> exportImageAndSaveInHive(
    Uint8List thumbNailBytes,
    Uint8List imageBytes,
    int? imageIndex,
  ) async {
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
    Map<String, dynamic>? exportJsonMap = await export?.toMap();
    final layerJson = jsonEncode(exportJsonMap);
    final box = Hive.box<dynamic>(AppKeys.imageLayerBox);
    if (imageIndex != null && imageIndex >= 0 && imageIndex < box.length) {
      if (removedLayers.isNotEmpty) {
        removedLayers.forEach((index, layer) {
          if (index >= 0 && index <= editorKey.currentState!.stateHistory.last.layers.length) {
            editorKey.currentState!.stateHistory.last.layers.insert(index, layer);
          }
        });
      }
      var data = await box.getAt(imageIndex);
      data[AppKeys.imageThumbnail] = thumbNailBytes;
      data[AppKeys.layerJson] = layerJson;
    } else {
      await box.add({
        AppKeys.imageThumbnail: thumbNailBytes,
        AppKeys.image: imageBytes,
        AppKeys.layerJson: layerJson,
      });
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
      final layerToRemove = layers.where((l) => l.id == layerId).isNotEmpty
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
    editorKey.currentState!.activeLayers.assignAll(
      editorState.stateHistory.last.layers
          .where((layer) => selectedItems[activeLayersList!.indexWhere((al) => al.id == layer.id)])
          .toList(),
    );
  }

  Future<void> exportAndDownloadImage() async {
    bool isSuccess = false;
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return;
      }
      final currentDate = DateTime.now();
      final year = currentDate.year;
      final month = currentDate.month.toString().padLeft(2, '0');
      final day = currentDate.day.toString().padLeft(2, '0');
      final time = "${currentDate.hour}${currentDate.minute}${currentDate.second}";
      final timestamp = "$year$month${day}_$time";
      final filePath = "$selectedDirectory/layer_base_$timestamp.png";
      final file = File(filePath);
      final Uint8List imageBytes = await editorKey.currentState!.captureEditorImage();
      await file.writeAsBytes(imageBytes);
      saveImageToHive(imageBytes, imageBytes, imageIndex.value, AppStrings.export);
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
}
