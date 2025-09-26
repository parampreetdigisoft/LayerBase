import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/authentication/sign_up/question_response_model.dart';
import 'package:layerbase/authentication/sign_up/sign_up_view_model.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';

import '../../utils/base/widgets/base_button.dart';
import '../../utils/base/widgets/base_dropdown.dart';
import '../../utils/base/widgets/base_form.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/base/widgets/base_text_field.dart';
import '../../utils/constants/app_keys.dart';

class SignUpScreen extends GetWidget<SignUpViewModel> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppAssets.authBg), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BaseForm(
          formKey: controller.formKey,
          child: Row(
            children: [
              Expanded(
                child: Image.asset(AppAssets.appLogo, height: spacerSize60, width: spacerSize300),
              ),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isMobile(context) ? spacerSize0 : spacerSize30),
                      bottomLeft: Radius.circular(isMobile(context) ? spacerSize0 : spacerSize30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacerSize135),
                    child: Column(
                      spacing: spacerSize15,
                      children: [
                        Expanded(flex: 3, child: SizedBox.shrink()),
                        BaseText(
                          text: AppStrings.createAndAccount,
                          textColor: AppColors.lightPurple,
                          fontSize: spacerSize40,
                          fontWeight: FontWeight.w500,
                        ),

                        fullName(),

                        emailField(),

                        Obx(() => passwordField()),

                        Obx(() => confirmPasswordField()),

                        questionDropDown(),
                        answerField(),
                        SizedBox(height: spacerSize5),
                        signUpBtn(context),

                        alreadyHaveAccount(context),
                        Expanded(flex: 2, child: SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  fullName() {
    return BaseTextField(
      controller: controller.fullNameController,
      hintText: AppStrings.fullName,
      prefixIcon: Icon(Icons.person_2_outlined, color: AppColors.lightPink, size: spacerSize20),
      validator: controller.fullNameValidator,
    );
  }

  emailField() {
    return BaseTextField(
      controller: controller.emailController,
      hintText: AppKeys.email,
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.lightPink, size: spacerSize20),
      validator: controller.emailValidator,
      keyboardType: TextInputType.emailAddress,
    );
  }

  passwordField() {
    return BaseTextField(
      controller: controller.passwordController,
      hintText: AppStrings.password,
      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.lightPink, size: spacerSize20),
      obscureText: controller.showPassword.value,
      validator: controller.passwordValidator,
      suffixIcon: IconButton(
        onPressed: () {
          controller.showPassword.value = !controller.showPassword.value;
        },
        icon: Icon(
          controller.showPassword.value ? Icons.visibility : Icons.visibility_off,
          color: AppColors.lightPink,
          size: spacerSize20,
        ),
      ),
    );
  }

  confirmPasswordField() {
    return BaseTextField(
      controller: controller.confirmPasswordController,
      hintText: AppStrings.confirmPassword,
      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.lightPink, size: spacerSize20),
      obscureText: controller.showConfirmPassword.value,
      validator: controller.confirmPasswordValidator,
      suffixIcon: Obx(
        () => IconButton(
          onPressed: () {
            controller.showConfirmPassword.value = !controller.showConfirmPassword.value;
          },
          icon: Icon(
            controller.showConfirmPassword.value ? Icons.visibility : Icons.visibility_off,
            color: AppColors.lightPink,
            size: spacerSize20,
          ),
        ),
      ),
    );
  }

  answerField() {
    return BaseTextField(
      controller: controller.answerController,
      hintText: AppStrings.enterYourAnswer,
      keyboardType: TextInputType.text,
    );
  }

  signUpBtn(BuildContext context) {
    return Obx(
      () => BaseButton(
        onPressed: () {
          if (controller.formKey.currentState!.validate()) {
            if (defaultTargetPlatform == TargetPlatform.linux) {
              controller.registerUserUsingRestApi();
            } else {
              controller.registerUser(context);
            }
          }
        },
        backgroundColor: AppColors.darkBlue,
        buttonLabel: AppStrings.signUp,
        fontSize: fontSize16,
        textColor: Colors.white,
        showLoader: controller.isLoading.value,
      ),
    );
  }

  alreadyHaveAccount(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: AppStrings.alreadyHaveAccount,
        style: TextStyle(color: AppColors.greyColor, fontSize: fontSize16),
        children: [
          TextSpan(
            text: AppStrings.login,
            style: TextStyle(
              color: AppColors.lightPurple,
              fontSize: fontSize16,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pop(context);
              },
          ),
        ],
      ),
    );
  }

  questionDropDown() {
    return BaseDropdown(
      labelText: AppStrings.chooseMySecurityQuestions,
      items: controller.securityQuestionList.map((QuestionResponseModel questionDetail) {
        return DropdownMenuItem<QuestionResponseModel>(
          value: questionDetail,
          enabled: true,
          child: BaseText(
            text: questionDetail.question.toString(),
            textColor: AppColors.greyColor,
            fontSize: fontSize16,
          ),
        );
      }).toList(),
      onChanged: (value) {
        controller.selectedQuestion.value = value!.question.toString();
      },
    );
  }

  isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}
