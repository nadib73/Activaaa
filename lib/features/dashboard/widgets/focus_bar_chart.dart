import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FocusBarChart extends StatelessWidget {
  const FocusBarChart({super.key});

  static const _days = ['S', 'M', 'S', 'R', 'K', 'J', 'S'];
  static const _heights = [0.55, 0.60, 0.58, 0.65, 0.72, 0.80, 0.92];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_days.length, (i) => _buildBar(i)),
      ),
    );
  }

  Widget _buildBar(int i) {
    final isLast = i == _days.length - 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 80 * _heights[i],
          decoration: BoxDecoration(
            color: isLast
                ? AppColors.teal
                : AppColors.teal.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _days[i],
          style: TextStyle(
            color: isLast ? AppColors.teal : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isLast ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
