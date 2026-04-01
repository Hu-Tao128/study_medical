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
    Dio? dio,
    String? baseUrl,
  }) : _tokenProvider = tokenProvider,
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
           );

  final Dio _dio;
  final Future<String?> Function() _tokenProvider;

  static String _normalizeBaseUrl(String rawBaseUrl) {
    final trimmed = rawBaseUrl.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'http://$trimmed';
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    Options? options,
  }) async {
    try {
      final requestOptions = await _prepareOptions(options, requiresAuth);
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
      );
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    bool requiresAuth = true,
    Options? options,
  }) async {
    try {
      final requestOptions = await _prepareOptions(options, requiresAuth);
      return await _dio.post<T>(path, data: data, options: requestOptions);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    bool requiresAuth = true,
    Options? options,
  }) async {
    try {
      final requestOptions = await _prepareOptions(options, requiresAuth);
      return await _dio.patch<T>(path, data: data, options: requestOptions);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    bool requiresAuth = true,
    Options? options,
  }) async {
    try {
      final requestOptions = await _prepareOptions(options, requiresAuth);
      return await _dio.put<T>(path, data: data, options: requestOptions);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    bool requiresAuth = true,
    Options? options,
  }) async {
    try {
      final requestOptions = await _prepareOptions(options, requiresAuth);
      return await _dio.delete<T>(path, data: data, options: requestOptions);
    } on DioException catch (error) {
      throw BackendApiException.fromDio(error);
    }
  }

  Future<Options> _prepareOptions(Options? options, bool requiresAuth) async {
    final merged = options?.copyWith() ?? Options();
    merged.headers = Map<String, dynamic>.from(merged.headers ?? {});

    if (requiresAuth) {
      final token = await _tokenProvider();
      if (token == null || token.isEmpty) {
        throw const AuthTokenMissingException();
      }
      merged.headers!['Authorization'] = 'Bearer $token';
    }

    return merged;
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
