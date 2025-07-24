import 'dart:async';

import 'package:Layerbase/utils/constants/app_keys.dart';
import 'package:Layerbase/utils/constants/app_strings.dart';
import 'package:Layerbase/utils/routes.dart' show Routes;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants/app_constants.dart';

class LoginViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final formKey = GlobalKey<FormState>();
  SharedPreferences? sharedPreferences;
  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
    super.onInit();
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<UserCredential?> signInWithGoogle() async {
    sharedPreferences!.clear();
    isLoading.value = true;
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );
      sharedPreferences!.setString(AppKeys.idToken, googleAuth.idToken ?? "");

      var data = await FirebaseAuth.instance.signInWithCredential(credential);
      return data;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.message);
      BaseSnackBar.show(
        title: AppStrings.error,
        message: e.message ?? AppStrings.googleSignInFailed,
      );
      return null;
    } catch (e) {
      debugPrint(e.toString());
      BaseSnackBar.show(
        title: AppStrings.error,
        message: "${AppStrings.googleSignInFailed}: $e",
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    sharedPreferences!.clear();
    isLoading.value = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
      sharedPreferences!.setString(
        AppKeys.idToken,
        userCredential.user!.refreshToken.toString(),
      );

      Navigator.pushReplacementNamed(Get.context!, Routes.imageGallery);
    } on FirebaseAuthException catch (exception) {
      if (exception.code == AppKeys.userNotFound) {
        BaseSnackBar.show(
          title: AppStrings.validate,
          message: AppStrings.noUserFound,
        );
      } else if (exception.code == AppKeys.wrongPassword) {
        BaseSnackBar.show(
          title: AppStrings.validate,
          message: AppStrings.wrongPasswordEntered,
        );
      } else {
        BaseSnackBar.show(
          title: AppStrings.error,
          message: '${exception.message}',
        );

        BaseSnackBar.show(
          title: AppStrings.validate,
          message: '${exception.message}',
        );
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential?> logInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        final data = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        sharedPreferences!.setString(
          AppKeys.idToken,
          result.accessToken!.tokenString.toString(),
        );

        return data;
      } else {
        debugPrint(result.message);
        return null;
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return null;
    }
  }

  forgotPassword(BuildContext context) {
    Navigator.pushNamed(context, Routes.forgotPassword);
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    scrollController.dispose();
  }
}
