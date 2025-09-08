import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/imageEditor/components/all_sticker.dart';
import 'package:layerbase/imageEditor/image_editor_view_model.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:pro_image_editor/core/enums/editor_mode.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';
import 'package:pro_image_editor/shared/services/import_export/enums/export_import_enum.dart';
import 'package:pro_image_editor/shared/services/import_export/import_state_history.dart';
import 'package:pro_image_editor/shared/services/import_export/models/export_state_history_configs.dart';
import 'package:pro_image_editor/shared/services/import_export/models/import_state_history_configs.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_strings.dart';

class ImageEditor extends StatelessWidget {
  final ImageEditorViewModel controller;

  const ImageEditor({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkJungleGreen,
      body: Container(
        margin: EdgeInsets.only(right: spacerSize10),
        padding: EdgeInsets.symmetric(horizontal: spacerSize10, vertical: spacerSize10),
        decoration: BoxDecoration(
          color: AppColors.chineseBlack,
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(spacerSize8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(spacerSize8),
          child: ProImageEditor.memory(
            controller.imageFile.value ?? Uint8List(0),
            key: controller.editorKey,
            configs: ProImageEditorConfigs(
              emojiEditor: EmojiEditorConfigs(
                checkPlatformCompatibility: true,
                enablePreloadWebFont: false,
              ),
              textEditor: TextEditorConfigs(widgets: TextEditorWidgets()),

              i18n: I18n(
                done: AppStrings.save,
                undo: AppStrings.undo,
                redo: AppStrings.redo,
                doneLoadingMsg: AppStrings.savingPleaseWait,
                importStateHistoryMsg: AppStrings.loadingPleaseWait,
                various: I18nVarious(loadingDialogMsg: AppStrings.loading),
              ),
              heroTag: 'hero-tag',
              theme: ThemeData(
                cardColor: AppColors.gunMetal,
                useMaterial3: true,
                canvasColor: AppColors.gunMetal,
              ),
              helperLines: helperLineConfigs(),
              progressIndicatorConfigs: progressIndicatorConfigs(),
              designMode: ImageEditorDesignMode.material,
              mainEditor: mainEditorConfigs(),
              imageGeneration: imageGenerationConfigs(),
              paintEditor: paintEditorConfigs(),
              tuneEditor: TuneEditorConfigs(enabled: true, showLayers: true),
              layerInteraction: layerInteractionConfigs(),
              stateHistory: stateHistoryConfigs(),
              cropRotateEditor: cropRotateEditorConfigs(),
              stickerEditor: stickerEditorConfigs(),
            ),
            callbacks: ProImageEditorCallbacks(
              onCloseEditor: (EditorMode mode) async {
                Get.back();
              },
              emojiEditorCallbacks: EmojiEditorCallbacks(),
              onImageEditingComplete: (Uint8List bytes) async {},
              filterEditorCallbacks: FilterEditorCallbacks(
                onFilterChanged: (value) {
                  final Map<String, dynamic> jsonData = jsonDecode(controller.layerData.value);
                  controller.applyFiltersToReferences(jsonData, value.filters);
                },
              ),
              onCompleteWithParameters: (parameters) async {
                final export = await controller.editorKey.currentState?.exportStateHistory(
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
                controller.saveImageToHive(
                  parameters.image,
                  controller.imageFile.value!,
                  controller.imageIndex.value,
                  layerJson,
                );
                return Future.value();
              },
              mainEditorCallbacks: MainEditorCallbacks(
                onAddLayer: (layer) {
                  controller.activeLayersList!.add(layer);
                  controller.selectedItems.value = List<bool>.from(controller.selectedItems)
                    ..add(true);
                  controller.activeLayersList!.refresh();
                },
                onRemoveLayer: (layer) {
                  controller.activeLayersList!.remove(layer);
                  controller.activeLayersList!.refresh();
                  controller.editorKey.currentState!.setState(() {});
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  HelperLineConfigs helperLineConfigs() {
    return HelperLineConfigs(
      showLayerAlignLine: true,
      style: HelperLineStyle(horizontalColor: Colors.red),
      showHorizontalLine: true,
      showRotateLine: true,
      showVerticalLine: true,
    );
  }

  ProgressIndicatorConfigs progressIndicatorConfigs() {
    return ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(circularProgressIndicator: CircularProgressIndicator()),
    );
  }

  MainEditorConfigs mainEditorConfigs() {
    return MainEditorConfigs(
      enableDoubleTapZoom: true,
      canZoomWhenLayerSelected: true,
      enableZoom: true,
      enableCloseButton: false,
      enableEscapeButton: false,
      style: MainEditorStyle(
        background: AppColors.darkGunMetal,
        bottomBarBackground: AppColors.darkGunMetal,
        appBarBackground: AppColors.darkGunMetal,
      ),
      widgets: MainEditorWidgets(
        closeWarningDialog: (editor) async {
          final result = await showBaseDialog(
            context: Get.context!,
            title: "${AppStrings.closeImageEditor}?",
            subtitle:
                "${AppStrings.areYouSureWantTo}\t${AppStrings.closeImageEditor}${AppStrings.yourChangeWillNotBeSaved}",
            onYes: () {
              Get.back();
              Get.back(result: true);
            },
            onNo: () {
              Get.back(result: false);
            },
          );
          return result ?? false;
        },
      ),

      icons: MainEditorIcons(doneIcon: Icons.check_outlined),
    );
  }

  ImageGenerationConfigs imageGenerationConfigs() {
    return ImageGenerationConfigs(
      cropToDrawingBounds: false,
      maxOutputSize: Size.infinite,
      enableUseOriginalBytes: false,
      processorConfigs: ProcessorConfigs(processorMode: ProcessorMode.maximum),
      allowEmptyEditingCompletion: true,
      enableBackgroundGeneration: false,
      cropToImageBounds: true,
      enableIsolateGeneration: false,
      singleFrame: false,
      outputFormat: OutputFormat.tiff,
    );
  }

  PaintEditorConfigs paintEditorConfigs() {
    return PaintEditorConfigs(
      showLayers: true,
      enabled: true,
      enableModeArrow: true,
      enableDoubleTapZoom: true,
      showToggleFillButton: true,
      isInitiallyFilled: true,
      enableEdit: true,
      enableModeCircle: true,
      enableZoom: true,
      enableModeBlur: true,
      enableShareZoomMatrix: true,
      showOpacityAdjustmentButton: true,
      showLineWidthAdjustmentButton: true,
      enableModePolygon: true,
    );
  }

  LayerInteractionConfigs layerInteractionConfigs() {
    return LayerInteractionConfigs(
      selectable: LayerInteractionSelectable.auto,
      keepSelectionOnInteraction: true,
      initialSelected: true,
      enableLayerDragSelection: true,
    );
  }

  StateHistoryConfigs stateHistoryConfigs() {
    return StateHistoryConfigs(
      stateHistoryLimit: 50,
      initStateHistory: controller.layerData.value.isNotEmpty
          ? ImportStateHistory.fromJson(
              controller.layerData.value,
              configs: ImportEditorConfigs(
                enableInitialEmptyState: true,
                recalculateSizeAndPosition: true,
                mergeMode: ImportEditorMergeMode.merge,
              ),
            )
          : null,
    );
  }

  CropRotateEditorConfigs cropRotateEditorConfigs() {
    return CropRotateEditorConfigs(
      enabled: true,
      showLayers: true,
      enableTransformLayers: true,
      enableProvideImageInfos: true,
      desktopCornerDragArea: spacerSize20,
    );
  }

  StickerEditorConfigs stickerEditorConfigs() {
    return StickerEditorConfigs(
      enabled: true,
      style: StickerEditorStyle(
        bottomSheetBackgroundColor: AppColors.chineseBlack,
        showDragHandle: false,
      ),
      builder: (context, addSticker) {
        return AllSticker(controller: controller);
      },
    );
  }
}
