import '../../../orders/data/models/order_model.dart' show titleCaseStatus;

// The API sends money as strings ("12.50") and ids as strings.
double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse('$v')?.toLocal();
List<Map<String, dynamic>> _maps(dynamic v) =>
    v is List ? v.whereType<Map<String, dynamic>>().toList() : const [];
Map<String, dynamic> _map(dynamic v) =>
    v is Map<String, dynamic> ? v : const {};

const refundStatusLabels = {
  'VENDOR_REVIEW': 'With the seller',
  'ADMIN_REVIEW': 'With our team',
  'APPROVED': 'Approved',
  'REJECTED': 'Rejected',
  'REFUNDING': 'Refund on its way',
  'REFUNDED': 'Refunded',
  'REFUND_FAILED': 'Refund delayed',
  'CANCELLED': 'Withdrawn',
};

const refundActionLabels = {
  'SUBMITTED': 'Request sent',
  'AUTO_APPROVED': 'Approved automatically under the refund policy',
  'VENDOR_ACCEPTED': 'Seller accepted',
  'VENDOR_DISPUTED': 'Seller disputed — sent to our team',
  'ESCALATED': 'Seller did not answer in time — sent to our team',
  'ADMIN_APPROVED': 'Approved by our team',
  'ADMIN_REJECTED': 'Rejected by our team',
  'REFUND_STARTED': 'Refund sent',
  'REFUND_START_FAILED': 'Refund could not be started',
  'AUTO_REFUND_SKIPPED': 'Waiting for an admin to send the refund',
  'REFUNDED': 'Money returned',
  'REFUND_FAILED': 'Refund failed',
  'REFUND_CANCELLED': 'Refund cancelled — can be sent again',
  'CANCELLED': 'Withdrawn by the customer',
};

const refundActorLabels = {
  'CUSTOMER': 'You',
  'VENDOR': 'Seller',
  'ADMIN': 'Our team',
  'SYSTEM': 'System',
};

class RefundReason {
  final String code;
  final String label;
  final bool requiresEvidence;
  final bool customerPaysCharges;

  const RefundReason({
    required this.code,
    required this.label,
    this.requiresEvidence = false,
    this.customerPaysCharges = false,
  });

  factory RefundReason.fromJson(Map<String, dynamic> j) => RefundReason(
    code: '${j['code'] ?? ''}',
    label: '${j['label'] ?? j['code'] ?? ''}',
    requiresEvidence: j['requiresEvidence'] == true,
    customerPaysCharges: j['customerPaysCharges'] == true,
  );
}

/// One order line as the refund policy sees it right now.
class RefundLine {
  final String orderItemId;
  final String title;
  final String shopName;
  final int quantity;
  final double totalAmount;
  final bool eligible;
  final int maxQuantity;

  /// Why it cannot be asked for, when not [eligible].
  final String? reason;
  final DateTime? deadline;
  final List<RefundReason> reasons;
  final double restockingFeePercent;

  const RefundLine({
    required this.orderItemId,
    required this.title,
    this.shopName = '',
    this.quantity = 1,
    this.totalAmount = 0,
    required this.eligible,
    this.maxQuantity = 0,
    this.reason,
    this.deadline,
    this.reasons = const [],
    this.restockingFeePercent = 0,
  });

  factory RefundLine.fromJson(Map<String, dynamic> j) => RefundLine(
    orderItemId: '${j['orderItemId']}',
    title: '${j['title'] ?? ''}',
    shopName: '${_map(j['vendor'])['shopName'] ?? ''}',
    quantity: _num(j['quantity']).toInt(),
    totalAmount: _num(j['totalAmount']),
    eligible: j['eligible'] == true,
    maxQuantity: _num(j['maxQuantity']).toInt(),
    reason: j['reason'] as String?,
    deadline: _date(j['deadline']),
    reasons: _maps(j['reasons']).map(RefundReason.fromJson).toList(),
    restockingFeePercent: _num(j['restockingFeePercent']),
  );

  /// Value of [qty] units, as the server works it out.
  double valueOf(int qty) => quantity == 0 ? 0 : totalAmount * qty / quantity;
}

class RefundEligibility {
  final String orderNumber;
  final bool available;

  /// Why nothing on the order can be asked for (e.g. not paid).
  final String? message;
  final List<RefundLine> lines;

  const RefundEligibility({
    this.orderNumber = '',
    required this.available,
    this.message,
    this.lines = const [],
  });

  factory RefundEligibility.fromJson(Map<String, dynamic> j) =>
      RefundEligibility(
        orderNumber: '${_map(j['order'])['orderNumber'] ?? ''}',
        available: j['available'] == true,
        message: j['message'] as String?,
        lines: _maps(j['lines']).map(RefundLine.fromJson).toList(),
      );
}

class RefundRequestItem {
  final String title;
  final String sku;
  final int quantity;
  final double amount;

  const RefundRequestItem({
    required this.title,
    this.sku = '',
    this.quantity = 1,
    this.amount = 0,
  });

  factory RefundRequestItem.fromJson(Map<String, dynamic> j) =>
      RefundRequestItem(
        title: '${j['title'] ?? ''}',
        sku: '${j['sku'] ?? ''}',
        quantity: _num(j['quantity']).toInt(),
        amount: _num(j['amount']),
      );
}

class RefundEvent {
  final String actorType;
  final String action;
  final String? note;
  final DateTime? createdAt;

  const RefundEvent({
    required this.actorType,
    required this.action,
    this.note,
    this.createdAt,
  });

  factory RefundEvent.fromJson(Map<String, dynamic> j) => RefundEvent(
    actorType: '${j['actorType'] ?? ''}',
    action: '${j['action'] ?? ''}',
    note: j['note'] as String?,
    createdAt: _date(j['createdAt']),
  );

  String get label => refundActionLabels[action] ?? titleCaseStatus(action);
  String get actor => refundActorLabels[actorType] ?? actorType;
}

class RefundRequestModel {
  final String uuid;
  final String reference;
  final String status;
  final String reasonLabel;
  final String? description;
  final List<String> evidence;
  final double itemsAmount;
  final double chargesAmount;
  final double refundAmount;
  final DateTime? vendorRespondBy;
  final String? adminNote;
  final DateTime? createdAt;
  final String orderNumber;
  final String shopName;
  final List<RefundRequestItem> items;
  final String? refundReference;
  final List<RefundEvent> events;

  const RefundRequestModel({
    required this.uuid,
    this.reference = '',
    required this.status,
    this.reasonLabel = '',
    this.description,
    this.evidence = const [],
    this.itemsAmount = 0,
    this.chargesAmount = 0,
    this.refundAmount = 0,
    this.vendorRespondBy,
    this.adminNote,
    this.createdAt,
    this.orderNumber = '',
    this.shopName = '',
    this.items = const [],
    this.refundReference,
    this.events = const [],
  });

  factory RefundRequestModel.fromJson(Map<String, dynamic> j) =>
      RefundRequestModel(
        uuid: '${j['uuid']}',
        reference: '${j['reference'] ?? ''}',
        status: '${j['status'] ?? ''}',
        reasonLabel: '${j['reasonLabel'] ?? j['reasonCode'] ?? ''}',
        description: j['description'] as String?,
        evidence: (j['evidence'] is List)
            ? (j['evidence'] as List).whereType<String>().toList()
            : const [],
        itemsAmount: _num(j['itemsAmount']),
        chargesAmount: _num(j['chargesAmount']),
        refundAmount: _num(j['refundAmount']),
        vendorRespondBy: _date(j['vendorRespondBy']),
        adminNote: j['adminNote'] as String?,
        createdAt: _date(j['createdAt']),
        orderNumber: '${_map(j['order'])['orderNumber'] ?? ''}',
        shopName: '${_map(j['vendor'])['shopName'] ?? ''}',
        items: _maps(j['items']).map(RefundRequestItem.fromJson).toList(),
        refundReference: _map(j['refund'])['reference'] as String?,
        events: _maps(j['events']).map(RefundEvent.fromJson).toList(),
      );

  String get statusLabel =>
      refundStatusLabels[status] ?? titleCaseStatus(status);

  /// The customer may withdraw while nobody has paid anything out.
  bool get canCancel =>
      const {'VENDOR_REVIEW', 'ADMIN_REVIEW', 'APPROVED'}.contains(status);
}
