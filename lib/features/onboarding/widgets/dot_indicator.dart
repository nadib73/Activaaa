import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DotIndicator extends StatelessWidget {
  final int totalDots;
  final int activeIndex;

  const DotIndicator({
    super.key,
    required this.totalDots,
    required this.activeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (i) {
        final isActive = i == activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isActive ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.teal : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: isActive
                  ? null
                  : Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
          ),
        );
      }),
    );
  }
}
