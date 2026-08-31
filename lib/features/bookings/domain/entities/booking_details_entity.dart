class BookingDetailsEntity {
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
  final BookingAddressEntity address;
  final BookingOrderEntity order;
  final List<BookingTimelineEntity> timeline;
  final List<BookingAssignmentEntity> assignments;

  BookingDetailsEntity({
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
    required this.address,
    required this.order,
    required this.timeline,
    required this.assignments,
  });
}

class BookingServiceEntity {
  final String id;
  final String uuid;
  final String vendorId;
  final String categoryId;
  final String serviceTypeId;
  final String title;
  final String slug;
  final String shortDescription;
  final String description;
  final String status;
  final int durationMinutes;
  final int bufferMinutes;
  final int leadTimeMinutes;
  final int bookingWindowDays;
  final bool allowSameDayBooking;
  final String? availableFrom;
  final String? availableUntil;
  final bool allowPayAfterService;
  final String? serviceRadiusKm;
  final String? baseAddressId;
  final String latitude;
  final String longitude;
  final String locationLabel;
  final String? cancellationPolicyId;
  final bool isPublished;
  final bool isFeatured;
  final double averageRating;
  final int totalReviews;
  final String listingLevel;
  final String visibility;
  final String? earlyAccessStartAt;
  final String? publicReleaseAt;
  final String? requiredMembershipPlanId;
  final String? subscriptionId;
  final String? approvedById;
  final String? createdById;
  final String? approvedAt;
  final String? rejectedReason;
  final String? seoTitle;
  final String? seoDescription;
  final dynamic tags;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final dynamic policy;

  final BookingServiceTypeEntity serviceType;

  BookingServiceEntity({
    required this.id,
    required this.uuid,
    required this.vendorId,
    required this.categoryId,
    required this.serviceTypeId,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.description,
    required this.status,
    required this.durationMinutes,
    required this.bufferMinutes,
    required this.leadTimeMinutes,
    required this.bookingWindowDays,
    required this.allowSameDayBooking,
    this.availableFrom,
    this.availableUntil,
    required this.allowPayAfterService,
    this.serviceRadiusKm,
    this.baseAddressId,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    this.cancellationPolicyId,
    required this.isPublished,
    required this.isFeatured,
    required this.averageRating,
    required this.totalReviews,
    required this.listingLevel,
    required this.visibility,
    this.earlyAccessStartAt,
    this.publicReleaseAt,
    this.requiredMembershipPlanId,
    this.subscriptionId,
    this.approvedById,
    this.createdById,
    this.approvedAt,
    this.rejectedReason,
    this.seoTitle,
    this.seoDescription,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.policy,
    required this.serviceType,
  });
}

class BookingServiceTypeEntity {
  final String id;
  final String uuid;
  final String code;
  final String name;
  final String description;
  final String schedulingModel;
  final String deliveryMode;
  final String capacityModel;
  final bool requiresQuotation;
  final bool requiresStaff;
  final bool requiresResource;
  final bool allowsRescheduling;
  final bool isActive;
  final bool isSystem;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  BookingServiceTypeEntity({
    required this.id,
    required this.uuid,
    required this.code,
    required this.name,
    required this.description,
    required this.schedulingModel,
    required this.deliveryMode,
    required this.capacityModel,
    required this.requiresQuotation,
    required this.requiresStaff,
    required this.requiresResource,
    required this.allowsRescheduling,
    required this.isActive,
    required this.isSystem,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
}

class BookingOfferingEntity {
  final String id;
  final String uuid;
  final String serviceId;
  final String code;
  final String title;
  final String offeringName;
  final String combinationKey;
  final String? description;
  final String pricingModelId;
  final String basePrice;
  final String? salePrice;
  final String currency;
  final int durationMinutes;
  final int minParticipants;
  final int maxParticipants;
  final bool isDefault;
  final bool isActive;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  BookingOfferingEntity({
    required this.id,
    required this.uuid,
    required this.serviceId,
    required this.code,
    required this.title,
    required this.offeringName,
    required this.combinationKey,
    this.description,
    required this.pricingModelId,
    required this.basePrice,
    this.salePrice,
    required this.currency,
    required this.durationMinutes,
    required this.minParticipants,
    required this.maxParticipants,
    required this.isDefault,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
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

class BookingAddressEntity {
  final String id;
  final String userId;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? landmark;
  final String? latitude;
  final String? longitude;
  final bool isDefault;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  BookingAddressEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.landmark,
    this.latitude,
    this.longitude,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
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

class BookingTimelineEntity {
  final String id;
  final String bookingId;
  final String status;
  final String note;
  final String? actorId;
  final String? actorRole;
  final String eventTime;

  BookingTimelineEntity({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.note,
    this.actorId,
    this.actorRole,
    required this.eventTime,
  });
}

class BookingAssignmentEntity {
  final String? id;

  BookingAssignmentEntity({
    this.id,
  });
}