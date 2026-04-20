import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../services/dashboard_service.dart';

// ── State ──────────────────────────────────────────────────────────────────────

enum DashboardStatus { initial, loading, success, error }

class DashboardState {
  final DashboardStatus status;
  final AnalyticsModel? analytics;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.analytics = null,
    this.errorMessage = null,
  });

  bool get isLoading => status == DashboardStatus.loading;
  bool get hasData => analytics != null;

  DashboardState copyWith({
    DashboardStatus? status,
    AnalyticsModel? analytics,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      analytics: analytics ?? this.analytics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────────

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardService _service;

  DashboardNotifier(this._service) : super(const DashboardState()) {
    // Auto-fetch saat pertama dibuka
    fetchAnalytics();
  }

  // ── Fetch analytics ────────────────────────────────────────────────────────
  Future<void> fetchAnalytics({bool useMock = true}) async {
    state = state.copyWith(status: DashboardStatus.loading, errorMessage: null);
    try {
      // Ganti getMockAnalytics() → getAnalytics() saat backend sudah siap
      final data = useMock
          ? await _service.getMockAnalytics()
          : await _service.getAnalytics();
      state = state.copyWith(status: DashboardStatus.success, analytics: data);
    } catch (e) {
      state = state.copyWith(
        status: DashboardStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refresh() => fetchAnalytics();
}

// ── Provider ───────────────────────────────────────────────────────────────────

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final service = ref.watch(dashboardServiceProvider);
      return DashboardNotifier(service);
    });

/// Shortcut — ambil data analytics langsung
final analyticsProvider = Provider<AnalyticsModel?>((ref) {
  return ref.watch(dashboardProvider).analytics;
});
