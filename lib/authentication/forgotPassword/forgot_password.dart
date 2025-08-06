import 'package:flutter/foundation.dart';
import 'package:layerbase/authentication/forgotPassword/forgot_password_view_model.dart';
import 'package:layerbase/base/widgets/base_button.dart';
import 'package:layerbase/base/widgets/base_form.dart';
import 'package:layerbase/base/widgets/base_text.dart';
import 'package:layerbase/base/widgets/base_text_field.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPassword extends GetWidget<ForgotPasswordViewModel> {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            AppAssets.authBackgroundImage,
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width * .6,
            height: MediaQuery.of(context).size.height * 1.5,
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
              child: Stack(
                children: [
                  Card(
                    shadowColor: Colors.black,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                          isMobile(context) ? spacerSize0 : spacerSize50,
                        ),
                        bottomLeft: Radius.circular(
                          isMobile(context) ? spacerSize0 : spacerSize50,
                        ),
                      ),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.zero,
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      margin: EdgeInsets.symmetric(
                        vertical: spacerSize60,
                        horizontal: MediaQuery.of(context).size.width * .03,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
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
                                MediaQuery.of(context).size.width * .7,
                              ),
                            SizedBox(height: spacerSize20),
                            Obx(
                              () => Center(
                                child: BaseText(
                                  text: controller.isEmailValidated.value
                                      ? AppStrings.resetPassword
                                      : AppStrings.forgotPassword,
                                  fontSize: fontSize30,
                                  textColor: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: spacerSize60),
                            emailField(),

                            resetPasswordFields(),

                            const SizedBox(height: spacerSize45),
                            submit(context),

                            Obx(() {
                              if (controller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: spacerSize20,
                    left: spacerSize20,
                    child: Wrap(
                      children: [
                        IconButton(
                          onPressed: () {
                            controller.onBackPressed(context);
                          },
                          color: Colors.black,
                          icon: Icon(Icons.arrow_back_ios_new),
                        ),
                      ],
                    ),
                  ),
                ],
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

  emailField() {
    return Obx(
      () => !controller.isEmailValidated.value
          ? BaseForm(
              formKey: controller.formKey,
              child: BaseTextField(
                textEditingController: controller.emailController,
                hintText: AppStrings.enterYourEmail,
                labelText: AppStrings.email,
                prefixIcon: const Icon(Icons.email),
                keyboardType: TextInputType.emailAddress,
              ),
            )
          : SizedBox(),
    );
  }

  passwordField() {
    return Obx(
      () => BaseTextField(
        textEditingController: controller.passwordController,
        labelText: AppStrings.newPassword,
        hintText: AppStrings.enterYourPassword,
        prefixIcon: const Icon(Icons.lock),
        keyboardType: TextInputType.visiblePassword,
        isTextObscure: controller.isPasswordObscure.value,
      ),
    );
  }

  confirmPasswordField() {
    return Obx(
      () => BaseTextField(
        textEditingController: controller.confirmPasswordController,
        labelText: AppStrings.confirmPassword,
        hintText: AppStrings.reEnterYourPassword,
        prefixIcon: const Icon(Icons.lock),
        keyboardType: TextInputType.visiblePassword,
        isTextObscure: controller.isPasswordObscure.value,
        suffixIcon: IconButton(
          onPressed: () {
            controller.isPasswordObscure.value =
                !controller.isPasswordObscure.value;
          },
          icon: controller.isPasswordObscure.value
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off),
        ),
      ),
    );
  }

  submit(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: spacerSize250,
        child: BaseButton(
          onPressed: () {
            if (controller.formKey.currentState!.validate()) {
              defaultTargetPlatform == TargetPlatform.linux
                  ? controller.sendPasswordResetEmailWithRest()
                  : controller.sendResetPasswordEmail();
            }
          },
          backgroundColor: AppColors.darkBlue,
          buttonLabel: controller.isEmailValidated.value
              ? AppStrings.update
              : AppStrings.submit,
          fontSize: fontSize18,
          textColor: Colors.white,
        ),
      ),
    );
  }

  isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  resetPasswordFields() {
    return Obx(
      () => controller.isEmailValidated.value
          ? Wrap(
              spacing: spacerSize30,
              children: [
                const SizedBox(height: spacerSize30),
                passwordField(),
                const SizedBox(height: spacerSize30),
                confirmPasswordField(),
              ],
            )
          : SizedBox(),
    );
  }
}
