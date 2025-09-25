import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/authentication/login/login_view_model.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart';

import '../../utils/base/widgets/base_button.dart';
import '../../utils/base/widgets/base_form.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/base/widgets/base_text_field.dart';

class LoginScreen extends GetWidget<LoginViewModel> {
  const LoginScreen({super.key});

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
                      children: [
                        Expanded(flex: 3, child: SizedBox.shrink()),
                        BaseText(
                          text: AppStrings.signInToYourAccount,
                          textColor: AppColors.lightPurple,
                          fontSize: spacerSize40,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: spacerSize35),

                        emailField(),
                        SizedBox(height: spacerSize35),
                        Obx(() => passwordField()),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
                            onPressed: () {
                              Navigator.pushNamed(context, Routes.forgotPassword);
                            },
                            child: BaseText(
                              text: AppStrings.forgotPassword,
                              textColor: AppColors.greyColor,
                              fontSize: fontSize16,
                            ),
                          ),
                        ),
                        SizedBox(height: spacerSize20),

                        loginBtn(context),
                        SizedBox(height: spacerSize20),
                        doNotHaveAccount(context),
                        SizedBox(height: spacerSize20),
                        orText(),
                        SizedBox(height: spacerSize20),
                        googleAndGuestBtn(context),

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

  emailField() {
    return BaseTextField(
      controller: controller.emailController,
      hintText: AppStrings.email,
      prefixIcon: Icon(Icons.email_outlined, color: AppColors.lightPink, size: spacerSize20),
      validator: controller.emailValidator,
    );
  }

  passwordField() {
    return BaseTextField(
      controller: controller.passwordController,
      hintText: AppStrings.password,
      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.lightPink, size: spacerSize20),
      obscureText: controller.isPasswordObscure.value,
      validator: controller.passwordValidator,

      suffixIcon: Obx(
        () => IconButton(
          onPressed: () {
            controller.isPasswordObscure.value = !controller.isPasswordObscure.value;
          },
          icon: Icon(
            controller.isPasswordObscure.value ? Icons.visibility : Icons.visibility_off,
            color: AppColors.lightPink,
            size: spacerSize20,
          ),
        ),
      ),
    );
  }

  loginBtn(BuildContext context) {
    return Obx(
      () => BaseButton(
        onPressed: () {
          if (controller.formKey.currentState!.validate()) {
            if (defaultTargetPlatform == TargetPlatform.linux ||
                defaultTargetPlatform == TargetPlatform.windows) {
              controller.signInWithEmailRest(
                controller.emailController.text,
                controller.passwordController.text,
              );
            } else {
              controller.signInWithEmailAndPassword();
            }
          }
        },
        backgroundColor: AppColors.darkBlue,
        buttonLabel: AppStrings.login,
        fontSize: fontSize16,
        textColor: Colors.white,
        showLoader: controller.isLoading.value,
      ),
    );
  }

  doNotHaveAccount(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: AppStrings.dontHaveAccount,
        style: TextStyle(color: AppColors.greyColor, fontSize: fontSize16),
        children: [
          TextSpan(
            text: AppStrings.register,
            style: TextStyle(
              color: AppColors.lightPurple,
              fontSize: fontSize16,
              fontWeight: FontWeight.w500,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, Routes.signUp);
              },
          ),
        ],
      ),
    );
  }

  orText() {
    return Row(
      children: [
        Expanded(
          child: Image.asset(AppAssets.waveLine, fit: BoxFit.fill, width: spacerSize18),
        ),
        BaseText(text: AppStrings.or, textColor: AppColors.greyColor),
        Expanded(
          child: Image.asset(AppAssets.waveLine, fit: BoxFit.fill, width: spacerSize18),
        ),
      ],
    );
  }

  googleAndGuestBtn(BuildContext context) {
    return Row(
      spacing: spacerSize5,
      children: [
        IconButton(
          style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),

          onPressed: () {
            controller.sharedPreferences!.clear();
            defaultTargetPlatform == TargetPlatform.windows
                ? controller.signInWithGoogleWindow().then((value) {
                    navigateToHome(value);
                  })
                : controller.signInWithGoogle().then((value) {
                    navigateToHome(value);
                  });
          },
          tooltip: AppStrings.logInWithGoogle,
          icon: Container(
            padding: EdgeInsets.all(spacerSize12),
            decoration: BoxDecoration(
              color: AppColors.darkSlatePurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spacerSize20),
                bottomLeft: Radius.circular(spacerSize20),
                topRight: Radius.circular(spacerSize10),
                bottomRight: Radius.circular(spacerSize10),
              ),
            ),
            child: Row(
              spacing: spacerSize8,
              children: [
                Image.asset(AppAssets.googleIcon, height: spacerSize20, width: spacerSize20),
                Text(
                  AppStrings.logInWithGoogle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: fontSize14),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size(0, 0)),

          onPressed: () {
            controller.sharedPreferences!.setBool(AppKeys.isGuestLoggedIn, true);
            Navigator.pushNamed(context, Routes.homeScreen);
          },
          tooltip: AppStrings.continueAsAGuest,
          icon: Container(
            padding: EdgeInsets.symmetric(horizontal: spacerSize24, vertical: spacerSize12),
            decoration: BoxDecoration(
              color: AppColors.darkSlatePurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spacerSize10),
                bottomLeft: Radius.circular(spacerSize10),
                topRight: Radius.circular(spacerSize20),
                bottomRight: Radius.circular(spacerSize20),
              ),
            ),
            child: Text(
              AppStrings.continueAsAGuest,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: fontSize14),
            ),
          ),
        ),
      ],
    );
  }

  isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  navigateToHome(var value) {
    if (value != null) {
      Navigator.pushNamedAndRemoveUntil(
        Get.context!,
        Routes.homeScreen,
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushReplacementNamed(Get.context!, Routes.logIn);
    }
  }
}
