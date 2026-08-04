import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:layerbase/authentication/sign_up/question_response_model.dart';
import 'package:layerbase/authentication/sign_up/sign_up_repository.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart';

import '../../utils/base/dialogs/base_dialog.dart';
import '../../utils/constants/app_constants.dart';

class SignUpViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool showPassword = true.obs;
  RxBool showConfirmPassword = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  SignUpRepository signUpRepository = SignUpRepository();
  RxList<QuestionResponseModel> securityQuestionList = <QuestionResponseModel>[].obs;
  ScrollController scrollController = ScrollController();
  RxString selectedQuestion = "".obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    getSecurityQuestions();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    answerController.dispose();
    scrollController.dispose();
  }

  String? fullNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${AppStrings.fullName}\t${AppStrings.isText}\t${AppStrings.required}";
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${AppStrings.email}\t${AppStrings.isText}\t${AppStrings.required}";
    }
    if (!emailRegExp.hasMatch(value)) {
      return AppStrings.enterAValidEmail;
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${AppStrings.password}\t${AppStrings.isText}\t${AppStrings.required}";
    }
    if (!passwordRegExp.hasMatch(value)) {
      return AppStrings.passwordValidationDesc;
    }

    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "${AppStrings.confirmPassword}\t${AppStrings.isText}\t${AppStrings.required}";
    }
    if (value != passwordController.text) {
      return AppStrings.passwordDoNotMatch;
    }

    return null;
  }

  void getSecurityQuestions() {
    securityQuestionList.value = signUpRepository.fetchSecurityQuestion();
  }

  Future<void> registerUser(BuildContext context) async {
    isLoading.value = true;
    isLoading.refresh();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection(AppKeys.users).add({
          AppKeys.uid: user.uid,
          AppKeys.email: emailController.text,
          AppKeys.displayName: fullNameController.text,
          AppKeys.createdAt: FieldValue.serverTimestamp(),
          AppKeys.securityQuestion: selectedQuestion.value,
          AppKeys.securityAnswer: answerController.text,
        });
        registerSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == AppKeys.weakPassword) {
        AppToast.show(
          title: AppStrings.validate,
          AppStrings.passwordNotStrong,
          backgroundColor: Colors.red,
        );
      } else if (e.code == AppKeys.emailAlreadyInUse) {
        AppToast.show(
          title: AppStrings.validate,
          AppStrings.emailAlreadyUsed,
          backgroundColor: Colors.red,
        );
      } else {
        AppToast.show(
          title: AppStrings.validate,
          e.message.toString(),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      debugPrint('${AppStrings.error}: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerUserUsingRestApi() async {
    isLoading.value = true;
    isLoading.refresh();
    final url = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${dotenv.env[AppKeys.webApiKey] ?? ""}',
    );

    final Map<String, dynamic> map = {
      AppKeys.email: emailController.text,
      AppKeys.password: passwordController.text,
      AppKeys.displayName: fullNameController.text,
      AppKeys.securityQuestion: selectedQuestion.value,
      AppKeys.securityAnswer: answerController.text,
      AppKeys.returnSecureToken: true,
    };

    debugPrint("map:::$map");
    final response = await http.post(
      url,
      headers: {AppKeys.contentType: 'application/json'},
      body: jsonEncode(map),
    );
    debugPrint("statusCode::::${response.body}");

    if (response.statusCode == 200) {
      isLoading.value = false;
      await FirebaseFirestore.instance
          .collection(AppKeys.users)
          .add({
            AppKeys.email: emailController.text,
            AppKeys.displayName: fullNameController.text,
            AppKeys.createdAt: FieldValue.serverTimestamp(),
            AppKeys.securityQuestion: selectedQuestion.value,
            AppKeys.securityAnswer: answerController.text,
          })
          .then((v) {
            registerSuccessDialog();
          });
    } else {
      isLoading.value = false;
      AppToast.show(
        title: AppStrings.validate,
        AppStrings.invalidDataEntered,
        backgroundColor: Colors.red,
      );
    }
  }

  void registerSuccessDialog() {
    return BaseDialog.show(
      Get.context!,
      dialogTitle: AppStrings.success,
      dialogDescription: AppStrings.yourAccountHasBeenCreated,
      onButtonPressed: () {
        Navigator.pushNamedAndRemoveUntil(
          Get.context!,
          Routes.logIn,
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
