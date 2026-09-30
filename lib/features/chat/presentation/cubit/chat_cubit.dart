import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../profile/domain/usecase/get_profile_usecase.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository repository;
  final GetProfileUseCase _getProfile;

  ChatCubit(this.repository, this._getProfile) : super(ChatInitial());

  String _describe(Object error, String fallback) {
    if (error is Exception) {
      final message = ErrorHandler.mapExceptionToFailure(error).message;
      if (message.isNotEmpty) return message;
    }
    debugPrint('ChatCubit error: $error');
    return fallback;
  }

  Future<void> checkCurrentSession() async {
    emit(ChatSessionLoading());

    try {
      final session = await repository.fetchCurrentSession();
      if (session != null) {
        await _emitLoadedWithHistory(session);
      } else {
        await _autoStartSession();
      }
    } catch (e) {
      emit(ChatSessionError(_describe(e, 'Failed to load chat')));
    }
  }

  Future<void> _autoStartSession() async {
    final profileResult = await _getProfile();

    await profileResult.fold(
      (failure) async => emit(ChatContactInfoRequired()),
      (profile) async {
        try {
          final session = await repository.startOrResumeSession(
            email: profile.email,
            phone: profile.phone,
          );
          await _emitLoadedWithHistory(session);
        } catch (e) {
          debugPrint('ChatCubit: auto start failed, falling back: $e');
          emit(ChatContactInfoRequired());
        }
      },
    );
  }

  Future<void> startSession({
    required String email,
    required String phone,
  }) async {
    emit(ChatSessionLoading());

    try {
      final session = await repository.startOrResumeSession(
        email: email,
        phone: phone,
      );
      await _emitLoadedWithHistory(session);
    } catch (e) {
      emit(ChatSessionError(_describe(e, 'Failed to start chat')));
    }
  }

  Future<void> _emitLoadedWithHistory(ChatSessionEntity session) async {
    List<ChatMessageEntity> messages = const [];
    try {
      messages = await repository.fetchMessages(sessionUuid: session.uuid);
    } catch (e) {
      debugPrint('ChatCubit: failed to load message history: $e');
    }
    emit(ChatSessionLoaded(session, messages: messages));
  }

  Future<String?> sendMessage(String body) async {
    final current = state;
    if (current is! ChatSessionLoaded) return 'No active chat session';

    try {
      final message = await repository.sendMessage(
        sessionUuid: current.session.uuid,
        body: body,
      );
      emit(current.copyWith(messages: [...current.messages, message]));
      return null;
    } catch (e) {
      return _describe(e, 'Failed to send message');
    }
  }

  Future<String?> closeSession() async {
    final current = state;
    if (current is! ChatSessionLoaded) return 'No active chat session';

    try {
      final updated = await repository.closeSession(current.session.uuid);
      emit(ChatSessionLoaded(updated, messages: current.messages));
      return null;
    } catch (e) {
      return _describe(e, 'Failed to close chat');
    }
  }
}
