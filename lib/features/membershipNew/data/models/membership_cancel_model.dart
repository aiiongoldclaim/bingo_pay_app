import 'package:equatable/equatable.dart';

DateTime? _date(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

String _titleCase(String raw) => raw
    .split(RegExp(r'[_\s]+'))
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

// ---------------------------------------------------------------------------
// PATCH /api/v1/customer/membership/{uuid}/cancel
//
// { data: { message, data: { uuid, status, accessUntil } } }
// ---------------------------------------------------------------------------

class MembershipCancelModel extends Equatable {
  final String uuid;
  final String status; // TERMINATED
  final DateTime? accessUntil;

  /// backend ka text — "Subscription ended. Your listings are safe ..."
  final String message;

  const MembershipCancelModel({
    required this.uuid,
    required this.status,
    required this.accessUntil,
    required this.message,
  });

  String get statusLabel => _titleCase(status);

  bool get isTerminated => status.toUpperCase() == 'TERMINATED';

  factory MembershipCancelModel.fromJson(
      Map<String, dynamic> json, {
        String message = '',
      }) =>
      MembershipCancelModel(
        uuid: json['uuid']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        accessUntil: _date(json['accessUntil']),
        message: message,
      );

  @override
  List<Object?> get props => [uuid, status, accessUntil, message];
}