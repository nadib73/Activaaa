import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DependenceLineChart extends StatelessWidget {
  const DependenceLineChart({super.key});

  static const _points = [0.30, 0.35, 0.38, 0.42, 0.48, 0.55, 0.60];
  static const _labels = ['H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'H7'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: CustomPaint(
        painter: _DependencePainter(points: _points),
        child: Padding(
          padding: const EdgeInsets.only(top: 68),
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

class _DependencePainter extends CustomPainter {
  final List<double> points;

  const _DependencePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final chartH = size.height - 22;
    final stepX = size.width / (points.length - 1);

    final linePaint = Paint()
      ..color = AppColors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.red.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Build line path
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = chartH - (points[i] * chartH * 0.85);
      i == 0 ? linePath.moveTo(x, y) : linePath.lineTo(x, y);
    }

    // Build fill path (area under line)
    final fillPath = Path.from(linePath)
      ..lineTo((points.length - 1) * stepX, chartH)
      ..lineTo(0, chartH)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
