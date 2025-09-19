import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:layerbase/utils/routes.dart';

import '../../utils/base/widgets/base_shader_mask.dart';
import '../../utils/base/widgets/base_text.dart';
import '../../utils/constants/app_color.dart';
import '../../utils/constants/app_constants.dart';
import '../../utils/constants/app_keys.dart';
import '../../utils/constants/app_strings.dart';
import '../home_controller.dart';

class CloudFiles extends StatelessWidget {
  final HomeController controller;

  const CloudFiles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Visibility(
          visible: (controller.sharedPrefsService.getString(AppKeys.displayName) ?? "").isEmpty,
          replacement: Container(
            padding: EdgeInsets.all(spacerSize10),
            width: double.infinity,
            height: double.infinity,
            decoration: baseBoxDecoration(
              color: AppColors.lightBlack,
              radius: spacerSize10,
              borderColor: Colors.transparent,
            ),
            child: BaseText(
              text: AppStrings.noImageFound,
              fontSize: fontSize16,
              textColor: Colors.white,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(spacerSize10),
            width: double.infinity,
            decoration: baseBoxDecoration(
              color: AppColors.lightBlack,
              radius: spacerSize10,
              borderColor: Colors.transparent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.info, color: AppColors.antiqueWhite, size: spacerSize15),
                    const SizedBox(width: spacerSize5),
                    Expanded(
                      child: BaseText(
                        textAlign: TextAlign.center,
                        text: AppStrings.cloudStorageAccess,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.antiqueWhite,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.antiqueWhite),
                    children: [
                      const TextSpan(text: AppStrings.toAccessCloudStorageFiles),
                      TextSpan(
                        text: AppStrings.login,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: AppColors.lightPurple,
                          decorationColor: AppColors.lightPurple,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(Routes.logIn);
                          },
                      ),
                      const TextSpan(text: AppStrings.withYourEmailAccount),
                    ],
                  ),
                ),
                Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
