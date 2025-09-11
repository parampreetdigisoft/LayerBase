import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';

import '../widgets/base_button.dart';
import '../widgets/base_text.dart';

class BaseDialog {
  static void show(
    BuildContext context, {
    String? dialogTitle,
    String? dialogDescription,
    String? buttonLabel = AppStrings.login,
    VoidCallback? onButtonPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: spacerSize600),
          child: Dialog(
            backgroundColor: AppColors.lightGrey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(spacerSize16)),
            child: Padding(
              padding: const EdgeInsets.all(spacerSize25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: spacerSize45, color: Colors.blue),
                  SizedBox(height: spacerSize16),
                  BaseText(
                    text: dialogTitle ?? "",
                    fontSize: fontSize20,
                    fontWeight: FontWeight.bold,
                    textColor: Colors.white,
                  ),

                  SizedBox(height: spacerSize15),
                  BaseText(
                    text: dialogDescription ?? "",
                    textAlign: TextAlign.center,
                    fontSize: fontSize16,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: spacerSize25),
                  BaseButton(
                    onPressed: onButtonPressed,
                    backgroundColor: AppColors.darkBlue,
                    buttonLabel: buttonLabel!.toUpperCase(),
                    fontSize: fontSize16,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

showBaseDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  String yesText = AppStrings.yes,
  String noText = AppStrings.no,
  required VoidCallback onYes,
  required VoidCallback onNo,
}) {
  return showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: AppColors.gunMetal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(spacerSize12)),
        title: BaseText(
          text: title,
          textAlign: TextAlign.start,
          fontWeight: FontWeight.bold,
          textColor: Colors.white,
          fontSize: spacerSize20,
        ),
        content: BaseText(
          text: subtitle,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.normal,
          textColor: Colors.white,
          fontSize: spacerSize15,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.black),
            ),
            onPressed: () {
              onNo();
            },
            child: BaseText(text: noText, fontWeight: FontWeight.bold, textColor: Colors.black),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.deepPurple,
              borderRadius: BorderRadius.circular(spacerSize15),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                enabledMouseCursor: MouseCursor.uncontrolled,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(spacerSize15)),
              ),
              onPressed: () {
                onYes();
              },
              child: BaseText(text: yesText, fontWeight: FontWeight.bold, textColor: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

class AppToast {
  static void show(
    String message, {
    String title = "",
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: textColor,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(spacerSize12),
      borderRadius: spacerSize5,
      duration: const Duration(seconds: 2),
    );
  }
}
