import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_service_detail_usecase.dart';
import 'service_detail_state.dart';

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
