import 'package:injectable/injectable.dart';

import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/repositories/support_ticket_repository.dart';
import '../datasources/support_ticket_remote_datasource.dart';

@Injectable(as: SupportTicketRepository)
class SupportTicketRepositoryImpl implements SupportTicketRepository {
  final SupportTicketRemoteDataSource remoteDataSource;

  SupportTicketRepositoryImpl(this.remoteDataSource);

  @override
  Future<SupportTicketEntity> raiseTicket({
    required String category,
    required String subject,
    required String description,
    String? relatedRef,
  }) async {
    final result = await remoteDataSource.raiseTicket(
      category: category,
      subject: subject,
      description: description,
      relatedRef: relatedRef,
    );
    return result.toEntity();
  }

  @override
  Future<SupportTicketListEntity> fetchMyTickets({
    int page = 1,
    int limit = 20,
  }) async {
    final result = await remoteDataSource.getMyTickets(
      page: page,
      limit: limit,
    );
    return result.toEntity();
  }

  @override
  Future<SupportTicketEntity> fetchTicketById(String uuid) async {
    final result = await remoteDataSource.getTicketDetail(uuid);
    return result.toEntity();
  }

  @override
  Future<SupportTicketMessageEntity> replyToTicket({
    required String ticketId,
    required String body,
  }) async {
    final result = await remoteDataSource.replyToTicket(
      ticketId: ticketId,
      body: body,
    );
    return result.toEntity();
  }
}
