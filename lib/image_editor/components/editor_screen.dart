import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/base/widgets/base_shader_mask.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_strings.dart';
import '../image_editor_view_model.dart';
import 'all_sticker.dart';

class ImageEditor extends StatelessWidget {
  final ImageEditorViewModel controller;

  const ImageEditor({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Container(
        margin: EdgeInsets.only(right: spacerSize10),
        padding: EdgeInsets.symmetric(horizontal: spacerSize10, vertical: spacerSize10),
        decoration: baseBoxDecoration(
          color: AppColors.lightGrey,
          radius: spacerSize8,
          borderColor: AppColors.lightGrey,
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
              dialogConfigs: DialogConfigs(
                style: DialogStyle(
                  loadingDialog: LoadingDialogStyle(textColor: AppColors.chineseBlack),
                ),
              ),
              tuneEditor: TuneEditorConfigs(
                icons: TuneEditorIcons(backButton: Icons.arrow_back_outlined),
                enabled: true,
                showLayers: true,
                style: TuneEditorStyle(
                  background: AppColors.lightGrey,
                  appBarBackground: AppColors.lightGrey,
                  bottomBarBackground: AppColors.lightGrey,
                ),
              ),
              layerInteraction: layerInteractionConfigs(),
              stateHistory: stateHistoryConfigs(),
              cropRotateEditor: cropRotateEditorConfigs(),
              stickerEditor: stickerEditorConfigs(),
              filterEditor: FilterEditorConfigs(
                icons: FilterEditorIcons(backButton: Icons.arrow_back_outlined),
                enabled: true,
                showLayers: true,
                style: FilterEditorStyle(
                  background: AppColors.lightGrey,
                  appBarBackground: AppColors.lightGrey,
                ),
              ),
              blurEditor: BlurEditorConfigs(
                icons: BlurEditorIcons(backButton: Icons.arrow_back_outlined),
                enabled: true,
                showLayers: true,
                style: BlurEditorStyle(
                  background: AppColors.lightGrey,
                  appBarBackgroundColor: AppColors.lightGrey,
                ),
              ),
            ),
            callbacks: ProImageEditorCallbacks(
              onCloseEditor: (EditorMode mode) async {
                Get.back();
              },
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
                controller.exportJsonMap = await export?.toMap();
                final layerJson = jsonEncode(controller.exportJsonMap);
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
                  controller.editorKey.currentState!.activeLayers.remove(layer);
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
        background: AppColors.lightGrey,
        bottomBarBackground: AppColors.lightGrey,
        appBarBackground: AppColors.lightGrey,
      ),
      widgets: MainEditorWidgets(
        closeWarningDialog: (editor) async {
          final result = await showBaseDialog(
            context: Get.context!,
            title: AppStrings.closeImageEditor,
            subtitle: AppStrings.closeImageEditorDesc,
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
      icons: PaintEditorIcons(backButton: Icons.arrow_back_outlined),
      style: PaintEditorStyle(
        background: AppColors.lightGrey,
        appBarBackground: AppColors.lightGrey,
      ),
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
      icons: CropRotateEditorIcons(backButton: Icons.arrow_back_outlined),
      style: CropRotateEditorStyle(
        background: AppColors.lightGrey,
        appBarBackground: AppColors.lightGrey,
        bottomBarBackground: AppColors.lightGrey,
        bottomBarColor: AppColors.lightGrey,
      ),
    );
  }

  StickerEditorConfigs stickerEditorConfigs() {
    return StickerEditorConfigs(
      enabled: true,
      style: StickerEditorStyle(
        bottomSheetBackgroundColor: AppColors.darkGunMetal,
        showDragHandle: false,
      ),
      builder: (context, addSticker) {
        return AllSticker(controller: controller);
      },
    );
  }
}
