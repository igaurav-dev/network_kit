import 'package:dio/dio.dart';

/// Callback types for interceptors
typedef OnRequestCallback =
    void Function(RequestOptions options, RequestInterceptorHandler handler);

typedef OnResponseCallback =
    void Function(Response response, ResponseInterceptorHandler handler);

typedef OnErrorCallback =
    void Function(DioException error, ErrorInterceptorHandler handler);

/// Configuration for network client interceptors
class NetworkInterceptorConfig {
  final OnRequestCallback? onRequest;
  final OnResponseCallback? onResponse;
  final OnErrorCallback? onError;

  const NetworkInterceptorConfig({
    this.onRequest,
    this.onResponse,
    this.onError,
  });
}

/// Custom interceptor that uses the provided callbacks
class CustomInterceptor extends Interceptor {
  final NetworkInterceptorConfig config;

  CustomInterceptor(this.config);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (config.onRequest != null) {
      config.onRequest!(options, handler);
    } else {
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (config.onResponse != null) {
      config.onResponse!(response, handler);
    } else {
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (config.onError != null) {
      config.onError!(err, handler);
    } else {
      handler.next(err);
    }
  }
}
