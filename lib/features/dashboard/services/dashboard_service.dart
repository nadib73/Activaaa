import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/analytics_model.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardService(client);
});

class DashboardService {
  final ApiClient _client;

  DashboardService(this._client);

  // ── Get Analytics ──────────────────────────────────────────────────────────
  /// GET /api/analytics/insight
  Future<AnalyticsModel> getAnalytics() async {
    try {
      final response = await _client.get(ApiEndpoints.analyticsInsight);
      final data = response.data as Map<String, dynamic>;
      return AnalyticsModel.fromJson(data['data'] ?? data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Mock ───────────────────────────────────────────────────────────────────
  Future<AnalyticsModel> getMockAnalytics() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return AnalyticsModel.mock();
  }

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null)
      return data['message'].toString();
    switch (e.response?.statusCode) {
      case 401:
        return 'Sesi habis. Silakan login ulang.';
      case 404:
        return 'Data analytics belum tersedia.';
      case 500:
        return 'Server sedang bermasalah. Coba lagi nanti.';
      default:
        if (e.type == DioExceptionType.connectionError) {
          return 'Tidak bisa terhubung ke server.';
        }
        return 'Terjadi kesalahan saat mengambil data.';
    }
  }
}
