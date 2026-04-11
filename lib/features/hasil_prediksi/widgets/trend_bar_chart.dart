import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TrendBarChart extends StatelessWidget {
  const TrendBarChart({super.key});

  static const _months = ['M1', 'M2', 'M3', 'M4'];
  static const _heights = [0.45, 0.55, 0.72, 0.90];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_months.length, (i) => _buildBar(i)),
      ),
    );
  }

  Widget _buildBar(int i) {
    final color = Color.lerp(
      const Color(0xFFFFCDD2),
      AppColors.red,
      _heights[i],
    )!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 44,
          height: 70 * _heights[i],
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _months[i],
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
