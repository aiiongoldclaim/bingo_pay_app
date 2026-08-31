import 'package:bingo_pay/features/bookings/domain/entities/booking_details_entity.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/bookings_entity.dart';
import '../../domain/entities/cancel_booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasources.dart';

@Injectable(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDatasources _remoteDatasources;

  BookingRepositoryImpl(this._remoteDatasources);

  @override
  Future<List<BookingEntity>> getBookings() async {
    final bookingModels = await _remoteDatasources.getBookings();
    return bookingModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<BookingDetailsEntity> getBookingDetails(String bookingUuid) async {
    final result = await _remoteDatasources.getBookingDetails(bookingUuid);

    return result.toEntity();
  }

  @override
  Future<CancelBookingEntity> cancelBooking({
    required String bookingUuid,
    required String reason,
  }) async {
    return await _remoteDatasources.cancelBooking(
      bookingUuid: bookingUuid,
      reason: reason,
    );
  }
}
