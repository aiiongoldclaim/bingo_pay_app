class ChatContactEntity {
  final String uuid;
  final String fullName;
  final String email;
  final String? avatar;

  ChatContactEntity({
    required this.uuid,
    required this.fullName,
    required this.email,
    this.avatar,
  });
}

class ChatMessageEntity {
  final String uuid;
  final String senderType;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final ChatContactEntity sender;

  ChatMessageEntity({
    required this.uuid,
    required this.senderType,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.sender,
  });
}

class ChatSessionEntity {
  final String uuid;
  final String status;
  final String email;
  final String? phone;
  final DateTime? startedAt;
  final DateTime? closedAt;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final ChatContactEntity? user;
  final ChatContactEntity? admin;
  final bool alreadyOpen;

  ChatSessionEntity({
    required this.uuid,
    required this.status,
    required this.email,
    this.phone,
    this.startedAt,
    this.closedAt,
    this.lastMessageAt,
    required this.createdAt,
    this.user,
    this.admin,
    this.alreadyOpen = false,
  });
}
