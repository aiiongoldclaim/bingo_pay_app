import '../../domain/entities/cancel_booking_entity.dart';

class CancelBookingModel extends CancelBookingEntity {
  const CancelBookingModel({
    required super.success,
    required super.message,
    required super.uuid,
    required super.bookingNumber,
    required super.status,
    super.cancellationReason,
    super.cancelledAt,
    super.cancellationFee,
  });

  factory CancelBookingModel.fromJson(Map<String, dynamic> json) {
    return CancelBookingModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      bookingNumber: json['bookingNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      cancellationReason:
          json['cancellationReason']?.toString(),
      cancelledAt: json['cancelledAt']?.toString(),
      cancellationFee:
          json['cancellationFee']?.toString(),
    );
  }
}