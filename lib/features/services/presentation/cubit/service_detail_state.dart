import 'package:equatable/equatable.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/entities/availability_entity.dart';

enum ServiceDetailStatus { initial, loading, loaded, error }
enum AvailabilityStatus { initial, loading, loaded, error }

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
