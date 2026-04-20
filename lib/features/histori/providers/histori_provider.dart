import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';
import '../services/histori_service.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum HistoriStatus { initial, loading, success, empty, error }

class HistoriState {
  final HistoriStatus status;
  final List<MlResultModel> items;
  final String? errorMessage;

  const HistoriState({
    this.status = HistoriStatus.initial,
    this.items = const [],
    this.errorMessage = null,
  });

  bool get isLoading => status == HistoriStatus.loading;
  bool get isEmpty => status == HistoriStatus.empty || items.isEmpty;

  HistoriState copyWith({
    HistoriStatus? status,
    List<MlResultModel>? items,
    String? errorMessage,
  }) {
    return HistoriState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
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

    for (final item in items) {
      final key = '${monthNames[item.createdAt.month]} ${item.createdAt.year}';
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return grouped;
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class HistoriNotifier extends StateNotifier<HistoriState> {
  final HistoriService _service;

  HistoriNotifier(this._service) : super(const HistoriState()) {
    fetch();
  }

  // ── Fetch histori ──────────────────────────────────────────────────────────
  Future<void> fetch({bool useMock = true}) async {
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
  return HistoriNotifier(service);
});

/// Shortcut — cek apakah ada perkembangan positif (untuk banner)
final hasPerkembanganProvider = Provider<bool>((ref) {
  final items = ref.watch(historiProvider).items;
  if (items.length < 2) return false;
  // Bandingkan focus score 2 data terbaru
  return items[0].focusScore > items[1].focusScore;
});

/// Shortcut — persentase perubahan focus score terbaru vs sebelumnya
final focusChangeProvider = Provider<double>((ref) {
  final items = ref.watch(historiProvider).items;
  if (items.length < 2) return 0.0;
  final latest = items[0].focusScore;
  final prev = items[1].focusScore;
  if (prev == 0) return 0.0;
  return ((latest - prev) / prev) * 100;
});
