import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget slider untuk pertanyaan numerik.
/// Dipakai untuk: jam pakai HP, menit sosmed, jam tidur, dll.
class QuestionSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit; // satuan: "jam", "menit", "kali", "hari"
  final String? minLabel;
  final String? maxLabel;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const QuestionSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
    this.minLabel,
    this.maxLabel,
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildValueDisplay(),
        const SizedBox(height: 12),
        _buildSlider(context),
        _buildLabels(),
      ],
    );
  }

  // ── Value Display ──────────────────────────────────────────────────────────

  Widget _buildValueDisplay() {
    final displayVal = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: activeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayVal,
            style: TextStyle(
              color: activeColor,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            unit,
            style: TextStyle(
              color: activeColor.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Slider ─────────────────────────────────────────────────────────────────

  Widget _buildSlider(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: activeColor.withValues(alpha: 0.15),
        thumbColor: activeColor,
        overlayColor: activeColor.withValues(alpha: 0.12),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 13),
        trackHeight: 6,
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  // ── Labels ─────────────────────────────────────────────────────────────────

  Widget _buildLabels() {
    if (minLabel == null && maxLabel == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            minLabel ?? '',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          Text(
            maxLabel ?? '',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
