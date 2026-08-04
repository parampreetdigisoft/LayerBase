import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/base/dialogs/base_dialog.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';

import '../utils/base/widgets/base_shader_mask.dart';
import '../utils/base/widgets/base_text.dart';
import '../utils/routes.dart';
import 'components/editor_screen.dart';
import 'components/layer_history_layout.dart';
import 'image_editor_view_model.dart';

class ImageEditorScreen extends GetWidget<ImageEditorViewModel> {
  const ImageEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      floatingActionButton: floatingBtn(),
      body: Column(
        spacing: spacerSize15,
        children: [
          SizedBox.shrink(),
          buildExportAndProfileBtn(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: spacerSize5),
              child: Row(
                spacing: spacerSize8,
                children: [
                  /// All layer
                  Expanded(
                    child: LayerHistoryLayout(
                      controller: controller,
                    ).marginOnly(left: spacerSize10),
                  ),

                  /// image Editor
                  Expanded(flex: 5, child: ImageEditor(controller: controller)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget floatingBtn() {
    return IconButton(
      tooltip: AppStrings.aiGenerate,
      style: TextButton.styleFrom(
        padding: EdgeInsets.only(right: spacerSize5, left: 0, bottom: spacerSize2),
        minimumSize: Size(0, 0),
      ),
      onPressed: () {},
      icon: Container(
        padding: EdgeInsets.all(spacerSize2),
        margin: EdgeInsets.only(right: spacerSize12),
        decoration: BoxDecoration(
          color: Colors.cyanAccent.shade400,
          borderRadius: BorderRadius.circular(spacerSize8),
          boxShadow: [
            BoxShadow(
              color: AppColors.brightCyan,
              blurRadius: spacerSize3,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: GradientShaderMask(
          child: Image.asset(AppAssets.aiIcon, height: spacerSize35, width: spacerSize35),
        ),
      ),
    );
  }

  Widget buildExportAndProfileBtn() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: spacerSize15),
      alignment: Alignment.topLeft,
      padding: EdgeInsets.only(left: spacerSize20, right: spacerSize10),
      decoration: baseBoxDecoration(
        color: AppColors.lightGrey,
        radius: spacerSize40,
        borderColor: AppColors.blackColor,
      ),
      child: Row(
        spacing: spacerSize20,
        children: [
          Image.asset(AppAssets.appLogo, height: spacerSize25),
          Spacer(),

          IconButton(
            onPressed: () {
              controller.exportAndDownloadImage();
            },
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: spacerSize12, vertical: spacerSize2),
              decoration: baseBoxDecoration(
                color: AppColors.darkSlatePurple,
                borderColor: Colors.transparent,
                radius: spacerSize20,
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.downloadIcon,
                    height: spacerSize18,
                    width: spacerSize18,
                    fit: BoxFit.cover,
                  ),
                  BaseText(
                    text: AppStrings.export,
                    textColor: AppColors.antiqueWhite,
                    fontSize: fontSize14,
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              showProfilePopup(Get.context!);
            },
            child: Container(
              decoration: baseBoxDecoration(
                color: AppColors.blackColor,
                borderColor: Colors.transparent,
                radius: spacerSize20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(spacerSize30),
                child: Image.asset(
                  AppAssets.dummyProfileImage,
                  height: spacerSize40,
                  width: spacerSize40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showProfilePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          alignment: Alignment.topRight,
          backgroundColor: AppColors.lightGrey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(spacerSize12)),
          title: Visibility(
            visible: controller.userEmail.isNotEmpty,
            replacement: BaseText(
              text: AppStrings.guestModeDesc,
              textAlign: TextAlign.center,
              textColor: Colors.white,
              fontSize: fontSize13,
              fontWeight: FontWeight.w500,
            ),
            child: Row(
              spacing: spacerSize5,
              children: [
                Container(
                  decoration: baseBoxDecoration(
                    color: AppColors.blackColor,
                    borderColor: Colors.transparent,
                    radius: spacerSize30,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(spacerSize30),
                    child: Image.asset(
                      AppAssets.dummyProfileImage,
                      height: spacerSize45,
                      width: spacerSize45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BaseText(
                      text: controller.userDisplayName.value.toCapitalized(),
                      textColor: Colors.white,
                      fontSize: fontSize14,
                      fontWeight: FontWeight.bold,
                    ),
                    BaseText(
                      text: controller.userEmail.value,
                      textColor: AppColors.antiqueWhite,
                      fontSize: fontSize13,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
          ),

          content: InkWell(
            onTap: () {
              if (controller.userEmail.value.isNotEmpty) {
                Get.back();
                showLogoutDialog();
              } else {
                Get.toNamed(Routes.logIn);
              }
            },
            child: Container(
              decoration: baseBoxDecoration(
                color: AppColors.deepPurple,
                radius: spacerSize10,
                borderColor: Colors.transparent,
              ),
              child: BaseText(
                text: controller.userEmail.isNotEmpty ? AppStrings.logout : AppStrings.login,
                textColor: AppColors.antiqueWhite,
                fontSize: fontSize13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showLogoutDialog() {
    return showBaseDialog(
      context: Get.context!,
      title: AppStrings.logout,
      subtitle: "${AppStrings.areYouSureWantTo}\t${AppStrings.logout}?",
      onYes: () {
        controller.sharedPrefsService.clear();
        Navigator.pushNamedAndRemoveUntil(Get.context!, Routes.logIn, (route) => false);
      },
      onNo: () {
        Get.back();
      },
    );
  }
}
