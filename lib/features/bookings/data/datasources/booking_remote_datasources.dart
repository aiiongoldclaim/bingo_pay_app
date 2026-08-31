import 'package:bingo_pay/features/bookings/data/models/booking_details_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/booking_model.dart';
import '../models/cancel_booking_model.dart';

class InvoiceDownload {
  final List<int> bytes;
  final String filename;

  const InvoiceDownload({required this.bytes, required this.filename});
}

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

  Future<InvoiceDownload> downloadInvoice(String bookingUuid) async {
    final response = await _apiClient.dio.get<List<int>>(
      '${ApiEndpoints.myBookings}/$bookingUuid/invoice',
      options: Options(responseType: ResponseType.bytes),
    );
    final disposition = response.headers.value('content-disposition');
    return InvoiceDownload(
      bytes: response.data ?? [],
      filename: _filenameFrom(disposition) ?? 'invoice-$bookingUuid.pdf',
    );
  }

  String? _filenameFrom(String? contentDisposition) {
    if (contentDisposition == null) return null;
    final match = RegExp(
      r'filename\*?=(?:UTF-8\x27\x27)?"?([^";]+)"?',
      caseSensitive: false,
    ).firstMatch(contentDisposition);
    if (match == null) return null;
    return Uri.decodeComponent(match.group(1)!);
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
}