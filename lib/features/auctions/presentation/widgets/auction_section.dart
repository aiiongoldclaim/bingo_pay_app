import 'package:flutter/material.dart';

import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import 'auction_product_card.dart';

class AuctionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AuctionEntity> auctions;

  final Future<void> Function(String auctionId) onAuctionTap;

  const AuctionSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.auctions,
    required this.onAuctionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Text(
                  'View all',
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 350,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: auctions.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 14);
              },
              itemBuilder: (context, index) {
                final auction = auctions[index];

                return AuctionProductCard(
                  auction: auction,
                  onTap: () {
                    onAuctionTap(auction.uuid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}