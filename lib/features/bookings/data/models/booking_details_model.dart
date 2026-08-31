import '../../domain/entities/booking_details_entity.dart';

class BookingDetailsModel {
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
  final BookingAddressModel address;
  final BookingOrderModel order;
  final List<BookingTimelineModel> timeline;
  final List<BookingAssignmentModel> assignments;

  BookingDetailsModel({
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

  /// JSON → Model
  factory BookingDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingDetailsModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      bookingNumber: json['bookingNumber'] ?? '',
      orderItemId: json['orderItemId']?.toString() ?? '',
      vendorOrderId: json['vendorOrderId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      offeringId: json['offeringId']?.toString() ?? '',
      slotId: json['slotId']?.toString() ?? '',
      status: json['status'] ?? '',
      scheduledStartAt: json['scheduledStartAt'] ?? '',
      scheduledEndAt: json['scheduledEndAt'] ?? '',
      participants: json['participants'] ?? 0,
      addressId: json['addressId']?.toString() ?? '',
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
      cancellationFee: json['cancellationFee']?.toString(),
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
      address: BookingAddressModel.fromJson(
        json['address'] ?? {},
      ),
      order: BookingOrderModel.fromJson(
        json['order'] ?? {},
      ),
      timeline: (json['timeline'] as List? ?? [])
          .map(
            (item) => BookingTimelineModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      assignments: (json['assignments'] as List? ?? [])
          .map(
            (item) => BookingAssignmentModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  /// Model → Entity
  BookingDetailsEntity toEntity() {
    return BookingDetailsEntity(
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
      address: address.toEntity(),
      order: order.toEntity(),
      timeline: timeline.map((item) => item.toEntity()).toList(),
      assignments: assignments.map((item) => item.toEntity()).toList(),
    );
  }

  /// Entity → Model
  factory BookingDetailsModel.fromEntity(
    BookingDetailsEntity entity,
  ) {
    return BookingDetailsModel(
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
      address: BookingAddressModel.fromEntity(entity.address),
      order: BookingOrderModel.fromEntity(entity.order),
      timeline: entity.timeline
          .map((item) => BookingTimelineModel.fromEntity(item))
          .toList(),
      assignments: entity.assignments
          .map((item) => BookingAssignmentModel.fromEntity(item))
          .toList(),
    );
  }
}

class BookingServiceModel {
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

  final BookingServiceTypeModel serviceType;

  BookingServiceModel({
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

  factory BookingServiceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingServiceModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      serviceTypeId: json['serviceTypeId']?.toString() ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      shortDescription: json['shortDescription'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      bufferMinutes: json['bufferMinutes'] ?? 0,
      leadTimeMinutes: json['leadTimeMinutes'] ?? 0,
      bookingWindowDays: json['bookingWindowDays'] ?? 0,
      allowSameDayBooking: json['allowSameDayBooking'] ?? false,
      availableFrom: json['availableFrom'],
      availableUntil: json['availableUntil'],
      allowPayAfterService:
          json['allowPayAfterService'] ?? false,
      serviceRadiusKm:
          json['serviceRadiusKm']?.toString(),
      baseAddressId:
          json['baseAddressId']?.toString(),
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      locationLabel: json['locationLabel'] ?? '',
      cancellationPolicyId:
          json['cancellationPolicyId']?.toString(),
      isPublished: json['isPublished'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      averageRating:
          (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      listingLevel: json['listingLevel'] ?? '',
      visibility: json['visibility'] ?? '',
      earlyAccessStartAt:
          json['earlyAccessStartAt'],
      publicReleaseAt:
          json['publicReleaseAt'],
      requiredMembershipPlanId:
          json['requiredMembershipPlanId']?.toString(),
      subscriptionId:
          json['subscriptionId']?.toString(),
      approvedById:
          json['approvedById']?.toString(),
      createdById:
          json['createdById']?.toString(),
      approvedAt: json['approvedAt'],
      rejectedReason: json['rejectedReason'],
      seoTitle: json['seoTitle'],
      seoDescription: json['seoDescription'],
      tags: json['tags'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
      policy: json['policy'],
      serviceType:
          BookingServiceTypeModel.fromJson(
        json['serviceType'] ?? {},
      ),
    );
  }

  BookingServiceEntity toEntity() {
    return BookingServiceEntity(
      id: id,
      uuid: uuid,
      vendorId: vendorId,
      categoryId: categoryId,
      serviceTypeId: serviceTypeId,
      title: title,
      slug: slug,
      shortDescription: shortDescription,
      description: description,
      status: status,
      durationMinutes: durationMinutes,
      bufferMinutes: bufferMinutes,
      leadTimeMinutes: leadTimeMinutes,
      bookingWindowDays: bookingWindowDays,
      allowSameDayBooking: allowSameDayBooking,
      availableFrom: availableFrom,
      availableUntil: availableUntil,
      allowPayAfterService: allowPayAfterService,
      serviceRadiusKm: serviceRadiusKm,
      baseAddressId: baseAddressId,
      latitude: latitude,
      longitude: longitude,
      locationLabel: locationLabel,
      cancellationPolicyId: cancellationPolicyId,
      isPublished: isPublished,
      isFeatured: isFeatured,
      averageRating: averageRating,
      totalReviews: totalReviews,
      listingLevel: listingLevel,
      visibility: visibility,
      earlyAccessStartAt: earlyAccessStartAt,
      publicReleaseAt: publicReleaseAt,
      requiredMembershipPlanId:
          requiredMembershipPlanId,
      subscriptionId: subscriptionId,
      approvedById: approvedById,
      createdById: createdById,
      approvedAt: approvedAt,
      rejectedReason: rejectedReason,
      seoTitle: seoTitle,
      seoDescription: seoDescription,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      policy: policy,
      serviceType: serviceType.toEntity(),
    );
  }

  factory BookingServiceModel.fromEntity(
    BookingServiceEntity entity,
  ) {
    return BookingServiceModel(
      id: entity.id,
      uuid: entity.uuid,
      vendorId: entity.vendorId,
      categoryId: entity.categoryId,
      serviceTypeId: entity.serviceTypeId,
      title: entity.title,
      slug: entity.slug,
      shortDescription: entity.shortDescription,
      description: entity.description,
      status: entity.status,
      durationMinutes: entity.durationMinutes,
      bufferMinutes: entity.bufferMinutes,
      leadTimeMinutes: entity.leadTimeMinutes,
      bookingWindowDays: entity.bookingWindowDays,
      allowSameDayBooking: entity.allowSameDayBooking,
      availableFrom: entity.availableFrom,
      availableUntil: entity.availableUntil,
      allowPayAfterService: entity.allowPayAfterService,
      serviceRadiusKm: entity.serviceRadiusKm,
      baseAddressId: entity.baseAddressId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      locationLabel: entity.locationLabel,
      cancellationPolicyId: entity.cancellationPolicyId,
      isPublished: entity.isPublished,
      isFeatured: entity.isFeatured,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      listingLevel: entity.listingLevel,
      visibility: entity.visibility,
      earlyAccessStartAt: entity.earlyAccessStartAt,
      publicReleaseAt: entity.publicReleaseAt,
      requiredMembershipPlanId:
          entity.requiredMembershipPlanId,
      subscriptionId: entity.subscriptionId,
      approvedById: entity.approvedById,
      createdById: entity.createdById,
      approvedAt: entity.approvedAt,
      rejectedReason: entity.rejectedReason,
      seoTitle: entity.seoTitle,
      seoDescription: entity.seoDescription,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      policy: entity.policy,
      serviceType:
          BookingServiceTypeModel.fromEntity(
        entity.serviceType,
      ),
    );
  }
}

class BookingServiceTypeModel {
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

  BookingServiceTypeModel({
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

  factory BookingServiceTypeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingServiceTypeModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      schedulingModel:
          json['schedulingModel'] ?? '',
      deliveryMode:
          json['deliveryMode'] ?? '',
      capacityModel:
          json['capacityModel'] ?? '',
      requiresQuotation:
          json['requiresQuotation'] ?? false,
      requiresStaff:
          json['requiresStaff'] ?? false,
      requiresResource:
          json['requiresResource'] ?? false,
      allowsRescheduling:
          json['allowsRescheduling'] ?? false,
      isActive: json['isActive'] ?? false,
      isSystem: json['isSystem'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  BookingServiceTypeEntity toEntity() {
    return BookingServiceTypeEntity(
      id: id,
      uuid: uuid,
      code: code,
      name: name,
      description: description,
      schedulingModel: schedulingModel,
      deliveryMode: deliveryMode,
      capacityModel: capacityModel,
      requiresQuotation: requiresQuotation,
      requiresStaff: requiresStaff,
      requiresResource: requiresResource,
      allowsRescheduling: allowsRescheduling,
      isActive: isActive,
      isSystem: isSystem,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory BookingServiceTypeModel.fromEntity(
    BookingServiceTypeEntity entity,
  ) {
    return BookingServiceTypeModel(
      id: entity.id,
      uuid: entity.uuid,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      schedulingModel: entity.schedulingModel,
      deliveryMode: entity.deliveryMode,
      capacityModel: entity.capacityModel,
      requiresQuotation: entity.requiresQuotation,
      requiresStaff: entity.requiresStaff,
      requiresResource: entity.requiresResource,
      allowsRescheduling: entity.allowsRescheduling,
      isActive: entity.isActive,
      isSystem: entity.isSystem,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class BookingOfferingModel {
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

  BookingOfferingModel({
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

  factory BookingOfferingModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingOfferingModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid'] ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      offeringName: json['offeringName'] ?? '',
      combinationKey: json['combinationKey'] ?? '',
      description: json['description'],
      pricingModelId:
          json['pricingModelId']?.toString() ?? '',
      basePrice:
          json['basePrice']?.toString() ?? '0',
      salePrice:
          json['salePrice']?.toString(),
      currency: json['currency'] ?? '',
      durationMinutes:
          json['durationMinutes'] ?? 0,
      minParticipants:
          json['minParticipants'] ?? 0,
      maxParticipants:
          json['maxParticipants'] ?? 0,
      isDefault:
          json['isDefault'] ?? false,
      isActive:
          json['isActive'] ?? false,
      sortOrder:
          json['sortOrder'] ?? 0,
      createdAt:
          json['createdAt'] ?? '',
      updatedAt:
          json['updatedAt'] ?? '',
    );
  }

  BookingOfferingEntity toEntity() {
    return BookingOfferingEntity(
      id: id,
      uuid: uuid,
      serviceId: serviceId,
      code: code,
      title: title,
      offeringName: offeringName,
      combinationKey: combinationKey,
      description: description,
      pricingModelId: pricingModelId,
      basePrice: basePrice,
      salePrice: salePrice,
      currency: currency,
      durationMinutes: durationMinutes,
      minParticipants: minParticipants,
      maxParticipants: maxParticipants,
      isDefault: isDefault,
      isActive: isActive,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory BookingOfferingModel.fromEntity(
    BookingOfferingEntity entity,
  ) {
    return BookingOfferingModel(
      id: entity.id,
      uuid: entity.uuid,
      serviceId: entity.serviceId,
      code: entity.code,
      title: entity.title,
      offeringName: entity.offeringName,
      combinationKey: entity.combinationKey,
      description: entity.description,
      pricingModelId: entity.pricingModelId,
      basePrice: entity.basePrice,
      salePrice: entity.salePrice,
      currency: entity.currency,
      durationMinutes: entity.durationMinutes,
      minParticipants: entity.minParticipants,
      maxParticipants: entity.maxParticipants,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

class BookingVendorModel {
  final String uuid;
  final String shopName;
  final String? supportPhone;

  BookingVendorModel({
    required this.uuid,
    required this.shopName,
    this.supportPhone,
  });

  factory BookingVendorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingVendorModel(
      uuid: json['uuid'] ?? '',
      shopName: json['shopName'] ?? '',
      supportPhone: json['supportPhone'],
    );
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

class BookingAddressModel {
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

  BookingAddressModel({
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

  factory BookingAddressModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingAddressModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      landmark: json['landmark'],
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      deletedAt: json['deletedAt'],
    );
  }

  BookingAddressEntity toEntity() {
    return BookingAddressEntity(
      id: id,
      userId: userId,
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      landmark: landmark,
      latitude: latitude,
      longitude: longitude,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  factory BookingAddressModel.fromEntity(
    BookingAddressEntity entity,
  ) {
    return BookingAddressModel(
      id: entity.id,
      userId: entity.userId,
      fullName: entity.fullName,
      phone: entity.phone,
      addressLine1: entity.addressLine1,
      addressLine2: entity.addressLine2,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
      landmark: entity.landmark,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }
}

class BookingOrderModel {
  final String uuid;
  final String orderNumber;

  BookingOrderModel({
    required this.uuid,
    required this.orderNumber,
  });

  factory BookingOrderModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingOrderModel(
      uuid: json['uuid'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
    );
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

class BookingTimelineModel {
  final String id;
  final String bookingId;
  final String status;
  final String note;
  final String? actorId;
  final String? actorRole;
  final String eventTime;

  BookingTimelineModel({
    required this.id,
    required this.bookingId,
    required this.status,
    required this.note,
    this.actorId,
    this.actorRole,
    required this.eventTime,
  });

  factory BookingTimelineModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingTimelineModel(
      id: json['id']?.toString() ?? '',
      bookingId:
          json['bookingId']?.toString() ?? '',
      status: json['status'] ?? '',
      note: json['note'] ?? '',
      actorId: json['actorId']?.toString(),
      actorRole: json['actorRole'],
      eventTime: json['eventTime'] ?? '',
    );
  }

  BookingTimelineEntity toEntity() {
    return BookingTimelineEntity(
      id: id,
      bookingId: bookingId,
      status: status,
      note: note,
      actorId: actorId,
      actorRole: actorRole,
      eventTime: eventTime,
    );
  }

  factory BookingTimelineModel.fromEntity(
    BookingTimelineEntity entity,
  ) {
    return BookingTimelineModel(
      id: entity.id,
      bookingId: entity.bookingId,
      status: entity.status,
      note: entity.note,
      actorId: entity.actorId,
      actorRole: entity.actorRole,
      eventTime: entity.eventTime,
    );
  }
}

class BookingAssignmentModel {
  final String? id;

  BookingAssignmentModel({
    this.id,
  });

  factory BookingAssignmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BookingAssignmentModel(
      id: json['id']?.toString(),
    );
  }

  BookingAssignmentEntity toEntity() {
    return BookingAssignmentEntity(
      id: id,
    );
  }

  factory BookingAssignmentModel.fromEntity(
    BookingAssignmentEntity entity,
  ) {
    return BookingAssignmentModel(
      id: entity.id,
    );
  }
}