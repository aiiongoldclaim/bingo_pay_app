

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bingo_pay/features/auctions/domain/entities/bid_entity.dart';
import 'package:bingo_pay/features/auctions/domain/repositories/auction_repository.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
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
      // --------------------------------------------------------
      // LIVE
      // --------------------------------------------------------

      final liveAuctions =
          await repository.fetchAllAuctions(
        status: 'LIVE',
        sort: 'MOST_BIDS',
        take: 6,
      );

      // --------------------------------------------------------
      // ENDING SOON
      // --------------------------------------------------------

      final endingSoonAuctions =
          await repository.fetchAllAuctions(
        status: 'ENDING_SOON',
        sort: 'ENDING_SOON',
        take: 6,
      );

      // --------------------------------------------------------
      // UPCOMING
      // --------------------------------------------------------

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

      // Automatically load bidding history.
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

  // ==========================================================
  // PLACE BID
  // ==========================================================

  Future<void> placeBid({
    required String auctionId,
    required String amount,
  }) async {
    final currentState = state;

    // ----------------------------------------------------------
    // Make sure auction detail is loaded
    // ----------------------------------------------------------

    if (currentState is! AuctionDetailLoaded) {
      debugPrint(
        'Cannot place bid because auction detail is not loaded.',
      );
      return;
    }

    // ----------------------------------------------------------
    // Prevent duplicate button clicks
    // ----------------------------------------------------------

    if (currentState.isPlacingBid) {
      debugPrint(
        'Place bid request already in progress.',
      );
      return;
    }

    // ----------------------------------------------------------
    // Validate amount
    // ----------------------------------------------------------

    if (amount.trim().isEmpty) {
      emit(
        currentState.copyWith(
          placeBidError: 'Please enter a bid amount.',
          clearPlaceBidError: false,
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // Generate 128-character idempotency key
    // ----------------------------------------------------------

    final idempotencyKey =
        IdempotencyKeyGenerator.generate();

    debugPrint(
      'Place bid idempotency key length: '
      '${idempotencyKey.length}',
    );

    // ----------------------------------------------------------
    // Show loading
    // ----------------------------------------------------------

    emit(
      currentState.copyWith(
        isPlacingBid: true,
        clearPlaceBidError: true,
        clearPlacedBid: true,
      ),
    );

    try {
      // --------------------------------------------------------
      // PLACE BID API
      // --------------------------------------------------------

      final placedBid = await repository.placeBid(
        auctionUuid: auctionId,
        amount: amount.trim(),
        idempotencyKey: idempotencyKey,
      );

      debugPrint(
        'Bid placed successfully: ${placedBid.bidUuid}',
      );

      debugPrint(
        'Current bid: ${placedBid.currentBid}',
      );

      debugPrint(
        'Minimum next bid: ${placedBid.minimumNextBid}',
      );

      debugPrint(
        'Bid count: ${placedBid.bidCount}',
      );

      debugPrint(
        'Highest bidder: ${placedBid.isHighestBidder}',
      );

      // --------------------------------------------------------
      // Update current detail state
      // --------------------------------------------------------

      final latestState = state;

      if (latestState is AuctionDetailLoaded) {
        emit(
          latestState.copyWith(
            isPlacingBid: false,
            placedBid: placedBid,
            clearPlaceBidError: true,
          ),
        );
      }

      // --------------------------------------------------------
      // Refresh bidding history
      // --------------------------------------------------------

      await getBidsHistory(auctionId);
    } catch (e) {
      final message = _describe(
        e,
        'Unable to place bid. Please try again.',
      );

      debugPrint(
        'placeBid error: $message',
      );

      // --------------------------------------------------------
      // Keep AuctionDetailLoaded state
      // --------------------------------------------------------

      final latestState = state;

      if (latestState is AuctionDetailLoaded) {
        emit(
          latestState.copyWith(
            isPlacingBid: false,
            placeBidError: message,
            clearPlacedBid: true,
          ),
        );
      }
    }
  }

  // ==========================================================
  // CLEAR BID RESULT
  // ==========================================================

  void clearBidResult() {
    final currentState = state;

    if (currentState is AuctionDetailLoaded) {
      emit(
        currentState.copyWith(
          clearPlaceBidError: true,
          clearPlacedBid: true,
        ),
      );
    }
  }

  // ==========================================================
// GET MY BIDS
// ==========================================================

Future<void> getMyBids({
  int take = 20,
  int skip = 0,
  String? state,
}) async {
  emit(MyBidsLoading());

  try {
    debugPrint(
      'Getting my bids... '
      'take: $take, '
      'skip: $skip, '
      'state: $state',
    );

    final myBids = await repository.getMyBids(
      take: take,
      skip: skip,
      state: state,
    );

    debugPrint(
      'My bids loaded successfully.',
    );

    emit(
      MyBidsLoaded(
        myBids: myBids,
      ),
    );
  } catch (e) {
    final message = _describe(
      e,
      'Unable to load your bids. Please try again.',
    );

    debugPrint(
      'getMyBids error: $message',
    );

    emit(
      MyBidsError(message),
    );
  }
}
}