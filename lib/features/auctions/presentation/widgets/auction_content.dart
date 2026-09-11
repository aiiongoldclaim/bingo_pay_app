// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the Auctions-screen content: hero card followed directly by
// the Live/Ending Soon/Upcoming sections (no PLACE A BID / VIEW MY BIDS
// buttons on this screen), kept for reference. The redesigned content adds
// those two buttons below the hero card — see the active AuctionContent
// implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
//
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';
//
// import 'auction_section.dart';
// import 'hero_auction_card.dart';
//
// class AuctionContent extends StatelessWidget {
//   final List<AuctionEntity> liveAuctions;
//   final List<AuctionEntity> endingSoonAuctions;
//   final List<AuctionEntity> upcomingAuctions;
//
//   final Future<void> Function(String auctionId) onAuctionTap;
//
//   const AuctionContent({
//     super.key,
//     required this.liveAuctions,
//     required this.endingSoonAuctions,
//     required this.upcomingAuctions,
//     required this.onAuctionTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final heroAuction = _getHeroAuction();
//
//     final hasAuctions =
//         liveAuctions.isNotEmpty ||
//         endingSoonAuctions.isNotEmpty ||
//         upcomingAuctions.isNotEmpty;
//
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.only(bottom: 30),
//       children: [
//         if (heroAuction != null)
//           HeroAuctionCard(
//             auction: heroAuction,
//             onTap: () {
//               onAuctionTap(heroAuction.uuid);
//             },
//           ),
//
//         if (heroAuction != null)
//           const SizedBox(height: 28),
//
//         if (liveAuctions.isNotEmpty)
//           AuctionSection(
//             title: 'Live',
//             subtitle: 'Bidding open now',
//             auctions: liveAuctions,
//             onAuctionTap: onAuctionTap,
//           ),
//
//         if (endingSoonAuctions.isNotEmpty)
//           AuctionSection(
//             title: 'Ending Soon',
//             subtitle: 'Don\'t miss these auctions',
//             auctions: endingSoonAuctions,
//             onAuctionTap: onAuctionTap,
//           ),
//
//         if (upcomingAuctions.isNotEmpty)
//           AuctionSection(
//             title: 'Upcoming',
//             subtitle: 'Get ready to bid',
//             auctions: upcomingAuctions,
//             onAuctionTap: onAuctionTap,
//           ),
//
//         if (!hasAuctions)
//           Padding(
//             padding: const EdgeInsets.all(40),
//             child: Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.gavel_outlined,
//                     size: 48,
//                     color: colors.textMuted,
//                   ),
//                   const SizedBox(height: 14),
//                   Text(
//                     'No auctions available',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: colors.textMuted,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   AuctionEntity? _getHeroAuction() {
//     if (liveAuctions.isEmpty) {
//       return null;
//     }
//
//     final sorted = List<AuctionEntity>.from(liveAuctions);
//
//     sorted.sort((a, b) {
//       final aTime = a.secondsRemaining ?? 999999999;
//       final bTime = b.secondsRemaining ?? 999999999;
//
//       return aTime.compareTo(bTime);
//     });
//
//     return sorted.first;
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';

import 'auction_section.dart';
import 'hero_auction_card.dart';

/// Redesigned Auctions-screen content: hero card, then the PLACE A BID /
/// VIEW MY BIDS buttons (moved out of the hero's info pane so they span
/// the full width), then the Live/Ending Soon/Upcoming sections.
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
    final colors = context.colors;
    final heroAuction = _getHeroAuction();

    final hasAuctions =
        liveAuctions.isNotEmpty ||
        endingSoonAuctions.isNotEmpty ||
        upcomingAuctions.isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: 1.42.h, bottom: 3.55.h),
      children: [
        if (heroAuction != null)
          HeroAuctionCard(
            auction: heroAuction,
            onTap: () {
              onAuctionTap(heroAuction.uuid);
            },
          ),

        if (heroAuction != null) ...[
          SizedBox(height: 1.66.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.1.w),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 6.16.h,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: colors.buttonPrimaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onAuctionTap(heroAuction.uuid),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gavel_rounded, color: colors.onBrand, size: 17.sp),
                            SizedBox(width: 2.05.w),
                            Text(
                              'PLACE A BID',
                              style: TextStyle(
                                color: colors.onBrand,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 2.05.w),
                            Icon(Icons.arrow_forward_rounded, color: colors.onBrand, size: 17.sp),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 1.42.h),

                SizedBox(
                  width: double.infinity,
                  height: 6.16.h,
                  child: OutlinedButton(
                    onPressed: () async {
                      final cubit = context.read<AuctionCubit>();

                      await context.push(AppRoutes.myBids);

                      await cubit.getAuctions();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.brand,
                      side: BorderSide(color: colors.brand, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 17.sp),
                        SizedBox(width: 2.05.w),
                        Text(
                          'VIEW MY BIDS',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 2.05.w),
                        Icon(Icons.arrow_forward_rounded, size: 15.sp),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (liveAuctions.isNotEmpty) ...[
          SizedBox(height: 2.84.h),
          AuctionSection(
            title: 'Live Auctions',
            subtitle: 'Bidding open now',
            auctions: liveAuctions,
            onAuctionTap: onAuctionTap,
          ),
        ],

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
          Padding(
            padding: EdgeInsets.all(10.26.w),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gavel_outlined,
                    size: 12.31.w,
                    color: colors.textMuted,
                  ),
                  SizedBox(height: 1.66.h),
                  Text(
                    'No auctions available',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: colors.textMuted,
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
