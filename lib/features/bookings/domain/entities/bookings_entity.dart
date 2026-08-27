class BookingEntity {
  final String id;
  final String uuid;
  final String bookingNumber;
  final String orderItemId;
  final String vendorOrderId;
  final String orderId;
  final String userId;
  final String vendorId;
  final String serviceId;
  final String offeringId;
  final String slotId;
  final String status;
  final String scheduledStartAt;
  final String scheduledEndAt;
  final int participants;
  final String addressId;
  final String? outletId;
  final String? customerNotes;
  final String? vendorNotes;
  final String? confirmedAt;
  final String? checkedInAt;
  final String? startedAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancelledById;
  final String? cancellationReason;
  final String? cancellationFee;
  final int rescheduleCount;
  final String? previousSlotId;
  final String paymentMode;
  final String? collectedAt;
  final String? collectedById;
  final String createdAt;
  final String updatedAt;

  final BookingServiceEntity service;
  final BookingOfferingEntity offering;
  final BookingVendorEntity vendor;
  final BookingOrderEntity order;
  final BookingOrderItemEntity orderItem;

  BookingEntity({
    required this.id,
    required this.uuid,
    required this.bookingNumber,
    required this.orderItemId,
    required this.vendorOrderId,
    required this.orderId,
    required this.userId,
    required this.vendorId,
    required this.serviceId,
    required this.offeringId,
    required this.slotId,
    required this.status,
    required this.scheduledStartAt,
    required this.scheduledEndAt,
    required this.participants,
    required this.addressId,
    this.outletId,
    this.customerNotes,
    this.vendorNotes,
    this.confirmedAt,
    this.checkedInAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelledById,
    this.cancellationReason,
    this.cancellationFee,
    required this.rescheduleCount,
    this.previousSlotId,
    required this.paymentMode,
    this.collectedAt,
    this.collectedById,
    required this.createdAt,
    required this.updatedAt,
    required this.service,
    required this.offering,
    required this.vendor,
    required this.order,
    required this.orderItem,
  });
}

class BookingServiceEntity {
  final String uuid;
  final String title;
  final String slug;

  BookingServiceEntity({
    required this.uuid,
    required this.title,
    required this.slug,
  });
}

class BookingOfferingEntity {
  final String uuid;
  final String code;
  final String offeringName;

  BookingOfferingEntity({
    required this.uuid,
    required this.code,
    required this.offeringName,
  });
}

class BookingVendorEntity {
  final String uuid;
  final String shopName;
  final String? supportPhone;

  BookingVendorEntity({
    required this.uuid,
    required this.shopName,
    this.supportPhone,
  });
}

class BookingOrderEntity {
  final String uuid;
  final String orderNumber;

  BookingOrderEntity({
    required this.uuid,
    required this.orderNumber,
  });
}

class BookingOrderItemEntity {
  final String totalAmount;

  BookingOrderItemEntity({
    required this.totalAmount,
  });
}