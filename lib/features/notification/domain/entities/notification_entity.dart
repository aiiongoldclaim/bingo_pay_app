class NotificationEntity {
  final String id;
  final String uuid;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.uuid,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.metadata,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        uuid: uuid,
        title: title,
        message: message,
        type: type,
        isRead: isRead ?? this.isRead,
        metadata: metadata,
        createdAt: createdAt,
      );
}
