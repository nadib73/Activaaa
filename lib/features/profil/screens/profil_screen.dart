import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/stats_row.dart';
import '../widgets/setting_item.dart';
import '../widgets/setting_item_toggle.dart';
import '../../histori/screens/histori_screen.dart';
import '../../grafik/screens/grafik_screen.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  bool _notifikasiEnabled = true;

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _onNavTap(int index) {
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

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> _onLogout() async {
    Navigator.pop(context); // tutup dialog

    // Tampilkan loading overlay selama proses logout
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.teal,
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Sedang keluar...',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    HapticFeedback.lightImpact();
    await ref.read(authProvider.notifier).logout();

    // Beri sedikit delay agar loading terasa natural
    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      // Navigasi ke LoginScreen & hapus seluruh stack
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (route) => false,
      );

      // Snackbar konfirmasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Berhasil keluar dari akun',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari provider
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildProfileHeader(user),
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
                            StatsRow(),
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
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile Header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader(user) {
    final name = user?.name ?? 'Pengguna';
    final email = user?.email ?? '-';
    final initials = user?.initials ?? '?';
    final age = user?.age.toString() ?? '-';
    final edu = user?.educationLevel ?? '-';
    final region = user?.region ?? '-';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          _buildAvatar(initials),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          _buildTags(age: age, edu: edu, region: region),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initials) {
    return Container(
      width: 76,
      height: 76,
      decoration: const BoxDecoration(
        color: AppColors.teal,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildTags({
    required String age,
    required String edu,
    required String region,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [_buildTag('$age tahun'), _buildTag(edu), _buildTag(region)],
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
        onPressed: _showKeluarDialog,
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
            onPressed: _onLogout,
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
