import 'package:ecrumedia/base/widgets/base_text.dart';
import 'package:ecrumedia/utils/app_color.dart';
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
      onPressed: () {
        //  controller.login();
      },
      style:
          ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 5),
            textStyle: TextStyle(fontSize: fontSize),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5, // Add shadow for depth
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.pressed)) {
                return AppColors.antiqueWhite;
              }
              return null;
            }),
          ),
      child: BaseText(
        textLabel: buttonLabel ?? "",
        fontSize: fontSize,
        textColor: Colors.white,
      ),
    );
  }
}
