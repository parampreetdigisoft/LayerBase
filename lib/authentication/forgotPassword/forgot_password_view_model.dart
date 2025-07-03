import 'package:ecrumedia/base/dialogs/base_dialog.dart';
import 'package:ecrumedia/routes.dart';
import 'package:ecrumedia/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  RxBool isEmailValidated = false.obs;

  validateEmail() {
    isEmailValidated.value = !isEmailValidated.value;
  }

  changePassword(BuildContext context) {
    BaseDialog.showPasswordChangedDialog(
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

  void onBackPressed(BuildContext context) {
    if (isEmailValidated.value) {
      isEmailValidated.value = !isEmailValidated.value;
    } else {
      Navigator.pop(context);
    }
  }
}
