import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';
import '../services/histori_service.dart';
import '../../auth/providers/auth_provider.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum HistoriStatus { initial, loading, success, empty, error }
enum HistoriSortOption { terbaru, terlama, skorTertinggi, skorTerendah }
enum HistoriFilterCategory { semua, rendah, sedang, tinggi }

class HistoriState {
  final HistoriStatus status;
  final List<MlResultModel> items;
  final String? errorMessage;
  final HistoriSortOption sortOption;
  final HistoriFilterCategory filterCategory;

  const HistoriState({
    this.status = HistoriStatus.initial,
    this.items = const [],
    this.errorMessage,
    this.sortOption = HistoriSortOption.terbaru,
    this.filterCategory = HistoriFilterCategory.semua,
  });

  bool get isLoading => status == HistoriStatus.loading;
  bool get isEmpty => status == HistoriStatus.empty || items.isEmpty;

  HistoriState copyWith({
    HistoriStatus? status,
    List<MlResultModel>? items,
    String? errorMessage,
    HistoriSortOption? sortOption,
    HistoriFilterCategory? filterCategory,
  }) {
    return HistoriState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
      sortOption: sortOption ?? this.sortOption,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }

  // ── Group by bulan untuk tampilan list ────────────────────────────────────
  // Contoh output: { 'APRIL 2025': [...], 'MARET 2025': [...] }
  Map<String, List<MlResultModel>> get groupedByMonth {
    const monthNames = [
      '',
      'JANUARI',
      'FEBRUARI',
      'MARET',
      'APRIL',
      'MEI',
      'JUNI',
      'JULI',
      'AGUSTUS',
      'SEPTEMBER',
      'OKTOBER',
      'NOVEMBER',
      'DESEMBER',
    ];

    final Map<String, List<MlResultModel>> grouped = {};

    // 1. Filter
    var filteredItems = items.where((item) {
      if (filterCategory == HistoriFilterCategory.semua) return true;
      final cat = item.category.toLowerCase();
      if (filterCategory == HistoriFilterCategory.rendah && cat == 'rendah') return true;
      if (filterCategory == HistoriFilterCategory.sedang && cat == 'sedang') return true;
      if (filterCategory == HistoriFilterCategory.tinggi && cat == 'tinggi') return true;
      return false;
    }).toList();

    // 2. Sort
    filteredItems.sort((a, b) {
      switch (sortOption) {
        case HistoriSortOption.terbaru:
          return b.createdAt.compareTo(a.createdAt);
        case HistoriSortOption.terlama:
          return a.createdAt.compareTo(b.createdAt);
        case HistoriSortOption.skorTertinggi:
          return b.digitalDependenceScore.compareTo(a.digitalDependenceScore);
        case HistoriSortOption.skorTerendah:
          return a.digitalDependenceScore.compareTo(b.digitalDependenceScore);
      }
    });

    for (final item in filteredItems) {
      final key = '${monthNames[item.createdAt.month]} ${item.createdAt.year}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class HistoriNotifier extends StateNotifier<HistoriState> {
  final HistoriService _service;
  final String? _currentUserId;

  HistoriNotifier(this._service, [this._currentUserId]) : super(const HistoriState()) {
    fetch();
  }

  // ── Fetch histori ──────────────────────────────────────────────────────────
  Future<void> fetch({bool useMock = false}) async {
    state = state.copyWith(status: HistoriStatus.loading, errorMessage: null);
    try {
      // Ganti getMockHistory() → getHistory() saat backend siap
      final items = useMock
          ? await _service.getMockHistory()
          : await _service.getHistory();

      state = state.copyWith(
        status: items.isEmpty ? HistoriStatus.empty : HistoriStatus.success,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        status: HistoriStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refresh() => fetch();

  // ── Filter & Sort ──────────────────────────────────────────────────────────
  void setSortOption(HistoriSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  void setFilterCategory(HistoriFilterCategory category) {
    state = state.copyWith(filterCategory: category);
  }

  // ── Tambah item baru setelah submit kuesioner ──────────────────────────────
  // Dipanggil setelah kuesioner berhasil → tidak perlu fetch ulang
  void addItem(MlResultModel result) {
    state = state.copyWith(
      status: HistoriStatus.success,
      items: [result, ...state.items],
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────────────

final historiProvider = StateNotifierProvider<HistoriNotifier, HistoriState>((
  ref,
) {
  final service = ref.watch(historiServiceProvider);
  final user = ref.watch(currentUserProvider);
  return HistoriNotifier(service, user?.id);
});

/// Shortcut — cek apakah ada perkembangan positif (untuk banner)
/// Untuk dependensi: skor turun = positif (membaik)
final hasPerkembanganProvider = Provider<bool>((ref) {
  final items = ref.watch(historiProvider).items;
  if (items.length < 2) return false;
  // Bandingkan dependence score 2 data terbaru — turun = membaik
  return items[0].digitalDependenceScore < items[1].digitalDependenceScore;
});

/// Shortcut — persentase perubahan dependence score terbaru vs sebelumnya
final dependenceChangeProvider = Provider<double>((ref) {
  final items = ref.watch(historiProvider).items;
  if (items.length < 2) return 0.0;
  final latest = items[0].digitalDependenceScore;
  final prev = items[1].digitalDependenceScore;
  if (prev == 0) return 0.0;
  return ((latest - prev) / prev) * 100;
});
