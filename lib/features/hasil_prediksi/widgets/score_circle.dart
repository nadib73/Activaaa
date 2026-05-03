import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ScoreCircle extends StatelessWidget {
  final String score;
  final String label;
  final Color color;
  final double percent;

  final double size;
  final double fontSize;

  const ScoreCircle({
    super.key,
    required this.score,
    required this.label,
    required this.color,
    required this.percent,
    this.size = 80,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: percent,
                strokeWidth: size * 0.08,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Center(
                child: Text(
                  score,
                  style: TextStyle(
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
