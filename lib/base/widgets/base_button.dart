import 'package:ecrumedia/base/widgets/base_text.dart';
import 'package:ecrumedia/utils/app_constants.dart';
import 'package:flutter/material.dart';

class BaseButton extends StatelessWidget {
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(
          vertical: spacerSize15,
          horizontal: spacerSize5,
        ),
        textStyle: TextStyle(fontSize: fontSize),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacerSize30),
        ),
        elevation: 5, // Add shadow for depth
      ),
      child: BaseText(
        text: buttonLabel ?? "",
        fontSize: fontSize,
        textColor: Colors.white,
      ),
    );
  }
}
