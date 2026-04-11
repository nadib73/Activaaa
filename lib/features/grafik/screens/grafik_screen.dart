import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/dependence_line_chart.dart';
import '../widgets/screen_time_row.dart';
import '../../histori/screens/histori_screen.dart';
import '../../profil/screens/profil_screen.dart';

class GrafikScreen extends StatefulWidget {
  const GrafikScreen({super.key});

  @override
  State<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends State<GrafikScreen> {
  int _selectedPeriod = 1; // 0=7Hari, 1=Bulanan, 2=3Bulan

  static const _periods = ['7 Hari', 'Bulanan', '3 Bulan'];

  @override
  Widget build(BuildContext context) {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 20),
                      _buildFocusProdCard(),
                      const SizedBox(height: 16),
                      _buildScreenTimeCard(),
                      const SizedBox(height: 16),
                      _buildDependenceCard(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
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

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoriScreen()),
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

  // ── Header ─────────────────────────────────────────────────────────────────

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
            'Tren gaya hidup digital kamu',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Period Selector ────────────────────────────────────────────────────────

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

  // ── Cards ──────────────────────────────────────────────────────────────────

  Widget _buildFocusProdCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Focus vs\nProduktivitas',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              _badge('+12%', AppColors.teal),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _legend(AppColors.teal, 'Focus'),
              const SizedBox(width: 16),
              _legend(AppColors.blue, 'Produktivitas'),
            ],
          ),
          const SizedBox(height: 16),
          const LineChartWidget(),
        ],
      ),
    );
  }

  Widget _buildScreenTimeCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Screen Time\nHarian',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              _badge('Perlu\nDikurangi', AppColors.red, center: true),
            ],
          ),
          const SizedBox(height: 18),
          const ScreenTimeRow(
            label: 'Social',
            hours: 3.2,
            color: AppColors.red,
            ratio: 3.2 / 5,
          ),
          const ScreenTimeRow(
            label: 'Belajar',
            hours: 2.0,
            color: AppColors.teal,
            ratio: 2.0 / 5,
          ),
          const ScreenTimeRow(
            label: 'Hiburan',
            hours: 2.4,
            color: AppColors.amber,
            ratio: 2.4 / 5,
          ),
          ScreenTimeRow(
            label: 'Lainnya',
            hours: 0.9,
            color: Colors.grey.shade400,
            ratio: 0.9 / 5,
          ),
        ],
      ),
    );
  }

  Widget _buildDependenceCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Digital Dependence',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _badge('Sedang', AppColors.amber),
            ],
          ),
          const SizedBox(height: 16),
          const DependenceLineChart(),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _badge(String text, Color color, {bool center = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }
}
