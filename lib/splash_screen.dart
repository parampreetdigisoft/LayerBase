import 'package:ecrumedia/routes.dart';
import 'package:ecrumedia/utils/app_assets.dart';
import 'package:ecrumedia/utils/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  _checkLoginStatus(BuildContext context) {

    Future.delayed(const Duration(seconds: 2));
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, Routes.editor);
    } else {
      Navigator.pushReplacementNamed(context, Routes.logIn);
    }
  }

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
}
