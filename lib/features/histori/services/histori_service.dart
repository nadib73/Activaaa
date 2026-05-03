// histori_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../hasil_prediksi/models/confidence_model.dart'; // ✅ import baru
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
      final response = await _client.get(ApiEndpoints.surveys);
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
        userId: 'mock_001',
        questionnaireId: 'q8',
        digitalDependenceScore: 60,
        category: 'sedang',
        confidence: ConfidenceModel.fromJson(0.82), // ✅ fix
        penyebab: ['screen_time_tinggi'],
        rekomendasi: [
          const RecommendationItem(
            tag: 'social_media',
            isi: 'Kurangi social media 30 menit per hari',
          ),
        ],
        summary: 'Skor sedang — perhatikan media sosial.',
        aiModel: 'mock',
        weekGroup: '2026-W14',
        createdAt: DateTime(2025, 4, 7),
      ),
      MlResultModel(
        id: 'r7',
        userId: 'mock_001',
        questionnaireId: 'q7',
        digitalDependenceScore: 55,
        category: 'sedang',
        confidence: ConfidenceModel.fromJson(0.78), // ✅ fix
        penyebab: ['tidur_kurang'],
        rekomendasi: [
          const RecommendationItem(tag: 'sleep', isi: 'Tingkatkan jam tidur'),
        ],
        summary: 'Skor cukup — tidur perlu diperbaiki.',
        aiModel: 'mock',
        weekGroup: '2026-W13',
        createdAt: DateTime(2025, 4, 1),
      ),
      MlResultModel(
        id: 'r6',
        userId: 'mock_001',
        questionnaireId: 'q6',
        digitalDependenceScore: 58,
        category: 'sedang',
        confidence: ConfidenceModel.fromJson(0.80), // ✅ fix
        penyebab: ['kurang_olahraga'],
        rekomendasi: [
          const RecommendationItem(
            tag: 'exercise',
            isi: 'Olahraga 3x seminggu',
          ),
        ],
        summary: 'Skor sedang — aktivitas fisik kurang.',
        aiModel: 'mock',
        weekGroup: '2026-W12',
        createdAt: DateTime(2025, 3, 22),
      ),
      MlResultModel(
        id: 'r5',
        userId: 'mock_001',
        questionnaireId: 'q5',
        digitalDependenceScore: 35,
        category: 'rendah',
        confidence: ConfidenceModel.fromJson(0.85), // ✅ fix
        penyebab: [],
        rekomendasi: [
          const RecommendationItem(
            tag: 'general',
            isi: 'Pertahankan kebiasaan positif!',
          ),
        ],
        summary: 'Skor rendah — gaya hidup digital sudah baik.',
        aiModel: 'mock',
        weekGroup: '2026-W11',
        createdAt: DateTime(2025, 3, 15),
      ),
    ];
  }

  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
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
