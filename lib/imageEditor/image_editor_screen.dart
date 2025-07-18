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

    return ProImageEditor.memory(
      imageFile!,
      configs: ProImageEditorConfigs(
        emojiEditor: EmojiEditorConfigs(checkPlatformCompatibility: true),i18n:   I18n(
        done: 'Save Changes',
        undo: 'Undo',
        redo: 'Redo',
      ),
        heroTag: 'hero-tag',
        theme: ThemeData.dark(useMaterial3: true),
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
          canZoomWhenLayerSelected: true,
          enableZoom: true,
          enableCloseButton: true,
          icons: MainEditorIcons(
            doneIcon: Icons.save,
            applyChanges: Icons.check,
          ),

        ),
        imageGeneration: ImageGenerationConfigs(
          cropToDrawingBounds: true,
          maxOutputSize: Size.infinite,
          enableUseOriginalBytes: false,
          processorConfigs: ProcessorConfigs(processorMode: ProcessorMode.auto),
          allowEmptyEditingCompletion: true,
          enableBackgroundGeneration: true,
          cropToImageBounds: true,
          enableIsolateGeneration: true,
          singleFrame: false,
          outputFormat: OutputFormat.png,
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
        onImageEditingStarted: () {},
        emojiEditorCallbacks: EmojiEditorCallbacks(
          onAfterViewInit: () {},
          onInit: () {},
        ),
        onImageEditingComplete: (Uint8List bytes) async {},
        onCompleteWithParameters: (parameters) {
          saveImageToHive(parameters.image, imageIndex);
          return Future.value(true);
        },
        mainEditorCallbacks: MainEditorCallbacks(onUpdateLayer: (layer) {}),
      ),
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
