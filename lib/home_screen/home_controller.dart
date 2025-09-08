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

import '../utils/base/dialogs/base_dialog.dart';
import '../utils/constants/app_constants.dart';
import '../utils/constants/app_strings.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  final RxBool isLoading = true.obs;
  Rx<File>? imageFile;
  final picker = ImagePicker();
  Rx<Uint8List>? imageBytes;
  Box<dynamic>? hiveBox;
  RxString userDisplayName = "".obs;
  RxList<dynamic> imageList = <Uint8List>[].obs;
  late SharedPrefsService sharedPrefsService;
  late TabController tabController;
  var selectedIndex = 0.obs;
  var isPickImageOpen = false.obs;
  final List<String> tabLabels = [AppStrings.localFiles, AppStrings.cloudFiles];

  @override
  Future<void> onInit() async {
    super.onInit();
    sharedPrefsService = SharedPrefsService.instance;
    userDisplayName.value = sharedPrefsService.getString(AppKeys.displayName) ?? "";
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
    await fetchImagesFromDb();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedIndex.value = index;
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
      dynamic loadedImage = await loadTiffAsImage(bytes[AppKeys.imageThumbnail]);
      if (loadedImage != null) {
        tempImageList.add(loadedImage);
      } else {
        tempImageList.add(bytes[AppKeys.imageThumbnail]);
      }
    }
    imageList.value = tempImageList;
    isLoading.value = false;
    return true;
  }

  Future<void> refreshImages(var index, {bool isImageEdited = false}) async {
    hiveBox ??= Hive.box<dynamic>(AppKeys.imageLayerBox);
    final thumbnail = hiveBox!.values.elementAt(index)[AppKeys.imageThumbnail];
    dynamic loadedImage = await loadTiffAsImage(thumbnail);
    if (isImageEdited) {
      imageList.removeAt(index);
    }
    imageList.insert(index, loadedImage ?? thumbnail);
    imageList.refresh();
  }

  Future<void> saveImageToHive(Uint8List imageBytes) async {
    final box = Hive.box<dynamic>(AppKeys.imageLayerBox);
    await box.add(imageBytes);
  }

  Future<dynamic> loadTiffAsImage(var imageData) async {
    if (imageData != null && imageData is Uint8List && imageData.isNotEmpty) {
      final decoded = img.decodeTiff(imageData);
      if (decoded == null) return null;
      final pngBytes = img.encodePng(decoded);
      return pngBytes;
    }
  }

  Future<void> downloadImage(bytes) async {
    bool isSuccess = false;
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        return;
      }
      final timestamp =
          "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}";
      final filePath = "$selectedDirectory/layer_base_img_$timestamp.png";
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      isSuccess = true;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (isSuccess) {
        AppToast.show(
          title: AppStrings.downloadSuccessfully,
          "${AppStrings.file}\t ${AppStrings.downloadSuccessfully}",
          backgroundColor: Colors.green,
        );
      }
    }
  }

  void goToEditor(int imageIndex) {
    Navigator.pushNamed(
      Get.context!,
      Routes.imageEditor,
      arguments: {AppKeys.imageIndex: imageIndex},
    ).then((value) {
      Future.delayed(
        Duration(milliseconds: 500),
        () => refreshImages(imageIndex, isImageEdited: true),
      );
    });
  }
}
