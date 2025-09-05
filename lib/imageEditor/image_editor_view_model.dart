import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../utils/base/dialogs/base_dialog.dart';
import '../utils/constants/app_keys.dart';
import '../utils/constants/app_strings.dart';
import '../utils/routes.dart';
import '../utils/shared_prefs_service.dart';

class ImageEditorViewModel extends GetxController {
  Box<dynamic>? hiveBox;
  RxList<dynamic>? activeLayersList = <dynamic>[].obs;
  final editorKey = GlobalKey<ProImageEditorState>();
  final Map<int, Layer> removedLayers = {};
  late SharedPrefsService sharedPrefsService;
  List<String> galleryImageList = [];

  String userDisplayName = "";
  var layerData = "".obs,
      stickersList = <String>[].obs,
      imageData = Rx<dynamic>(null),
      imageIndex = Rx<int?>(null),
      imageFile = Rx<Uint8List?>(null),
      selectedItems = <bool>[].obs,
      isLoading = true.obs;

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

  Future<void> saveImageToHive(
    Uint8List thumbNailBytes,
    Uint8List imageBytes,
    int? imageIndex,
    dynamic layerJson,
  ) async {
    try {
      final box = Hive.box<dynamic>(AppKeys.imageLayerBox);
      if (imageIndex != null && imageIndex >= 0 && imageIndex < box.length) {
        if (removedLayers.isNotEmpty) {
          removedLayers.forEach((index, layer) {
            if (index >= 0 && index <= editorKey.currentState!.stateHistory.last.layers.length) {
              editorKey.currentState!.stateHistory.last.layers.insert(index, layer);
            }
            // editorKey.currentState!.stateHistory.last.layers.insert(index,layer);
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
        debugPrint("Updated item at index::::: $imageIndex");
      } else {
        await box.add({
          AppKeys.imageThumbnail: thumbNailBytes,
          AppKeys.image: imageBytes,
          AppKeys.layerJson: layerJson,
        });
        debugPrint("Added new item::: ${activeLayersList!.length}");
      }
    } catch (e, stack) {
      debugPrint("saveImageToHive crashed::::: $e");
      debugPrint("stack:::: $stack");
      if (e.toString().contains("Unexpected error")) {
        debugPrint("Hive box corrupted. Resetting::::::");
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
        debugPrint("Recovered::::: Box reset and data saved");
      }
      debugPrint("Stack trace:\n$stack");
    } finally {
      AppToast.show(
        title: AppStrings.savedSuccessfully,
        "${AppStrings.image}\t${AppStrings.savedSuccessfully}",
        backgroundColor: Colors.green,
      );
    }
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

  Future<void> restoreLayer(int index) async {
    var layers = editorKey.currentState!.stateHistory.last.layers;
    if (index < 0) return;
    if (index >= selectedItems.length) return;
    selectedItems[index] = !selectedItems[index];
    bool isChecked = selectedItems[index];
    //Hide the layer
    if (!isChecked) {
      if (index < layers.length) {
        removedLayers[index] = layers[index];
        layers.removeAt(index);
      }
    } else {
      if (removedLayers.containsKey(index)) {
        Layer toRestore = removedLayers[index]!;
        bool alreadyPresent = layers.any((l) => l.id == toRestore.id);
        if (!alreadyPresent) {
          int insertIndex = index.clamp(0, layers.length);
          layers.insert(insertIndex, toRestore);
        }
        removedLayers.remove(index);
      }
    }
    activeLayersList?.refresh();
    //editorKey.currentState!.addHistory(layers:List<Layer>.from(editorKey.currentState!.stateHistory.last.layers));
    editorKey.currentState!.setState(() {});
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

  void updateDragLayer(int newIndex, int oldIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex < 0 ||
        oldIndex >= activeLayersList!.length ||
        newIndex < 0 ||
        newIndex >= activeLayersList!.length) {
      return;
    }
    final movedLayer = activeLayersList!.removeAt(oldIndex);
    activeLayersList!.insert(newIndex, movedLayer);
    if (editorKey.currentState != null &&
        editorKey.currentState!.activeLayers.isNotEmpty &&
        editorKey.currentState!.activeLayers.length == activeLayersList!.length) {
      final movedCanvasLayer = editorKey.currentState!.activeLayers.removeAt(oldIndex);
      editorKey.currentState!.activeLayers.insert(newIndex, movedCanvasLayer);
      //editorKey.currentState!.stateHistory.last.layers.insert(newIndex, movedCanvasLayer);
      editorKey.currentState!.setState(() {});
      activeLayersList?.refresh();
    }
  }

  logoutDialog() {
    return showCommonDialog(
      context: Get.context!,
      title: AppStrings.logout,
      subtitle: "${AppStrings.areYouSureWantTo}\t${AppStrings.logout}?",
      onYes: () {
        sharedPrefsService.clear();
        Navigator.pushNamedAndRemoveUntil(Get.context!, Routes.logIn, (route) => false);
      },
      onNo: () {
        Get.back();
      },
    );
  }
}
