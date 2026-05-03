import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BarChartWidget extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color barColor;

  const BarChartWidget({
    super.key,
    required this.values,
    required this.labels,
    this.barColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          return _buildBar(context, i);
        }),
      ),
    );
  }

  Widget _buildBar(BuildContext context, int index) {
    final value = values[index];
    final label = labels[index];
    
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: LayoutBuilder(builder: (context, constraints) {
                final height = constraints.maxHeight * (value / 10.0).clamp(0.1, 1.0);
                return Container(
                  width: 24,
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        barColor,
                        barColor.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                      bottom: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: barColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Label
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
