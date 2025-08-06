import 'dart:convert';
import 'package:layerbase/components/bottom_navigation_sheet.dart';
import 'package:layerbase/imageEditor/image_editor_view_model.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'dart:convert';
import 'package:layerbase/components/bottom_navigation_sheet.dart';
import 'package:layerbase/imageEditor/image_editor_view_model.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageEditorScreen extends GetWidget<ImageEditorViewModel> {
  const ImageEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dynamic imageData;

    Uint8List? imageFile;
    int? imageIndex;
    imageData = Get.arguments[AppKeys.imageData];
    imageFile = imageData[AppKeys.image];
    controller.layerData.value = imageData[AppKeys.layerJson] ?? "";
    imageIndex = Get.arguments[AppKeys.imageIndex];

    return Obx(
      () => Stack(
        alignment: Alignment.centerRight,
        children: [
          ProImageEditor.memory(
            imageFile!,
            key: controller.editorKey,
            configs: ProImageEditorConfigs(
              emojiEditor: EmojiEditorConfigs(
                checkPlatformCompatibility: true,
                enablePreloadWebFont: false,
              ),
              textEditor: TextEditorConfigs(widgets: TextEditorWidgets()),
              i18n: I18n(done: 'Save', undo: 'Undo', redo: 'Redo'),
              heroTag: 'hero-tag',
              theme: ThemeData(
                cardColor: AppColors.gunMetal,
                useMaterial3: true,
                canvasColor: AppColors.gunMetal,
              ),
              helperLines: HelperLineConfigs(
                showLayerAlignLine: true,
                style: HelperLineStyle(),
                showHorizontalLine: true,
                showRotateLine: true,
                showVerticalLine: true,
              ),
              progressIndicatorConfigs: ProgressIndicatorConfigs(
                widgets: ProgressIndicatorWidgets(
                  circularProgressIndicator: CircularProgressIndicator(),
                ),
              ),
              designMode: ImageEditorDesignMode.material,
              mainEditor: MainEditorConfigs(
                enableDoubleTapZoom: true,
                style: MainEditorStyle(
                  background: AppColors.darkGunMetal,
                  bottomBarBackground: AppColors.gunMetal,
                  appBarBackground: AppColors.gunMetal,
                ),
                canZoomWhenLayerSelected: true,
                enableZoom: true,
                enableCloseButton: true,
                icons: MainEditorIcons(
                  doneIcon: Icons.save,
                  applyChanges: Icons.check,
                ),
              ),
              imageGeneration: ImageGenerationConfigs(
                cropToDrawingBounds: false,
                maxOutputSize: Size.infinite,
                enableUseOriginalBytes: false,
                processorConfigs: ProcessorConfigs(
                  processorMode: ProcessorMode.auto,
                ),
                allowEmptyEditingCompletion: true,
                enableBackgroundGeneration: false,
                cropToImageBounds: true,
                enableIsolateGeneration: false,
                singleFrame: false,
                outputFormat: OutputFormat.tiff,
              ),
              paintEditor: PaintEditorConfigs(
                showLayers: true,
                enabled: true,
                enableModeArrow: true,
                enableDoubleTapZoom: true,
                enableFreeStyleHighPerformanceMoving: true,
                enableFreeStyleHighPerformanceHero: true,
                showToggleFillButton: true,
                isInitiallyFilled: true,
                enableEdit: true,
                enableModeCircle: true,
                enableZoom: true,
                enableModeBlur: true,
                enableShareZoomMatrix: true,
                showOpacityAdjustmentButton: true,
                showLineWidthAdjustmentButton: true,
                enableModePolygon: false,
                enableFreeStyleHighPerformanceScaling: true,
              ),

              tuneEditor: TuneEditorConfigs(enabled: true, showLayers: true),
              layerInteraction: LayerInteractionConfigs(
                selectable: LayerInteractionSelectable.auto,
                keepSelectionOnInteraction: true,
                initialSelected: true,
              ),
              stateHistory: StateHistoryConfigs(
                stateHistoryLimit: 1000,
                initStateHistory: controller.layerData.value.isNotEmpty
                    ? ImportStateHistory.fromJson(
                        controller.layerData.value,
                        configs: ImportEditorConfigs(
                          enableInitialEmptyState: true,
                        ),
                      )
                    : null,
              ),
              cropRotateEditor: CropRotateEditorConfigs(
                enabled: true,
                showLayers: true,
                enableTransformLayers: true,
                enableProvideImageInfos: true,
                desktopCornerDragArea: spacerSize20,
              ),
            ),
            callbacks: ProImageEditorCallbacks(
              onCloseEditor: (EditorMode editor) {
                Get.back();
              },
              onImageEditingStarted: () {},
              emojiEditorCallbacks: EmojiEditorCallbacks(
                onAfterViewInit: () {},
                onInit: () {},
              ),
              onImageEditingComplete: (Uint8List bytes) async {},
              filterEditorCallbacks: FilterEditorCallbacks(
                onFilterChanged: (value) {
                  print(controller.layerData.value);
                  final Map<String, dynamic> jsonData = jsonDecode(
                    controller.layerData.value,
                  );
                  controller.applyFiltersToReferences(jsonData, value.filters);
                  // final jsonString = jsonEncode(yourModifiedLayerMap);

                  // final stateHistory = ImportStateHistory.fromJson(jsonDecode(jsonString));

                  //  layerData= jsonEncode(jsonData['references']);

                  print(jsonData);
                  print(jsonData['references']);
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
                controller.saveImageToHive(
                  parameters.image,
                  imageFile!,
                  imageIndex,
                  layerJson,
                );
                return Future.value(true);
              },
              mainEditorCallbacks: MainEditorCallbacks(),
            ),
          ),
          Positioned(
            bottom: spacerSize10,
            left: spacerSize0,
            child: BottomNavigationSheet(),
          ),
          Positioned(
            top: kToolbarHeight + spacerSize10,
            right: spacerSize20,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.brightCyan,
              child: IconButton(
                onPressed: () {},
                icon: Image.asset(AppAssets.aiIcon),
              ), // Example AI icon
            ),
          ),
        ],
      ),
    );
  }
}
