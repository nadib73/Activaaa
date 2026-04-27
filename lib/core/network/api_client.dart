import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_endpoints.dart';
import '../storage/local_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ApiClient(storage);
});

/// Base HTTP client menggunakan Dio.
/// Fitur:
/// - Auto inject JWT token ke setiap request
/// - Auto refresh token saat 401 (token expired, TTL 60 menit dari jwt.php)
/// - Auto logout jika refresh juga gagal
class ApiClient {
  final LocalStorage _storage;
  late final Dio _dio;

  // Flag untuk mencegah infinite loop saat refresh gagal
  bool _isRefreshing = false;

  ApiClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: ApiEndpoints.connectTimeout),
        receiveTimeout: const Duration(seconds: ApiEndpoints.receiveTimeout),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage, _dio, this),
      _LogInterceptor(),
    ]);
  }

  // ── HTTP Methods ───────────────────────────────────────────────────────────

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return _dio.get(path, queryParameters: queryParams);
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}

// ── Auth Interceptor ──────────────────────────────────────────────────────────
/// - Inject JWT token ke header setiap request
/// - Saat dapat 401: coba refresh token (jwt.php: ttl=60, refresh_ttl=20160)
/// - Jika refresh berhasil: retry request original
/// - Jika refresh gagal: clear storage → user perlu login ulang
class _AuthInterceptor extends Interceptor {
  final LocalStorage _storage;
  final Dio _dio;
  final ApiClient _client;

  _AuthInterceptor(this._storage, this._dio, this._client);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Hanya handle 401 — token expired (jwt ttl = 60 menit)
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Cegah loop: jika sedang refresh atau ini request refresh/login
    final path = err.requestOptions.path;
    if (_client._isRefreshing ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/login') ||
        path.contains('/auth/register')) {
      // Refresh gagal → clear semua data → user harus login ulang
      await _storage.clearAll();
      handler.next(err);
      return;
    }

    // Coba refresh token
    _client._isRefreshing = true;
    try {
      final refreshResponse = await _dio.post(
        ApiEndpoints.refresh,
        options: Options(
          headers: {'Authorization': 'Bearer ${await _storage.getToken()}'},
        ),
      );

      final newToken = refreshResponse.data['data']?['token']?.toString();

      if (newToken != null && newToken.isNotEmpty) {
        // Simpan token baru
        await _storage.saveToken(newToken);

        // Retry request original dengan token baru
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer $newToken';

        final retryResponse = await _dio.fetch(retryOptions);
        handler.resolve(retryResponse);
      } else {
        // Token baru tidak valid → logout
        await _storage.clearAll();
        handler.next(err);
      }
    } catch (_) {
      // Refresh gagal → logout
      await _storage.clearAll();
      handler.next(err);
    } finally {
      _client._isRefreshing = false;
    }
  }
}

// ── Log Interceptor ───────────────────────────────────────────────────────────
/// Print log di console saat development
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─ REQUEST ─────────────────────────────');
    print('│ ${options.method} ${options.uri}');
    if (options.data != null) print('│ Body: ${options.data}');
    print('└───────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─ RESPONSE ────────────────────────────');
    print('│ Status : ${response.statusCode}');
    print('│ Data   : ${response.data}');
    print('└───────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─ ERROR ───────────────────────────────');
    print('│ ${err.response?.statusCode} ${err.message}');
    print('│ Response: ${err.response?.data}');
    print('└───────────────────────────────────────');
    handler.next(err);
  }
}
