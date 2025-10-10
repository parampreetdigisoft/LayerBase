import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/base/widgets/base_form.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';

import '../../utils/base/widgets/base_button.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/base/widgets/base_text_field.dart';
import 'forgot_password_view_model.dart';

class ForgotPassword extends GetWidget<ForgotPasswordViewModel> {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppAssets.authBg), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: spacerSize15,
                  children: [
                    IconButton(
                      padding: EdgeInsets.all(spacerSize20),

                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_sharp,
                        color: Colors.white,
                        size: spacerSize20,
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacerSize150),
                        child: Column(
                          spacing: spacerSize20,
                          children: [
                            Expanded(child: SizedBox.shrink()),
                            Center(
                              child: BaseText(
                                text: controller.isEmailValidated.value
                                    ? AppStrings.resetPassword
                                    : AppStrings.forgotPassword,
                                textColor: AppColors.lightPurple,
                                fontSize: spacerSize30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            emailField(),
                            resetPasswordFields(),
                            Obx(() => submit(context)),
                            Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget emailField() {
    return BaseForm(
      formKey: controller.formKey,
      child: BaseTextField(
        controller: controller.emailController,
        hintText: AppStrings.email,
        prefixIcon: Icon(Icons.email_outlined, color: AppColors.lightPink, size: spacerSize20),
        validator: controller.emailValidator,
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget passwordField() {
    return Obx(
      () => BaseTextField(
        controller: controller.passwordController,
        labelText: AppStrings.newPassword,
        hintText: AppStrings.enterYourPassword,
        prefixIcon: const Icon(Icons.lock),
        keyboardType: TextInputType.visiblePassword,
      ),
    );
  }

  Widget confirmPasswordField() {
    return Obx(
      () => BaseTextField(
        controller: controller.confirmPasswordController,
        labelText: AppStrings.confirmPassword,
        hintText: AppStrings.reEnterYourPassword,
        prefixIcon: const Icon(Icons.lock),
        keyboardType: TextInputType.visiblePassword,
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

  Widget submit(BuildContext context) {
    return BaseButton(
      onPressed: () {
        if (controller.formKey.currentState!.validate()) {
          defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.windows
              ? controller.sendPasswordResetEmailWithRest()
              : controller.sendResetPasswordEmail();
        }
      },
      backgroundColor: AppColors.darkBlue,
      buttonLabel: controller.isEmailValidated.value ? AppStrings.update : AppStrings.submit,
      fontSize: fontSize16,
      textColor: Colors.white,
      showLoader: controller.isLoading.value,
    );
  }

  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  Widget resetPasswordFields() {
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
