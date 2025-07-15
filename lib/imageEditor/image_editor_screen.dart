import 'package:layerbase/utils/constants/app_keys.dart';
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
        emojiEditor: EmojiEditorConfigs(
          enablePreloadWebFont: true,
          checkPlatformCompatibility: true,
          enabled: true,
        ),
        designMode: ImageEditorDesignMode.material,
        mainEditor: MainEditorConfigs(
          enableDoubleTapZoom: true,
          style: MainEditorStyle(uiOverlayStyle: SystemUiOverlayStyle.dark),
          canZoomWhenLayerSelected: true,
          enableZoom: true,
        ),
        imageGeneration: ImageGenerationConfigs(
          cropToDrawingBounds: true,
          enableUseOriginalBytes: true,
          processorConfigs: ProcessorConfigs(processorMode: ProcessorMode.auto),
          allowEmptyEditingCompletion: true,
          enableBackgroundGeneration: true,
          cropToImageBounds: true,
          enableIsolateGeneration: true,
          singleFrame: true,
          outputFormat: OutputFormat.png,
        ),
        paintEditor: PaintEditorConfigs(
          showLayers: true,
          enabled: true,
          enableDoubleTapZoom: true,
          enableFreeStyleHighPerformanceMoving: true,
          enableFreeStyleHighPerformanceHero: true,
          showToggleFillButton: true,
          isInitiallyFilled: true,
          enableFreeStyleHighPerformanceScaling: true,
        ),
        tuneEditor: TuneEditorConfigs(enabled: true, showLayers: true),
        layerInteraction: LayerInteractionConfigs(
          selectable: LayerInteractionSelectable.auto,
          keepSelectionOnInteraction: true,
          hideVideoControlsOnInteraction: false,
          hideToolbarOnInteraction: false,
          initialSelected: true,
        ),
        stateHistory: StateHistoryConfigs(stateHistoryLimit: 1000),
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

        onImageEditingComplete: (Uint8List bytes) async {
          print('saving image');
          saveImageToHive(bytes, imageIndex);
        },
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
