/// Base exception for all app domain errors.
class AppException implements Exception {
  final String message;
  final Exception? originalError;

  AppException({
    required this.message,
    this.originalError,
  });

  @override
  String toString() {
    if (originalError != null) {
      return 'AppException: $message (Caused by: $originalError)';
    }
    return 'AppException: $message';
  }
}

/// Exception for repository/data layer errors.
class RepositoryException extends AppException {
  RepositoryException({
    required super.message,
    super.originalError,
  });
}

/// Exception for authentication/authorization errors.
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.originalError,
  });
}

/// Exception for network/connectivity errors.
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.originalError,
  });
}
