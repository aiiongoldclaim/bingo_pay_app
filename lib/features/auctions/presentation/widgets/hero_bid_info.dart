import 'package:flutter/material.dart';

import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

class HeroBidInfo extends StatelessWidget {
  final AuctionEntity auction;

  const HeroBidInfo({
    super.key,
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final price = auction.currentBid ?? auction.startingPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CURRENT BID',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '\$$price',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${auction.bidCount} '
          '${auction.bidCount == 1 ? 'bid' : 'bids'} placed',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}