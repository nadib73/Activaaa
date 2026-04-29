import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/analisis_data.dart';

class AnalisisCard extends StatelessWidget {
  final AnalisisData data;
  final VoidCallback? onTap;

  const AnalisisCard({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildDate(),
            const SizedBox(width: 14),
            _buildDivider(),
            const SizedBox(width: 14),
            Expanded(child: _buildContent()),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDisabled,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Date ───────────────────────────────────────────────────────────────────

  Widget _buildDate() {
    return SizedBox(
      width: 38,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            data.day,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.month,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 48, color: AppColors.lightBorder);
  }

  // ── Content ────────────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analisis #${data.number}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        _buildBadges(),
      ],
    );
  }

  Widget _buildBadges() {
    final isHighRisk = data.category.toLowerCase() == 'tinggi';
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _scoreBadge(
          'Dep ${data.dep}',
          isHighRisk ? AppColors.red : AppColors.amber,
        ),
        _scoreBadge(
          data.category.isNotEmpty
              ? data.category[0].toUpperCase() + data.category.substring(1)
              : 'N/A',
          isHighRisk ? AppColors.red : AppColors.teal,
        ),
        if (data.note != null && data.noteColor != null)
          _scoreBadge(data.note!, data.noteColor!),
      ],
    );
  }

  Widget _scoreBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
