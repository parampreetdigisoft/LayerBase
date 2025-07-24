import 'package:Layerbase/components/bottom_navigation_sheet.dart';
import 'package:Layerbase/utils/constants/app_assets.dart';
import 'package:Layerbase/utils/constants/app_color.dart';
import 'package:Layerbase/utils/constants/app_constants.dart';
import 'package:Layerbase/utils/constants/app_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class ImageEditorScreen extends StatelessWidget {
  const ImageEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Uint8List? imageFile;
    int? imageIndex;
    imageFile = Get.arguments['image'];
    imageIndex = Get.arguments['image_index'];

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        ProImageEditor.memory(
          imageFile!,
          configs: ProImageEditorConfigs(
            emojiEditor: EmojiEditorConfigs(
              checkPlatformCompatibility: true,
              enablePreloadWebFont: true,
            ),
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
              widgets: MainEditorWidgets(),
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
              selectable: LayerInteractionSelectable.enabled,
              keepSelectionOnInteraction: true,
              initialSelected: true,
            ),
            stateHistory: StateHistoryConfigs(stateHistoryLimit: 1000),
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
            emojiEditorCallbacks: EmojiEditorCallbacks(
              onAfterViewInit: () {},
              onInit: () {},
            ),
            onImageEditingComplete: (Uint8List bytes) async {},
            onCompleteWithParameters: (parameters) {
              saveImageToHive(imageFile!, imageIndex);
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
            onPressed: () {},backgroundColor: AppColors.brightCyan,
            child: IconButton(
              onPressed: () {},
              icon: Image.asset(AppAssets.aiIcon),
            ), // Example AI icon
          ),
        ),
      ],
    );
  }

  Future<void> saveImageToHive(Uint8List imageBytes, int? imageIndex) async {
    final box = Hive.box<Uint8List>(AppKeys.imageBox);
    if (imageIndex != null) {
      await box.putAt(imageIndex, imageBytes);
    } else {
      await box.add(imageBytes);
    }
  }
}
