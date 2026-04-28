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
  /// POST /api/auth/login
  /// Request: { email, password }
  /// Response: {
  ///   success: true,
  ///   message: "Login berhasil",
  ///   data: {
  ///     token: "eyJ...",
  ///     token_type: "bearer",
  ///     expires_in: 86400,
  ///     user: { ...UserModel }
  ///   }
  /// }
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

      // Validasi token format (JWT harus 3 parts dipisah dengan dot)
      if (authResponse.token.isEmpty) {
        throw Exception('Token kosong dari server. Cek respons API.');
      }
      final tokenParts = authResponse.token.split('.');
      if (tokenParts.length != 3) {
        throw Exception(
          'Token JWT tidak valid (${tokenParts.length} parts, harusnya 3). '
          'Periksa format token dari Laravel auth middleware.',
        );
      }

      // Simpan token & data user
      await _storage.saveToken(authResponse.token);
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
  /// POST /api/auth/register
  /// Request: { name, email, password, password_confirmation, gender, age, region, education_level }
  /// Response: {
  ///   success: true,
  ///   message: "Registrasi berhasil",
  ///   data: {
  ///     user: { ...UserModel },
  ///     token: "eyJ..."
  ///   }
  /// }
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
          // Laravel menerima lowercase sesuai validation 'in:male,female,other'
          'gender': gender.toLowerCase(),
          'education_level': educationLevel,
          'region': region,
        },
      );

      final registerResponse = RegisterResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Validasi token format (JWT harus 3 parts dipisah dengan dot)
      if (registerResponse.token.isEmpty) {
        throw Exception('Token kosong dari server. Cek respons API.');
      }
      final tokenParts = registerResponse.token.split('.');
      if (tokenParts.length != 3) {
        throw Exception(
          'Token JWT tidak valid (${tokenParts.length} parts, harusnya 3). '
          'Periksa format token dari Laravel auth middleware.',
        );
      }

      // Simpan token & data user
      await _storage.saveToken(registerResponse.token);
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
  /// POST /api/auth/logout (butuh JWT token)
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout);
    } on DioException catch (_) {
      // Tetap lanjut logout lokal meski request gagal
    } finally {
      await _storage.clearAll();
    }
  }

  // ── Get Profile ────────────────────────────────────────────────────────────
  /// GET /api/auth/me (butuh JWT token)
  /// Response: { success, data: { user object } }
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.get(ApiEndpoints.me);
      final data = response.data as Map<String, dynamic>;

      // Response: { success: true, data: { ...user } }
      final userJson =
          data['data'] as Map<String, dynamic>? ?? data as Map<String, dynamic>;

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────────────
  /// POST /api/auth/forgot-password
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
  /// POST /api/auth/verify-otp
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
  /// POST /api/auth/reset-password
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

  // ── Simpan sesi mock ───────────────────────────────────────────────────────
  Future<void> saveMockSession(UserModel user) async {
    await _storage.saveToken('mock_token_${user.id}');
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
      // Ambil message dari response Laravel
      if (data['message'] != null) {
        return data['message'].toString();
      }
      // Ambil dari errors (validation)
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final first = errors.values.first;
        return first is List ? first.first.toString() : first.toString();
      }
    }

    switch (e.response?.statusCode) {
      case 401:
        // Detail error dari Laravel JWT
        if (data is Map<String, dynamic> && data['message'] != null) {
          return 'Unauthorized: ${data['message']}';
        }
        return 'Email atau password salah.';
      case 403:
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'].toString();
        }
        return 'Akses ditolak.';
      case 404:
        if (data is Map<String, dynamic> && data['message'] != null) {
          return data['message'].toString();
        }
        return 'Permintaan tidak ditemukan.';
      case 410:
        return 'Kode OTP sudah expired. Silakan minta ulang.';
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
          return 'Tidak bisa terhubung ke server. '
              'Pastikan server Laravel sudah berjalan';
        }
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
