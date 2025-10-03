import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/base/widgets/base_shader_mask.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';

import '../utils/base/dialogs/base_dialog.dart';
import '../utils/base/widgets/base_text.dart';
import '../utils/routes.dart';
import 'components/cloud_files.dart';
import 'components/local_files.dart';
import 'home_controller.dart';

class HomeScreen extends GetWidget<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Column(
          children: [
            SizedBox(height: spacerSize15),
            buildCustomTabBtn(),
            SizedBox(height: spacerSize5),
            importAndAIBtn(),
            SizedBox(height: spacerSize5),
            controller.selectedIndex.value == 0
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacerSize15),
                      child: LocalFiles(controller: controller),
                    ),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacerSize15),
                      child: CloudFiles(controller: controller),
                    ),
                  ),
            SizedBox(height: spacerSize10),
          ],
        ),
      ),
    );
  }

  Widget buildCustomTabBtn() {
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
          InkWell(
            onTap: () {
              controller.changeTab(0);
            },
            child: Container(
              margin: EdgeInsets.only(top: spacerSize8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: spacerSize18, vertical: spacerSize2),
                    decoration: baseBoxDecoration(
                      color: controller.selectedIndex.value == 0
                          ? AppColors.darkSlatePurple
                          : Colors.transparent,
                      borderColor: Colors.transparent,
                      radius: spacerSize20,
                    ),
                    child: Image.asset(
                      AppAssets.fileIcon,
                      height: spacerSize18,
                      width: spacerSize18,
                      fit: BoxFit.cover,
                    ),
                  ),
                  BaseText(
                    text: AppStrings.local,
                    textColor: AppColors.antiqueWhite,
                    fontSize: fontSize13,
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              controller.changeTab(1);
            },
            child: Container(
              margin: EdgeInsets.only(top: spacerSize8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: spacerSize18, vertical: spacerSize2),
                    decoration: baseBoxDecoration(
                      color: controller.selectedIndex.value == 1
                          ? AppColors.darkSlatePurple
                          : Colors.transparent,
                      borderColor: Colors.transparent,
                      radius: spacerSize20,
                    ),
                    child: Icon(Icons.cloud, size: spacerSize18, color: AppColors.lightWhite),
                  ),
                  BaseText(
                    text: AppStrings.cloud,
                    textColor: AppColors.antiqueWhite,
                    fontSize: fontSize13,
                  ),
                ],
              ),
            ),
          ),

          Spacer(),
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

  importAndAIBtn() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacerSize10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              controller.onClickPickImageOpen();
            },
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: spacerSize15, vertical: spacerSize2),
              decoration: baseBoxDecoration(
                color: AppColors.darkSlatePurple,
                borderColor: Colors.transparent,
                radius: spacerSize20,
              ),
              child: Row(
                children: [
                  Icon(Icons.add, color: AppColors.antiqueWhite, size: spacerSize16),
                  BaseText(
                    text: AppStrings.import,
                    textColor: AppColors.antiqueWhite,
                    fontSize: fontSize14,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: spacerSize10, vertical: spacerSize2),
              decoration: baseBoxDecoration(
                color: AppColors.lightPurple,
                borderColor: Colors.transparent,
                radius: spacerSize20,
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.aiImage,
                    height: spacerSize20,
                    width: spacerSize20,
                    fit: BoxFit.cover,
                  ),
                  BaseText(
                    text: "${AppStrings.balance}:\t123",
                    textColor: AppColors.darkPurple,
                    fontSize: fontSize14,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  showProfilePopup(BuildContext context) {
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
              text: "You’re currently using the app as a guest.\nPlease log in to continue.",
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
