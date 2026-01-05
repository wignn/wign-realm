import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  final StorageService _storage = StorageService();
  bool _isRefreshing = false;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': ApiConfig.apiKey,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('REQUEST[${options.method}] => ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              'RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print(
              'ERROR[${error.response?.statusCode}] => ${error.requestOptions.path}',
            );
          }

          // Handle 401 - try refresh token
          // IMPORTANT: Skip refresh for the refresh endpoint itself to prevent infinite loop
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/refresh') &&
              !_isRefreshing) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              // Retry request
              try {
                final token = await _storage.getAccessToken();
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(error);
              }
            } else {
              // Refresh failed - clear tokens to prevent future loops
              await _storage.clearTokens();
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;

    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    _isRefreshing = true;

    try {
      // Use a separate Dio instance without interceptors to avoid recursion
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': ApiConfig.apiKey,
          },
        ),
      );

      final response = await refreshDio.post(
        ApiConfig.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken != null) {
          await _storage.saveTokens(newAccessToken, newRefreshToken);
          _isRefreshing = false;
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token failed: $e');
      }
      await _storage.clearTokens();
    }

    _isRefreshing = false;
    return false;
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  // DELETE request
  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }
}
