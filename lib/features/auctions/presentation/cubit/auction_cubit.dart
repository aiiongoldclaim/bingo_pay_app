

// import 'package:flutter/foundation.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';

// import 'package:bingo_pay/features/auctions/domain/repositories/auction_repository.dart';

// import '../../../../core/error/error_handler.dart';
// import 'auction_state.dart';

// @injectable
// class AuctionCubit extends Cubit<AuctionState> {
//   final AuctionRepository repository;

//   AuctionCubit(this.repository) : super(AuctionInitial());

//   String _describe(Object error, String fallback) {
//     if (error is Exception) {
//       final message =
//           ErrorHandler.mapExceptionToFailure(error).message;

//       if (message.isNotEmpty) {
//         return message;
//       }
//     }

//     debugPrint('AuctionCubit error: $error');

//     return fallback;
//   }

//   // ==========================================================
//   // GET ALL AUCTIONS
//   // ==========================================================

//   Future<void> getAuctions() async {
//     emit(AuctionLoading());

//     try {
//       final liveAuctions =
//           await repository.fetchAllAuctions(
//         status: 'LIVE',
//         sort: 'MOST_BIDS',
//         take: 6,
//       );

//       final endingSoonAuctions =
//           await repository.fetchAllAuctions(
//         status: 'ENDING_SOON',
//         sort: 'ENDING_SOON',
//         take: 6,
//       );

//       final upcomingAuctions =
//           await repository.fetchAllAuctions(
//         status: 'STARTING_SOON',
//         sort: 'NEWEST',
//         take: 6,
//       );

//       emit(
//         AuctionLoaded(
//           liveAuctions: liveAuctions,
//           endingSoonAuctions: endingSoonAuctions,
//           upcomingAuctions: upcomingAuctions,
//         ),
//       );
//     } catch (e) {
//       emit(
//         AuctionError(
//           _describe(
//             e,
//             'Unable to load auctions. Please try again.',
//           ),
//         ),
//       );
//     }
//   }

//   // ==========================================================
//   // GET AUCTION DETAIL
//   // ==========================================================

//   Future<void> getAuctionDetail(String auctionId) async {
//     emit(AuctionDetailLoading());

//     try {
//       final auction =
//           await repository.fetchAuctionById(auctionId);

//       emit(
//         AuctionDetailLoaded(
//           auction: auction,
//         ),
//       );
//     } catch (e) {
//       emit(
//         AuctionDetailError(
//           _describe(
//             e,
//             'Unable to load auction details. Please try again.',
//           ),
//         ),
//       );
//     }
//   }
// }

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bingo_pay/features/auctions/domain/entities/bid_entity.dart';
import 'package:bingo_pay/features/auctions/domain/repositories/auction_repository.dart';

import '../../../../core/error/error_handler.dart';
import 'auction_state.dart';

@injectable
class AuctionCubit extends Cubit<AuctionState> {
  final AuctionRepository repository;

  AuctionCubit(this.repository) : super(AuctionInitial());

  // ==========================================================
  // ERROR HANDLER
  // ==========================================================

  String _describe(Object error, String fallback) {
    if (error is Exception) {
      final message =
          ErrorHandler.mapExceptionToFailure(error).message;

      if (message.isNotEmpty) {
        return message;
      }
    }

    debugPrint('AuctionCubit error: $error');

    return fallback;
  }

  // ==========================================================
  // GET ALL AUCTIONS
  // ==========================================================

  Future<void> getAuctions() async {
    emit(AuctionLoading());

    try {
      // LIVE
      final liveAuctions =
          await repository.fetchAllAuctions(
        status: 'LIVE',
        sort: 'MOST_BIDS',
        take: 6,
      );

      // ENDING SOON
      final endingSoonAuctions =
          await repository.fetchAllAuctions(
        status: 'ENDING_SOON',
        sort: 'ENDING_SOON',
        take: 6,
      );

      // UPCOMING
      final upcomingAuctions =
          await repository.fetchAllAuctions(
        status: 'STARTING_SOON',
        sort: 'NEWEST',
        take: 6,
      );

      emit(
        AuctionLoaded(
          liveAuctions: liveAuctions,
          endingSoonAuctions: endingSoonAuctions,
          upcomingAuctions: upcomingAuctions,
        ),
      );
    } catch (e) {
      emit(
        AuctionError(
          _describe(
            e,
            'Unable to load auctions. Please try again.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // GET AUCTION DETAIL
  // ==========================================================

  Future<void> getAuctionDetail(String auctionId) async {
    emit(AuctionDetailLoading());

    try {
      final auction =
          await repository.fetchAuctionById(auctionId);

      emit(
        AuctionDetailLoaded(
          auction: auction,
        ),
      );

      // Automatically load bidding history
      await getBidsHistory(auctionId);
    } catch (e) {
      emit(
        AuctionDetailError(
          _describe(
            e,
            'Unable to load auction details. Please try again.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // GET BIDDING HISTORY
  // ==========================================================

  Future<void> getBidsHistory(String auctionId) async {
    final currentState = state;

    // ----------------------------------------------------------
    // Make sure auction detail is already loaded
    // ----------------------------------------------------------

    if (currentState is! AuctionDetailLoaded) {
      debugPrint(
        'Cannot load bids because auction detail is not loaded.',
      );
      return;
    }

    // ----------------------------------------------------------
    // Show bids loading
    // ----------------------------------------------------------

    emit(
      currentState.copyWith(
        isBidsLoading: true,
        clearBidsError: true,
      ),
    );

    try {
      // --------------------------------------------------------
      // API CALL
      // --------------------------------------------------------

      final List<BidEntity> bids =
          await repository.getBidsHistory(auctionId);

      debugPrint(
        'Bids loaded successfully: ${bids.length}',
      );

      // --------------------------------------------------------
      // Update state
      // --------------------------------------------------------

      final latestState = state;

      if (latestState is AuctionDetailLoaded) {
        emit(
          latestState.copyWith(
            bids: bids,
            isBidsLoading: false,
            clearBidsError: true,
          ),
        );
      }
    } catch (e) {
      final message = _describe(
        e,
        'Unable to load bidding history. Please try again.',
      );

      debugPrint(
        'getBidsHistory error: $message',
      );

      final latestState = state;

      if (latestState is AuctionDetailLoaded) {
        emit(
          latestState.copyWith(
            isBidsLoading: false,
            bidsError: message,
          ),
        );
      }
    }
  }
}