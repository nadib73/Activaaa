import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  static const _focusPoints = [0.55, 0.52, 0.60, 0.58, 0.65, 0.70, 0.75];
  static const _prodPoints = [0.42, 0.45, 0.43, 0.50, 0.52, 0.55, 0.58];
  static const _labels = ['M1', 'M2', 'M3', 'M4', 'M5', 'M6', 'M7'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: CustomPaint(
        painter: _LineChartPainter(
          focusPoints: _focusPoints,
          prodPoints: _prodPoints,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 110),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _labels
                .map(
                  (l) => Text(
                    l,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> focusPoints;
  final List<double> prodPoints;

  const _LineChartPainter({
    required this.focusPoints,
    required this.prodPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartH = size.height - 20;
    final stepX = size.width / (focusPoints.length - 1);

    _drawYAxisLabels(canvas, size, chartH);
    _drawLine(canvas, focusPoints, AppColors.teal, chartH, stepX);
    _drawLine(canvas, prodPoints, AppColors.blue, chartH, stepX);
  }

  void _drawYAxisLabels(Canvas canvas, Size size, double chartH) {
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final val in [100, 50, 0]) {
      labelPainter.text = TextSpan(
        text: '$val',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
      );
      labelPainter.layout();
      final y = chartH - (val / 100 * chartH * 0.7) - 10;
      labelPainter.paint(canvas, Offset(0, y - 6));
    }
  }

  void _drawLine(
    Canvas canvas,
    List<double> points,
    Color color,
    double chartH,
    double stepX,
  ) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotFillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw line path
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = chartH - (points[i] * chartH * 0.7) - 10;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, linePaint);

    // Draw dots
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = chartH - (points[i] * chartH * 0.7) - 10;
      canvas.drawCircle(Offset(x, y), 3.5, dotFillPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
