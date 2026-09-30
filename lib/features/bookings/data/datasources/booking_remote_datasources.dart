import 'package:bingo_pay/features/bookings/data/models/booking_details_model.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/booking_model.dart';
import '../models/cancel_booking_model.dart';

@injectable
class BookingRemoteDatasources {
  final ApiClient _apiClient;
  BookingRemoteDatasources(this._apiClient);

  Future<List<BookingModel>> getBookings() async {
    final response = await _apiClient.dio.get(ApiEndpoints.myBookings);
    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid bookings response');
    }

    final dataWrapper = responseData['data'];
    if (dataWrapper is! Map<String, dynamic>) {
      throw const FormatException('Invalid data wrapper in bookings response');
    }

    final bookingsJson = dataWrapper['data'];
    if (bookingsJson is! List) {
      throw const FormatException('Invalid bookings list in response');
    }

    return bookingsJson.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingDetailsModel> getBookingDetails(String bookingUuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.bookingDetail(bookingUuid));
    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid booking details response');
    }

    final dataWrapper = responseData['data'];
    if (dataWrapper is! Map<String, dynamic>) {
      throw const FormatException('Invalid data wrapper in booking details response');
    }

    final bookingJson = dataWrapper['data'];
    if (bookingJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid booking details in response');
    }

    return BookingDetailsModel.fromJson(bookingJson);
  }

    // ---------------------------------------------------------------------------
  // CANCEL BOOKING
  // ---------------------------------------------------------------------------

  Future<CancelBookingModel> cancelBooking({
    required String bookingUuid,
    required String reason,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.cancelBooking(bookingUuid),
      data: {
        'reason': reason,
      },
    );

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid cancel booking response',
      );
    }

    final dataWrapper = responseData['data'];

    if (dataWrapper is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid data wrapper in cancel booking response',
      );
    }

    final bookingJson = dataWrapper['data'];

    if (bookingJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid cancelled booking data in response',
      );
    }

    return CancelBookingModel.fromJson(
      bookingJson,
    );
  }

  // ---------------------------------------------------------------------------
  // RESCHEDULE BOOKING
  // ---------------------------------------------------------------------------

  Future<BookingDetailsModel> rescheduleBooking({
    required String bookingUuid,
    required String slotUuid,
  }) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.rescheduleBooking(bookingUuid),
      data: {
        'slotUuid': slotUuid,
      },
    );

    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid reschedule booking response',
      );
    }

    final dataWrapper = responseData['data'];

    if (dataWrapper is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid data wrapper in reschedule booking response',
      );
    }

    final bookingJson = dataWrapper['data'];

    if (bookingJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid rescheduled booking data in response',
      );
    }

    return BookingDetailsModel.fromJson(
      bookingJson,
    );
  }
}