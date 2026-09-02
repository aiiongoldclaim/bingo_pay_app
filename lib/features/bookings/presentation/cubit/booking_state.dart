import 'package:equatable/equatable.dart';

import '../../domain/entities/bookings_entity.dart';
import '../../domain/entities/booking_details_entity.dart';

class BookingState extends Equatable{
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState{}

class BookingLoading extends BookingState{}

class BookingListLoaded extends BookingState{

  final List<BookingEntity> bookings;

  const BookingListLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingError extends BookingState{
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}

//BOOKING DETAIL
class BookingDetailLoading extends BookingState{}

class BookingDetailLoaded extends BookingState{

  final BookingDetailsEntity bookingDetails;

  const BookingDetailLoaded(this.bookingDetails);

  @override
  List<Object?> get props => [bookingDetails];
}

class BookingDetailError extends BookingState {
  final String message;

  const BookingDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

//CANCEL BOOKING
class BookingCancelLoading extends BookingState{}

class BookingCancelSuccess extends BookingState{}

class BookingCancelError extends BookingState{
  final String message;

  const BookingCancelError(this.message);

  @override
  List<Object?> get props => [message];
}

//RESCHEDULE BOOKING
class BookingRescheduleLoading extends BookingState{}

class BookingRescheduleSuccess extends BookingState{
  final BookingDetailsEntity bookingDetails;

  const BookingRescheduleSuccess(this.bookingDetails);

  @override
  List<Object?> get props => [bookingDetails];
}

class BookingRescheduleError extends BookingState{
  final String message;

  const BookingRescheduleError(this.message);

  @override
  List<Object?> get props => [message];
}