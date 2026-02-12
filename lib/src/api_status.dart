/// Common HTTP status codes used in API responses.
enum ApiStatus {
  // Success
  success(200),
  created(201),
  accepted(202),
  noContent(204),

  // Client Errors
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  methodNotAllowed(405),
  conflict(409),
  gone(410),
  unprocessableEntity(422),
  tooManyRequests(429),

  // Server Errors
  internalServerError(500),
  badGateway(502),
  serviceUnavailable(503),
  gatewayTimeout(504),

  // Custom/Unknown
  unknown(-1),
  noInternet(-2),
  timeout(-3);

  final int code;
  const ApiStatus(this.code);

  /// Create ApiStatus from HTTP status code
  static ApiStatus fromCode(int? code) {
    if (code == null) return ApiStatus.unknown;
    return ApiStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => ApiStatus.unknown,
    );
  }
}

/// Extension methods for ApiStatus
extension ApiStatusExtension on ApiStatus {
  bool get isSuccess => code >= 200 && code < 300;

  bool get isClientError => code >= 400 && code < 500;

  bool get isServerError => code >= 500 && code < 600;

  bool get isUnauthorized => this == ApiStatus.unauthorized;

  bool get isForbidden => this == ApiStatus.forbidden;

  bool get isNotFound => this == ApiStatus.notFound;

  bool get isConflict => this == ApiStatus.conflict;

  bool get isBadGateway => this == ApiStatus.badGateway;

  bool get isNetworkError =>
      this == ApiStatus.noInternet || this == ApiStatus.timeout;

  String get message {
    switch (this) {
      case ApiStatus.success:
        return 'Success';
      case ApiStatus.created:
        return 'Created successfully';
      case ApiStatus.noContent:
        return 'No content';
      case ApiStatus.badRequest:
        return 'Bad request';
      case ApiStatus.unauthorized:
        return 'Unauthorized. Please login again.';
      case ApiStatus.forbidden:
        return 'Access denied';
      case ApiStatus.notFound:
        return 'Resource not found';
      case ApiStatus.conflict:
        return 'Conflict occurred';
      case ApiStatus.tooManyRequests:
        return 'Too many requests. Please try again later.';
      case ApiStatus.internalServerError:
        return 'Server error. Please try again.';
      case ApiStatus.badGateway:
        return 'Bad gateway';
      case ApiStatus.serviceUnavailable:
        return 'Service unavailable';
      case ApiStatus.noInternet:
        return 'No internet connection';
      case ApiStatus.timeout:
        return 'Request timeout';
      default:
        return 'Unknown error';
    }
  }
}
