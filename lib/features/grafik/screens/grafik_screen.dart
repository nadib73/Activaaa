import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../widgets/v2_charts.dart';

class GrafikScreen extends ConsumerStatefulWidget {
  const GrafikScreen({super.key});

  @override
  ConsumerState<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends ConsumerState<GrafikScreen> {
  int _selectedPeriod = 0; // 0=7Hari, 1=Bulanan, 2=3Bulan
  static const _periods = ['7 Hari', 'Bulanan', '3 Bulan'];

  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardProvider);
    final analytics = dashState.analytics;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: analytics == null && dashState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildPeriodSelector(),
                            const SizedBox(height: 24),

                            // 1. Digital Dependence Trend (Line Chart)
                            _card(
                              title: 'Trend Skor Ketergantungan Digital',
                              child: SimpleLineChart(
                                values:
                                    analytics?.dailyTrend
                                        .map((t) => t.dependenceScore)
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: AppColors.teal,
                                maxValue: 100,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 2. Screen Time Trend (Line Chart)
                            _card(
                              title: 'Screen Time Trend (Jam/Hari)',
                              child: SimpleLineChart(
                                values:
                                    analytics?.dailyTrend
                                        .map((t) => t.deviceHours)
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: AppColors.blue,
                                maxValue: 15,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 3. Social Media Usage (Bar Chart)
                            _card(
                              title: 'Penggunaan Media Sosial (Menit)',
                              child: GenericBarChart(
                                values:
                                    analytics?.dailyTrend
                                        .map(
                                          (t) => t.socialMediaMins.toDouble(),
                                        )
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: AppColors.purple,
                                maxValue: 500,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 4. Sleep Tracking (Bar Chart)
                            _card(
                              title: 'Sleep Tracking (Jam Tidur)',
                              child: GenericBarChart(
                                values:
                                    analytics?.dailyTrend
                                        .map((t) => t.sleepHours)
                                        .toList() ??
                                    [],
                                labels:
                                    analytics?.dailyTrend
                                        .map((t) => t.shortDate)
                                        .toList() ??
                                    [],
                                color: Colors.indigo,
                                maxValue: 12,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // 5. Category Donut Chart
                            _card(
                              title: 'Frekuensi Kategori Dependensi',
                              child: DonutChartWidget(
                                low: analytics?.countLow ?? 0,
                                medium: analytics?.countMedium ?? 0,
                                high: analytics?.countHigh ?? 0,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
              ),
            ),
            BottomNav(
              currentIndex: 3,
              navTheme: NavTheme.light,
              onTap: (i) => _onNavTap(context, i),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    if (index == 3) return;
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
        break;
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Visualisasi Data',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Analisis detail aktivitas digital harianmu',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: List.generate(_periods.length, (i) => _buildPeriodItem(i)),
      ),
    );
  }

  Widget _buildPeriodItem(int i) {
    final isSelected = _selectedPeriod == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.bgDark : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            _periods[i],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade500,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
