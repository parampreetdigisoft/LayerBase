import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pro_image_editor/core/platform/io/io_web.dart';

class GalleryScreenViewModel extends GetxController
    with GetTickerProviderStateMixin {
  final RxBool isLoading = true.obs;
  late TabController tabController;
  File? imageFile;
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      imageFile = file;
    } else {}
  }
}
