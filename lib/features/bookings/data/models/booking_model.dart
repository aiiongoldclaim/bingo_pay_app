
import '../../domain/entities/bookings_entity.dart';

class BookingModel {
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

  final BookingServiceModel service;
  final BookingOfferingModel offering;
  final BookingVendorModel vendor;
  final BookingOrderModel order;
  final BookingOrderItemModel orderItem;

  BookingModel({
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

  /// JSON → Model
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'].toString(),
      uuid: json['uuid'] ?? '',
      bookingNumber: json['bookingNumber'] ?? '',
      orderItemId: json['orderItemId'].toString(),
      vendorOrderId: json['vendorOrderId'].toString(),
      orderId: json['orderId'].toString(),
      userId: json['userId'].toString(),
      vendorId: json['vendorId'].toString(),
      serviceId: json['serviceId'].toString(),
      offeringId: json['offeringId'].toString(),
      slotId: json['slotId'].toString(),
      status: json['status'] ?? '',
      scheduledStartAt: json['scheduledStartAt'] ?? '',
      scheduledEndAt: json['scheduledEndAt'] ?? '',
      participants: json['participants'] ?? 0,
      addressId: json['addressId'].toString(),
      outletId: json['outletId']?.toString(),
      customerNotes: json['customerNotes'],
      vendorNotes: json['vendorNotes'],
      confirmedAt: json['confirmedAt'],
      checkedInAt: json['checkedInAt'],
      startedAt: json['startedAt'],
      completedAt: json['completedAt'],
      cancelledAt: json['cancelledAt'],
      cancelledById: json['cancelledById']?.toString(),
      cancellationReason: json['cancellationReason'],
      cancellationFee: json['cancellationFee'],
      rescheduleCount: json['rescheduleCount'] ?? 0,
      previousSlotId: json['previousSlotId']?.toString(),
      paymentMode: json['paymentMode'] ?? '',
      collectedAt: json['collectedAt'],
      collectedById: json['collectedById']?.toString(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',

      service: BookingServiceModel.fromJson(
        json['service'] ?? {},
      ),

      offering: BookingOfferingModel.fromJson(
        json['offering'] ?? {},
      ),

      vendor: BookingVendorModel.fromJson(
        json['vendor'] ?? {},
      ),

      order: BookingOrderModel.fromJson(
        json['order'] ?? {},
      ),

      orderItem: BookingOrderItemModel.fromJson(
        json['orderItem'] ?? {},
      ),
    );
  }

  /// Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'bookingNumber': bookingNumber,
      'orderItemId': orderItemId,
      'vendorOrderId': vendorOrderId,
      'orderId': orderId,
      'userId': userId,
      'vendorId': vendorId,
      'serviceId': serviceId,
      'offeringId': offeringId,
      'slotId': slotId,
      'status': status,
      'scheduledStartAt': scheduledStartAt,
      'scheduledEndAt': scheduledEndAt,
      'participants': participants,
      'addressId': addressId,
      'outletId': outletId,
      'customerNotes': customerNotes,
      'vendorNotes': vendorNotes,
      'confirmedAt': confirmedAt,
      'checkedInAt': checkedInAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'cancelledById': cancelledById,
      'cancellationReason': cancellationReason,
      'cancellationFee': cancellationFee,
      'rescheduleCount': rescheduleCount,
      'previousSlotId': previousSlotId,
      'paymentMode': paymentMode,
      'collectedAt': collectedAt,
      'collectedById': collectedById,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'service': service.toJson(),
      'offering': offering.toJson(),
      'vendor': vendor.toJson(),
      'order': order.toJson(),
      'orderItem': orderItem.toJson(),
    };
  }

  /// Model → Entity
  BookingEntity toEntity() {
    return BookingEntity(
      id: id,
      uuid: uuid,
      bookingNumber: bookingNumber,
      orderItemId: orderItemId,
      vendorOrderId: vendorOrderId,
      orderId: orderId,
      userId: userId,
      vendorId: vendorId,
      serviceId: serviceId,
      offeringId: offeringId,
      slotId: slotId,
      status: status,
      scheduledStartAt: scheduledStartAt,
      scheduledEndAt: scheduledEndAt,
      participants: participants,
      addressId: addressId,
      outletId: outletId,
      customerNotes: customerNotes,
      vendorNotes: vendorNotes,
      confirmedAt: confirmedAt,
      checkedInAt: checkedInAt,
      startedAt: startedAt,
      completedAt: completedAt,
      cancelledAt: cancelledAt,
      cancelledById: cancelledById,
      cancellationReason: cancellationReason,
      cancellationFee: cancellationFee,
      rescheduleCount: rescheduleCount,
      previousSlotId: previousSlotId,
      paymentMode: paymentMode,
      collectedAt: collectedAt,
      collectedById: collectedById,
      createdAt: createdAt,
      updatedAt: updatedAt,
      service: service.toEntity(),
      offering: offering.toEntity(),
      vendor: vendor.toEntity(),
      order: order.toEntity(),
      orderItem: orderItem.toEntity(),
    );
  }

  /// Entity → Model
  factory BookingModel.fromEntity(BookingEntity entity) {
    return BookingModel(
      id: entity.id,
      uuid: entity.uuid,
      bookingNumber: entity.bookingNumber,
      orderItemId: entity.orderItemId,
      vendorOrderId: entity.vendorOrderId,
      orderId: entity.orderId,
      userId: entity.userId,
      vendorId: entity.vendorId,
      serviceId: entity.serviceId,
      offeringId: entity.offeringId,
      slotId: entity.slotId,
      status: entity.status,
      scheduledStartAt: entity.scheduledStartAt,
      scheduledEndAt: entity.scheduledEndAt,
      participants: entity.participants,
      addressId: entity.addressId,
      outletId: entity.outletId,
      customerNotes: entity.customerNotes,
      vendorNotes: entity.vendorNotes,
      confirmedAt: entity.confirmedAt,
      checkedInAt: entity.checkedInAt,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      cancelledAt: entity.cancelledAt,
      cancelledById: entity.cancelledById,
      cancellationReason: entity.cancellationReason,
      cancellationFee: entity.cancellationFee,
      rescheduleCount: entity.rescheduleCount,
      previousSlotId: entity.previousSlotId,
      paymentMode: entity.paymentMode,
      collectedAt: entity.collectedAt,
      collectedById: entity.collectedById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      service: BookingServiceModel.fromEntity(entity.service),
      offering: BookingOfferingModel.fromEntity(entity.offering),
      vendor: BookingVendorModel.fromEntity(entity.vendor),
      order: BookingOrderModel.fromEntity(entity.order),
      orderItem: BookingOrderItemModel.fromEntity(entity.orderItem),
    );
  }
}

// -----------------------------------------------------------------------------
// SERVICE
// -----------------------------------------------------------------------------

class BookingServiceModel {
  final String uuid;
  final String title;
  final String slug;

  BookingServiceModel({
    required this.uuid,
    required this.title,
    required this.slug,
  });

  factory BookingServiceModel.fromJson(Map<String, dynamic> json) {
    return BookingServiceModel(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'slug': slug,
    };
  }

  BookingServiceEntity toEntity() {
    return BookingServiceEntity(
      uuid: uuid,
      title: title,
      slug: slug,
    );
  }

  factory BookingServiceModel.fromEntity(
    BookingServiceEntity entity,
  ) {
    return BookingServiceModel(
      uuid: entity.uuid,
      title: entity.title,
      slug: entity.slug,
    );
  }
}

// -----------------------------------------------------------------------------
// OFFERING
// -----------------------------------------------------------------------------

class BookingOfferingModel {
  final String uuid;
  final String code;
  final String offeringName;

  BookingOfferingModel({
    required this.uuid,
    required this.code,
    required this.offeringName,
  });

  factory BookingOfferingModel.fromJson(Map<String, dynamic> json) {
    return BookingOfferingModel(
      uuid: json['uuid'] ?? '',
      code: json['code'] ?? '',
      offeringName: json['offeringName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'code': code,
      'offeringName': offeringName,
    };
  }

  BookingOfferingEntity toEntity() {
    return BookingOfferingEntity(
      uuid: uuid,
      code: code,
      offeringName: offeringName,
    );
  }

  factory BookingOfferingModel.fromEntity(
    BookingOfferingEntity entity,
  ) {
    return BookingOfferingModel(
      uuid: entity.uuid,
      code: entity.code,
      offeringName: entity.offeringName,
    );
  }
}

// -----------------------------------------------------------------------------
// VENDOR
// -----------------------------------------------------------------------------

class BookingVendorModel {
  final String uuid;
  final String shopName;
  final String? supportPhone;

  BookingVendorModel({
    required this.uuid,
    required this.shopName,
    this.supportPhone,
  });

  factory BookingVendorModel.fromJson(Map<String, dynamic> json) {
    return BookingVendorModel(
      uuid: json['uuid'] ?? '',
      shopName: json['shopName'] ?? '',
      supportPhone: json['supportPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'shopName': shopName,
      'supportPhone': supportPhone,
    };
  }

  BookingVendorEntity toEntity() {
    return BookingVendorEntity(
      uuid: uuid,
      shopName: shopName,
      supportPhone: supportPhone,
    );
  }

  factory BookingVendorModel.fromEntity(
    BookingVendorEntity entity,
  ) {
    return BookingVendorModel(
      uuid: entity.uuid,
      shopName: entity.shopName,
      supportPhone: entity.supportPhone,
    );
  }
}

// -----------------------------------------------------------------------------
// ORDER
// -----------------------------------------------------------------------------

class BookingOrderModel {
  final String uuid;
  final String orderNumber;

  BookingOrderModel({
    required this.uuid,
    required this.orderNumber,
  });

  factory BookingOrderModel.fromJson(Map<String, dynamic> json) {
    return BookingOrderModel(
      uuid: json['uuid'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'orderNumber': orderNumber,
    };
  }

  BookingOrderEntity toEntity() {
    return BookingOrderEntity(
      uuid: uuid,
      orderNumber: orderNumber,
    );
  }

  factory BookingOrderModel.fromEntity(
    BookingOrderEntity entity,
  ) {
    return BookingOrderModel(
      uuid: entity.uuid,
      orderNumber: entity.orderNumber,
    );
  }
}

// -----------------------------------------------------------------------------
// ORDER ITEM
// -----------------------------------------------------------------------------

class BookingOrderItemModel {
  final String totalAmount;

  BookingOrderItemModel({
    required this.totalAmount,
  });

  factory BookingOrderItemModel.fromJson(Map<String, dynamic> json) {
    return BookingOrderItemModel(
      totalAmount: json['totalAmount']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
    };
  }

  BookingOrderItemEntity toEntity() {
    return BookingOrderItemEntity(
      totalAmount: totalAmount,
    );
  }

  factory BookingOrderItemModel.fromEntity(
    BookingOrderItemEntity entity,
  ) {
    return BookingOrderItemModel(
      totalAmount: entity.totalAmount,
    );
  }
}