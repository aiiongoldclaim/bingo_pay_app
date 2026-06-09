import 'package:equatable/equatable.dart';
import '../error/failures.dart';

sealed class AppState<T> extends Equatable {
  const AppState();
}

final class InitialState<T> extends AppState<T> {
  const InitialState();

  @override
  List<Object?> get props => [];
}

final class LoadingState<T> extends AppState<T> {
  const LoadingState();

  @override
  List<Object?> get props => [];
}

final class SuccessState<T> extends AppState<T> {
  final T data;
  const SuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

final class ErrorState<T> extends AppState<T> {
  final Failure failure;
  const ErrorState(this.failure);

  @override
  List<Object?> get props => [failure];
}
