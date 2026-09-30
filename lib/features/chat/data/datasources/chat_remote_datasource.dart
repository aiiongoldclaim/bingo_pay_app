import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/chat_session_model.dart';

@injectable
class ChatRemoteDataSource {
  final ApiClient _client;

  ChatRemoteDataSource(this._client);

  Future<ChatSessionModel?> getCurrentSession() async {
    final response = await _client.dio.get(ApiEndpoints.chatCurrentSession);

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat session response');
    }

    final wrapper = responseData['data'];
    if (wrapper is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat session payload');
    }

    final sessionJson = wrapper['data'];
    if (sessionJson == null) return null;

    if (sessionJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat session payload');
    }

    return ChatSessionModel.fromJson(sessionJson);
  }

  Future<ChatSessionModel> startOrResumeSession({
    required String email,
    required String phone,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.chatSessions,
      data: {'email': email, 'phone': phone},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat session response');
    }

    dynamic sessionJson = responseData['data'];
    while (sessionJson is Map &&
        sessionJson['uuid'] == null &&
        sessionJson['data'] != null) {
      sessionJson = sessionJson['data'];
    }

    if (sessionJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat session payload');
    }

    return ChatSessionModel.fromJson(sessionJson);
  }

  Future<List<ChatMessageModel>> getMessages({
    required String sessionUuid,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _client.dio.get(
      ApiEndpoints.chatMessages(sessionUuid),
      queryParameters: {'page': page, 'limit': limit},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat messages response');
    }

    final wrapper = responseData['data'];
    if (wrapper is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat messages payload');
    }

    final inner = wrapper['data'];

    List<dynamic> itemsJson;
    if (inner is List) {
      itemsJson = inner;
    } else if (inner is Map<String, dynamic> && inner['items'] is List) {
      itemsJson = inner['items'] as List<dynamic>;
    } else if (inner == null) {
      itemsJson = const [];
    } else {
      throw const FormatException('Invalid chat messages payload');
    }

    final messages = itemsJson
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  Future<ChatMessageModel> sendMessage({
    required String sessionUuid,
    required String body,
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.chatMessages(sessionUuid),
      data: {'message': body},
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat message response');
    }

    dynamic messageJson = responseData['data'];
    while (messageJson is Map &&
        messageJson['uuid'] == null &&
        messageJson['data'] != null) {
      messageJson = messageJson['data'];
    }

    if (messageJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat message payload');
    }

    return ChatMessageModel.fromJson(messageJson);
  }

  Future<ChatSessionModel> closeSession(String sessionUuid) async {
    final response = await _client.dio.post(
      ApiEndpoints.chatSessionClose(sessionUuid),
    );

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat session response');
    }

    dynamic sessionJson = responseData['data'];
    while (sessionJson is Map &&
        sessionJson['uuid'] == null &&
        sessionJson['data'] != null) {
      sessionJson = sessionJson['data'];
    }

    if (sessionJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat session payload');
    }

    return ChatSessionModel.fromJson(sessionJson);
  }
}
