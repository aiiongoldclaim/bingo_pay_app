import 'package:equatable/equatable.dart';

import '../../domain/entities/bookings_entity.dart';

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