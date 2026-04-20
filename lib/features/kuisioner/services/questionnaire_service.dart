import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/questionnaire_model.dart';

final questionnaireServiceProvider = Provider<QuestionnaireService>((ref) {
  final client = ref.watch(apiClientProvider);
  return QuestionnaireService(client);
});

class QuestionnaireService {
  final ApiClient _client;

  QuestionnaireService(this._client);

  // ── Submit Survey ──────────────────────────────────────────────────────────
  /// POST /api/surveys  (butuh JWT token)
  /// Laravel akan otomatis trigger Flask ML setelah menerima data ini
  Future<Map<String, dynamic>> submit(QuestionnaireModel data) async {
    try {
      final response = await _client.post(
        ApiEndpoints.surveys,
        data: data.toJson(),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Get Latest Survey ──────────────────────────────────────────────────────
  /// GET /api/surveys/latest
  Future<Map<String, dynamic>> getLatest() async {
    try {
      final response = await _client.get(ApiEndpoints.latestSurvey);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Error Handler ──────────────────────────────────────────────────────────
  String _handleError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) return data['message'].toString();
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final first = errors.values.first;
        return first is List ? first.first.toString() : first.toString();
      }
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Sesi habis. Silakan login ulang.';
      case 422:
        return 'Data kuesioner tidak valid. Periksa kembali.';
      case 500:
        return 'Server sedang bermasalah. Coba lagi nanti.';
      default:
        if (e.type == DioExceptionType.connectionError) {
          return 'Tidak bisa terhubung ke server.';
        }
        return 'Terjadi kesalahan saat mengirim kuesioner.';
    }
  }
}
