
import 'package:flutter/material.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import 'status_badge.dart';

class AuctionProductCard extends StatelessWidget {
  final AuctionEntity auction;
  final VoidCallback onTap;

  const AuctionProductCard({
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

    final price = auction.currentBid ?? auction.startingPrice;

    return SizedBox(
      width: 245,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.border,
              ),
              boxShadow: colors.isDark
                  ? null
                  : [
                      BoxShadow(
                        color: colors.textPrimary.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 175,
                  width: double.infinity,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _placeholder(colors);
                          },
                        )
                      : _placeholder(colors),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge(
                              status: auction.status,
                            ),
                            Text(
                              '${auction.bidCount} bids',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),

                        Text(
                          auction.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          auction.currentBid != null
                              ? 'Current Bid'
                              : 'Starting Price',
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$$price',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: colors.textPrimary,
                              ),
                            ),

                            if (auction.status == 'LIVE')
                              Icon(
                                Icons.arrow_forward,
                                size: 18,
                                color: colors.textPrimary,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder(AppThemeColors colors) {
    return Container(
      color: colors.surfaceAlt,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 45,
          color: colors.textMuted,
        ),
      ),
    );
  }
}