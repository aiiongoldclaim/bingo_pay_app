class ServerException implements Exception {
  final int? statusCode;
  final String message;
  const ServerException({this.statusCode, required this.message});
}

class NetworkException implements Exception {
  const NetworkException();
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String> fieldErrors;
  const ValidationException({required this.message, required this.fieldErrors});
}

class EmailNotVerifiedException implements Exception {
  final String message;
  const EmailNotVerifiedException({required this.message});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}
