import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_services_usecase.dart';
import '../../domain/usecases/get_service_detail_usecase.dart';
import 'services_state.dart';

// ===== Services List Cubit =====
@injectable
class ServicesCubit extends Cubit<ServicesState> {
  final GetServicesUseCase _getServicesUseCase;

  ServicesCubit(this._getServicesUseCase) : super(const ServicesState());

  Future<void> loadServices({int limit = 8, int page = 1}) async {
    emit(state.copyWith(status: ServicesStatus.loading));
    try {
      final services = await _getServicesUseCase(limit: limit, page: page);
      emit(state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        currentPage: page,
        hasMorePages: page < (state.totalPages == 0 ? 1 : state.totalPages),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadAllServices({int limit = 20}) async {
    emit(state.copyWith(status: ServicesStatus.loading));
    try {
      final services = await _getServicesUseCase(limit: limit, page: 1);
      emit(state.copyWith(
        status: ServicesStatus.loaded,
        services: services,
        currentPage: 1,
        totalPages: 1,
        hasMorePages: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMoreServices({int limit = 20}) async {
    if (!state.hasMorePages) return;

    emit(state.copyWith(status: ServicesStatus.loadingMore));
    try {
      final nextPage = state.currentPage + 1;
      final newServices = await _getServicesUseCase(limit: limit, page: nextPage);

      final updatedServices = [...state.services, ...newServices];
      emit(state.copyWith(
        status: ServicesStatus.loaded,
        services: updatedServices,
        currentPage: nextPage,
        hasMorePages: newServices.isNotEmpty && newServices.length == limit,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

// ===== Service Detail Cubit =====
@injectable
class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  final GetServiceDetailUseCase _getServiceDetailUseCase;

  ServiceDetailCubit(this._getServiceDetailUseCase)
      : super(const ServiceDetailState());

  Future<void> loadServiceDetail(String serviceUuid) async {
    emit(state.copyWith(status: ServiceDetailStatus.loading));
    try {
      final service = await _getServiceDetailUseCase(serviceUuid);
      emit(state.copyWith(
        status: ServiceDetailStatus.loaded,
        service: service,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ServiceDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}

// ===== Availability Cubit =====
@injectable
class AvailabilityCubit extends Cubit<AvailabilityState> {
  final GetServiceAvailabilityUseCase _getAvailabilityUseCase;

  AvailabilityCubit(this._getAvailabilityUseCase)
      : super(const AvailabilityState());

  Future<void> loadAvailability({
    required String serviceUuid,
    required String offeringUuid,
    int participants = 1,
  }) async {
    emit(state.copyWith(
      status: AvailabilityStatus.loading,
      selectedOfferingUuid: offeringUuid,
      participants: participants,
    ));
    try {
      final availability = await _getAvailabilityUseCase(
        serviceUuid: serviceUuid,
        offeringUuid: offeringUuid,
        participants: participants,
      );
      emit(state.copyWith(
        status: AvailabilityStatus.loaded,
        availability: availability,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvailabilityStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateParticipants(int participants) {
    emit(state.copyWith(participants: participants));
  }
}
