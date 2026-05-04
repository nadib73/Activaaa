// lib/features/hasil_prediksi/services/result_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/confidence_model.dart'; // ✅ import baru
import '../models/ml_result_model.dart';

final resultServiceProvider = Provider<ResultService>((ref) {
  final client = ref.watch(apiClientProvider);
  return ResultService(client);
});

class ResultService {
  final ApiClient _client;

  ResultService(this._client);

  // ── Get Hasil Terbaru ──────────────────────────────────────────────────────
  Future<MlResultModel> getLatestResult() async {
    try {
      final response = await _client.get(ApiEndpoints.latestSurvey);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw 'Belum ada hasil prediksi. Isi kuesioner terlebih dahulu.';
      }
      // Response Laravel: { questionnaire: {...}, ml_result: {...} }
      // MlResultModel.fromJson sudah handle nested ml_result + ai_analysis
      final mlJson = data['ml_result'] as Map<String, dynamic>?;
      if (mlJson == null) {
        throw 'Belum ada hasil prediksi. Isi kuesioner terlebih dahulu.';
      }
      return MlResultModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Get Semua Histori ──────────────────────────────────────────────────────
  Future<List<MlResultModel>> getHistory() async {
    try {
      final response = await _client.get(ApiEndpoints.surveys);
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
      userId: 'mock_001',
      questionnaireId: 'mock_q1',
      digitalDependenceScore: 60,
      category: 'sedang',
      confidence: ConfidenceModel.fromJson(0.82), // ✅ fix
      penyebab: ['screen_time_tinggi', 'tidur_kurang'],
      rekomendasi: [
        const RecommendationItem(
          tag: 'social_media',
          isi: 'Kurangi penggunaan media sosial 30 menit per hari',
        ),
        const RecommendationItem(
          tag: 'sleep',
          isi: 'Tidur minimal 7 jam setiap malam',
        ),
        const RecommendationItem(
          tag: 'exercise',
          isi: 'Lakukan olahraga ringan 3x seminggu',
        ),
      ],
      pembukaan: '',
      highRiskFlag: 0,
      summary:
          'Ketergantungan digital kamu pada level sedang. '
          'Perhatikan waktu layar dan kualitas tidur.',
      aiModel: 'mock',
      weekGroup: '2026-W17',
      createdAt: DateTime.now(),
    );
  }

  Future<List<MlResultModel>> getMockHistory() async {
    await Future.delayed(const Duration(milliseconds: 800));
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
        pembukaan: '',
        highRiskFlag: 0,
        summary: 'Skor sedang — perlu perhatian pada media sosial.',
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
        pembukaan: '',
        highRiskFlag: 0,
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
        pembukaan: '',
        highRiskFlag: 0,
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
        pembukaan: '',
        highRiskFlag: 0,
        summary: 'Skor rendah — gaya hidup digital sudah baik.',
        aiModel: 'mock',
        weekGroup: '2026-W11',
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
