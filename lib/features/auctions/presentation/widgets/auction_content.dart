import 'package:flutter/material.dart';

import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import 'auction_section.dart';
import 'hero_auction_card.dart';

class AuctionContent extends StatelessWidget {
  final List<AuctionEntity> liveAuctions;
  final List<AuctionEntity> endingSoonAuctions;
  final List<AuctionEntity> upcomingAuctions;

  final Future<void> Function(String auctionId) onAuctionTap;

  const AuctionContent({
    super.key,
    required this.liveAuctions,
    required this.endingSoonAuctions,
    required this.upcomingAuctions,
    required this.onAuctionTap,
  });

  @override
  Widget build(BuildContext context) {
    final heroAuction = _getHeroAuction();

    final hasAuctions =
        liveAuctions.isNotEmpty ||
        endingSoonAuctions.isNotEmpty ||
        upcomingAuctions.isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        if (heroAuction != null)
          HeroAuctionCard(
            auction: heroAuction,
            onTap: () {
              onAuctionTap(heroAuction.uuid);
            },
          ),

        if (heroAuction != null)
          const SizedBox(height: 28),

        if (liveAuctions.isNotEmpty)
          AuctionSection(
            title: 'Live',
            subtitle: 'Bidding open now',
            auctions: liveAuctions,
            onAuctionTap: onAuctionTap,
          ),

        if (endingSoonAuctions.isNotEmpty)
          AuctionSection(
            title: 'Ending Soon',
            subtitle: 'Don\'t miss these auctions',
            auctions: endingSoonAuctions,
            onAuctionTap: onAuctionTap,
          ),

        if (upcomingAuctions.isNotEmpty)
          AuctionSection(
            title: 'Upcoming',
            subtitle: 'Get ready to bid',
            auctions: upcomingAuctions,
            onAuctionTap: onAuctionTap,
          ),

        if (!hasAuctions)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gavel_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'No auctions available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  AuctionEntity? _getHeroAuction() {
    if (liveAuctions.isEmpty) {
      return null;
    }

    final sorted = List<AuctionEntity>.from(liveAuctions);

    sorted.sort((a, b) {
      final aTime = a.secondsRemaining ?? 999999999;
      final bTime = b.secondsRemaining ?? 999999999;

      return aTime.compareTo(bTime);
    });

    return sorted.first;
  }
}