import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget skala angka untuk pertanyaan kondisi mental.
/// Menerima value bertipe num (int atau double).
/// onChanged mengembalikan int.
///
/// [invertColor] = false (default):
///   nilai rendah = merah, nilai tinggi = hijau
///   → dipakai untuk happiness (tinggi = bagus)
///
/// [invertColor] = true:
///   nilai rendah = hijau, nilai tinggi = merah
///   → dipakai untuk anxiety, depresi, stres (tinggi = buruk)
class QuestionScalePicker extends StatelessWidget {
  final num value;
  final int min;
  final int max;
  final String? lowLabel;
  final String? highLabel;
  final bool invertColor;
  final ValueChanged<int> onChanged;

  const QuestionScalePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 10,
    this.lowLabel,
    this.highLabel,
    this.invertColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [_buildScaleRow(), const SizedBox(height: 10), _buildLabels()],
    );
  }

  Widget _buildScaleRow() {
    final selectedInt = value.round();
    final total = max - min + 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(total, (i) {
        final number = min + i;
        final isSelected = number == selectedInt;
        final color = _colorForValue(number);

        return GestureDetector(
          onTap: () => onChanged(number),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: _boxWidth(total),
            height: 44,
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
                  fontSize: total > 10 ? 12 : 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLabels() {
    if (lowLabel == null && highLabel == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
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
      ),
    );
  }

  // ── Lebar kotak menyesuaikan jumlah item ──────────────────────────────────
  double _boxWidth(int total) {
    if (total <= 5) return 56;
    if (total <= 10) return 30;
    return 24;
  }

  // ── Warna berdasarkan posisi & mode ───────────────────────────────────────
  Color _colorForValue(int val) {
    final total = max - min + 1;
    final position = val - min; // 0-based

    // Bagi jadi 3 zona: rendah / sedang / tinggi
    final lowEnd = (total * 0.33).floor();
    final highEnd = (total * 0.67).floor();

    final isLow = position < lowEnd;
    final isHigh = position >= highEnd;

    if (invertColor) {
      // Tinggi = buruk (anxiety, depresi, stres)
      if (isHigh) return AppColors.red;
      if (isLow) return AppColors.green;
      return AppColors.amber;
    } else {
      // Tinggi = bagus (happiness)
      if (isHigh) return AppColors.green;
      if (isLow) return AppColors.red;
      return AppColors.amber;
    }
  }
}
