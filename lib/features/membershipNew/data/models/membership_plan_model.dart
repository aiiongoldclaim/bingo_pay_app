import 'package:equatable/equatable.dart';

import 'member_ship_model.dart' show trimNumber;

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

num? _num(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

bool? _boolOrNull(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase();
  if (s == 'true') return true;
  if (s == 'false') return false;
  return null;
}

String _titleCase(String raw) => raw
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

// ---------------------------------------------------------------------------
// plan (catalog item)
// ---------------------------------------------------------------------------

class MembershipPlanOption extends Equatable {
  final String uuid;
  final String code;
  final String name;
  final String description;
  final String kind;
  final int rank;

  /// "Most popular" — null/empty ho sakta hai
  final String? highlight;

  final MembershipPlanVersion? version;

  const MembershipPlanOption({
    required this.uuid,
    required this.code,
    required this.name,
    required this.description,
    required this.kind,
    required this.rank,
    required this.highlight,
    required this.version,
  });

  String get kindLabel => _titleCase(kind);

  bool get isHighlighted => (highlight ?? '').trim().isNotEmpty;

  bool get hasDescription => description.trim().isNotEmpty;

  /// Subscribe body me yahi bhejna hai
  String? get planVersionUuid => version?.uuid;

  List<MembershipPlanFeature> get features => version?.features ?? const [];

  /// booleanValue == false wale bhi list me aate hain -> unhe cross dikhana
  List<MembershipPlanFeature> get includedFeatures =>
      features.where((f) => f.isIncluded).toList();

  factory MembershipPlanOption.fromJson(Map<String, dynamic> json) =>
      MembershipPlanOption(
        uuid: json['uuid']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        kind: json['kind']?.toString() ?? '',
        rank: (_num(json['rank']) ?? 0).toInt(),
        highlight: json['highlight']?.toString(),
        version: json['version'] is Map
            ? MembershipPlanVersion.fromJson(
          Map<String, dynamic>.from(json['version']),
        )
            : null,
      );

  @override
  List<Object?> get props => [uuid, code, name, kind, rank, highlight, version];
}

// ---------------------------------------------------------------------------
// version (pricing + features)
// ---------------------------------------------------------------------------

class MembershipPlanVersion extends Equatable {
  final String uuid;
  final int version;
  final String status;
  final num? price;
  final String currency;
  final String billingCycle;
  final int durationDays;
  final int trialDays;
  final DateTime? publishedAt;
  final DateTime? archivedAt;
  final List<MembershipPlanFeature> features;

  const MembershipPlanVersion({
    required this.uuid,
    required this.version,
    required this.status,
    required this.price,
    required this.currency,
    required this.billingCycle,
    required this.durationDays,
    required this.trialDays,
    required this.publishedAt,
    required this.archivedAt,
    required this.features,
  });

  bool get isPublished => status.toUpperCase() == 'PUBLISHED';

  bool get hasTrial => trialDays > 0;

  String get currencySymbol => switch (currency.toUpperCase()) {
    'USD' => '\$',
    'SGD' => 'S\$',
    'INR' => '\u20B9',
    'EUR' => '\u20AC',
    'GBP' => '\u00A3',
    _ => '${currency.toUpperCase()} ',
  };

  String get priceLabel =>
      price == null ? '--' : '$currencySymbol${trimNumber(price!)}';

  /// ANNUAL -> "/ year"
  String get periodLabel => switch (billingCycle.toUpperCase()) {
    'ANNUAL' || 'YEARLY' => '/ year',
    'MONTHLY' => '/ month',
    'QUARTERLY' => '/ quarter',
    'WEEKLY' => '/ week',
    'DAILY' => '/ day',
    '' => '',
    _ => '/ ${billingCycle.toLowerCase()}',
  };

  String get billingCycleLabel => _titleCase(billingCycle);

  /// "360 days access"
  String get durationLabel =>
      durationDays <= 0 ? '' : '$durationDays days access';

  factory MembershipPlanVersion.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    return MembershipPlanVersion(
      uuid: json['uuid']?.toString() ?? '',
      version: (_num(json['version']) ?? 0).toInt(),
      status: json['status']?.toString() ?? '',
      price: _num(json['price']),
      currency: json['currency']?.toString() ?? '',
      billingCycle: json['billingCycle']?.toString() ?? '',
      durationDays: (_num(json['durationDays']) ?? 0).toInt(),
      trialDays: (_num(json['trialDays']) ?? 0).toInt(),
      publishedAt: _date(json['publishedAt']),
      archivedAt: _date(json['archivedAt']),
      features: rawFeatures is List
          ? rawFeatures
          .whereType<Map>()
          .map(
            (e) => MembershipPlanFeature.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList()
          : const [],
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    version,
    status,
    price,
    currency,
    billingCycle,
    durationDays,
    trialDays,
    features,
  ];
}

// ---------------------------------------------------------------------------
// feature
// ---------------------------------------------------------------------------

class MembershipPlanFeature extends Equatable {
  final String key;
  final String name;
  final String type; // BOOLEAN | PERCENTAGE | DURATION
  final String group; // ACCESS | BENEFIT
  final String? unitLabel;
  final String? mode;
  final bool? booleanValue;
  final num? numericValue;
  final Map<String, dynamic>? jsonValue;

  const MembershipPlanFeature({
    required this.key,
    required this.name,
    required this.type,
    required this.group,
    this.unitLabel,
    this.mode,
    this.booleanValue,
    this.numericValue,
    this.jsonValue,
  });

  /// BOOLEAN -> booleanValue, warna numericValue hone par included
  bool get isIncluded => switch (type.toUpperCase()) {
    'BOOLEAN' => booleanValue ?? false,
    _ => numericValue != null,
  };

  /// Tile ke neeche dikhne wali value
  String get valueLabel {
    switch (type.toUpperCase()) {
      case 'PERCENTAGE':
        if (numericValue == null) return isIncluded ? 'Included' : '--';
        return '${trimNumber(numericValue!)}${unitLabel ?? '%'} off';
      case 'DURATION':
        if (numericValue == null) return isIncluded ? 'Included' : '--';
        return '${trimNumber(numericValue!)} ${unitLabel ?? ''}'.trim();
      case 'BOOLEAN':
      default:
        return isIncluded ? 'Included' : 'Not included';
    }
  }

  factory MembershipPlanFeature.fromJson(Map<String, dynamic> json) =>
      MembershipPlanFeature(
        key: json['key']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        type: json['type']?.toString() ?? 'BOOLEAN',
        group: json['group']?.toString() ?? '',
        unitLabel: json['unitLabel']?.toString(),
        mode: json['mode']?.toString(),
        booleanValue: _boolOrNull(json['booleanValue']),
        numericValue: _num(json['numericValue']),
        jsonValue: json['jsonValue'] is Map
            ? Map<String, dynamic>.from(json['jsonValue'])
            : null,
      );

  @override
  List<Object?> get props => [
    key,
    name,
    type,
    group,
    unitLabel,
    booleanValue,
    numericValue,
  ];
}