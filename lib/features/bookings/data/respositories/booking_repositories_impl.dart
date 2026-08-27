import 'package:bingo_pay/features/bookings/domain/entities/bookings_entity.dart';

import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasources.dart';

class BookingRepositoriesImpl extends BookingRepository{
  final BookingRemoteDatasources _bookingRemoteDatasources;

  BookingRepositoriesImpl(this._bookingRemoteDatasources);

  @override
  Future<List<BookingEntity>> getBookings() async{
    final result = await _bookingRemoteDatasources.getBookings();
    return result.map(((e) => e.toEntity())).toList();
  }
}