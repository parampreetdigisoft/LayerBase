import 'package:Layerbase/utils/constants/app_color.dart';
import 'package:Layerbase/utils/constants/app_constants.dart';
import 'package:Layerbase/utils/constants/app_strings.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:Layerbase/utils/routes.dart';

class CloudStorageAccessTooltip extends StatelessWidget {
  const CloudStorageAccessTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: spacerSize250,
          padding: const EdgeInsets.all(spacerSize16),
          decoration: BoxDecoration(
            color: AppColors.dodgerBlue,
            borderRadius: BorderRadius.circular(spacerSize12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info,
                    color: Colors.white,
                    size: spacerSize15,
                  ),
                  const SizedBox(width: spacerSize5),
                  Expanded(
                    child: const Text(
                      AppStrings.cloudStorageAccess,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: spacerSize4),
                  GestureDetector(
                    child: Icon(Icons.close, size: spacerSize15),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white),
                  children: [
                    const TextSpan(text: AppStrings.toAccessCloudStorageFiles),
                    TextSpan(
                      text: AppStrings.login,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // First, pop the dialog
                          Navigator.pop(context);
                          // Then, navigate back to the previous screen (assuming it's a login screen)
                          // Replace '/login' with the actual route name of your login screen if different
                          Navigator.popUntil(
                            context,
                            (route) => route.settings.name == Routes.logIn,
                          );
                        },
                    ),
                    const TextSpan(text: AppStrings.withYourEmailAccount),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bubble arrow
        Positioned(
          top: -spacerSize10,
          left: spacerSize20,
          child: CustomPaint(
            size: const Size(spacerSize20, spacerSize10),
            painter: _TooltipArrowPainter(color: AppColors.dodgerBlue),
          ),
        ),
      ],
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  final Color color;

  _TooltipArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TooltipArrowPainter oldDelegate) => false;
}
