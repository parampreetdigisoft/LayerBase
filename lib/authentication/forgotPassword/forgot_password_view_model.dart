import 'package:Layerbase/base/dialogs/base_dialog.dart';
import 'package:Layerbase/utils/constants/app_constants.dart';
import 'package:Layerbase/utils/constants/app_keys.dart';
import 'package:Layerbase/utils/routes.dart';
import 'package:Layerbase/utils/constants/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  RxBool isEmailValidated = false.obs;
  final formKey = GlobalKey<FormState>();

  validateEmail() {
    isEmailValidated.value = !isEmailValidated.value;
  }

  changePassword(BuildContext context) {
    BaseDialog.show(
      context,
      dialogDescription: AppStrings.passwordChangedSuccessfully,
      dialogTitle: AppStrings.passwordChanged,
      onButtonPressed: () {
        Navigator.popUntil(
          context,
          (route) => route.settings.name == Routes.logIn,
        );
      },
    );
  }

  sendResetPasswordEmail() async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      BaseDialog.show(
        Get.context!,
        dialogTitle: AppStrings.sent,
        buttonLabel: AppStrings.ok,
        dialogDescription: AppStrings.passwordResetLink,
        onButtonPressed: () {
          Navigator.pop(Get.context!);
          Navigator.pop(Get.context!);
        },
      );
    } on FirebaseAuthException catch (exception) {
      if (exception.code == AppKeys.userNotFound) {
        BaseSnackBar.show(
          title: AppStrings.error,
          message: AppStrings.noUserFound,
        );
      } else {
        BaseSnackBar.show(title: AppStrings.error, message: exception.message!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onBackPressed(BuildContext context) {
    if (isEmailValidated.value) {
      isEmailValidated.value = !isEmailValidated.value;
    } else {
      Navigator.pop(context);
    }
  }
}
