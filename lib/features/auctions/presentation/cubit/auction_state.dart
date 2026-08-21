
// import 'package:equatable/equatable.dart';

// import '../../domain/entities/auction_entity.dart';
// import '../../domain/entities/auction_detail_entity.dart';
// import '../../domain/entities/bid_entity.dart';
// import '../../domain/entities/place_bid_entity.dart';

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

//   // ----------------------------------------------------------
//   // BIDDING HISTORY
//   // ----------------------------------------------------------

//   final List<BidEntity> bids;

//   final bool isBidsLoading;

//   final String? bidsError;

//   // ----------------------------------------------------------
//   // PLACE BID
//   // ----------------------------------------------------------

//   /// True while place bid API is running.
//   final bool isPlacingBid;

//   /// Error from place bid API.
//   final String? placeBidError;

//   /// Response received after successfully placing a bid.
//   final PlaceBidEntity? placedBid;

//   const AuctionDetailLoaded({
//     required this.auction,

//     // Bidding history
//     this.bids = const [],
//     this.isBidsLoading = false,
//     this.bidsError,

//     // Place bid
//     this.isPlacingBid = false,
//     this.placeBidError,
//     this.placedBid,
//   });

//   AuctionDetailLoaded copyWith({
//     AuctionDetailEntity? auction,

//     // Bidding history
//     List<BidEntity>? bids,
//     bool? isBidsLoading,
//     String? bidsError,
//     bool clearBidsError = false,

//     // Place bid
//     bool? isPlacingBid,
//     String? placeBidError,
//     bool clearPlaceBidError = false,
//     PlaceBidEntity? placedBid,
//     bool clearPlacedBid = false,
//   }) {
//     return AuctionDetailLoaded(
//       auction: auction ?? this.auction,

//       // Bidding history
//       bids: bids ?? this.bids,
//       isBidsLoading: isBidsLoading ?? this.isBidsLoading,
//       bidsError: clearBidsError
//           ? null
//           : bidsError ?? this.bidsError,

//       // Place bid
//       isPlacingBid: isPlacingBid ?? this.isPlacingBid,
//       placeBidError: clearPlaceBidError
//           ? null
//           : placeBidError ?? this.placeBidError,
//       placedBid: clearPlacedBid
//           ? null
//           : placedBid ?? this.placedBid,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         auction,

//         // Bidding history
//         bids,
//         isBidsLoading,
//         bidsError,

//         // Place bid
//         isPlacingBid,
//         placeBidError,
//         placedBid,
//       ];
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
import '../../domain/entities/my_bids_entity.dart';
import '../../domain/entities/place_bid_entity.dart';

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

  // ----------------------------------------------------------
  // BIDDING HISTORY
  // ----------------------------------------------------------

  final List<BidEntity> bids;

  final bool isBidsLoading;

  final String? bidsError;

  // ----------------------------------------------------------
  // PLACE BID
  // ----------------------------------------------------------

  final bool isPlacingBid;

  final String? placeBidError;

  final PlaceBidEntity? placedBid;

  const AuctionDetailLoaded({
    required this.auction,

    // Bidding history
    this.bids = const [],
    this.isBidsLoading = false,
    this.bidsError,

    // Place bid
    this.isPlacingBid = false,
    this.placeBidError,
    this.placedBid,
  });

  AuctionDetailLoaded copyWith({
    AuctionDetailEntity? auction,

    // Bidding history
    List<BidEntity>? bids,
    bool? isBidsLoading,
    String? bidsError,
    bool clearBidsError = false,

    // Place bid
    bool? isPlacingBid,
    String? placeBidError,
    bool clearPlaceBidError = false,
    PlaceBidEntity? placedBid,
    bool clearPlacedBid = false,
  }) {
    return AuctionDetailLoaded(
      auction: auction ?? this.auction,

      // Bidding history
      bids: bids ?? this.bids,
      isBidsLoading: isBidsLoading ?? this.isBidsLoading,
      bidsError: clearBidsError
          ? null
          : bidsError ?? this.bidsError,

      // Place bid
      isPlacingBid: isPlacingBid ?? this.isPlacingBid,
      placeBidError: clearPlaceBidError
          ? null
          : placeBidError ?? this.placeBidError,
      placedBid: clearPlacedBid
          ? null
          : placedBid ?? this.placedBid,
    );
  }

  @override
  List<Object?> get props => [
        auction,
        bids,
        isBidsLoading,
        bidsError,
        isPlacingBid,
        placeBidError,
        placedBid,
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

// ============================================================
// MY BIDS LOADING
// ============================================================

class MyBidsLoading extends AuctionState {}

// ============================================================
// MY BIDS LOADED
// ============================================================

class MyBidsLoaded extends AuctionState {
  final MyBidsEntity myBids;

  const MyBidsLoaded({
    required this.myBids,
  });

  @override
  List<Object?> get props => [myBids];
}

// ============================================================
// MY BIDS ERROR
// ============================================================

class MyBidsError extends AuctionState {
  final String message;

  const MyBidsError(this.message);

  @override
  List<Object?> get props => [message];
}