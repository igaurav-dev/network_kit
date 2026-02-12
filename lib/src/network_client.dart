import 'dart:io';
import 'package:dio/dio.dart';
import 'api_status.dart';
import 'api_response.dart';
import 'interceptor_config.dart';

/// Singleton Network Client using Dio
class NetworkClient {
  static final NetworkClient instance = NetworkClient._();

  NetworkClient._();

  late Dio _dio;
  bool _isInitialized = false;

  Dio get dio => _dio;

  /// Initialize the network client
  void init({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Map<String, dynamic>? headers,
    NetworkInterceptorConfig? interceptorConfig,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: headers ?? {'Content-Type': 'application/json'},
      ),
    );

    if (interceptorConfig != null) {
      _dio.interceptors.add(CustomInterceptor(interceptorConfig));
    }

    // Add logging in debug mode
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );

    _isInitialized = true;
  }

  void _checkInit() {
    if (!_isInitialized) {
      throw Exception('NetworkClient not initialized. Call init() first.');
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    _checkInit();
    return _execute<T>(
      () => _dio.get(path, queryParameters: queryParameters, options: options),
      fromJson: fromJson,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    _checkInit();
    return _execute<T>(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    _checkInit();
    return _execute<T>(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    _checkInit();
    return _execute<T>(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    _checkInit();
    return _execute<T>(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      fromJson: fromJson,
    );
  }

  /// Multipart/FormData upload
  Future<ApiResponse<T>> uploadMultipart<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    _checkInit();
    return _execute<T>(
      () => _dio.post(
        path,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      ),
      fromJson: fromJson,
    );
  }

  /// Download file
  Future<ApiResponse<String>> download(
    String urlPath,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    Options? options,
  }) async {
    _checkInit();
    try {
      await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: options,
      );
      return ApiResponse.success(savePath, message: 'Download complete');
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      return ApiResponse.error(ApiStatus.unknown, message: e.toString());
    }
  }

  /// Internal executor for all requests
  Future<ApiResponse<T>> _execute<T>(
    Future<Response> Function() request, {
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await request();
      final status = ApiStatus.fromCode(response.statusCode);

      if (status.isSuccess) {
        final data =
            fromJson != null ? fromJson(response.data) : response.data as T;
        return ApiResponse(
          data: data,
          status: status,
          rawResponse: response.data,
        );
      } else {
        return ApiResponse.error(status, message: response.statusMessage);
      }
    } on DioException catch (e) {
      return _handleError(e);
    } on SocketException {
      return ApiResponse.error(ApiStatus.noInternet);
    } catch (e) {
      return ApiResponse.error(ApiStatus.unknown, message: e.toString());
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(ApiStatus.timeout);
      case DioExceptionType.connectionError:
        return ApiResponse.error(ApiStatus.noInternet);
      case DioExceptionType.badResponse:
        final status = ApiStatus.fromCode(e.response?.statusCode);
        // Try to extract message from API response body first
        String? errorMessage;
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] as String?;
        }
        return ApiResponse.error(status, message: errorMessage ?? e.message);
      default:
        return ApiResponse.error(ApiStatus.unknown, message: e.message);
    }
  }
}
