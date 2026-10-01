import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  final String id;
  final String uuid;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'];
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      uuid: json['uuid']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      isRead: json['isRead'] == true,
      metadata: metadata is Map<String, dynamic> ? metadata : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '')
              ?.toLocal() ??
          DateTime.now(),
    );
  }

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        uuid: uuid,
        title: title,
        message: message,
        type: type,
        isRead: isRead,
        metadata: metadata,
        createdAt: createdAt,
      );
}
