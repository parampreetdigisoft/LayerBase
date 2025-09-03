import 'dart:convert';

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

  void initializeLayer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (editorKey.currentState != null &&
          editorKey.currentState!.stateHistory.isNotEmpty) {
        activeLayersList!.assignAll(
          editorKey.currentState!.stateHistory.last.layers,
        );
        activeLayersList!.refresh();
      } else {
        activeLayersList!.value = [];
      }
      debugPrint(
        "after activeLayersList length::: ${activeLayersList!.length}",
      );
      initSelection();
    });
  }

  void initHiveData() {
    debugPrint("active layer List:::::${activeLayersList!.length}");
    if (Get.arguments[AppKeys.imageIndex] != null) {
      hiveBox = Hive.box<dynamic>(AppKeys.imageLayerBox);
      imageIndex.value = Get.arguments[AppKeys.imageIndex];
      var data = hiveBox!.getAt(Get.arguments[AppKeys.imageIndex]);
      final img = data[AppKeys.image];
      if (img is Uint8List) {
        imageFile.value = img;
      }
      layerData.value = data[AppKeys.layerJson] ?? "";
      debugPrint("active layer `11111111`:::::${layerData.value.length}");
    } else {
      hiveBox = Hive.box<dynamic>(AppKeys.imageLayerBox);
      debugPrint("inside else::::");
      imageData.value = Get.arguments[AppKeys.imageData];
      imageFile.value = imageData.value[AppKeys.image];
      imageIndex.value = Get.arguments[AppKeys.imageIndex];
    }
  }

  void initSelection() {
    debugPrint('value of layerList :${activeLayersList!.length}');
    selectedItems.value = List.filled(
      activeLayersList!.length,
      true,
      growable: true,
    );
    isLoading.value = false;
  }


  void deleteLayer(int index){
    if (index >= 0 && index < activeLayersList!.length) {
      activeLayersList!.removeAt(index);
    }
    if (index >= 0 && index <editorKey.currentState!.activeLayers.length) {
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
              editorKey.currentState!.stateHistory.last.layers.insert(index,layer);
            }
           // editorKey.currentState!.stateHistory.last.layers.insert(index,layer);
          });
        }
        final export = await editorKey.currentState
            ?.exportStateHistory(
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

    /* await box.putAt(imageIndex, {
          AppKeys.image: imageBytes,
          AppKeys.layerJson: layerJson,
          AppKeys.imageThumbnail: thumbNailBytes,
        });*/
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
      if (e.toString().contains("Unexpected EOF")) {
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
        debugPrint("Recovered: Box reset and data saved");
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

  void applyFiltersToReferences(
    Map<String, dynamic> data,
    List<List<double>> filters,
  ) {
    final references = data[AppKeys.references] as Map<String, dynamic>;
    int index = 0;
    for (final entry in references.entries) {
      if (index >= filters.length) break;
      final ref = entry.value as Map<String, dynamic>;
      ref['f'] = filters[index];
      index++;
    }
  }

  void onImageEditingFinished({
    CompleteParameters? parameters,
    Uint8List? imageFile,
    int? imageIndex,
  }) async {
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
    saveImageToHive(parameters!.image, imageFile!, imageIndex, layerJson);
    return Future.value();
  }

  Future<void> restoreLayer(int index) async {
    debugPrint("index:::::: $index");
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
        debugPrint("Removed layer at index:::$index");
      }
    } else {
      //Visible the layer
      if (removedLayers.containsKey(index)) {
        Layer toRestore = removedLayers[index]!;
        bool alreadyPresent = layers.any((l) => l.id == toRestore.id);
        if (!alreadyPresent) {
          int insertIndex = index.clamp(0, layers.length);
          layers.insert(insertIndex, toRestore);
          debugPrint("Restored layer at index:::$insertIndex");
          debugPrint("save:::::save");
          debugPrint("removeList:::$removedLayers");
        }
        removedLayers.remove(index);
      }
    }
    activeLayersList?.refresh();
    //editorKey.currentState!.addHistory(layers:List<Layer>.from(editorKey.currentState!.stateHistory.last.layers));
    editorKey.currentState!.setState(() {});
    debugPrint(
      "layers length::::${removedLayers.length},"
      "selectedItems length::::${selectedItems.length},"
      "activeLayersList length::::${activeLayersList!.length}",
    );
  }

  Future<void> restoreLayer1(int index) async {
    debugPrint("index:::::: $index");
    var layers = editorKey.currentState!.stateHistory.last.layers;

    /*
    if (index < 0) return;
    if (index >= selectedItems.length) return;
*/

    selectedItems[index] = !selectedItems[index];
    bool isChecked = selectedItems[index];

    debugPrint("Layer at index $index visibility = $isChecked");

    final box = await Hive.openBox<dynamic>(
      AppKeys.imageLayerBox,
      compactionStrategy: (entries, deletedEntries) => false,
    );

    if (index < box.length) {
      final existing = box.getAt(index);
      await box.putAt(index, {...existing, "isVisible": isChecked});
    }
    for (int i = 0; i < box.length; i++) {
      final data = box.getAt(i);
      bool isVisible = data["isVisible"] ?? true;
      selectedItems.add(isVisible);

      // activeLayersList?.add(layers);
    }
    activeLayersList?.refresh();
    editorKey.currentState!.setState(() {});

    debugPrint(
      "layers length::::${layers.length}, "
      "selectedItems length::::${selectedItems.length}, "
      "activeLayersList length::::${activeLayersList!.length}",
    );
  }

  Future<void> loadStickers() async {
    final String response = await rootBundle.loadString(AppAssets.stickersJson);
    final List<dynamic> data = json.decode(response);
    stickersList.value = List<String>.from(data);
    if (editorKey.currentState != null &&
        editorKey.currentState!.stateHistory.isNotEmpty) {
      List<Layer> newLayers = [];
      for (Layer originalLayer
          in editorKey.currentState!.stateHistory.last.layers) {
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
        editorKey.currentState!.activeLayers.length ==
            activeLayersList!.length) {
      final movedCanvasLayer = editorKey.currentState!.activeLayers.removeAt(
        oldIndex,
      );
      editorKey.currentState!.activeLayers.insert(newIndex, movedCanvasLayer);
    }
    activeLayersList?.refresh();
    editorKey.currentState!.setState(() {});
  }

  logoutDialog() {
    return showCommonDialog(
      context: Get.context!,
      title: AppStrings.logout,
      subtitle: "${AppStrings.areYouSureWantTo}\t${AppStrings.logout}?",
      onYes: () {
        sharedPrefsService.clear();
        Navigator.pushNamedAndRemoveUntil(
          Get.context!,
          Routes.logIn,
          (route) => false,
        );
      },
      onNo: () {
        Get.back();
      },
    );
  }
}
