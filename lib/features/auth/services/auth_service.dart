import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/local_storage.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(localStorageProvider);
  return AuthService(client, storage);
});

class AuthService {
  final ApiClient _client;
  final LocalStorage _storage;

  AuthService(this._client, this._storage);

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.login,
        data: {'email': email.trim().toLowerCase(), 'password': password},
      );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      final ttlMinutes = authResponse.expiresIn != null
          ? (authResponse.expiresIn! / 60).ceil()
          : 60;
      await _storage.saveToken(authResponse.token, ttlMinutes: ttlMinutes);
      await _storage.saveUserData(
        userId: authResponse.user.id,
        name: authResponse.user.name,
        email: authResponse.user.email,
      );
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<RegisterResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required int age,
    required String gender,
    required String educationLevel,
    required String region,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.register,
        data: {
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
          'password_confirmation': passwordConfirmation,
          'age': age,
          'gender': gender.toLowerCase(),
          'education_level': educationLevel,
          'region': region,
        },
      );
      final registerResponse = RegisterResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _storage.saveToken(registerResponse.token, ttlMinutes: 60);
      await _storage.saveUserData(
        userId: registerResponse.user.id,
        name: registerResponse.user.name,
        email: registerResponse.user.email,
      );
      return registerResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  /// JWT blacklist_enabled = true → token diinvalidate di server
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } on DioException catch (_) {
      // Tetap logout lokal meski request gagal
    } finally {
      await _storage.clearAll();
    }
  }

  // ── Get Profile ────────────────────────────────────────────────────────────
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.me);
      final data = response.data as Map<String, dynamic>;
      final userJson = data['data'] as Map<String, dynamic>? ?? data;
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  Future<void> forgotPassword(String email) async {
    try {
      await _client.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email.trim().toLowerCase()},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────
  Future<void> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email.trim().toLowerCase(), 'otp_code': otpCode.trim()},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Reset Password ─────────────────────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _client.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Mock Session ───────────────────────────────────────────────────────────
  Future<void> saveMockSession(UserModel user) async {
    await _storage.saveToken('mock_token_${user.id}', ttlMinutes: 60 * 24);
    await _storage.saveUserData(
      userId: user.id,
      name: user.name,
      email: user.email,
    );
  }

  // ── Check Login ────────────────────────────────────────────────────────────
  Future<bool> isLoggedIn() => _storage.isLoggedIn();

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
        return 'Email atau password salah.';
      case 403:
        return 'Akses ditolak.';
      case 404:
        return 'Endpoint tidak ditemukan.';
      case 410:
        return 'Kode OTP sudah expired, silakan minta ulang.';
      case 422:
        return 'Data yang dimasukkan tidak valid.';
      case 429:
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 500:
        return 'Server sedang bermasalah. Coba lagi nanti.';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return 'Koneksi timeout. Periksa internet kamu.';
        }
        if (e.type == DioExceptionType.connectionError) {
          return 'Tidak bisa terhubung ke server.';
        }
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
