import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'dart:ui';
import '../widgets/score_card.dart';
import '../../histori/providers/histori_provider.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final user = ref.watch(currentUserProvider);
    final analytics = dashState.analytics;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: () => ref.read(dashboardProvider.notifier).refresh(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Loading state
                        if (dashState.isLoading && analytics == null)
                          _buildLoadingShimmer()
                        else ...[
                          _buildScoreCards(ref),
                          const SizedBox(height: 16),
                          _buildInsightCard(analytics),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            BottomNav(
              currentIndex: 0,
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
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KuesionerScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilScreen()),
        );
        break;
    }
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(user) {
    final name = user?.name ?? 'Pengguna';
    final initials = user?.initials ?? '?';

    // Greeting berdasarkan jam
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Selamat pagi,'
        : hour < 15
        ? 'Selamat siang,'
        : hour < 18
        ? 'Selamat sore,'
        : 'Selamat malam,';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.teal,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Score Cards ────────────────────────────────────────────────────────────

  Widget _buildScoreCards(WidgetRef ref) {
    final historiState = ref.watch(historiProvider);
    final hasData = historiState.items.isNotEmpty;
    final value = hasData ? historiState.items.first.digitalDependenceScore.round().toString() : '0';

    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            ScoreCard(
              label: 'Skor\nDependensi', 
              value: value, 
              color: hasData ? AppColors.red : AppColors.textMuted,
            ),
          ],
        ),
        if (!hasData)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: AppColors.bgDark.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        if (!hasData)
          const Text(
            'Silakan isi kuesioner\nuntuk melihat skor',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  // ── Insight Card ───────────────────────────────────────────────────────────

  Widget _buildInsightCard(analytics) {
    final insightText =
        analytics?.insightText ??
        'Isi kuesioner untuk melihat insight pertamamu.';
    final changeLabel = analytics?.dependenceChangeLabelFormatted ?? '';
    // Untuk dependensi: turun = positif (membaik)
    final isPositive = (analytics?.dependenceChangePercentage ?? 0) < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Insight minggu ini',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            insightText,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (changeLabel.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildChangeBadge(changeLabel, isPositive),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeBadge(String label, bool isPositive) {
    final color = isPositive ? AppColors.teal : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'Dependensi $label minggu ini',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }



  // ── Loading Shimmer ────────────────────────────────────────────────────────

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        Row(
          children: List.generate(
            3,
            (_) => Expanded(
              child: Container(
                height: 72,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
