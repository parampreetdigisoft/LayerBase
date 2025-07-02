import 'package:flutter/material.dart';

class BaseText extends StatelessWidget {
  const BaseText({
    super.key,
    this.fontSize,
    this.textColor,
    this.textLabel = '',
  });

  final double? fontSize;
  final Color? textColor;
  final String textLabel;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: Text(
        textLabel,
        style: TextStyle(fontSize: fontSize, color: textColor),
      ),
    );
  }
}
