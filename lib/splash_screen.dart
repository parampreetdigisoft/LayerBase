import 'package:ecrumedia/utils/routes.dart';
import 'package:ecrumedia/utils/constants/app_assets.dart';
import 'package:ecrumedia/utils/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
        FirebaseAuth.instance.signOut();
      _checkLoginStatus(context);
    });
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(AppAssets.splashImage, fit: BoxFit.fill),
          ),
          Center(
            child: SizedBox(
              width: spacerSize500,
              child: Image.asset(AppAssets.appLogoWhite),
            ),
          ),
        ],
      ),
    );
  }

  _checkLoginStatus(BuildContext context) async {
    /*   SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    String? token = sharedPreference.getString(AppKeys.idToken);
    print('value of token $token');*/

    Future.delayed(const Duration(milliseconds: 1000  )).then((value) {
      User? user = FirebaseAuth.instance.currentUser;
      navigateToLogin(Get.context!, user);
    },);

  }

  navigateToLogin(BuildContext context, User? user) {
    if (user?.refreshToken != null) {
      Navigator.pushReplacementNamed(context, Routes.imageGallery);
    } else {
      Navigator.pushReplacementNamed(context, Routes.logIn);
    }
  }
}
