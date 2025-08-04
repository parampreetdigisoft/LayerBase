import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:layerbase/base/dialogs/base_dialog.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  sendResetPasswordEmail() async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      resetPasswordDialog();
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

  resetPasswordDialog() {
    return BaseDialog.show(
      Get.context!,
      dialogTitle: AppStrings.sent,
      buttonLabel: AppStrings.ok,
      dialogDescription: AppStrings.passwordResetLink,
      onButtonPressed: () {
        Navigator.pop(Get.context!);
        Navigator.pop(Get.context!);
      },
    );
  }

  Future<void> sendPasswordResetEmailWithRest() async {
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${dotenv.env['web_apiKey'] ?? ""}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': 'PASSWORD_RESET',
        'email': emailController.text,
      }),
    );

    if (response.statusCode == 200) {
      resetPasswordDialog();
    } else {
      final error = jsonDecode(response.body);
      print('❌ Error: ${error['error']['message']}');
    }
  }
}
