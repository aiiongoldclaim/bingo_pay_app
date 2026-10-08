import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_text_styles.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
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
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: 3.55.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.1.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontDisplay,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 0.24.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 1.9.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.1.w),
            child: Column(
              children: [
                for (var index = 0; index < auctions.length; index++) ...[
                  if (index > 0) SizedBox(height: 1.42.h),
                  AuctionProductCard(
                    auction: auctions[index],
                    onTap: () => onAuctionTap(auctions[index].uuid),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
