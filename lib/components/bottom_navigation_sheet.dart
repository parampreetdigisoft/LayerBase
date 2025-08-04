import 'package:flutter/foundation.dart';
import 'package:layerbase/base/dialogs/base_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:layerbase/base/widgets/base_text.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_keys.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/shared_prefs_service.dart';

class BottomNavigationSheet extends StatelessWidget {
  BottomNavigationSheet({super.key});

  SharedPrefsService? sharedPreferences = SharedPrefsService.instance;
  @override
  Widget build(BuildContext context) {
    return (defaultTargetPlatform == TargetPlatform.linux
            ? sharedPreferences!.getString(AppKeys.idToken)!.isNotEmpty
            : FirebaseAuth.instance.currentUser != null)
        ? TextButton.icon(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: fontSize16,
            ),
            label: BaseText(
              text: AppStrings.logOut,
              fontSize: fontSize14,
              textColor: Colors.white,
            ),
            onPressed: () {
              BaseDialog.showLogoutDialog(context, logout);
            },
          )
        : TextButton.icon(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
              size: fontSize16,
            ),
            label: BaseText(
              text: AppStrings.login,
              fontSize: fontSize14,
              textColor: Colors.white,
            ),
            onPressed: () => Navigator.pushNamed(context, Routes.logIn),
          );
  }

  void logout() {
    if (defaultTargetPlatform == TargetPlatform.linux) {
      sharedPreferences!.clear();
    } else {
      FirebaseAuth.instance.signOut();
    }
    Navigator.pushNamedAndRemoveUntil(
      Get.context!,
      Routes.logIn,
      (Route<dynamic> route) => false,
    );
  }
}
