import 'package:layerbase/utils/constants/app_color.dart';
import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:flutter/material.dart';

/*class BaseButton extends StatelessWidget {
  const BaseButton({
    super.key,
    this.buttonLabel,
    this.fontSize = 18,
    this.onPressed,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
  });

  final String? buttonLabel;
  final VoidCallback? onPressed;
  final double? fontSize;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: spacerSize250,
        height: spacerSize50,
        decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.violet, AppColors.brightCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
          borderRadius: BorderRadius.circular(spacerSize30),
        ),
        alignment: Alignment.center,
        child: Text(
          buttonLabel!,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}*/
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
        width: spacerSize250,
        height: spacerSize50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.violet, AppColors.brightCyan],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(spacerSize30),
        ),
        alignment: Alignment.center,
        child: showLoader
            ? const SizedBox(
          width: spacerSize20,
          height: spacerSize20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: spacerSize2,
          ),
        )
            : Text(
          buttonLabel ?? "",
          style: TextStyle(
            color: textColor,
            fontSize: fontSize ?? fontSize14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

