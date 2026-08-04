import 'package:flutter/material.dart';
import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';

import '../../constants/app_assets.dart';

class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    this.buttonLabel,
    this.fontSize = 14,
    this.onPressed,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.showLoader = false,
  });

  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showLoader ? null : onPressed,
      child: Container(
        padding: EdgeInsets.only(
          left: spacerSize18,
          right: spacerSize12,
          top: spacerSize10,
          bottom: spacerSize12,
        ),
        decoration: BoxDecoration(
          color: AppColors.deepPurple,
          borderRadius: BorderRadius.circular(spacerSize16),
        ),
        child: showLoader
            ? Container(
          height: spacerSize20,
          width: spacerSize20,
          margin: EdgeInsets.only(right: spacerSize8),
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: spacerSize2),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: spacerSize8,
          children: [
            Text(
              buttonLabel ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: fontSize ?? fontSize14),
            ),
            Container(
              margin: EdgeInsets.only(top: spacerSize2),
              child: Image.asset(AppAssets.forwardIcon, height: spacerSize20),
            ),
          ],
        ),
      ),
    );
  }
}
