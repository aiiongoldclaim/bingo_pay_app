import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import 'hero_information.dart';
import 'hero_image.dart';

class HeroAuctionCard extends StatelessWidget {
  final AuctionEntity auction;
  final VoidCallback onTap;

  const HeroAuctionCard({
    super.key,
    required this.auction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final imageUrl =
        auction.images != null && auction.images!.isNotEmpty
            ? auction.images!.first
            : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: colors.auctionHeroBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 650;

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  child: HeroInformation(
                    auction: auction,
                    onTap: onTap,
                  ),
                ),
                Expanded(
                  child: HeroImage(
                    imageUrl: imageUrl,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              HeroImage(
                imageUrl: imageUrl,
              ),
              HeroInformation(
                auction: auction,
                onTap: onTap,
              ),
            ],
          );
        },
      ),
    );
  }
}