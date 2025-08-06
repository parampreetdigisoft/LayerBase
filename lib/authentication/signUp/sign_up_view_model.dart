import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:layerbase/authentication/signUp/question_response_model.dart';
import 'package:layerbase/authentication/signUp/sign_up_repository.dart';
import 'package:layerbase/base/dialogs/base_dialog.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  SignUpRepository signUpRepository = SignUpRepository();
  RxList<QuestionResponseModel> securityQuestionList =
      <QuestionResponseModel>[].obs;

  ScrollController scrollController = ScrollController();

  RxString selectedQuestion = "".obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    getSecurityQuestions();
  }

  getSecurityQuestions() {
    securityQuestionList.value = signUpRepository.fetchSecurityQuestion();
  }

  Future<void> registerUser(BuildContext context) async {
    isLoading.value = true;
    isLoading.refresh();
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

      User? user = userCredential.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection(AppKeys.users).add({
          AppKeys.uid: user.uid,
          AppKeys.email: emailController.text,
          AppKeys.name: fullNameController.text,
          AppKeys.createdAt: FieldValue.serverTimestamp(),
          AppKeys.securityQuestion: selectedQuestion.value,
          AppKeys.securityAnswer: answerController.text,
        });
        registerSuccessDialog();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == AppKeys.weakPassword) {
        BaseSnackBar.show(
          title: AppStrings.validate,
          message: AppStrings.passwordNotStrong,
        );
      } else if (e.code == AppKeys.emailAlreadyInUse) {
        BaseSnackBar.show(
          title: AppStrings.validate,
          message: AppStrings.emailAlreadyUsed,
        );
      } else {
        BaseSnackBar.show(
          title: AppStrings.validate,
          message: e.message.toString(),
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
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${dotenv.env['web_apiKey'] ?? ""}',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        AppKeys.email: emailController.text,
        AppKeys.password: passwordController.text,
        AppKeys.name: fullNameController.text,
        AppKeys.securityQuestion: selectedQuestion.value,
        AppKeys.securityAnswer: answerController.text,
        'returnSecureToken': true,
      }),
    );

    if (response.statusCode == 200) {
      registerSuccessDialog();
    } else {
      BaseSnackBar.show(
        title: AppStrings.validate,
        message: AppStrings.invalidDataEntered,
      );
    }
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

  registerSuccessDialog() {
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
