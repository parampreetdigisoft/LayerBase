import 'package:ecrumedia/authentication/login/login_view_model.dart';
import 'package:ecrumedia/base/widgets/base_button.dart';
import 'package:ecrumedia/base/widgets/base_text.dart';
import 'package:ecrumedia/base/widgets/base_text_button.dart';
import 'package:ecrumedia/base/widgets/base_text_field.dart';
import 'package:ecrumedia/routes.dart';
import 'package:ecrumedia/utils/app_assets.dart';
import 'package:ecrumedia/utils/app_color.dart';
import 'package:ecrumedia/utils/app_constants.dart';
import 'package:ecrumedia/utils/app_strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetWidget<LoginViewModel> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            AppAssets.splashImage,
            fit: BoxFit.fill,
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
              child: SingleChildScrollView(
                child: Card(
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
                            MediaQuery.of(context).size.width * .5,
                          ),
                        SizedBox(height: spacerSize20),
                        Center(
                          child: const BaseText(
                            text: AppStrings.signInToYourAccount,
                            fontSize: fontSize30,
                            textColor: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: spacerSize60),
                        emailField(),

                        const SizedBox(height: spacerSize30),
                        passwordField(),
                        const SizedBox(height: spacerSize10),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: BaseText(
                            fontSize: fontSize14,
                            text: AppStrings.forgotPassword,
                            onPressed: () {
                              controller.forgotPassword(context);
                            },
                          ),
                        ),

                        const SizedBox(height: spacerSize45),
                        login(context),

                        const SizedBox(height: spacerSize25),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: AppStrings.dontHaveAccount),
                              WidgetSpan(child: SizedBox(width: spacerSize5)),
                              TextSpan(
                                text: AppStrings.register,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushNamed(context, Routes.signUp);
                                  },
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: spacerSize25),
                        const Row(
                          children: <Widget>[
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(AppStrings.or),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: spacerSize25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.asset(
                                AppAssets.googleIcon,
                                fit: BoxFit.fill,
                                scale: 2,
                              ),
                              onPressed: () {
                                controller.signInWithGoogle();
                              },
                              tooltip: AppStrings.signInWithGoogle,
                            ),
                            const SizedBox(width: spacerSize25),
                            // Spacing between icons
                            IconButton(
                              icon: Image.asset(
                                AppAssets.facebookIcon,
                                fit: BoxFit.fill,
                                scale: 2,
                              ),
                              onPressed: () {},
                              tooltip: AppStrings.signInWithFacebook,
                            ),
                          ],
                        ),
                        const SizedBox(height: spacerSize16),
                        BaseTextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.editor);
                          },
                          textLabel: AppStrings.continueWithoutLogin,
                          fontSize: fontSize14,
                          textColor: AppColors.darkBlue,
                        ),

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
    return BaseTextField(
      textEditingController: controller.emailController,
      hintText: AppStrings.enterYourEmail,
      labelText: AppStrings.email,
      prefixIcon: const Icon(Icons.email),
      keyboardType: TextInputType.emailAddress,
    );
  }

  passwordField() {
    return Obx(
      () => BaseTextField(
        textEditingController: controller.passwordController,
        labelText: AppStrings.password,
        hintText: AppStrings.enterYourPassword,
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

  login(BuildContext context) {
    return SizedBox(
      width: spacerSize250,
      child: BaseButton(
        onPressed: () {},
        backgroundColor: AppColors.darkBlue,
        buttonLabel: AppStrings.login,
        fontSize: fontSize18,
        textColor: Colors.white,
      ),
    );
  }

  isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}
