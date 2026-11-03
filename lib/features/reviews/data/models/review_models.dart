// Shapes of the /reviews API (inside the `data` envelope).

int _int(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse('$v')?.toLocal();
List<Map<String, dynamic>> _maps(dynamic v) =>
    v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];
Map<String, dynamic> _map(dynamic v) =>
    v is Map<String, dynamic> ? v : const {};

enum ReviewKind { product, agent }

const reviewStatusLabels = {
  'APPROVED': 'Published',
  'PENDING': 'Under review',
  'REJECTED': 'Not published',
  'HIDDEN': 'Hidden',
};

/// Why a line cannot be reviewed, in the customer's words.
const reviewReasonText = {
  'NOT_DELIVERED': 'Available after delivery',
  'CANCELLED': "Cancelled items can't be reviewed",
  'WINDOW_CLOSED': 'Review period has ended',
  'PRODUCT_REMOVED': 'This product is no longer available',
};

/// A review already written, as eligibility reports it.
class ReviewRef {
  final String uuid;
  final int rating;
  final String status;

  const ReviewRef({
    required this.uuid,
    required this.rating,
    required this.status,
  });

  static ReviewRef? fromJson(dynamic j) => j is Map<String, dynamic>
      ? ReviewRef(
          uuid: '${j['uuid']}',
          rating: _int(j['rating']),
          status: '${j['status'] ?? ''}',
        )
      : null;
}

/// Whether one product line, or one delivery, can be reviewed now.
class ReviewSlot {
  final bool eligible;
  final String? reason;
  final DateTime? reviewableUntil;
  final ReviewRef? review;

  const ReviewSlot({
    required this.eligible,
    this.reason,
    this.reviewableUntil,
    this.review,
  });

  factory ReviewSlot.fromJson(Map<String, dynamic> j) => ReviewSlot(
    eligible: j['eligible'] == true,
    reason: j['reason'] as String?,
    reviewableUntil: _date(j['reviewableUntil']),
    review: ReviewRef.fromJson(j['review']),
  );

  /// What to show when there is neither a review nor a write button.
  String? get reasonText => reviewReasonText[reason];
}

class ReviewItemSlot {
  final String orderItemId;
  final String? productUuid;
  final String title;
  final ReviewSlot slot;

  const ReviewItemSlot({
    required this.orderItemId,
    this.productUuid,
    required this.title,
    required this.slot,
  });

  factory ReviewItemSlot.fromJson(Map<String, dynamic> j) => ReviewItemSlot(
    orderItemId: '${j['orderItemId']}',
    productUuid: j['productUuid'] as String?,
    title: '${j['title'] ?? ''}',
    slot: ReviewSlot.fromJson(j),
  );
}

class ReviewDelivery {
  final String vendorOrderUuid;
  final String shopName;

  /// The agent the server named for this delivery, if any.
  final String? agentUuid;
  final String? agentName;
  final ReviewSlot agentReview;
  final List<ReviewItemSlot> items;

  const ReviewDelivery({
    required this.vendorOrderUuid,
    this.shopName = '',
    this.agentUuid,
    this.agentName,
    required this.agentReview,
    this.items = const [],
  });

  factory ReviewDelivery.fromJson(Map<String, dynamic> j) {
    final agent = j['agent'] is Map<String, dynamic>
        ? j['agent'] as Map<String, dynamic>
        : null;
    return ReviewDelivery(
      vendorOrderUuid: '${j['vendorOrderUuid']}',
      shopName: '${_map(j['vendor'])['shopName'] ?? ''}',
      agentUuid: agent?['uuid'] as String?,
      agentName: agent?['name'] as String?,
      agentReview: ReviewSlot.fromJson(_map(j['agentReview'])),
      items: _maps(j['items']).map(ReviewItemSlot.fromJson).toList(),
    );
  }
}

class ReviewEligibility {
  final bool canWrite;

  /// Why this account cannot write reviews, when [canWrite] is false.
  final String? message;
  final List<ReviewDelivery> deliveries;

  const ReviewEligibility({
    required this.canWrite,
    this.message,
    this.deliveries = const [],
  });

  factory ReviewEligibility.fromJson(Map<String, dynamic> j) =>
      ReviewEligibility(
        canWrite: j['canWrite'] == true,
        message: j['message'] as String?,
        deliveries: _maps(
          j['deliveries'],
        ).map(ReviewDelivery.fromJson).toList(),
      );

  /// The agent row shows only with a named agent and something to show.
  bool showsAgent(ReviewDelivery d) =>
      d.agentUuid != null &&
      (d.agentReview.review != null || (canWrite && d.agentReview.eligible));

  /// Nothing written, writable or explained: the section stays hidden.
  bool get hasAnything =>
      (message ?? '').isNotEmpty ||
      deliveries.any(
        (d) =>
            showsAgent(d) ||
            d.items.any(
              (i) =>
                  i.slot.review != null ||
                  (canWrite && i.slot.eligible) ||
                  i.slot.reasonText != null,
            ),
      );
}

/// A product review or a delivery rating, as its author or a shopper sees it.
class Review {
  final ReviewKind kind;
  final String uuid;
  final int rating;
  final String? title;
  final String? comment;
  final List<String> images;
  final String reviewer;
  final bool verifiedPurchase;
  final DateTime? createdAt;

  /// Author view only.
  final String? status;
  final String? moderationNote;
  final bool canEdit;

  /// The product's title, or who delivered the order.
  final String subject;

  const Review({
    required this.kind,
    required this.uuid,
    required this.rating,
    this.title,
    this.comment,
    this.images = const [],
    this.reviewer = '',
    this.verifiedPurchase = false,
    this.createdAt,
    this.status,
    this.moderationNote,
    this.canEdit = false,
    this.subject = '',
  });

  factory Review.fromJson(Map<String, dynamic> j, ReviewKind kind) {
    final agent = _map(j['agent']);
    final orderNumber = _map(j['order'])['orderNumber'];
    return Review(
      kind: kind,
      uuid: '${j['uuid']}',
      rating: _int(j['rating']),
      title: j['title'] as String?,
      comment: j['comment'] as String?,
      // Only http(s) URLs reach an image widget.
      images: (j['images'] is List)
          ? (j['images'] as List)
                .whereType<String>()
                .where((u) => u.startsWith('http'))
                .toList()
          : const [],
      reviewer: '${j['reviewer'] ?? ''}',
      verifiedPurchase: j['verifiedPurchase'] == true,
      createdAt: _date(j['createdAt']),
      status: j['status'] as String?,
      moderationNote: j['moderationNote'] as String?,
      canEdit: j['canEdit'] == true,
      subject: kind == ReviewKind.product
          ? '${_map(j['product'])['title'] ?? ''}'
          : [
              'Delivery by ${agent['name'] ?? 'agent'}',
              if (orderNumber != null) 'order $orderNumber',
            ].join(' · '),
    );
  }
}

class ReviewSummary {
  final double? averageRating;
  final int totalReviews;

  /// stars (1–5) → count.
  final Map<int, int> distribution;

  const ReviewSummary({
    this.averageRating,
    this.totalReviews = 0,
    this.distribution = const {},
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> j) => ReviewSummary(
    averageRating: (j['averageRating'] as num?)?.toDouble(),
    totalReviews: _int(j['totalReviews']),
    distribution: {
      for (final e in _map(j['distribution']).entries)
        _int(e.key): _int(e.value),
    },
  );
}
