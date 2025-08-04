import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:layerbase/utils/shared_prefs_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  _checkLoginStatus(BuildContext context) {
    SharedPrefsService sharedPreference = SharedPrefsService.instance;
    bool? isGuestLoggedIn = sharedPreference.getBool(AppKeys.isGuestLoggedIn);
    bool? isUserLoggedIn = sharedPreference
        .getString(AppKeys.idToken)!
        .isNotEmpty;
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      User? user = defaultTargetPlatform == TargetPlatform.linux
          ? null
          : FirebaseAuth.instance.currentUser;
      navigateToLogin(
        Get.context!,
        user,
        isGuestLoggedIn: isGuestLoggedIn ?? false,
        isLoggedIn: isUserLoggedIn,
      );
    });
  }

  navigateToLogin(
    BuildContext context,
    User? user, {
    bool isGuestLoggedIn = false,
    bool isLoggedIn = false,
  }) {
    if (user?.refreshToken != null || isGuestLoggedIn || isGuestLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.imageGallery);
    } else {
      Navigator.pushReplacementNamed(context, Routes.logIn);
    }
  }
}
