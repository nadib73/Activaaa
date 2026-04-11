import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../widgets/score_circle.dart';
import '../widgets/trend_bar_chart.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../histori/screens/histori_screen.dart';
import '../../profil/screens/profil_screen.dart';

class HasilPrediksiScreen extends StatelessWidget {
  const HasilPrediksiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildScoreCircles(),
                    const SizedBox(height: 16),
                    _buildHighRiskBadge(),
                    const SizedBox(height: 20),
                    _buildRekomendasiCard(),
                    const SizedBox(height: 16),
                    _buildTrendCard(),
                    const SizedBox(height: 20),
                    _buildHistoriButton(context),
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
    return const Column(
      children: [
        Text(
          'Hasil Analisis',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'Rizky Pratama',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircles() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ScoreCircle(
          score: '82',
          label: 'Focus',
          color: AppColors.teal,
          percent: 0.82,
        ),
        ScoreCircle(
          score: '75',
          label: 'Produktif',
          color: AppColors.amber,
          percent: 0.75,
        ),
        ScoreCircle(
          score: '60',
          label: 'Dependensi',
          color: AppColors.red,
          percent: 0.60,
        ),
      ],
    );
  }

  Widget _buildHighRiskBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
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
          const SizedBox(width: 8),
          const Text(
            'High Risk — Dependensi Digital',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRekomendasiCard() {
    const items = [
      'Kurangi penggunaan media sosial 30 menit per hari',
      'Tidur minimal 7 jam setiap malam',
      'Lakukan olahraga ringan 3x seminggu',
    ];

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
          const Row(
            children: [
              Icon(Icons.star_rounded, color: AppColors.teal, size: 18),
              SizedBox(width: 8),
              Text(
                'Rekomendasi Personal',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((text) => _buildRekomendasiItem(text)),
        ],
      ),
    );
  }

  Widget _buildRekomendasiItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Digital Dependence\nTrend',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tinggi',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const TrendBarChart(),
        ],
      ),
    );
  }

  Widget _buildHistoriButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoriScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgCard,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Lihat Histori Lengkap',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
