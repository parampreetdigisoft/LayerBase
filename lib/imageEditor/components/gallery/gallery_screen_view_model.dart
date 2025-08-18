import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/shared_prefs_service.dart';

class GalleryScreenViewModel extends GetxController
    with GetTickerProviderStateMixin {
  final RxBool isLoading = true.obs;
  late TabController tabController;
  Rx<File>? imageFile;
  final picker = ImagePicker();
  Rx<Uint8List>? imageBytes;
  Box<dynamic>? hiveBox;

  RxList<dynamic>? imageList = <Uint8List>[].obs;
  late SharedPrefsService sharedPrefsService;
  var extensions = [
    'png',
    'jpg',
    'jpeg',
    'gif',
    'cr2',
    'tiff',
    'psd',
    'dng',
    'NEF',
    'nrw',
    'cr3',
    'arw',
    'srf',
    'sr2',
    'orf',
    'raw',
    'rw2',
    'raf',
    'dcr',
    'k25',
    'kdc',
  ];

  @override
  void onInit() {
    super.onInit();
    sharedPrefsService = SharedPrefsService.instance;
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        if (tabController.index == 1) {
          Future.delayed(Duration.zero, () {
            tabController.index = tabController.previousIndex;
          });
        }
      }
    });
    fetchImagesFromDb();
  }

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: false,
      withData: true,
      compressionQuality: -100,
      withReadStream: true,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      imageBytes = bytes.obs;

      Navigator.pushNamed(
        Get.context!,
        Routes.imageEditor,
        arguments: {
          AppKeys.imageData: {AppKeys.image: imageBytes!.value},
        },
      ).then((value) {
        fetchImagesFromDb();
      });

      imageFile = file.obs;
    } else {}
  }

  fetchImagesFromDb() async {
    imageList!.clear();
    isLoading.value = true;
    hiveBox = Hive.box<dynamic>(AppKeys.imageLayerBox);

    List<Uint8List> tempImageList = [];
    for (var bytes in hiveBox!.values) {
      // Attempt to load as TIFF first
      dynamic loadedImage = await loadTiffAsImage(
        bytes[AppKeys.imageThumbnail],
      );
      if (loadedImage != null) {
        tempImageList.add(loadedImage);
      } else {
        // If not a TIFF or loading failed, add the original bytes
        tempImageList.add(bytes[AppKeys.imageThumbnail]);
        tempImageList.add(bytes[AppKeys.imageThumbnail]);
      }
    }
    imageList!.value = tempImageList;
    isLoading.value = false;
  }

  Future<void> saveImageToHive(Uint8List imageBytes) async {
    final box = Hive.box<dynamic>(AppKeys.imageLayerBox);
    await box.add(imageBytes);
  }

  Future<dynamic> loadTiffAsImage(var imageData) async {
    // Decode the TIFF image
    final decoded = img.decodeTiff(imageData);
    if (decoded == null) return null;

    // Convert to PNG bytes
    final pngBytes = img.encodePng(decoded);
    return pngBytes;
  }
}
