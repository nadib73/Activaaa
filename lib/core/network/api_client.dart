import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_endpoints.dart';
import '../storage/local_storage.dart';

/// Provider untuk ApiClient — bisa diakses dari mana saja via Riverpod.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(localStorageProvider);
  return ApiClient(storage);
});

/// Base HTTP client menggunakan Dio.
/// Otomatis menambahkan JWT token ke setiap request.
class ApiClient {
  final LocalStorage _storage;
  late final Dio _dio;

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

    _dio.interceptors.addAll([_AuthInterceptor(_storage), _LogInterceptor()]);
  }

  // ── GET ────────────────────────────────────────────────────────────────────
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    final params = queryParams ?? {};
    params['_t'] = DateTime.now().millisecondsSinceEpoch; // Cache buster
    return _dio.get(path, queryParameters: params);
  }

  // ── POST ───────────────────────────────────────────────────────────────────
  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return _dio.post(path, data: data);
  }

  // ── PUT ────────────────────────────────────────────────────────────────────
  Future<Response> put(String path, {Map<String, dynamic>? data}) async {
    return _dio.put(path, data: data);
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────
  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }
}

// ── Auth Interceptor ──────────────────────────────────────────────────────────
/// Otomatis sisipkan JWT token ke header setiap request.
class _AuthInterceptor extends Interceptor {
  final LocalStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Token expired / unauthorized → bisa redirect ke login
    if (err.response?.statusCode == 401) {
      _storage.clearToken();
    }
    handler.next(err);
  }
}

// ── Log Interceptor ───────────────────────────────────────────────────────────
/// Print log request & response di console (hanya saat development).
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('┌─ REQUEST ──────────────────────────');
    print('│ ${options.method} ${options.uri}');
    if (options.data != null) print('│ Body: ${options.data}');
    print('└────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('┌─ RESPONSE ─────────────────────────');
    print('│ Status: ${response.statusCode}');
    print('│ Data: ${response.data}');
    print('└────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('┌─ ERROR ─────────────────────────────');
    print('│ ${err.message}');
    print('│ Response: ${err.response?.data}');
    print('└─────────────────────────────────────');
    handler.next(err);
  }
}
