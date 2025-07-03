import 'package:ecrumedia/base/widgets/base_button.dart';
import 'package:ecrumedia/base/widgets/base_text.dart';
import 'package:ecrumedia/utils/app_color.dart';
import 'package:ecrumedia/utils/app_constants.dart';
import 'package:ecrumedia/utils/app_strings.dart';
import 'package:flutter/material.dart';

class BaseDialog {
  static void showPasswordChangedDialog(
    BuildContext context, {
    String? dialogTitle,
    String? dialogDescription,
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
                    width: double.infinity,
                    child: BaseButton(
                      onPressed: onButtonPressed,
                      backgroundColor: AppColors.darkBlue,
                      buttonLabel: AppStrings.login.toUpperCase(),
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
