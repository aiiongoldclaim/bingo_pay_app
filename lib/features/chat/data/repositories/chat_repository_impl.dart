import 'package:injectable/injectable.dart';

import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

@Injectable(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<ChatSessionEntity?> fetchCurrentSession() async {
    final result = await remoteDataSource.getCurrentSession();
    return result?.toEntity();
  }

  @override
  Future<ChatSessionEntity> startOrResumeSession({
    required String email,
    required String phone,
  }) async {
    final result = await remoteDataSource.startOrResumeSession(
      email: email,
      phone: phone,
    );
    return result.toEntity();
  }

  @override
  Future<List<ChatMessageEntity>> fetchMessages({
    required String sessionUuid,
    int page = 1,
    int limit = 50,
  }) async {
    final result = await remoteDataSource.getMessages(
      sessionUuid: sessionUuid,
      page: page,
      limit: limit,
    );
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<ChatMessageEntity> sendMessage({
    required String sessionUuid,
    required String body,
  }) async {
    final result = await remoteDataSource.sendMessage(
      sessionUuid: sessionUuid,
      body: body,
    );
    return result.toEntity();
  }

  @override
  Future<ChatSessionEntity> closeSession(String sessionUuid) async {
    final result = await remoteDataSource.closeSession(sessionUuid);
    return result.toEntity();
  }
}
