import 'package:flutter/material.dart';
import 'package:layerbase/utils/constants/app_constants.dart';

import '../../constants/app_color.dart';

class GradientShaderMask extends StatelessWidget {
  final Widget child;

  const GradientShaderMask({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [AppColors.violet, AppColors.brightCyan, AppColors.antiqueWhite],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: child,
    );
  }
}

BoxDecoration baseBoxDecoration({
  double radius = spacerSize2,
  bool? isGradiant = false,
  Color color = AppColors.darkJungleGreen,
  Color borderColor = AppColors.lightGrey,
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    color: color,
    border: Border.all(color: borderColor),
    gradient: isGradiant!
        ? LinearGradient(
            colors: [AppColors.violet, AppColors.brightCyan],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
        : null,
  );
}
