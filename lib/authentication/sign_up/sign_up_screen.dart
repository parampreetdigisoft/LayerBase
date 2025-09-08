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

class SignUpScreen extends GetWidget<SignUpViewModel> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            AppAssets.authBackgroundImage,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width * .6,
            height: MediaQuery.of(context).size.height * 1.2,
          ),

          Positioned.fill(
            left: MediaQuery.of(context).size.width * .1,
            child: Align(
              child: appLogo(
                context,
                AppAssets.appLogoWhite,
                MediaQuery.of(context).size.width * .3,
              ),
              alignment: Alignment.centerLeft,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: isMobile(context)
                  ? MediaQuery.of(context).size.width
                  : MediaQuery.of(context).size.width * .5,
              height: MediaQuery.of(context).size.height,
              child: Card(
                shadowColor: Colors.black,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMobile(context) ? spacerSize0 : spacerSize50),
                    bottomLeft: Radius.circular(isMobile(context) ? spacerSize0 : spacerSize50),
                  ),
                ),
                elevation: 5,
                margin: EdgeInsets.zero,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: controller.scrollController,
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      child: BaseForm(
                        formKey: controller.formKey,
                        child:
                            Column(
                              children: [
                                SizedBox(
                                  height: isMobile(context)
                                      ? MediaQuery.of(context).size.height * .05
                                      : MediaQuery.of(context).size.height * .1,
                                ),

                                if (isMobile(context))
                                  appLogo(
                                    context,
                                    AppAssets.appLogo,
                                    MediaQuery.of(context).size.width * .5,
                                  ),
                                SizedBox(height: spacerSize20),
                                Center(
                                  child: const BaseText(
                                    text: AppStrings.createAndAccount,
                                    fontSize: fontSize30,
                                    textColor: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: spacerSize60),

                                Row(
                                  spacing: spacerSize5,
                                  children: [
                                    Expanded(child: fullName()),
                                    Expanded(child: emailField()),
                                  ],
                                ),

                                const SizedBox(height: spacerSize30),
                                passwordField(),
                                const SizedBox(height: spacerSize30),
                                Obx(() => questionDropDown()),
                                const SizedBox(height: spacerSize30),
                                answerField(),

                                const SizedBox(height: spacerSize55),
                                signUpBtn(context),
                                const SizedBox(height: spacerSize25),

                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: AppStrings.alreadyHaveAccount),
                                      WidgetSpan(child: SizedBox(width: spacerSize5)),
                                      TextSpan(
                                        text: AppStrings.login,
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.pop(context);
                                          },
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).marginSymmetric(
                              vertical: spacerSize20,
                              horizontal: MediaQuery.of(context).size.width * .03,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  appLogo(BuildContext context, String appAsset, double width) {
    return SizedBox(
      width: width,
      child: Image.asset(appAsset, fit: BoxFit.fill),
    );
  }

  fullName() {
    return BaseTextField(
      textEditingController: controller.fullNameController,
      hintText: AppStrings.enterYourFullName,
      labelText: AppStrings.fullName,
      prefixIcon: const Icon(Icons.contacts),
      keyboardType: TextInputType.name,
    );
  }

  emailField() {
    return BaseTextField(
      textEditingController: controller.emailController,
      hintText: AppStrings.enterYourEmail,
      labelText: AppStrings.email,
      prefixIcon: const Icon(Icons.email),
      keyboardType: TextInputType.emailAddress,
    );
  }

  answerField() {
    return BaseTextField(
      textEditingController: controller.answerController,
      hintText: AppStrings.enterYourAnswer,
      labelText: AppStrings.yourAnswer,
      keyboardType: TextInputType.text,
    );
  }

  passwordField() {
    return Obx(
      () => BaseTextField(
        textEditingController: controller.passwordController,
        labelText: AppStrings.password,
        hintText: AppStrings.createYourPassword,
        prefixIcon: const Icon(Icons.lock),
        keyboardType: TextInputType.visiblePassword,
        isTextObscure: controller.isPasswordObscure.value,
        suffixIcon: IconButton(
          onPressed: () {
            controller.isPasswordObscure.value = !controller.isPasswordObscure.value;
          },
          icon: controller.isPasswordObscure.value
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off),
        ),
      ),
    );
  }

  signUpBtn(BuildContext context) {
    return SizedBox(
      width: spacerSize250,
      child: Obx(
        () => BaseButton(
          onPressed: () {
            if (controller.formKey.currentState!.validate()) {
              if (defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.windows) {
                controller.registerUserUsingRestApi();
              } else {
                controller.registerUser(context);
              }
            }
          },
          backgroundColor: AppColors.darkBlue,
          buttonLabel: AppStrings.signUp,
          fontSize: fontSize18,
          textColor: Colors.white,
          showLoader: controller.isLoading.value,
        ),
      ),
    );
  }

  questionDropDown() {
    return BaseDropdown(
      labelText: AppStrings.chooseMySecurityQuestions,
      items: controller.securityQuestionList.map((QuestionResponseModel questionDetail) {
        return DropdownMenuItem<QuestionResponseModel>(
          value: questionDetail,
          child: BaseText(text: questionDetail.question.toString()),
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
