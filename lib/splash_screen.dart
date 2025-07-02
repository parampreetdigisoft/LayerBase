import 'package:ecrumedia/routes.dart';
import 'package:ecrumedia/utils/app_assets.dart';
import 'package:ecrumedia/utils/app_constants.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, Routes.logIn);
      });
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
            child: ScaleTransition(

              child: SizedBox(
                width: spacerSize500,
                child: Image.asset(AppAssets.appLogoWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
