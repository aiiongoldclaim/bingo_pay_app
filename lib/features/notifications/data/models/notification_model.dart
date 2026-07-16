class NotificationModel {
  final String id;
  final String uuid;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.uuid,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
    id: id,
    uuid: uuid,
    title: title,
    message: message,
    type: type,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    id: json['id']?.toString() ?? '',
    uuid: json['uuid']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    message: json['message']?.toString() ?? '',
    type: json['type']?.toString() ?? '',
    isRead: json['isRead'] == true,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );

  static List<NotificationModel> listFromResponse(Map<String, dynamic> json) {
    final data = json['data'];
    final list = data is List ? data : const [];
    return list
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }
}
