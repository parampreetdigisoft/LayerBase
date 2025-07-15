import 'package:layerbase/base/widgets/base_button.dart';
import 'package:layerbase/base/widgets/base_text.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(spacerSize16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(spacerSize25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: spacerSize45,
                    color: Colors.blue,
                  ),
                  SizedBox(height: spacerSize16),
                  BaseText(
                    text: dialogTitle ?? "",
                    fontSize: fontSize20,
                    fontWeight: FontWeight.bold,
                    textColor: Colors.black,
                  ),

                  SizedBox(height: spacerSize15),
                  BaseText(
                    text: dialogDescription ?? "",
                    textAlign: TextAlign.center,
                    fontSize: fontSize16,
                    textColor: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  SizedBox(height: spacerSize25),
                  SizedBox(
                    width: MediaQuery.of(Get.context!).size.width*.1,
                    child: BaseButton(
                      onPressed: onButtonPressed,
                      backgroundColor: AppColors.darkBlue,
                      buttonLabel: buttonLabel!.toUpperCase(),
                      fontSize: fontSize16,
                      textColor: Colors.white,
                    ),
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
