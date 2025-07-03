import 'package:ecrumedia/routes.dart' show Routes;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginViewModel extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isPasswordObscure = true.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      var data = await FirebaseAuth.instance.signInWithCredential(credential);

      return data;
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Google sign-in failed");
      return null;
    } catch (e) {
      Get.snackbar("Error", "Google sign-in failed: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  forgotPassword(BuildContext context) {
    Navigator.pushNamed(context, Routes.forgotPassword);
  }
}
