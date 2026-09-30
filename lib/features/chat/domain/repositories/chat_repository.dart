import '../entities/chat_session_entity.dart';

abstract class ChatRepository {
  Future<ChatSessionEntity?> fetchCurrentSession();

  Future<ChatSessionEntity> startOrResumeSession({
    required String email,
    required String phone,
  });

  Future<List<ChatMessageEntity>> fetchMessages({
    required String sessionUuid,
    int page = 1,
    int limit = 50,
  });

  Future<ChatMessageEntity> sendMessage({
    required String sessionUuid,
    required String body,
  });

  Future<ChatSessionEntity> closeSession(String sessionUuid);
}
