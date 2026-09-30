import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/support_ticket_repository.dart';
import 'support_ticket_state.dart';

@injectable
class SupportTicketCubit extends Cubit<SupportTicketState> {
  final SupportTicketRepository repository;

  SupportTicketCubit(this.repository) : super(SupportTicketInitial());

  String _describe(Object error, String fallback) {
    if (error is Exception) {
      final message = ErrorHandler.mapExceptionToFailure(error).message;
      if (message.isNotEmpty) return message;
    }
    debugPrint('SupportTicketCubit error: $error');
    return fallback;
  }

  Future<void> raiseTicket({
    required String category,
    required String subject,
    required String description,
    String? relatedRef,
  }) async {
    emit(SupportTicketSubmitting());

    try {
      final ticket = await repository.raiseTicket(
        category: category,
        subject: subject,
        description: description,
        relatedRef: relatedRef,
      );
      emit(SupportTicketSubmitted(ticket));
    } catch (e) {
      emit(SupportTicketError(_describe(e, 'Failed to raise support ticket')));
    }
  }

  Future<void> loadMyTickets({int page = 1, int limit = 20}) async {
    emit(SupportTicketListLoading());

    try {
      final list = await repository.fetchMyTickets(page: page, limit: limit);
      emit(SupportTicketListLoaded(list));
    } catch (e) {
      emit(SupportTicketError(_describe(e, 'Failed to load your tickets')));
    }
  }

  Future<void> loadTicketDetail(String uuid) async {
    emit(SupportTicketDetailLoading());
    await _fetchAndEmitTicket(uuid);
  }

  Future<void> _fetchAndEmitTicket(String uuid) async {
    try {
      final ticket = await repository.fetchTicketById(uuid);
      emit(SupportTicketDetailLoaded(ticket));
    } catch (e) {
      emit(SupportTicketError(_describe(e, 'Failed to load ticket details')));
    }
  }

  Future<String?> sendReply({
    required String ticketId,
    required String body,
  }) async {
    try {
      await repository.replyToTicket(ticketId: ticketId, body: body);
      await _fetchAndEmitTicket(ticketId);
      return null;
    } catch (e) {
      return _describe(e, 'Failed to send reply');
    }
  }

  void reset() => emit(SupportTicketInitial());
}
