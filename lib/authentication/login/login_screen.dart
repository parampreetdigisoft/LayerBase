import 'package:flutter/foundation.dart';
import 'package:layerbase/authentication/login/login_view_model.dart';
import 'package:layerbase/base/widgets/base_button.dart';
import 'package:layerbase/base/widgets/base_form.dart';
import 'package:layerbase/base/widgets/base_text.dart';
import 'package:layerbase/base/widgets/base_text_button.dart';
import 'package:layerbase/base/widgets/base_text_field.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
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
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: controller.scrollController,
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
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
                                  text: AppStrings.signInToYourAccount,
                                  fontSize: fontSize30,
                                  textColor: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: spacerSize60),
                              BaseForm(
                                formKey: controller.formKey,
                                child: Column(
                                  children: [
                                    emailField(),
                                    const SizedBox(height: spacerSize30),
                                    passwordField(),
                                  ],
                                ),
                              ),

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
                                    WidgetSpan(
                                      child: SizedBox(width: spacerSize5),
                                    ),
                                    TextSpan(
                                      text: AppStrings.register,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(
                                            context,
                                            Routes.signUp,
                                          );
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
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
                                      controller.sharedPreferences!.clear();
                                      defaultTargetPlatform ==
                                              TargetPlatform.windows
                                          ? controller
                                                .signInWithGoogleWindow()
                                                .then((value) {
                                                  navigateToGallery(value);
                                                })
                                          : controller.signInWithGoogle().then((
                                              value,
                                            ) {
                                              navigateToGallery(value);
                                            });
                                    },
                                    tooltip: AppStrings.signInWithGoogle,
                                  ),
                                  /*  const SizedBox(width: spacerSize25),
                                  // Spacing between icons
                                  IconButton(
                                    icon: Image.asset(
                                      AppAssets.facebookIcon,
                                      fit: BoxFit.fill,
                                      scale: 2,
                                    ),
                                    onPressed: () {
                                      controller.logInWithFacebook().then((
                                        value,
                                      ) {
                                        if(value!=null){
                                          Navigator.pushReplacementNamed(
                                            Get.context!,
                                            Routes.imageGallery,
                                          );
                                        }else{
                                          Navigator.pushReplacementNamed(
                                            Get.context!,
                                            Routes.logIn
                                          );
                                        }


                                      });
                                    },
                                    tooltip: AppStrings.signInWithFacebook,
                                  ),*/
                                ],
                              ),
                              const SizedBox(height: spacerSize16),

                              BaseTextButton(
                                onPressed: () {
                                  controller.sharedPreferences!.setBool(
                                    AppKeys.isGuestLoggedIn,
                                    true,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    Routes.imageGallery,
                                  );
                                },
                                textLabel: AppStrings.continueWithoutLogin,
                                fontSize: fontSize14,
                                textColor: AppColors.darkBlue,
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
          Positioned.fill(
            left: MediaQuery.of(context).size.width * .1,
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.darkBlue),
                );
              }
              return const SizedBox.shrink();
            }),
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
        fontSize: fontSize18,
        textColor: Colors.white,
      ),
    );
  }

  isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  navigateToGallery(var value) {
    if (value != null) {
      Navigator.pushReplacementNamed(Get.context!, Routes.imageGallery);
    } else {
      Navigator.pushReplacementNamed(Get.context!, Routes.logIn);
    }
    ;
  }
}
