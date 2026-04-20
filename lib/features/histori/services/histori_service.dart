import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';

final historiServiceProvider = Provider<HistoriService>((ref) {
  final client = ref.watch(apiClientProvider);
  return HistoriService(client);
});

class HistoriService {
  final ApiClient _client;

  HistoriService(this._client);

  // ── Get Semua Histori ──────────────────────────────────────────────────────
  /// GET /api/prediksi
  Future<List<MlResultModel>> getHistory() async {
    try {
      final response = await _client.get(ApiEndpoints.prediksi);
      final data = response.data as Map<String, dynamic>;
      final list = data['data'] as List? ?? [];
      return list
          .map((e) => MlResultModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Mock ───────────────────────────────────────────────────────────────────
  Future<List<MlResultModel>> getMockHistory() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      MlResultModel(
        id: 'r8',
        userId: 'u1',
        questionnaireId: 'q8',
        focusScore: 0.82,
        productivityScore: 75,
        digitalDependenceScore: 60,
        highRiskFlag: true,
        recommendations: ['Kurangi social media 30 menit per hari'],
        createdAt: DateTime(2025, 4, 7),
      ),
      MlResultModel(
        id: 'r7',
        userId: 'u1',
        questionnaireId: 'q7',
        focusScore: 0.78,
        productivityScore: 70,
        digitalDependenceScore: 55,
        highRiskFlag: false,
        recommendations: ['Tingkatkan jam tidur'],
        createdAt: DateTime(2025, 4, 1),
      ),
      MlResultModel(
        id: 'r6',
        userId: 'u1',
        questionnaireId: 'q6',
        focusScore: 0.74,
        productivityScore: 68,
        digitalDependenceScore: 58,
        highRiskFlag: false,
        recommendations: ['Olahraga 3x seminggu'],
        createdAt: DateTime(2025, 3, 22),
      ),
      MlResultModel(
        id: 'r5',
        userId: 'u1',
        questionnaireId: 'q5',
        focusScore: 0.70,
        productivityScore: 65,
        digitalDependenceScore: 50,
        highRiskFlag: false,
        recommendations: ['Kurangi notifikasi HP'],
        createdAt: DateTime(2025, 3, 15),
      ),
    ];
  }

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null)
      return data['message'].toString();
    switch (e.response?.statusCode) {
      case 401:
        return 'Sesi habis. Silakan login ulang.';
      case 404:
        return 'Belum ada histori prediksi.';
      case 500:
        return 'Server sedang bermasalah. Coba lagi nanti.';
      default:
        if (e.type == DioExceptionType.connectionError) {
          return 'Tidak bisa terhubung ke server.';
        }
        return 'Gagal mengambil histori.';
    }
  }
}
