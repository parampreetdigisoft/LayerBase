import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      /*FirebaseAuth.instance.signOut();*/

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
    SharedPreferences sharedPreference = await SharedPreferences.getInstance();
    bool? isGuestLoggedIn = sharedPreference.getBool(AppKeys.isGuestLoggedIn);
    var token = sharedPreference.getString(AppKeys.idToken) ?? "";
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      User? user = FirebaseAuth.instance.currentUser;
      navigateToLogin(
        Get.context!,
        user,
        token!,
        isGuestLoggedIn: isGuestLoggedIn ?? false,
      );
    });
  }

  navigateToLogin(
    BuildContext context,
    User? user,
    String token, {
    bool isGuestLoggedIn = false,
  }) {
    if (user?.refreshToken != null || isGuestLoggedIn || token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, Routes.imageGallery);
    } else {
      Navigator.pushReplacementNamed(context, Routes.logIn);
    }
  }
}
