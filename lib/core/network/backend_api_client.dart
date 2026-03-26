import 'package:dio/dio.dart';

import '../../features/auth/data/auth_service.dart';

const String _defaultBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

class BackendApiClient {
  BackendApiClient({
    required AuthService authService,
    Dio? dio,
    String? baseUrl,
  }) : _authService = authService,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl ?? _defaultBaseUrl,
               connectTimeout: const Duration(seconds: 12),
               receiveTimeout: const Duration(seconds: 12),
               sendTimeout: const Duration(seconds: 12),
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
             ),
           );

  final Dio _dio;
  final AuthService _authService;

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

  Future<Options> _prepareOptions(Options? options, bool requiresAuth) async {
    final merged = options?.copyWith() ?? Options();
    merged.headers = Map<String, dynamic>.from(merged.headers ?? {});

    if (requiresAuth) {
      final token = await _authService.getToken();
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
