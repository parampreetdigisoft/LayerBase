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
import '../../utils/base/widgets/base_text_button.dart';
import '../../utils/base/widgets/base_text_field.dart';

class LoginScreen extends GetWidget<LoginViewModel> {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.authBackgroundImage),
            fit: BoxFit.cover,
          )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                                Center(
                                  child: const BaseText(
                                    text: AppStrings.signInToYourAccount,
                                    fontSize: fontSize30,
                                    textColor: Colors.black,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: spacerSize50),
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
                                loginBtn(context),
      
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
                                  ],
                                ),
                                const SizedBox(height: spacerSize16),
      
                                BaseTextButton(
                                  onPressed: () {
                                    controller.sharedPreferences!.setBool(AppKeys.isGuestLoggedIn,true);
                                    Navigator.pushNamed(
                                      context,
                                      Routes.homeScreen,
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
          ],
        ),
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

  loginBtn(BuildContext context) {
    return SizedBox(
      width: spacerSize250,
      child: Obx(
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
          fontSize: fontSize18,
          textColor: Colors.white,
          showLoader: controller.isLoading.value,
        ),
      ),
    );
  }

  isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  navigateToGallery(var value) {
    if (value != null) {
      /*   Navigator.pushNamedAndRemoveUntil(
        Get.context!,
        Routes.imageGallery,
            (Route<dynamic> route) => false,
      );*/
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
