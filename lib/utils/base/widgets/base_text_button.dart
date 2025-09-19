import 'package:layerbase/utils/constants/app_constants.dart';
import 'package:flutter/material.dart';

class BaseTextButton extends StatelessWidget {
  const BaseTextButton({
    super.key,
    this.onPressed,
    this.textLabel,
    this.fontSize,
    this.textColor,
    this.backgroundColor,
  });

  final VoidCallback? onPressed;
  final String? textLabel;
  final double? fontSize;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: backgroundColor,
        textStyle: const TextStyle(fontSize: fontSize16),
      ),
      child: Text(textLabel ?? "", style: TextStyle(color: textColor)),
    );
  }
}
