import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/support_ticket_model.dart';

@injectable
class SupportTicketRemoteDataSource {
  final ApiClient _client;

  SupportTicketRemoteDataSource(this._client);

  Future<SupportTicketModel> raiseTicket({
    required String category,
    required String subject,
    required String description,
    String? relatedRef,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.supportTickets,
      data: {
        'category': category,
        'subject': subject,
        'description': description,
        if (relatedRef != null && relatedRef.isNotEmpty)
          'relatedRef': relatedRef,
      },
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid support ticket response');
    }

    dynamic ticketJson = responseData['data'];
    while (ticketJson is Map &&
        ticketJson['uuid'] == null &&
        ticketJson['data'] != null) {
      ticketJson = ticketJson['data'];
    }

    if (ticketJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid support ticket payload');
    }

    return SupportTicketModel.fromJson(ticketJson);
  }

  Future<SupportTicketListModel> getMyTickets({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      ApiEndpoints.supportTickets,
      queryParameters: {'page': page, 'limit': limit},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid support tickets response');
    }

    dynamic listJson = responseData['data'];
    while (listJson is Map &&
        listJson['items'] == null &&
        listJson['data'] != null) {
      listJson = listJson['data'];
    }

    if (listJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid support tickets payload');
    }

    return SupportTicketListModel.fromJson(listJson);
  }

  Future<SupportTicketModel> getTicketDetail(String uuid) async {
    final response = await _client.dio.get(
      ApiEndpoints.supportTicketDetail(uuid),
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid support ticket response');
    }

    dynamic ticketJson = responseData['data'];
    while (ticketJson is Map &&
        ticketJson['uuid'] == null &&
        ticketJson['data'] != null) {
      ticketJson = ticketJson['data'];
    }

    if (ticketJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid support ticket payload');
    }

    return SupportTicketModel.fromJson(ticketJson);
  }

  Future<SupportTicketMessageModel> replyToTicket({
    required String ticketId,
    required String body,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.supportTicketReply(ticketId),
      data: {'body': body},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid reply response');
    }

    dynamic messageJson = responseData['data'];
    while (messageJson is Map &&
        messageJson['uuid'] == null &&
        messageJson['data'] != null) {
      messageJson = messageJson['data'];
    }

    if (messageJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid reply payload');
    }

    return SupportTicketMessageModel.fromJson(messageJson);
  }
}
