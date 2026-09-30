import 'package:equatable/equatable.dart';

import '../../domain/entities/support_ticket_entity.dart';

abstract class SupportTicketState extends Equatable {
  const SupportTicketState();

  @override
  List<Object?> get props => [];
}

class SupportTicketInitial extends SupportTicketState {}

class SupportTicketSubmitting extends SupportTicketState {}

class SupportTicketSubmitted extends SupportTicketState {
  final SupportTicketEntity ticket;

  const SupportTicketSubmitted(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class SupportTicketError extends SupportTicketState {
  final String errorMessage;

  const SupportTicketError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class SupportTicketDetailLoading extends SupportTicketState {}

class SupportTicketDetailLoaded extends SupportTicketState {
  final SupportTicketEntity ticket;

  const SupportTicketDetailLoaded(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class SupportTicketListLoading extends SupportTicketState {}

class SupportTicketListLoaded extends SupportTicketState {
  final SupportTicketListEntity list;

  const SupportTicketListLoaded(this.list);

  @override
  List<Object?> get props => [list];
}
