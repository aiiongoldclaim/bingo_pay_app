import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/booking_repository.dart';
import 'booking_state.dart';

@injectable
class BookingCubit extends Cubit<BookingState>{
  final BookingRepository repository;
  BookingCubit(this.repository) : super(BookingInitial());

// The repository throws the raw ex
  // The repository throws the raw exception from the API layer (DioException
  // wrapping a ServerException/AuthException/etc via ErrorInterceptor).
  // Unwrap it with the same ErrorHandler the rest of the app uses so the
  // real reason (e.g. "Booking not found", "Unauthorized") reaches the UI
  // instead of always showing the same generic fallback string.
  String _describe(Object error, String fallback) {
    if (error is Exception) {
      final message = ErrorHandler.mapExceptionToFailure(error).message;
      if (message.isNotEmpty) return message;
    }
    debugPrint('BookingCubit error: $error');
    return fallback;
  }

  Future<void> fetchBookings() async {
    emit(BookingLoading());
    try {
      final bookings = await repository.getBookings();
      emit(BookingListLoaded(bookings));
    } catch (e) {
      emit(BookingError(_describe(e, "Failed to fetch bookings")));
    }
  }

  // BOOKING DETAIL
  Future<void> fetchBookingDetails(String bookingUuid) async {
    emit(BookingDetailLoading());
    try {
      final bookingDetails = await repository.getBookingDetails(bookingUuid);
      emit(BookingDetailLoaded(bookingDetails));
    } catch (e) {
      emit(BookingDetailError(_describe(e, "Failed to fetch booking details")));
    }
  }

  // CANCEL BOOKING
  Future<void> cancelBooking(String bookingUuid, String reason) async {
    emit(BookingCancelLoading());
    try {
      await repository.cancelBooking(bookingUuid: bookingUuid, reason: reason);
      emit(BookingCancelSuccess());
    } catch (e) {
      emit(BookingCancelError(_describe(e, "Failed to cancel booking")));
    }
  }
}