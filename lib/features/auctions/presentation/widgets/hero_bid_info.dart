import 'package:flutter/material.dart';

import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import '../../../../core/theme/app_theme_colors.dart';

class HeroBidInfo extends StatelessWidget {
  final AuctionEntity auction;

  const HeroBidInfo({
    super.key,
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onHeroMuted = colors.onHeroBanner.withValues(alpha: 0.54);
    final price = auction.currentBid ?? auction.startingPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT BID',
          style: TextStyle(
            color: onHeroMuted,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '\$$price',
          style: TextStyle(
            color: colors.onHeroBanner,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${auction.bidCount} '
          '${auction.bidCount == 1 ? 'bid' : 'bids'} placed',
          style: TextStyle(
            color: onHeroMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}