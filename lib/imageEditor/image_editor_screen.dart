import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';

class ImageEditorScreen extends StatefulWidget {
  const ImageEditorScreen({super.key});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _imageFile = file;
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    if (_imageFile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Image')),
        body: Center(
          child: ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Browse Image'),
          ),
        ),
      );
    }
    return ProImageEditor.file(
      _imageFile,
      configs: ProImageEditorConfigs(
        theme: ThemeData.dark(useMaterial3: true),
        helperLines: HelperLineConfigs(
          showHorizontalLine: true,
          showRotateLine: true,
          showVerticalLine: true,
        ),

        designMode: ImageEditorDesignMode.material,
        mainEditor: MainEditorConfigs(
          enableDoubleTapZoom: true,
          canZoomWhenLayerSelected: true,
          enableZoom: true,
        ),
        imageGeneration: ImageGenerationConfigs(
          cropToDrawingBounds: true,
          allowEmptyEditingCompletion: true,
          enableBackgroundGeneration: true,
          cropToImageBounds: true,
          enableIsolateGeneration: true,
          singleFrame: true,
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
          selectable: LayerInteractionSelectable.enabled,
          keepSelectionOnInteraction: true,
          hideVideoControlsOnInteraction: true,
          hideToolbarOnInteraction: true,
          initialSelected: true,
        ),
      ),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
          print('Image save successfully');

          saveImageToHive(bytes);
          /*
          Your code to process the edited image, such as uploading it to your server.

          You can choose to use await to keep the loading dialog visible until
          your code completes, or run it without async to close the loading dialog immediately.

          By default, the image bytes are in JPG format.
        */
        },
      ),
    );
  }

  Future<void> saveImageToHive(Uint8List imageBytes) async {
    final box = Hive.box<Uint8List>('imageBox');
    await box.add(imageBytes);
  }
}
