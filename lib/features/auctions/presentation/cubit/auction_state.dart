

// import 'package:equatable/equatable.dart';

// import '../../domain/entities/auction_entity.dart';
// import '../../domain/entities/auction_detail_entity.dart';

// abstract class AuctionState extends Equatable {
//   const AuctionState();

//   @override
//   List<Object?> get props => [];
// }

// // ============================================================
// // INITIAL
// // ============================================================

// class AuctionInitial extends AuctionState {}

// // ============================================================
// // LIST LOADING
// // ============================================================

// class AuctionLoading extends AuctionState {}

// // ============================================================
// // LIST LOADED
// // ============================================================

// class AuctionLoaded extends AuctionState {
//   final List<AuctionEntity> liveAuctions;
//   final List<AuctionEntity> endingSoonAuctions;
//   final List<AuctionEntity> upcomingAuctions;

//   const AuctionLoaded({
//     required this.liveAuctions,
//     required this.endingSoonAuctions,
//     required this.upcomingAuctions,
//   });

//   @override
//   List<Object?> get props => [
//         liveAuctions,
//         endingSoonAuctions,
//         upcomingAuctions,
//       ];
// }

// // ============================================================
// // LIST ERROR
// // ============================================================

// class AuctionError extends AuctionState {
//   final String message;

//   const AuctionError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

// // ============================================================
// // DETAIL LOADING
// // ============================================================

// class AuctionDetailLoading extends AuctionState {}

// // ============================================================
// // DETAIL LOADED
// // ============================================================

// class AuctionDetailLoaded extends AuctionState {
//   final AuctionDetailEntity auction;

//   const AuctionDetailLoaded({
//     required this.auction,
//   });

//   @override
//   List<Object?> get props => [auction];
// }

// // ============================================================
// // DETAIL ERROR
// // ============================================================

// class AuctionDetailError extends AuctionState {
//   final String message;

//   const AuctionDetailError(this.message);

//   @override
//   List<Object?> get props => [message];
// }

import 'package:equatable/equatable.dart';

import '../../domain/entities/auction_entity.dart';
import '../../domain/entities/auction_detail_entity.dart';
import '../../domain/entities/bid_entity.dart';

abstract class AuctionState extends Equatable {
  const AuctionState();

  @override
  List<Object?> get props => [];
}

// ============================================================
// INITIAL
// ============================================================

class AuctionInitial extends AuctionState {}

// ============================================================
// LIST LOADING
// ============================================================

class AuctionLoading extends AuctionState {}

// ============================================================
// LIST LOADED
// ============================================================

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

// ============================================================
// LIST ERROR
// ============================================================

class AuctionError extends AuctionState {
  final String message;

  const AuctionError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// DETAIL LOADING
// ============================================================

class AuctionDetailLoading extends AuctionState {}

// ============================================================
// DETAIL LOADED
// ============================================================

class AuctionDetailLoaded extends AuctionState {
  final AuctionDetailEntity auction;

  /// Bidding history
  final List<BidEntity> bids;

  /// Whether bids API is currently loading
  final bool isBidsLoading;

  /// Error specifically related to bids
  final String? bidsError;

  const AuctionDetailLoaded({
    required this.auction,
    this.bids = const [],
    this.isBidsLoading = false,
    this.bidsError,
  });

  AuctionDetailLoaded copyWith({
    AuctionDetailEntity? auction,
    List<BidEntity>? bids,
    bool? isBidsLoading,
    String? bidsError,
    bool clearBidsError = false,
  }) {
    return AuctionDetailLoaded(
      auction: auction ?? this.auction,
      bids: bids ?? this.bids,
      isBidsLoading: isBidsLoading ?? this.isBidsLoading,
      bidsError: clearBidsError
          ? null
          : bidsError ?? this.bidsError,
    );
  }

  @override
  List<Object?> get props => [
        auction,
        bids,
        isBidsLoading,
        bidsError,
      ];
}

// ============================================================
// DETAIL ERROR
// ============================================================

class AuctionDetailError extends AuctionState {
  final String message;

  const AuctionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}