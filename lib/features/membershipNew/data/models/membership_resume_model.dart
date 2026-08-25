import 'package:equatable/equatable.dart';

class MembershipResumeModel extends Equatable {
  final String message;
  final String uuid;
  final String status;
  final DateTime? endAt;

  const MembershipResumeModel({
    required this.message,
    required this.uuid,
    required this.status,
    this.endAt,
  });

  factory MembershipResumeModel.fromJson(
      Map<String, dynamic> json, {
        String message = '',
      }) {
    final data = json['data'];

    final payload = data is Map
        ? Map<String, dynamic>.from(data)
        : json;

    return MembershipResumeModel(
      message: message,
      uuid: payload['uuid']?.toString() ?? '',
      status: payload['status']?.toString() ?? '',
      endAt: payload['endAt'] != null
          ? DateTime.tryParse(
        payload['endAt'].toString(),
      )?.toLocal()
          : null,
    );
  }

  @override
  List<Object?> get props => [
    message,
    uuid,
    status,
    endAt,
  ];
}