import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/ml_result_model.dart';

final resultServiceProvider = Provider<ResultService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ResultService(client);
});

class ResultService {
  final ApiClient _client;

  ResultService(this._client);

  // ── Get Hasil Terbaru ──────────────────────────────────────────────────────
  /// GET /api/prediksi/latest
  /// Response: { success, data: { id, focus_score, ..., risk_level,
  ///             recommendations, questionnaire, created_at } }
  Future<MlResultModel> getLatestResult() async {
    try {
      final response = await _client.get(ApiEndpoints.latestPrediksi);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw 'Belum ada hasil prediksi. Isi kuesioner terlebih dahulu.';
      }
      return MlResultModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Get Semua Histori ──────────────────────────────────────────────────────
  /// GET /api/prediksi
  /// Response: { success, data: [ ...formatResult() ] }
  Future<List<MlResultModel>> getHistory() async {
    try {
      final response = await _client.get(ApiEndpoints.prediksi);
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List? ?? [];
      return list
          .map((e) => MlResultModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Mock Data ──────────────────────────────────────────────────────────────

  Future<MlResultModel> getMockLatestResult() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MlResultModel(
      id: 'mock_r1',
      userId: 'mock_user',
      questionnaireId: 'mock_q1',
      focusScore: 0.82,
      productivityScore: 75,
      digitalDependenceScore: 60,
      highRiskFlag: true,
      riskLevel: 'Sedang',
      recommendations: [
        'Kurangi penggunaan media sosial 30 menit per hari',
        'Tidur minimal 7 jam setiap malam',
        'Lakukan olahraga ringan 3x seminggu',
      ],
      createdAt: DateTime.now(),
    );
  }

  Future<List<MlResultModel>> getMockHistory() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      MlResultModel(
        id: 'r8',
        userId: 'u1',
        questionnaireId: 'q8',
        focusScore: 0.82,
        productivityScore: 75,
        digitalDependenceScore: 60,
        highRiskFlag: true,
        riskLevel: 'Tinggi',
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
        riskLevel: 'Sedang',
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
        riskLevel: 'Sedang',
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
        riskLevel: 'Rendah',
        recommendations: ['Kurangi notifikasi HP'],
        createdAt: DateTime(2025, 3, 15),
      ),
    ];
  }

  // ── Error Handler ──────────────────────────────────────────────────────────
  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Sesi habis. Silakan login ulang.';
      case 404:
        return 'Belum ada hasil prediksi. Isi kuesioner terlebih dahulu.';
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
