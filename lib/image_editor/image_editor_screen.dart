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
      backgroundColor: AppColors.darkJungleGreen,
      appBar: appBarWidget(context),
      floatingActionButton: floatingBtn(),
      body: Row(
        spacing: spacerSize10,
        children: [
          /// All layer
          Expanded(
            child: LayerHistoryLayout(controller: controller).marginOnly(left: spacerSize10),
          ),

          /// image Editor
          Expanded(flex: 7, child: ImageEditor(controller: controller)),
        ],
      ),
    );
  }

  floatingBtn() {
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

  AppBar appBarWidget(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.darkJungleGreen,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: 0,
      title: Image.asset(AppAssets.appLogo, height: spacerSize25),
      actions: [
        IconButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.only(right: spacerSize5, left: 0),
            minimumSize: Size(0, 0),
          ),
          tooltip: controller.userDisplayName.isEmpty ? AppStrings.login : AppStrings.logout,
          onPressed: () {
            if (controller.userDisplayName.isEmpty) {
              Navigator.pushNamed(context, Routes.logIn);
            } else {
              logoutDialog();
            }
          },

          icon: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                controller.userDisplayName.isEmpty ? Icons.person : Icons.logout,
                size: spacerSize15,
                color: AppColors.antiqueWhite,
              ),
              BaseText(
                text: controller.userDisplayName.isEmpty ? AppStrings.login : AppStrings.logout,
                textColor: AppColors.antiqueWhite,
                fontWeight: FontWeight.w500,
                fontSize: fontSize14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  logoutDialog() {
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
