import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'hero_countdown.dart';
import 'hero_wishlist_button.dart';

class HeroInformation extends StatelessWidget {
  final AuctionEntity auction;

  const HeroInformation({
    super.key,
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final category = auction.category?.name.trim() ?? '';
    final price = auction.currentBid ?? auction.startingPrice;

    return Padding(
      padding: EdgeInsets.all(4.1.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.isNotEmpty)
                Expanded(
                  child: Text(
                    category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                )
              else
                const Spacer(),
              HeroWishlistButton(auctionUuid: auction.uuid),
            ],
          ),

          SizedBox(height: 0.1.h),

          Text(
            auction.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontFamily: AppTextStyles.fontDisplay,
              fontSize: 21.sp,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            'Current Bid',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.24.h),
          Text(
            '\$$price',
            style: TextStyle(
              color: colors.brand,
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: .5.h),

          HeroCountdown(
            secondsRemaining: auction.secondsRemaining ?? 0,
          ),
        ],
      ),
    );
  }
}
