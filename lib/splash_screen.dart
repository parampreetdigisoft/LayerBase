import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/constants/app_assets.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:layerbase/utils/shared_prefs_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkLoginStatus(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(AppAssets.splashImage, fit: BoxFit.fill),
          ),
          Center(
            child: SizedBox(width: spacerSize350, child: Image.asset(AppAssets.appLogo)),
          ),
        ],
      ),
    );
  }

  void checkLoginStatus(BuildContext context) {
    SharedPrefsService sharedPreference = SharedPrefsService.instance;
    bool? isGuestLoggedIn = sharedPreference.getBool(AppKeys.isGuestLoggedIn);
    bool? isUserLoggedIn = sharedPreference.getString(AppKeys.idToken)!.isNotEmpty;
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      User? user =
          defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.windows
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

  void navigateToLogin(
    BuildContext context,
    User? user, {
    bool isGuestLoggedIn = false,
    bool isLoggedIn = false,
  }) {
    if (user != null || isGuestLoggedIn || isLoggedIn) {
      Navigator.pushReplacementNamed(context, Routes.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, Routes.logIn);
    }
  }
}
