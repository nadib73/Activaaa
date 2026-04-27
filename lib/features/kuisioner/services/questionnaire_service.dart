import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/questionnaire_model.dart';
import '../../hasil_prediksi/models/ml_result_model.dart';

final questionnaireServiceProvider = Provider<QuestionnaireService>((ref) {
  final client = ref.watch(apiClientProvider);
  return QuestionnaireService(client);
});

/// Hasil submit survey — bisa sukses penuh atau partial (ML gagal)
class SurveySubmitResult {
  final bool success;
  final String message;
  final bool mlSuccess; // false jika status 207 (ML gagal)
  final MlResultModel? mlResult; // null jika ML gagal

  const SurveySubmitResult({
    required this.success,
    required this.message,
    required this.mlSuccess,
    this.mlResult,
  });
}

class QuestionnaireService {
  final ApiClient _client;

  QuestionnaireService(this._client);

  // ── Submit Survey ──────────────────────────────────────────────────────────
  /// POST /api/surveys
  ///
  /// Response 201 → survey + ml_result berhasil
  /// Response 207 → survey tersimpan, tapi ML gagal
  Future<SurveySubmitResult> submit(QuestionnaireModel data) async {
    try {
      final response = await _client.post(
        ApiEndpoints.surveys,
        data: data.toJson(),
      );

      final body = response.data as Map<String, dynamic>;
      final statusCode = response.statusCode ?? 200;
      final resData = body['data'] as Map<String, dynamic>? ?? {};

      // 207 → survey tersimpan tapi ML gagal
      if (statusCode == 207 || body['success'] == false) {
        return SurveySubmitResult(
          success: false,
          message: body['message']?.toString() ?? 'Prediksi ML gagal',
          mlSuccess: false,
          mlResult: null,
        );
      }

      // 201 → survey + ML berhasil
      final mlJson = resData['ml_result'] as Map<String, dynamic>?;
      MlResultModel? mlResult;

      if (mlJson != null) {
        // Inject questionnaire_id dari questionnaire yang baru dibuat
        final qJson = resData['questionnaire'] as Map<String, dynamic>?;
        if (qJson != null && mlJson['questionnaire'] == null) {
          mlJson['questionnaire'] = qJson;
        }
        mlResult = MlResultModel.fromJson(mlJson);
      }

      return SurveySubmitResult(
        success: true,
        message: body['message']?.toString() ?? 'Survey berhasil disubmit',
        mlSuccess: mlResult != null,
        mlResult: mlResult,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Get Latest Survey ──────────────────────────────────────────────────────
  /// GET /api/surveys/latest
  Future<Map<String, dynamic>?> getLatest() async {
    try {
      final response = await _client.get(ApiEndpoints.latestSurvey);
      final body = response.data as Map<String, dynamic>;
      return body['data'] as Map<String, dynamic>?;
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
      case 503:
        return 'Layanan ML sedang tidak tersedia. Coba lagi nanti.';
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
