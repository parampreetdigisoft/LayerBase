import 'package:ecrumedia/authentication/signUp/question_response_model.dart';
import 'package:ecrumedia/authentication/signUp/sign_up_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  RxString selectedQuestion = "".obs;
  RxString enteredAnswer = "".obs;

  @override
  void onInit() {
    super.onInit();

    getSecurityQuestions();
  }

  getSecurityQuestions() {
    securityQuestionList.value = signUpRepository.fetchSecurityQuestion();
  }
}
