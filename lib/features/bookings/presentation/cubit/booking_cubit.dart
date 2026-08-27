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
}