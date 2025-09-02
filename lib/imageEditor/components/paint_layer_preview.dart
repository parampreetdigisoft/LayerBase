import 'package:flutter/cupertino.dart';

class PaintLayerPreview extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  PaintLayerPreview({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(PaintLayerPreview oldDelegate) => true;
}