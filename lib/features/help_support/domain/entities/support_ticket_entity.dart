class SupportContactEntity {
  final String uuid;
  final String fullName;
  final String email;
  final String? avatar;

  SupportContactEntity({
    required this.uuid,
    required this.fullName,
    required this.email,
    this.avatar,
  });
}

class SupportTicketMessageEntity {
  final String uuid;
  final String body;
  final bool fromSupport;
  final DateTime createdAt;
  final SupportContactEntity author;

  SupportTicketMessageEntity({
    required this.uuid,
    required this.body,
    required this.fromSupport,
    required this.createdAt,
    required this.author,
  });
}

class SupportTicketEntity {
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
  final SupportContactEntity? user;
  final SupportContactEntity? assignedTo;
  final int messagesCount;
  final List<SupportTicketMessageEntity> messages;

  SupportTicketEntity({
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
}

class SupportTicketListEntity {
  final List<SupportTicketEntity> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  SupportTicketListEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
}
