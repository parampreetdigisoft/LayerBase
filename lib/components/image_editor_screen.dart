import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      // Now use this file
      setState(() {
        _imageFile = file;
      });

    } else {
    }
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
      _imageFile!,
      configs: const ProImageEditorConfigs(
        designMode: ImageEditorDesignMode.material,
        layerInteraction: LayerInteractionConfigs(
          selectable: LayerInteractionSelectable.enabled,
        ),
      ),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (Uint8List bytes) async {
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
}
