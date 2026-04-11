import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../widgets/score_card.dart';
import '../widgets/focus_bar_chart.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildScoreCards(),
                    const SizedBox(height: 16),
                    _buildInsightCard(),
                    const SizedBox(height: 20),
                    _buildSectionLabel('TREN 7 HARI'),
                    const SizedBox(height: 14),
                    _buildFocusChartCard(),
                  ],
                ),
              ),
            ),
            BottomNav(currentIndex: 0, onTap: (i) => _onNavTap(context, i)),
          ],
        ),
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
        break;
    }
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Halo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 2),
            Text(
              'Rizky Pratama',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.teal,
          child: Text(
            'RP',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCards() {
    return Row(
      children: const [
        ScoreCard(label: 'Focus\nScore', value: '82', color: AppColors.teal),
        SizedBox(width: 10),
        ScoreCard(label: 'Produktivitas', value: '75', color: AppColors.amber),
        SizedBox(width: 10),
        ScoreCard(label: 'Dependensi', value: '60', color: AppColors.red),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insight minggu ini',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: 'Focus score kamu '),
                TextSpan(
                  text: 'naik 12%',
                  style: TextStyle(color: AppColors.tealLight),
                ),
                TextSpan(
                  text:
                      ' dibanding minggu lalu. Screen time turun 20 menit per hari.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildDependensiBadge(),
        ],
      ),
    );
  }

  Widget _buildDependensiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Dependensi Digital Tinggi',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFocusChartCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus Score',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+12%',
                  style: TextStyle(
                    color: AppColors.tealLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const FocusBarChart(),
        ],
      ),
    );
  }
}
