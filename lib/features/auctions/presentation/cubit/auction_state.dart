import 'package:equatable/equatable.dart';

import '../../domain/entities/auction_entity.dart';

abstract class AuctionState extends Equatable {
  const AuctionState();

  @override
  List<Object?> get props => [];
}

class AuctionInitial extends AuctionState {}

class AuctionLoading extends AuctionState {}

class AuctionLoaded extends AuctionState {
  final List<AuctionEntity> liveAuctions;
  final List<AuctionEntity> endingSoonAuctions;
  final List<AuctionEntity> upcomingAuctions;

  const AuctionLoaded({
    required this.liveAuctions,
    required this.endingSoonAuctions,
    required this.upcomingAuctions,
  });

  @override
  List<Object?> get props => [
        liveAuctions,
        endingSoonAuctions,
        upcomingAuctions,
      ];
}

class AuctionError extends AuctionState {
  final String message;

  const AuctionError(this.message);

  @override
  List<Object?> get props => [message];
}