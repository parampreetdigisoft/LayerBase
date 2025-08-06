import 'package:flutter/material.dart';

class BaseText extends StatelessWidget {
  const BaseText({
    super.key,
    this.fontSize,
    this.textColor=Colors.black,
    this.text = '',
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.left,
    this.onPressed,
  });

  final double? fontSize;
  final Color? textColor;
  final String text;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          text,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
