import 'package:equatable/equatable.dart';

class CancelBookingEntity extends Equatable {
  final bool success;
  final String message;
  final String uuid;
  final String bookingNumber;
  final String status;
  final String? cancellationReason;
  final String? cancelledAt;
  final String? cancellationFee;

  const CancelBookingEntity({
    required this.success,
    required this.message,
    required this.uuid,
    required this.bookingNumber,
    required this.status,
    this.cancellationReason,
    this.cancelledAt,
    this.cancellationFee,
  });

  @override
  List<Object?> get props => [
        success,
        message,
        uuid,
        bookingNumber,
        status,
        cancellationReason,
        cancelledAt,
        cancellationFee,
      ];
}