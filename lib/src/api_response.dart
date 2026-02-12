import 'api_status.dart';

/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final ApiStatus status;
  final String? message;
  final dynamic rawResponse;

  const ApiResponse({
    this.data,
    required this.status,
    this.message,
    this.rawResponse,
  });

  bool get isSuccess => status.isSuccess;
  bool get isError => !isSuccess;
  bool get isUnauthorized => status.isUnauthorized;

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(data: data, status: ApiStatus.success, message: message);
  }

  factory ApiResponse.error(ApiStatus status, {String? message}) {
    return ApiResponse(
      data: null,
      status: status,
      message: message ?? status.message,
    );
  }
}
