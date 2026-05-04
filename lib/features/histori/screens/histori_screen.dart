import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav.dart';
import '../providers/histori_provider.dart';
import '../widgets/analisis_card.dart';
import '../widgets/perkembangan_card.dart';
import '../models/analisis_data.dart';
import '../../grafik/screens/grafik_screen.dart';
import '../../profil/screens/profil_screen.dart';
import '../../kuisioner/screens/kuesioner_screen.dart';
import '../../laporan_perkembangan/screens/laporan_perkembangan_screen.dart';

class HistoriScreen extends ConsumerWidget {
  const HistoriScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historiProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      endDrawer: const _FilterDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(child: _buildBody(context, ref, state)),
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
    if (index == 1) return; // Sudah di tab Kuesioner (Histori)

    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LaporanPerkembanganScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GrafikScreen()),
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

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.bgLight,
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Histori Analisis',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Semua kuesioner',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          _buildFilterButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historiProvider);
    final hasActiveFilter = state.filterCategory != HistoriFilterCategory.semua || state.sortOption != HistoriSortOption.terbaru;
    
    return Builder(
      builder: (innerContext) {
        return GestureDetector(
          onTap: () {
            Scaffold.of(innerContext).openEndDrawer();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: hasActiveFilter ? AppColors.teal.withValues(alpha: 0.1) : AppColors.bgWhite,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: hasActiveFilter ? AppColors.teal : AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 16, color: hasActiveFilter ? AppColors.teal : AppColors.textDark),
                const SizedBox(width: 6),
                Text(
                  'Filter',
                  style: TextStyle(
                    color: hasActiveFilter ? AppColors.teal : AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, WidgetRef ref, HistoriState state) {
    // Loading state
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    // Error state
    if (state.status == HistoriStatus.error) {
      return _buildErrorState(ref, state.errorMessage ?? 'Terjadi kesalahan');
    }

    // Empty state
    if (state.isEmpty) {
      return _buildEmptyState();
    }

    // Success — tampilkan list
    final grouped = state.groupedByMonth;

    if (grouped.isEmpty && !state.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada hasil yang sesuai',
              style: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coba ubah filter atau urutan',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.teal,
      onRefresh: () => ref.read(historiProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perkembangan banner
            _buildPerkembanganBanner(ref),
            const SizedBox(height: 24),
            // List per bulan
            ...grouped.entries.map(
              (entry) => _buildMonthSection(entry.key, entry.value),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Perkembangan Banner ────────────────────────────────────────────────────

  Widget _buildPerkembanganBanner(WidgetRef ref) {
    final hasPerkembangan = ref.watch(hasPerkembanganProvider);
    final depChange = ref.watch(dependenceChangeProvider);

    if (!hasPerkembangan) return const SizedBox.shrink();

    // Untuk dependensi: turun = membaik
    final changeText = depChange < 0
        ? 'Dependensi turun ${depChange.abs().toStringAsFixed(0)}% — semakin membaik!'
        : 'Dependensi naik ${depChange.toStringAsFixed(0)}% — perlu perhatian';

    return PerkembanganCard(title: 'Perkembangan Diri', subtitle: changeText);
  }

  // ── Month Section ──────────────────────────────────────────────────────────

  Widget _buildMonthSection(String label, items) {
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
        ...items.map(
          (item) => AnalisisCard(
            data: AnalisisDataConverter.fromMlResult(item),
            onTap: () {},
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Belum ada histori',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Isi kuesioner untuk melihat hasil analisis',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────

  Widget _buildErrorState(WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.red,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => ref.read(historiProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _FilterDrawer extends ConsumerWidget {
  const _FilterDrawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historiProvider);
    final notifier = ref.read(historiProvider.notifier);

    return Drawer(
      backgroundColor: AppColors.bgWhite,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Urutkan & Filter',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Text('Urutkan Berdasarkan', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildSortChip('Terbaru', HistoriSortOption.terbaru, state, notifier),
                  _buildSortChip('Terlama', HistoriSortOption.terlama, state, notifier),
                  _buildSortChip('Skor Tertinggi', HistoriSortOption.skorTertinggi, state, notifier),
                  _buildSortChip('Skor Terendah', HistoriSortOption.skorTerendah, state, notifier),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Kategori', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterChip('Semua', HistoriFilterCategory.semua, state, notifier),
                  _buildFilterChip('Rendah', HistoriFilterCategory.rendah, state, notifier),
                  _buildFilterChip('Sedang', HistoriFilterCategory.sedang, state, notifier),
                  _buildFilterChip('Tinggi', HistoriFilterCategory.tinggi, state, notifier),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(String label, HistoriSortOption option, HistoriState state, HistoriNotifier notifier) {
    final isSelected = state.sortOption == option;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.teal,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
      backgroundColor: AppColors.bgLight,
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? AppColors.teal : AppColors.lightBorder)),
      onSelected: (selected) {
        if (selected) notifier.setSortOption(option);
      },
    );
  }

  Widget _buildFilterChip(String label, HistoriFilterCategory category, HistoriState state, HistoriNotifier notifier) {
    final isSelected = state.filterCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.blue,
      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
      backgroundColor: AppColors.bgLight,
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? AppColors.blue : AppColors.lightBorder)),
      onSelected: (selected) {
        if (selected) notifier.setFilterCategory(category);
      },
    );
  }
}
