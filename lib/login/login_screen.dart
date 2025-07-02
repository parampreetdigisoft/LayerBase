import 'package:ecrumedia/base/widgets/base_button.dart';
import 'package:ecrumedia/base/widgets/base_text.dart';
import 'package:ecrumedia/base/widgets/base_text_button.dart';
import 'package:ecrumedia/base/widgets/base_text_field.dart';
import 'package:ecrumedia/login/login_view_model.dart';
import 'package:ecrumedia/utils/app_assets.dart';
import 'package:ecrumedia/utils/app_constants.dart';
import 'package:ecrumedia/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends GetWidget<LoginViewModel> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: spacerSize500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  appLogo(),
                  SizedBox(height: spacerSize40),
                  Center(
                    child: const BaseText(
                      textLabel: AppStrings.signInToYourAccount,
                      fontSize: fontSize22,
                      textColor: Colors.black,
                    ),
                  ),
                  SizedBox(height: spacerSize30),
                  // Email and Password Login
                  emailField(),

                  const SizedBox(height: spacerSize25),
                  passwordField(),
                  const SizedBox(height: spacerSize10),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: BaseText(
                      fontSize: fontSize14,
                      textLabel: AppStrings.forgotPassword,
                    ),
                  ),

                  const SizedBox(height: spacerSize25),
                  login(context),

                  const SizedBox(height: spacerSize16),

                  BaseTextButton(
                    onPressed: () {},
                    textLabel: AppStrings.dontHaveAccount,
                    fontSize: fontSize16,
                    backgroundColor: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).colorScheme.secondary,
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
                      CircleAvatar(
                        child: IconButton(
                          icon: Image.asset(
                            AppAssets.googleIcon,
                            fit: BoxFit.fill,
                          ),
                          onPressed: () {},
                          tooltip: AppStrings.signInWithGoogle,
                        ),
                      ),
                      const SizedBox(width: spacerSize25),
                      // Spacing between icons
                      CircleAvatar(
                        child: IconButton(
                          icon: Image.asset(
                            AppAssets.facebookIcon,
                            fit: BoxFit.fill,
                          ),
                          onPressed: () {},
                          tooltip: AppStrings.signInWithFacebook,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: spacerSize16),
                  BaseTextButton(
                    onPressed: () {},
                    textLabel: AppStrings.continueWithoutLogin,
                    fontSize: fontSize16,
                    textColor: Theme.of(context).primaryColor,
                  ),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  appLogo() {
    return SizedBox(child: Image.asset(AppAssets.appLogo, fit: BoxFit.fill));
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
        backgroundColor: Theme.of(context).primaryColor,
        buttonLabel: AppStrings.login,
        fontSize: fontSize18,
        textColor: Colors.white,
      ),
    );
  }
}
