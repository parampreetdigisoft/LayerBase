import 'package:layerbase/base/dialogs/base_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:layerbase/base/widgets/base_text.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:layerbase/utils/constants/app_strings.dart';
import 'package:layerbase/utils/routes.dart';
import 'package:get/get.dart';

class BottomNavigationSheet extends StatelessWidget {
  const BottomNavigationSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null
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
    FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
      Get.context!,
      Routes.logIn,
          (Route<dynamic> route) => false,
    );
  }
}
