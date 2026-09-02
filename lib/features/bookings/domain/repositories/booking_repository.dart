import 'package:bingo_pay/features/bookings/domain/entities/bookings_entity.dart';

import '../entities/booking_details_entity.dart';
import '../entities/cancel_booking_entity.dart';

abstract class BookingRepository {

  Future<List<BookingEntity>> getBookings();

  Future<BookingDetailsEntity> getBookingDetails(String bookingUuid);

  Future<CancelBookingEntity> cancelBooking({
    required String bookingUuid,
    required String reason,
  });

  Future<BookingDetailsEntity> rescheduleBooking({
    required String bookingUuid,
    required String slotUuid,
  });
}