import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PerkembanganCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const PerkembanganCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [_buildIcon(), const SizedBox(width: 12), _buildText()],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.trending_up_rounded,
        color: AppColors.teal,
        size: 22,
      ),
    );
  }

  Widget _buildText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.teal,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.teal, fontSize: 12),
        ),
      ],
    );
  }
}
