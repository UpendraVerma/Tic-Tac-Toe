import 'package:flutter/material.dart';

class WinLinePainter extends CustomPainter {
  final List<int> pattern;
  WinLinePainter(this.pattern);

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern.length != 3) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    Offset getOffset(int index) {
      double cellSize = size.width / 3;
      double x = (index % 3) * cellSize + cellSize / 2;
      double y = (index ~/ 3) * cellSize + cellSize / 2;
      return Offset(x, y);
    }

    Offset p1 = getOffset(pattern.first);
    Offset p2 = getOffset(pattern.last);

    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
