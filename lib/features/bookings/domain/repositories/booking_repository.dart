import 'package:bingo_pay/features/bookings/domain/entities/bookings_entity.dart';

abstract class BookingRepository {

  Future<List<BookingEntity>> getBookings();
}