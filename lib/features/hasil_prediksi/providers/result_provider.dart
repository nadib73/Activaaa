import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ml_result_model.dart';
import '../services/result_service.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum ResultStatus { initial, loading, success, empty, error }

class ResultState {
  final ResultStatus status;
  final MlResultModel? latestResult;
  final String? errorMessage;

  const ResultState({
    this.status = ResultStatus.initial,
    this.latestResult,
    this.errorMessage,
  });

  bool get isLoading => status == ResultStatus.loading;
  bool get hasResult => latestResult != null;

  ResultState copyWith({
    ResultStatus? status,
    MlResultModel? latestResult,
    String? errorMessage,
  }) {
    return ResultState(
      status: status ?? this.status,
      latestResult: latestResult ?? this.latestResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class ResultNotifier extends StateNotifier<ResultState> {
  final ResultService _service;

  ResultNotifier(this._service) : super(const ResultState());

  // ── Fetch hasil terbaru ────────────────────────────────────────────────────
  Future<void> fetchLatest({bool useMock = false}) async {
    state = state.copyWith(status: ResultStatus.loading);
    try {
      final result = useMock
          ? await _service.getMockLatestResult()
          : await _service.getLatestResult();
      state = state.copyWith(
        status: ResultStatus.success,
        latestResult: result,
      );
    } catch (e) {
      final msg = e.toString();
      // 404 → belum ada hasil, bukan error
      if (msg.contains('Belum ada hasil')) {
        state = state.copyWith(status: ResultStatus.empty);
      } else {
        state = state.copyWith(status: ResultStatus.error, errorMessage: msg);
      }
    }
  }

  // ── Set hasil setelah submit kuesioner ─────────────────────────────────────
  // Dipanggil setelah kuesioner berhasil disubmit
  // agar tidak perlu fetch ulang
  void setResult(MlResultModel result) {
    state = state.copyWith(status: ResultStatus.success, latestResult: result);
  }

  void reset() => state = const ResultState();
}

// ── Provider ───────────────────────────────────────────────────────────────────

final resultProvider = StateNotifierProvider<ResultNotifier, ResultState>((
  ref,
) {
  final service = ref.watch(resultServiceProvider);
  return ResultNotifier(service);
});

// ── Histori Provider (FutureProvider) ─────────────────────────────────────────
// Menggunakan FutureProvider karena histori hanya perlu di-fetch sekali

final historyProvider = FutureProvider<List<MlResultModel>>((ref) async {
  final service = ref.watch(resultServiceProvider);
  // Ganti getMockHistory() → getHistory() saat backend sudah siap
  return service.getMockHistory();
});
