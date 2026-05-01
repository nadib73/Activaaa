import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../dashboard/models/analytics_model.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../histori/providers/histori_provider.dart';
import '../../grafik/screens/grafik_screen.dart';

class LaporanPerkembanganScreen extends ConsumerStatefulWidget {
  const LaporanPerkembanganScreen({super.key});

  @override
  ConsumerState<LaporanPerkembanganScreen> createState() => _LaporanPerkembanganScreenState();
}

class _LaporanPerkembanganScreenState extends ConsumerState<LaporanPerkembanganScreen> {
  @override
  Widget build(BuildContext context) {
    final historiState = ref.watch(historiProvider);
    final historyCount = historiState.items.length;
    final isLocked = historyCount < 14;

    final dashState = ref.watch(dashboardProvider);
    final analytics = dashState.analytics;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(analytics),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: analytics == null && dashState.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInsightHeader(analytics),
                                const SizedBox(height: 20),
                                _buildInsightCards(analytics),
                                const SizedBox(height: 24),
                                _buildComparisonChart(analytics),
                                const SizedBox(height: 24),
                                _buildPenyebabCard(analytics),
                                const SizedBox(height: 16),
                                _buildRekomendasiCard(analytics),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                  ),
                  if (isLocked) _buildLockOverlay(historyCount),
                ],
              ),
            ),
            BottomNav(
              currentIndex: 2,
              navTheme: NavTheme.light,
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AnalyticsModel? analytics) {
    String statusText = 'Memuat...';
    Color statusColor = AppColors.textSecondary;

    if (analytics != null) {
      statusText = analytics.dependenceChangeLabel.toUpperCase();
      if (statusText == 'MEMBAIK') {
        statusColor = AppColors.teal;
      } else if (statusText == 'MEMBURUK') {
        statusColor = AppColors.red;
      } else {
        statusColor = AppColors.amber;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Perkembangan',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                '7 hari terakhir = ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Text(
                statusText,
                style: TextStyle(color: statusColor, fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightHeader(AnalyticsModel? analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INSIGHT UTAMA',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Text(
          analytics?.insightText ?? 'Mengumpulkan data...',
          style: const TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
        ),
      ],
    );
  }

  // ── Insight Cards ──────────────────────────────────────────────────────────

  Widget _buildInsightCards(AnalyticsModel? data) {
    if (data == null) return const SizedBox();

    return Column(
      children: [
        _insightItem(
          icon: Icons.speed_rounded,
          color: AppColors.teal,
          title: 'Digital Dependence Score',
          desc: data.insightText,
        ),
        _insightItem(
          icon: Icons.timer_rounded,
          color: AppColors.blue,
          title: 'Screen Time',
          desc: data.screenTimeInsight,
        ),
        _insightItem(
          icon: Icons.share_rounded,
          color: AppColors.purple,
          title: 'Social Media Usage',
          desc: data.socialMediaInsight,
        ),
        _insightItem(
          icon: Icons.bedtime_rounded,
          color: Colors.indigo,
          title: 'Sleep',
          desc: data.sleepInsight,
        ),
        _insightItem(
          icon: Icons.psychology_rounded,
          color: AppColors.amber,
          title: 'Stress Level',
          desc: data.stressInsight,
        ),
      ],
    );
  }

  Widget _insightItem({required IconData icon, required Color color, required String title, required String desc}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Comparison Chart ───────────────────────────────────────────────────────

  Widget _buildComparisonChart(AnalyticsModel? data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PERBANDINGAN SKOR',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _chartBar('Minggu Lalu', data?.lastWeekAvgScore ?? 0, Colors.grey.shade400),
                  _chartBar('Minggu Ini', data?.thisWeekAvgScore ?? 0, AppColors.teal),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Rata-rata Skor Dependensi',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chartBar(String label, double value, Color color) {
    return Column(
      children: [
        Text(value.toStringAsFixed(0), style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 100,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: (value / 100).clamp(0.1, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Penyebab & Rekomendasi ─────────────────────────────────────────────────

  Widget _buildPenyebabCard(AnalyticsModel? data) {
    return _sectionCard(
      title: 'PENYEBAB UTAMA',
      icon: Icons.warning_amber_rounded,
      color: AppColors.red,
      items: data?.causes ?? [],
    );
  }

  Widget _buildRekomendasiCard(AnalyticsModel? data) {
    return _sectionCard(
      title: 'REKOMENDASI AI',
      icon: Icons.auto_awesome_rounded,
      color: AppColors.teal,
      items: data?.recommendations ?? [],
    );
  }

  Widget _sectionCard({required String title, required IconData icon, required Color color, required List<String> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Text('Belum ada data analisis.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── Locked UI ──────────────────────────────────────────────────────────────

  Widget _buildLockOverlay(int currentCount) {
    final remaining = 14 - currentCount;
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.white.withValues(alpha: 0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.lock_person_rounded, color: AppColors.teal, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Fitur Terkunci',
                  style: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Isi kuesioner $remaining x lagi untuk membuka fitur ini',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textDark.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: 200,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (currentCount / 14).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('$currentCount / 14 Kuesioner', style: const TextStyle(color: AppColors.teal, fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const KuesionerScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GrafikScreen()));
        break;
      case 4:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilScreen()));
        break;
    }
  }
}
