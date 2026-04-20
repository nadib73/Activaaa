import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget skala 1–10 untuk pertanyaan kondisi mental.
/// Dipakai untuk: sleep_quality, anxiety_score, depression_score,
/// stress_level, happiness_score.
class QuestionScalePicker extends StatelessWidget {
  final int value; // nilai saat ini (1–10)
  final int min;
  final int max;
  final String? lowLabel; // label ujung kiri, misal "Sangat Buruk"
  final String? highLabel; // label ujung kanan, misal "Sangat Baik"
  final Color activeColor;
  final ValueChanged<int> onChanged;

  const QuestionScalePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
    this.lowLabel,
    this.highLabel,
    this.activeColor = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildScaleRow(), const SizedBox(height: 10), _buildLabels()],
    );
  }

  // ── Scale Row ──────────────────────────────────────────────────────────────

  Widget _buildScaleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(max - min + 1, (i) {
        final number = min + i;
        final isSelected = number == value;
        final color = _colorForValue(number);

        return GestureDetector(
          onTap: () => onChanged(number),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 30,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : color.withValues(alpha: 0.25),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Labels ─────────────────────────────────────────────────────────────────

  Widget _buildLabels() {
    if (lowLabel == null && highLabel == null) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          lowLabel ?? '',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
        Text(
          highLabel ?? '',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
        ),
      ],
    );
  }

  // ── Color berdasarkan nilai ────────────────────────────────────────────────
  // Gradasi warna: merah (rendah) → kuning (sedang) → hijau (tinggi)
  // Untuk happiness & sleep_quality (nilai tinggi = bagus)
  // Untuk anxiety, depression, stress (nilai rendah = bagus) → dibalik di screen

  Color _colorForValue(int val) {
    if (val <= 3) return AppColors.red;
    if (val <= 6) return AppColors.amber;
    return AppColors.green;
  }
}
