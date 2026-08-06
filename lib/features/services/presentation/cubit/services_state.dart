import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';

enum ServicesStatus { initial, loading, loaded, loadingMore, error }

class ServicesState extends Equatable {
  final ServicesStatus status;
  final List<ServiceEntity> services;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool hasMorePages;

  const ServicesState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 0,
    this.hasMorePages = false,
  });

  ServicesState copyWith({
    ServicesStatus? status,
    List<ServiceEntity>? services,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    bool? hasMorePages,
  }) {
    return ServicesState(
      status: status ?? this.status,
      services: services ?? this.services,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  @override
  List<Object?> get props => [
        status,
        services,
        errorMessage,
        currentPage,
        totalPages,
        hasMorePages,
      ];
}
