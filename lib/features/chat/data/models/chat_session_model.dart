import '../../domain/entities/chat_session_entity.dart';

class ChatContactModel {
  final String uuid;
  final String fullName;
  final String email;
  final String? avatar;

  ChatContactModel({
    required this.uuid,
    required this.fullName,
    required this.email,
    this.avatar,
  });

  factory ChatContactModel.fromJson(Map<String, dynamic> json) {
    return ChatContactModel(
      uuid: json['uuid']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
    );
  }

  ChatContactEntity toEntity() => ChatContactEntity(
        uuid: uuid,
        fullName: fullName,
        email: email,
        avatar: avatar,
      );
}

class ChatMessageModel {
  final String uuid;
  final String senderType;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final ChatContactModel sender;

  ChatMessageModel({
    required this.uuid,
    required this.senderType,
    required this.body,
    required this.isRead,
    required this.createdAt,
    required this.sender,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      uuid: json['uuid']?.toString() ?? '',
      senderType: json['senderType'] ?? '',
      body: json['body'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      sender: ChatContactModel.fromJson(
        (json['sender'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  ChatMessageEntity toEntity() => ChatMessageEntity(
        uuid: uuid,
        senderType: senderType,
        body: body,
        isRead: isRead,
        createdAt: createdAt,
        sender: sender.toEntity(),
      );
}

class ChatSessionModel {
  final String uuid;
  final String status;
  final String email;
  final String? phone;
  final DateTime? startedAt;
  final DateTime? closedAt;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final ChatContactModel? user;
  final ChatContactModel? admin;
  final bool alreadyOpen;

  ChatSessionModel({
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

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      uuid: json['uuid']?.toString() ?? '',
      status: json['status'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.tryParse(json['startedAt'].toString()),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.tryParse(json['closedAt'].toString()),
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.tryParse(json['lastMessageAt'].toString()),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      user: json['user'] == null
          ? null
          : ChatContactModel.fromJson(json['user'] as Map<String, dynamic>),
      admin: json['admin'] == null
          ? null
          : ChatContactModel.fromJson(json['admin'] as Map<String, dynamic>),
      alreadyOpen: json['alreadyOpen'] ?? false,
    );
  }

  ChatSessionEntity toEntity() {
    return ChatSessionEntity(
      uuid: uuid,
      status: status,
      email: email,
      phone: phone,
      startedAt: startedAt,
      closedAt: closedAt,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      user: user?.toEntity(),
      admin: admin?.toEntity(),
      alreadyOpen: alreadyOpen,
    );
  }
}
