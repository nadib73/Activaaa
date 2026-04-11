import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RoleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            _buildRadioCircle(),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioCircle() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.white : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.circle, size: 12, color: AppColors.teal)
          : null,
    );
  }
}
