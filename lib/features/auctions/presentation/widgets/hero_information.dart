// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the Auctions-screen hero's info pane (bidding-open badge, gold
// divider, PLACE A BID / VIEW MY BIDS buttons stacked inside the pane),
// kept for reference. The redesigned layout moves the two buttons out to
// the screen below the whole hero card (see auction_content.dart) and
// reworks this pane to match the new mockup — see the active
// HeroInformation implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
//
// import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';
// import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';
//
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_theme_colors.dart';
// import 'hero_bid_info.dart';
// import 'hero_countdown.dart';
//
// class HeroInformation extends StatelessWidget {
//   final AuctionEntity auction;
//   final VoidCallback onTap;
//
//   const HeroInformation({
//     super.key,
//     required this.auction,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               SizedBox(
//                 width: 8,
//                 height: 8,
//                 child: DecoratedBox(
//                   decoration: BoxDecoration(
//                     color: colors.auctionAccent,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'BIDDING OPEN NOW',
//                 style: TextStyle(
//                   color: colors.auctionAccent,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 2,
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 18),
//
//           Text(
//             auction.title,
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//             style: TextStyle(
//               color: colors.onHeroBanner,
//               fontSize: 26,
//               height: 1.15,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//
//           const SizedBox(height: 22),
//
//           Container(
//             width: 70,
//             height: 1,
//             color: colors.auctionAccent,
//           ),
//
//           const SizedBox(height: 22),
//
//           Wrap(
//             spacing: 30,
//             runSpacing: 18,
//             children: [
//               HeroBidInfo(auction: auction),
//               HeroCountdown(
//                 secondsRemaining: auction.secondsRemaining ?? 0,
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 24),
//
//           SizedBox(
//             height: 48,
//             child: ElevatedButton(
//               onPressed: onTap,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colors.auctionAccent,
//                 foregroundColor: colors.onAuctionAccent,
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 24,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'PLACE A BID',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   Icon(Icons.arrow_forward, size: 18),
//                 ],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: OutlinedButton(
//               onPressed: () async {
//                 final cubit = context.read<AuctionCubit>();
//
//                 await context.push(AppRoutes.myBids);
//
//                 await cubit.getAuctions();
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: colors.auctionAccent,
//                 side: BorderSide(
//                   color: colors.auctionAccent,
//                   width: 1.2,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.history_rounded, size: 18),
//                   SizedBox(width: 8),
//                   Text(
//                     'VIEW MY BIDS',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 1.3,
//                     ),
//                   ),
//                   SizedBox(width: 6),
//                   Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: 13,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
