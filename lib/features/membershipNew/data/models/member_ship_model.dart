import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// helpers
// ---------------------------------------------------------------------------

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

num? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

bool _flag(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  return v?.toString().toLowerCase() == 'true';
}

String _titleCase(String raw) => raw
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

/// 10.0 -> "10", 10.5 -> "10.5"
String trimNumber(num v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

String _currencySymbol(String currency) => switch (currency.toUpperCase()) {
  'USD' => '\$',
  'SGD' => 'S\$',
  'INR' => '\u20B9',
  'EUR' => '\u20AC',
  'GBP' => '\u00A3',
  '' => '',
  _ => '${currency.toUpperCase()} ',
};

// ---------------------------------------------------------------------------
// root model  (maps `data.data` of GET /membership)
// ---------------------------------------------------------------------------

class MembershipModel extends Equatable {
  final MembershipPlan? plan;
  final MembershipSubscription? subscription;
  final List<MembershipSubscriptionSummary> allSubscriptions;

  /// subscribe ho chuka hai par payment on-chain confirm nahi hua
  final MembershipPending? pending;

  /// Insertion order of the API is preserved.
  final Map<String, MembershipEntitlement> entitlements;

  final DateTime? resolvedAt;
  final DateTime? validUntil;

  const MembershipModel({
    this.plan,
    this.subscription,
    this.allSubscriptions = const [],
    this.pending,
    this.entitlements = const {},
    this.resolvedAt,
    this.validUntil,
  });

  bool get hasMembership => subscription != null;

  bool get isActive => subscription?.isActive ?? false;

  bool get hasPending => pending != null;

  /// na member hai na pending -> free plan
  bool get isGuest => subscription == null && pending == null;

  List<MembershipEntitlement> _group(String group) {
    final list = entitlements.values
        .where((e) => e.group.toUpperCase() == group)
        .toList();
    list.sort((a, b) {
      if (a.enabled == b.enabled) return a.name.compareTo(b.name);
      return a.enabled ? -1 : 1;
    });
    return list;
  }

  /// group == BENEFIT
  List<MembershipEntitlement> get benefits => _group('BENEFIT');

  /// group == ACCESS
  List<MembershipEntitlement> get accessRights => _group('ACCESS');

  /// Anything the API sends with an unknown group.
  List<MembershipEntitlement> get otherEntitlements {
    const known = {'BENEFIT', 'ACCESS'};
    return entitlements.values
        .where((e) => !known.contains(e.group.toUpperCase()))
        .toList();
  }

  int get activeBenefitCount =>
      entitlements.values.where((e) => e.enabled).length;

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    final rawEntitlements = json['entitlements'];
    final parsed = <String, MembershipEntitlement>{};
    if (rawEntitlements is Map) {
      rawEntitlements.forEach((key, value) {
        if (value is Map) {
          parsed[key.toString()] = MembershipEntitlement.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    final rawAll = json['allSubscriptions'];

    return MembershipModel(
      plan: json['plan'] is Map
          ? MembershipPlan.fromJson(Map<String, dynamic>.from(json['plan']))
          : null,
      subscription: json['subscription'] is Map
          ? MembershipSubscription.fromJson(
        Map<String, dynamic>.from(json['subscription']),
      )
          : null,
      allSubscriptions: rawAll is List
          ? rawAll
          .whereType<Map>()
          .map(
            (e) => MembershipSubscriptionSummary.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : const [],
      pending: json['pending'] is Map
          ? MembershipPending.fromJson(
        Map<String, dynamic>.from(json['pending']),
      )
          : null,
      entitlements: parsed,
      resolvedAt: _date(json['resolvedAt']),
      validUntil: _date(json['validUntil']),
    );
  }

  @override
  List<Object?> get props => [
    plan,
    subscription,
    allSubscriptions,
    pending,
    entitlements,
    resolvedAt,
    validUntil,
  ];
}

// ---------------------------------------------------------------------------
// plan
// ---------------------------------------------------------------------------

class MembershipPlan extends Equatable {
  final String uuid;
  final String code;
  final String name;
  final String kind;
  final int rank;

  const MembershipPlan({
    required this.uuid,
    required this.code,
    required this.name,
    required this.kind,
    required this.rank,
  });

  /// CUSTOMER_CLUB -> Customer Club
  String get kindLabel => _titleCase(kind);

  factory MembershipPlan.fromJson(Map<String, dynamic> json) => MembershipPlan(
    uuid: json['uuid']?.toString() ?? '',
    code: json['code']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    kind: json['kind']?.toString() ?? '',
    rank: (_num(json['rank']) ?? 0).toInt(),
  );

  @override
  List<Object?> get props => [uuid, code, name, kind, rank];
}

// ---------------------------------------------------------------------------
// subscription
// ---------------------------------------------------------------------------

class MembershipSubscription extends Equatable {
  final String id;
  final String uuid;
  final String reference;
  final String status;
  final DateTime? startAt;
  final DateTime? endAt;
  final String billingCycle;
  final num? price;
  final String currency;
  final bool autoRenew;
  final int planVersion;

  const MembershipSubscription({
    required this.id,
    required this.uuid,
    required this.reference,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.billingCycle,
    required this.price,
    required this.currency,
    required this.autoRenew,
    required this.planVersion,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  bool get isExpired =>
      (endAt != null && endAt!.isBefore(DateTime.now())) || !isActive;

  String get statusLabel => _titleCase(status);

  String get billingCycleLabel => _titleCase(billingCycle);

  int get totalDays {
    if (startAt == null || endAt == null) return 0;
    final d = endAt!.difference(startAt!).inDays;
    return d < 0 ? 0 : d;
  }

  int get daysRemaining {
    if (endAt == null) return 0;
    final d = endAt!.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  /// 0.0 -> just started, 1.0 -> fully consumed
  double get progress {
    if (totalDays <= 0) return 0;
    final used = totalDays - daysRemaining;
    return (used / totalDays).clamp(0.0, 1.0);
  }

  String get currencySymbol => _currencySymbol(currency);

  String get priceLabel =>
      price == null ? '--' : '$currencySymbol${trimNumber(price!)}';

  factory MembershipSubscription.fromJson(Map<String, dynamic> json) =>
      MembershipSubscription(
        id: json['id']?.toString() ?? '',
        uuid: json['uuid']?.toString() ?? '',
        reference: json['reference']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        startAt: _date(json['startAt']),
        endAt: _date(json['endAt']),
        billingCycle: json['billingCycle']?.toString() ?? '',
        price: _num(json['price']),
        currency: json['currency']?.toString() ?? '',
        autoRenew: _flag(json['autoRenew']),
        planVersion: (_num(json['planVersion']) ?? 0).toInt(),
      );

  @override
  List<Object?> get props => [
    id,
    uuid,
    reference,
    status,
    startAt,
    endAt,
    billingCycle,
    price,
    currency,
    autoRenew,
    planVersion,
  ];
}

// ---------------------------------------------------------------------------
// pending subscription — payment abhi on-chain confirm nahi hua
//
// { uuid, reference, planName, price, currency, createdAt }
// ---------------------------------------------------------------------------

class MembershipPending extends Equatable {
  final String uuid;
  final String reference;
  final String planName;
  final num? price;
  final String currency;
  final DateTime? createdAt;

  const MembershipPending({
    required this.uuid,
    required this.reference,
    required this.planName,
    required this.price,
    required this.currency,
    required this.createdAt,
  });

  String get currencySymbol => _currencySymbol(currency);

  String get priceLabel =>
      price == null ? '--' : '$currencySymbol${trimNumber(price!)}';

  /// order kitni der pehle bana
  Duration get age {
    if (createdAt == null) return Duration.zero;
    final d = DateTime.now().difference(createdAt!);
    return d.isNegative ? Duration.zero : d;
  }

  factory MembershipPending.fromJson(Map<String, dynamic> json) =>
      MembershipPending(
        uuid: json['uuid']?.toString() ?? '',
        reference: json['reference']?.toString() ?? '',
        planName: json['planName']?.toString() ?? '',
        price: _num(json['price']),
        currency: json['currency']?.toString() ?? '',
        createdAt: _date(json['createdAt']),
      );

  @override
  List<Object?> get props => [
    uuid,
    reference,
    planName,
    price,
    currency,
    createdAt,
  ];
}

// ---------------------------------------------------------------------------
// subscription summary (history list)
// ---------------------------------------------------------------------------

class MembershipSubscriptionSummary extends Equatable {
  final String uuid;
  final String planCode;
  final String planName;
  final String kind;
  final String status;
  final DateTime? endAt;

  const MembershipSubscriptionSummary({
    required this.uuid,
    required this.planCode,
    required this.planName,
    required this.kind,
    required this.status,
    required this.endAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  String get statusLabel => _titleCase(status);

  factory MembershipSubscriptionSummary.fromJson(Map<String, dynamic> json) =>
      MembershipSubscriptionSummary(
        uuid: json['uuid']?.toString() ?? '',
        planCode: json['planCode']?.toString() ?? '',
        planName: json['planName']?.toString() ?? '',
        kind: json['kind']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        endAt: _date(json['endAt']),
      );

  @override
  List<Object?> get props => [uuid, planCode, planName, kind, status, endAt];
}

// ---------------------------------------------------------------------------
// entitlement
// ---------------------------------------------------------------------------

class MembershipEntitlement extends Equatable {
  final String key;
  final String name;
  final String type; // BOOLEAN | PERCENTAGE | DURATION | COUNT ...
  final String group; // ACCESS | BENEFIT
  final String? unitLabel;
  final bool enabled;
  final String? mode;
  final num? limit;
  final num? numeric;
  final Map<String, dynamic>? config;
  final String? source; // PLAN | FEATURE_DEFAULT
  final String? planCode;
  final String? planName;
  final num used;
  final bool unlimited;
  final num? remaining;

  const MembershipEntitlement({
    required this.key,
    required this.name,
    required this.type,
    required this.group,
    this.unitLabel,
    this.enabled = false,
    this.mode,
    this.limit,
    this.numeric,
    this.config,
    this.source,
    this.planCode,
    this.planName,
    this.used = 0,
    this.unlimited = false,
    this.remaining,
  });

  bool get fromPlan => (source ?? '').toUpperCase() == 'PLAN';

  /// Right-side value text shown on the tile.
  String get valueLabel {
    switch (type.toUpperCase()) {
      case 'PERCENTAGE':
        if (numeric == null) return enabled ? 'Included' : 'Not included';
        return '${trimNumber(numeric!)}${unitLabel ?? '%'} off';
      case 'DURATION':
        if (numeric == null) return enabled ? 'Included' : 'Not included';
        return '${trimNumber(numeric!)} ${unitLabel ?? ''}'.trim();
      case 'COUNT':
      case 'QUOTA':
      case 'NUMERIC':
        if (unlimited) return 'Unlimited';
        if (limit != null) {
          final left = remaining ?? limit!;
          return '${trimNumber(left)} of ${trimNumber(limit!)} ${unitLabel ?? ''}'
              .trim();
        }
        if (numeric != null) {
          return '${trimNumber(numeric!)} ${unitLabel ?? ''}'.trim();
        }
        return enabled ? 'Included' : 'Not included';
      case 'BOOLEAN':
      default:
        return enabled ? 'Included' : 'Not included';
    }
  }

  factory MembershipEntitlement.fromJson(Map<String, dynamic> json) =>
      MembershipEntitlement(
        key: json['key']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? 'BOOLEAN',
        group: json['group']?.toString() ?? '',
        unitLabel: json['unitLabel']?.toString(),
        enabled: _flag(json['enabled']),
        mode: json['mode']?.toString(),
        limit: _num(json['limit']),
        numeric: _num(json['numeric']),
        config: json['config'] is Map
            ? Map<String, dynamic>.from(json['config'])
            : null,
        source: json['source']?.toString(),
        planCode: json['planCode']?.toString(),
        planName: json['planName']?.toString(),
        used: _num(json['used']) ?? 0,
        unlimited: _flag(json['unlimited']),
        remaining: _num(json['remaining']),
      );

  @override
  List<Object?> get props => [
    key,
    name,
    type,
    group,
    unitLabel,
    enabled,
    mode,
    limit,
    numeric,
    source,
    planCode,
    planName,
    used,
    unlimited,
    remaining,
  ];
}