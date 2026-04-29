import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get _defaultBaseUrl {
  final url = dotenv.env['API_BASE_URL'];
  if (url == null || url.isEmpty) {
    throw Exception('API_BASE_URL no definida en .env');
  }
  return url;
}

class BackendApiClient {
  BackendApiClient({
    required Future<String?> Function() tokenProvider,
    Future<void> Function()? refreshTokens,
    Dio? dio,
    String? baseUrl,
  }) : _tokenProvider = tokenProvider,
       _refreshTokens = refreshTokens,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _normalizeBaseUrl(baseUrl ?? _defaultBaseUrl),
               connectTimeout: const Duration(seconds: 12),
               receiveTimeout: const Duration(seconds: 12),
               sendTimeout: const Duration(seconds: 12),
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
             ),
           ) {
    _setupInterceptors();
  }

  final Dio _dio;
  final Future<String?> Function() _tokenProvider;
  final Future<void> Function()? _refreshTokens;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth for public endpoints
          final isPublicEndpoint = _isPublicEndpoint(options.path);

          if (!isPublicEndpoint && !options.headers.containsKey('Authorization')) {
            final token = await _tokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors globally
          final isRefreshEndpoint = error.requestOptions.path.contains('api/v1/auth/refresh');
          
          if (error.response?.statusCode == 401 && _refreshTokens != null && !isRefreshEndpoint) {
            try {
              // Attempt to refresh tokens
              await _refreshTokens!();
              
              // Retry the original request
              final options = error.requestOptions;
              final token = await _tokenProvider();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              // Refresh failed, proceed with error
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  static String _normalizeBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }

  bool _isPublicEndpoint(String path) {
    // Remove leading slash for consistent comparison
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;

    // Public endpoints that don't require authentication
    final publicEndpoints = {
      '', // Root endpoint /
      'health',
      'keep-alive',
      'api/v1/auth/dev-login', // Dev only endpoint
      'api/v1/auth/sync-session', // Needs Firebase token, not Backend JWT
      'api/v1/auth/refresh',
      'api/v1/topics',
    };

    return publicEndpoints.contains(normalizedPath);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, options: options);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, options: options);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, options: options);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }
}

class BackendApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const BackendApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory BackendApiException.fromDio(DioException error) {
    final response = error.response;
    final status = response?.statusCode;
    final data = response?.data;
    final resolvedMessage =
        data is Map<String, dynamic> && data['message'] is String
        ? data['message'] as String
        : error.message ?? 'Error de red inesperado';

    return BackendApiException(
      message: resolvedMessage,
      statusCode: status,
      details: data,
    );
  }

  @override
  String toString() => 'BackendApiException($statusCode): $message';
}

class AuthTokenMissingException extends BackendApiException {
  const AuthTokenMissingException()
    : super(message: 'No se pudo obtener el token de autenticación');
}
