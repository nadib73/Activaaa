import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../widgets/stats_row.dart';
import '../widgets/setting_item.dart';
import '../widgets/setting_item_toggle.dart';
import '../../histori/screens/histori_screen.dart';
import '../../grafik/screens/grafik_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _notifikasiEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StatsRow(),
                            const SizedBox(height: 24),
                            _buildPengaturanSection(),
                            const SizedBox(height: 20),
                            _buildKeluarButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
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
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
        break;
    }
  }

  // ── Profile Header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 14),
          const Text(
            'Rizky Pratama',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'rizky@gmail.com',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 14),
          _buildTags(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 76,
      height: 76,
      decoration: const BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'RP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildTags() {
    const tags = ['21 tahun', 'Mahasiswa', 'Asia', 'S1'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: tags.map((tag) => _buildTag(tag)).toList(),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Pengaturan Section ─────────────────────────────────────────────────────

  Widget _buildPengaturanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PENGATURAN',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              SettingItem(
                icon: Icons.person_outline_rounded,
                iconBg: AppColors.tealOverlay,
                iconColor: AppColors.teal,
                title: 'Data Diri',
                subtitle: 'Edit profil & informasi',
                onTap: () {},
              ),
              SettingItemToggle(
                icon: Icons.notifications_outlined,
                iconBg: AppColors.tealOverlay,
                iconColor: AppColors.teal,
                title: 'Notifikasi',
                subtitle: 'Pengingat kuesioner',
                value: _notifikasiEnabled,
                onChanged: (v) => setState(() => _notifikasiEnabled = v),
              ),
              SettingItem(
                icon: Icons.add_box_outlined,
                iconBg: AppColors.amberOverlay,
                iconColor: AppColors.amber,
                title: 'Ekspor Data',
                subtitle: 'Unduh hasil analisis',
                onTap: () {},
              ),
              SettingItem(
                icon: Icons.info_outline_rounded,
                iconBg: const Color(0xFFF1F5F9),
                iconColor: AppColors.textMuted,
                title: 'Tentang Aplikasi',
                subtitle: 'v1.0.0 · DigitalLife Analyzer',
                onTap: () {},
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Keluar Button ──────────────────────────────────────────────────────────

  Widget _buildKeluarButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _showKeluarDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red.withValues(alpha: 0.12),
          foregroundColor: AppColors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Keluar dari Akun',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showKeluarDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Keluar dari Akun?',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Kamu yakin ingin keluar dari akun ini?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
