// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the Auctions-screen section: a horizontally-scrolling row of
// fixed-width cards, kept for reference. The redesigned section renders a
// vertical list of full-width row cards instead — see the active
// AuctionSection implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
//
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';
//
// import 'auction_product_card.dart';
//
// class AuctionSection extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final List<AuctionEntity> auctions;
//
//   final Future<void> Function(String auctionId) onAuctionTap;
//
//   const AuctionSection({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.auctions,
//     required this.onAuctionTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 30),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: colors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   'View all',
//                   style: TextStyle(
//                     color: colors.brand,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           SizedBox(
//             height: 350,
//             child: ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               scrollDirection: Axis.horizontal,
//               itemCount: auctions.length,
//               separatorBuilder: (_, __) {
//                 return const SizedBox(width: 14);
//               },
//               itemBuilder: (context, index) {
//                 final auction = auctions[index];
//
//                 return AuctionProductCard(
//                   auction: auction,
//                   onTap: () {
//                     onAuctionTap(auction.uuid);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_text_styles.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import 'auction_product_card.dart';

/// Redesigned Auctions-screen section: a vertical list of full-width row
/// cards, matching the new mockup, replacing the old horizontally-scrolling
/// row of fixed-width cards.
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
                      ),
                    ),
                    SizedBox(height: 0.24.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        color: colors.brand,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.brand,
                      size: 16.sp,
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
