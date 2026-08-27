import 'package:injectable/injectable.dart';

import '../../domain/entities/bookings_entity.dart';
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
}
