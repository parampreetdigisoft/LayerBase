import 'package:ecrumedia/utils/constants/app_keys.dart';
import 'package:ecrumedia/utils/constants/app_strings.dart';
import 'package:ecrumedia/utils/routes.dart' show Routes;
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
      BaseSnackBar.show(
        title: AppStrings.error,
        message: e.message ?? AppStrings.googleSignInFailed,
      );
      return null;
    } catch (e) {
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
      Navigator.pushReplacementNamed(Get.context!, Routes.editor);
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


  Future<void> logInWithFacebook() async {
    try {
      // 1. Log in with Facebook
      final LoginResult result = await FacebookAuth.instance.login();
final OAuthCredential facebookauthCredential = FacebookAuthProvider.credential(result.accessToken!.tokenString);

      if (result.status == LoginStatus.success) {
        print(result.accessToken);
        // 2. Create a credential from the access token
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);

        // 3. Sign in to Firebase with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);

        // 4. (Optional) Get user data from Facebook
        final userData = await FacebookAuth.instance.getUserData();
        print(userData);
      } else {
        print(result.message);
      }
    } catch (e) {
      print(e);
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
