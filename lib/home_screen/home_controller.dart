import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/shared_prefs_service.dart';

import '../utils/constants/app_constants.dart';

class HomeController extends GetxController {
  final picker = ImagePicker();
  late SharedPrefsService sharedPrefsService;
  Box<dynamic>? hiveBox;
  Rx<File>? imageFile;
  Rx<Uint8List>? imageBytes;
  RxString userDisplayName = "".obs;
  RxString userEmail = "".obs;
  RxList<dynamic> imageList = <Uint8List>[].obs;
  RxBool isPickImageOpen = false.obs;
  RxBool isLoading = true.obs;
  var selectedIndex = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await fetchImagesFromDb();
    sharedPrefsService = SharedPrefsService.instance;
    userDisplayName.value = sharedPrefsService.getString(AppKeys.displayName) ?? "";
    userEmail.value = sharedPrefsService.getString(AppKeys.email) ?? "";
    debugPrint("email:::${userEmail.value} / Name::::${userDisplayName.value}");
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  void goToEditor(int imageIndex) {
    Navigator.pushNamed(
      Get.context!,
      Routes.imageEditor,
      arguments: {AppKeys.imageIndex: imageIndex},
    ).then((value) async {
      Future.delayed(
        Duration(milliseconds: 500),
        () => refreshImages(imageIndex, isImageEdited: true),
      );
    });
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
        Future.delayed(Duration(milliseconds: 500), () => refreshImages(imageList.length));
      });

      imageFile = file.obs;
    }
  }

  Future<void> onClickPickImageOpen() async {
    if (isPickImageOpen.value) return;
    isPickImageOpen.value = true;
    try {
      await pickImage();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isPickImageOpen.value = false;
    }
  }

  Future fetchImagesFromDb() async {
    imageList.clear();
    isLoading.value = true;
    hiveBox = Hive.box<dynamic>(AppKeys.imageLayerBox);
    List<Uint8List> tempImageList = [];
    for (var bytes in hiveBox!.values) {
      tempImageList.add(bytes[AppKeys.imageThumbnail]);
    }
    imageList.value = tempImageList;
    isLoading.value = false;
    return true;
  }

  Future<void> refreshImages(int index, {bool isImageEdited = false}) async {
    hiveBox ??= Hive.box<dynamic>(AppKeys.imageLayerBox);
    final thumbnail = hiveBox!.values.elementAt(index)[AppKeys.imageThumbnail];
    if (isImageEdited) {
      imageList.removeAt(index);
    }
    imageList.insert(index, thumbnail);
    imageList.refresh();
  }

  Future<void> saveImageToHive(Uint8List imageBytes) async {
    final box = Hive.box<dynamic>(AppKeys.imageLayerBox);
    await box.add(imageBytes);
  }
}
