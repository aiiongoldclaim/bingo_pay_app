import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/availability_entity.dart';

// ===== Services List States =====
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

// ===== Service Detail States =====
enum ServiceDetailStatus { initial, loading, loaded, error }

class ServiceDetailState extends Equatable {
  final ServiceDetailStatus status;
  final ServiceEntity? service;
  final String? errorMessage;

  const ServiceDetailState({
    this.status = ServiceDetailStatus.initial,
    this.service,
    this.errorMessage,
  });

  ServiceDetailState copyWith({
    ServiceDetailStatus? status,
    ServiceEntity? service,
    String? errorMessage,
  }) {
    return ServiceDetailState(
      status: status ?? this.status,
      service: service ?? this.service,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, service, errorMessage];
}

// ===== Availability States =====
enum AvailabilityStatus { initial, loading, loaded, error }

class AvailabilityState extends Equatable {
  final AvailabilityStatus status;
  final AvailabilityEntity? availability;
  final String? errorMessage;
  final String selectedOfferingUuid;
  final int participants;

  const AvailabilityState({
    this.status = AvailabilityStatus.initial,
    this.availability,
    this.errorMessage,
    this.selectedOfferingUuid = '',
    this.participants = 1,
  });

  AvailabilityState copyWith({
    AvailabilityStatus? status,
    AvailabilityEntity? availability,
    String? errorMessage,
    String? selectedOfferingUuid,
    int? participants,
  }) {
    return AvailabilityState(
      status: status ?? this.status,
      availability: availability ?? this.availability,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedOfferingUuid:
          selectedOfferingUuid ?? this.selectedOfferingUuid,
      participants: participants ?? this.participants,
    );
  }

  @override
  List<Object?> get props => [
        status,
        availability,
        errorMessage,
        selectedOfferingUuid,
        participants,
      ];
}
