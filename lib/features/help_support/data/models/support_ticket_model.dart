import '../../domain/entities/support_ticket_entity.dart';

class SupportContactModel {
  final String uuid;
  final String fullName;
  final String email;
  final String? avatar;

  SupportContactModel({
    required this.uuid,
    required this.fullName,
    required this.email,
    this.avatar,
  });

  factory SupportContactModel.fromJson(Map<String, dynamic> json) {
    return SupportContactModel(
      uuid: json['uuid']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
    );
  }

  SupportContactEntity toEntity() => SupportContactEntity(
        uuid: uuid,
        fullName: fullName,
        email: email,
        avatar: avatar,
      );
}

class SupportTicketMessageModel {
  final String uuid;
  final String body;
  final bool fromSupport;
  final DateTime createdAt;
  final SupportContactModel author;

  SupportTicketMessageModel({
    required this.uuid,
    required this.body,
    required this.fromSupport,
    required this.createdAt,
    required this.author,
  });

  factory SupportTicketMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessageModel(
      uuid: json['uuid']?.toString() ?? '',
      body: json['body'] ?? '',
      fromSupport: json['fromSupport'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      author: SupportContactModel.fromJson(
        (json['author'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  SupportTicketMessageEntity toEntity() => SupportTicketMessageEntity(
        uuid: uuid,
        body: body,
        fromSupport: fromSupport,
        createdAt: createdAt,
        author: author.toEntity(),
      );
}

class SupportTicketModel {
  final String uuid;
  final String ref;
  final String subject;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final String? relatedRef;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;
  final SupportContactModel? user;
  final SupportContactModel? assignedTo;
  final int messagesCount;
  final List<SupportTicketMessageModel> messages;

  SupportTicketModel({
    required this.uuid,
    required this.ref,
    required this.subject,
    this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.relatedRef,
    required this.createdAt,
    this.lastMessageAt,
    this.resolvedAt,
    this.closedAt,
    this.user,
    this.assignedTo,
    this.messagesCount = 0,
    this.messages = const [],
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    final countWrapper = json['_count'] as Map<String, dynamic>?;

    return SupportTicketModel(
      uuid: json['uuid']?.toString() ?? '',
      ref: json['ref']?.toString() ?? '',
      subject: json['subject'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      relatedRef: json['relatedRef'],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.tryParse(json['lastMessageAt'].toString()),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.tryParse(json['resolvedAt'].toString()),
      closedAt: json['closedAt'] == null
          ? null
          : DateTime.tryParse(json['closedAt'].toString()),
      user: json['user'] == null
          ? null
          : SupportContactModel.fromJson(json['user'] as Map<String, dynamic>),
      assignedTo: json['assignedTo'] == null
          ? null
          : SupportContactModel.fromJson(
              json['assignedTo'] as Map<String, dynamic>),
      messagesCount: countWrapper?['messages'] ?? 0,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) =>
                  SupportTicketMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  SupportTicketEntity toEntity() {
    return SupportTicketEntity(
      uuid: uuid,
      ref: ref,
      subject: subject,
      description: description,
      category: category,
      priority: priority,
      status: status,
      relatedRef: relatedRef,
      createdAt: createdAt,
      lastMessageAt: lastMessageAt,
      resolvedAt: resolvedAt,
      closedAt: closedAt,
      user: user?.toEntity(),
      assignedTo: assignedTo?.toEntity(),
      messagesCount: messagesCount,
      messages: messages.map((e) => e.toEntity()).toList(),
    );
  }
}

class SupportTicketListModel {
  final List<SupportTicketModel> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  SupportTicketListModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory SupportTicketListModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketListModel(
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((e) => SupportTicketModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      pages: json['pages'] ?? 1,
    );
  }

  SupportTicketListEntity toEntity() {
    return SupportTicketListEntity(
      items: items.map((e) => e.toEntity()).toList(),
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}
