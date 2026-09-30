import 'package:equatable/equatable.dart';

import '../../domain/entities/chat_session_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatSessionLoading extends ChatState {}

class ChatContactInfoRequired extends ChatState {}

class ChatSessionLoaded extends ChatState {
  final ChatSessionEntity session;
  final List<ChatMessageEntity> messages;

  const ChatSessionLoaded(this.session, {this.messages = const []});

  ChatSessionLoaded copyWith({List<ChatMessageEntity>? messages}) =>
      ChatSessionLoaded(session, messages: messages ?? this.messages);

  @override
  List<Object?> get props => [session, messages];
}

class ChatSessionError extends ChatState {
  final String errorMessage;

  const ChatSessionError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
