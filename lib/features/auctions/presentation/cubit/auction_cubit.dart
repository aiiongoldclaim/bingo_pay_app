import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bingo_pay/features/auctions/domain/repositories/auction_repository.dart';

import '../../../../core/error/error_handler.dart';
import 'auction_state.dart';

@injectable
class AuctionCubit extends Cubit<AuctionState> {
  final AuctionRepository repository;

  AuctionCubit(this.repository) : super(AuctionInitial());

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

  Future<void> getAuctions() async {
    emit(AuctionLoading());

    try {
      // LIVE
      final liveAuctions = await repository.fetchAllAuctions(
        status: 'LIVE',
        sort: 'MOST_BIDS',
        take: 6,
      );

      // ENDING SOON
      final endingSoonAuctions = await repository.fetchAllAuctions(
        status: 'ENDING_SOON',
        sort: 'ENDING_SOON',
        take: 6,
      );

      // UPCOMING
      final upcomingAuctions = await repository.fetchAllAuctions(
        status: 'STARTING_SOON',
        sort: 'NEWEST',
        take: 6,
      );

      emit(
        AuctionLoaded(
          liveAuctions: liveAuctions,
          // endingSoonAuctions: endingSoonAuctions,
          endingSoonAuctions: liveAuctions,
          // upcomingAuctions: upcomingAuctions,
          upcomingAuctions: liveAuctions,
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
}