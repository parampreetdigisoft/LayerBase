import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:layerbase/imageEditor/components/layer_history_layout.dart';
import 'package:layerbase/imageEditor/image_editor_view_model.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

import '../utils/base/widgets/base_text.dart';
import '../utils/routes.dart';

class ImageEditorScreen extends GetWidget<ImageEditorViewModel> {
  const ImageEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkJungleGreen,
      appBar: appBarWidget(context),
      body: Row(
        children: [
          SizedBox(width: spacerSize10),

          /// All layer
          Expanded(child: LayerHistoryLayout(controller: controller)),
          SizedBox(width: spacerSize10),

          /// image Editor
          editorWidget(),
        ],
      ),
    );
  }

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkJungleGreen,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: 0,
      title: Image.asset(AppAssets.appLogo, height: spacerSize25),
      actions: [
        IconButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(right: spacerSize5, left: 0),
            minimumSize: Size(0, 0),
          ),
          tooltip: controller.userDisplayName.isEmpty
              ? AppStrings.login
              : AppStrings.logout,
          onPressed: () {
            if (controller.userDisplayName.isEmpty) {
              Navigator.pushNamed(context, Routes.logIn);
            } else {
              controller.logoutDialog();
            }
          },

          icon: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                controller.userDisplayName.isEmpty
                    ? Icons.person
                    : Icons.logout,
                size: spacerSize15,
                color: AppColors.antiqueWhite,
              ),
              BaseText(
                text: controller.userDisplayName.isEmpty
                    ? AppStrings.login
                    : AppStrings.logout,
                textColor: AppColors.antiqueWhite,
                fontWeight: FontWeight.w500,
                fontSize: fontSize14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget editorWidget() {
    return Expanded(
      flex: 7,
      child: Container(
        margin: EdgeInsets.only(right: spacerSize10),
        padding: EdgeInsets.symmetric(
          horizontal: spacerSize10,
          vertical: spacerSize10,
        ),
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
              dialogConfigs: DialogConfigs(
                style: DialogStyle(
                  loadingDialog: LoadingDialogStyle(
                    textColor: AppColors.chineseBlack,
                  ),
                ),
              ),
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
              emojiEditorCallbacks: EmojiEditorCallbacks(
                onAfterViewInit: () {
                  debugPrint("on onAfterViewInit");
                },
                onInit: () {
                  debugPrint("on init");
                },
              ),
              onImageEditingComplete: (Uint8List bytes) async {},
              filterEditorCallbacks: FilterEditorCallbacks(
                onFilterChanged: (value) {
                  final Map<String, dynamic> jsonData = jsonDecode(
                    controller.layerData.value,
                  );
                  controller.applyFiltersToReferences(jsonData, value.filters);
                },
                onUpdateUI: () {
                  debugPrint("onUpdateUI:::::::");
                },
                onFilterFactorChangeEnd: (c) {
                  debugPrint("onFilterFactorChangeEnd:::::::");
                },
                onFilterFactorChange: (v) {
                  debugPrint("onFilterFactorChange:::::::");
                },
                onAfterViewInit: () {
                  debugPrint("onAfterViewInit:::::::");
                },
                onInit: () {
                  debugPrint("onInit:::::::");
                },
                onCloseEditor: () {
                  debugPrint("onCloseEditor:::::::");
                },
                onDone: () {
                  debugPrint("onDone:::::::");
                },
              ),
              onCompleteWithParameters: (parameters) async {
                final export = await controller.editorKey.currentState
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
                debugPrint("save:::::save");
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
                  controller.activeLayersList!.insert(0, layer);
                  controller.selectedItems.insert(0, true);
                  debugPrint("Layer:::::${layer.toMap()}");
                  //controller.activeLayersList!.add(layer);
                //  controller.selectedItems.value = List<bool>.from(controller.selectedItems,)..add(true);
                },
                onRemoveLayer: (layer) {
                  debugPrint("layer is remove:::::");
                  controller.activeLayersList!.remove(layer);
                  controller.activeLayersList!.refresh();
                  controller.editorKey.currentState!.setState(() {});
                },
                onUndo: () {
                  debugPrint("layer undo:::::");
                },
                onRedo: () {
                  debugPrint("layer redo:::::");
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
      style: HelperLineStyle(),
      showHorizontalLine: true,
      showRotateLine: true,
      showVerticalLine: true,
    );
  }

  ProgressIndicatorConfigs progressIndicatorConfigs() {
    return ProgressIndicatorConfigs(
      widgets: ProgressIndicatorWidgets(
        circularProgressIndicator: CircularProgressIndicator(),
      ),
    );
  }

  MainEditorConfigs mainEditorConfigs() {
    return MainEditorConfigs(
      enableDoubleTapZoom: true,
      canZoomWhenLayerSelected: true,
      enableZoom: true,
      enableCloseButton: false,

      style: MainEditorStyle(
        background: AppColors.darkGunMetal,
        bottomBarBackground: AppColors.darkGunMetal,
        appBarBackground: AppColors.darkGunMetal,
      ),

      icons: MainEditorIcons(
        doneIcon: Icons.check_outlined,
        applyChanges: Icons.check,
      ),
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
    );
  }

  StateHistoryConfigs stateHistoryConfigs() {
    return StateHistoryConfigs(
      stateHistoryLimit: 1000,
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
        bottomSheetBackgroundColor: AppColors.darkGunMetal,
        showDragHandle: false,
      ),
      builder: (context, addSticker) {
        return GridView.builder(
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
        );
      },
    );
  }
}
