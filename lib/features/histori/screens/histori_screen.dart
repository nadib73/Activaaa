import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../models/analisis_data.dart';
import '../widgets/analisis_card.dart';
import '../widgets/perkembangan_card.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

class HistoriScreen extends StatelessWidget {
  const HistoriScreen({super.key});

  // ── Dummy Data ─────────────────────────────────────────────────────────────

  static const _april = [
    AnalisisData(
      number: 8,
      day: '07',
      month: 'APR',
      focus: 82,
      prod: 75,
      dep: 60,
      depHigh: true,
      note: 'Focus naik 5%',
      noteColor: AppColors.teal,
    ),
    AnalisisData(
      number: 7,
      day: '01',
      month: 'APR',
      focus: 78,
      prod: 70,
      dep: 55,
      depHigh: false,
      note: 'Prod naik 3%',
      noteColor: AppColors.teal,
    ),
  ];

  static const _maret = [
    AnalisisData(
      number: 6,
      day: '22',
      month: 'MAR',
      focus: 74,
      prod: 68,
      dep: 58,
      depHigh: false,
      note: 'Dep naik 8%',
      noteColor: AppColors.amber,
    ),
    AnalisisData(
      number: 5,
      day: '15',
      month: 'MAR',
      focus: 70,
      prod: 65,
      dep: 50,
      depHigh: false,
    ),
  ];

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PerkembanganCard(
                      title: 'Perkembangan Diri',
                      subtitle: 'Focus naik 15% dalam 30 hari terakhir',
                    ),
                    const SizedBox(height: 24),
                    _buildMonthSection('APRIL 2025', _april),
                    const SizedBox(height: 24),
                    _buildMonthSection('MARET 2025', _maret),
                    const SizedBox(height: 8),
                    _buildLihatSemua(),
                  ],
                ),
              ),
            ),
            BottomNav(
              currentIndex: 1,
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.bgLight,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histori Analisis',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Semua hasil kuesioner kamu',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: const Text(
        'Filter',
        style: TextStyle(
          color: AppColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMonthSection(String label, List<AnalisisData> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => AnalisisCard(data: item, onTap: () {})),
      ],
    );
  }

  Widget _buildLihatSemua() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Lihat semua histori ›',
          style: TextStyle(
            color: AppColors.teal,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
