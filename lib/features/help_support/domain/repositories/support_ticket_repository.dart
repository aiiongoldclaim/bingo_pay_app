import '../entities/support_ticket_entity.dart';

abstract class SupportTicketRepository {
  Future<SupportTicketEntity> raiseTicket({
    required String category,
    required String subject,
    required String description,
    String? relatedRef,
  });

  Future<SupportTicketListEntity> fetchMyTickets({int page = 1, int limit = 20});

  Future<SupportTicketEntity> fetchTicketById(String uuid);

  Future<SupportTicketMessageEntity> replyToTicket({
    required String ticketId,
    required String body,
  });
}
