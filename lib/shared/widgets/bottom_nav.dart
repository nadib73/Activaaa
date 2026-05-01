import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Tipe tampilan bottom nav — gelap (dark bg) atau terang (white bg).
enum NavTheme { dark, light }

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final NavTheme navTheme;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.navTheme = NavTheme.dark,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = navTheme == NavTheme.dark;

    final bgColor = isDark ? AppColors.bgCard : AppColors.bgWhite;
    final borderColor = isDark ? AppColors.cardBorder : AppColors.lightBorder;
    final inactiveColor = isDark
        ? AppColors.textSecondary
        : Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (i) => _buildNavItem(
                index: i,
                icon: _navItems[i].$1,
                label: _navItems[i].$2,
                inactiveColor: inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color inactiveColor,
  }) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.teal : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.teal : inactiveColor,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _navItems = [
  (Icons.home_rounded, 'Beranda'),
  (Icons.assignment_outlined, 'Kuesioner'),
  (Icons.analytics_outlined, 'Laporan'),
  (Icons.show_chart_rounded, 'Grafik'),
  (Icons.person_rounded, 'Profil'),
];
