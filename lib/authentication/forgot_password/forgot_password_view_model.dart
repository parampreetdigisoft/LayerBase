import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/constants/app_constants.dart';

class ForgotPasswordViewModel extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  RxBool isEmailValidated = false.obs;

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${AppStrings.email}\t${AppStrings.isText}\t${AppStrings.required}";
    }
    if (!emailRegExp.hasMatch(value)) {
      return AppStrings.enterAValidEmail;
    }

    return null;
  }

  void validateEmail() {
    isEmailValidated.value = !isEmailValidated.value;
  }

  void sendResetPasswordEmail() async {
    isLoading.value = true;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      resetPasswordDialog();
    } on FirebaseAuthException catch (exception) {
      if (exception.code == AppKeys.userNotFound) {
        AppToast.show(title: AppStrings.error, AppStrings.noUserFound, backgroundColor: Colors.red);
      } else {
        AppToast.show(title: AppStrings.error, exception.message!, backgroundColor: Colors.red);
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

  void resetPasswordDialog() {
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
    isLoading.value = true;

    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${dotenv.env['web_apiKey'] ?? ""}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestType': 'PASSWORD_RESET', AppKeys.email: emailController.text}),
    );

    if (response.statusCode == 200) {
      isLoading.value = false;
      resetPasswordDialog();
    } else {
      final error = jsonDecode(response.body);
      isLoading.value = false;
      AppToast.show(
        title: "Error",
        error['error']['message'].toString().replaceAll("_", " "),
        backgroundColor: Colors.red,
      );
    }
  }
}
