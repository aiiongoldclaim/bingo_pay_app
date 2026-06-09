import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  final String? serverMessage;

  const ServerFailure({
    required String message,
    this.statusCode,
    this.serverMessage,
  }) : super(message);

  @override
  List<Object?> get props => [message, statusCode, serverMessage];
}

class AuthFailure extends Failure {
  const AuthFailure({required String message}) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required String message,
    required this.fieldErrors,
  }) : super(message);

  @override
  List<Object?> get props => [message, fieldErrors];
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred'])
      : super(message);
}
