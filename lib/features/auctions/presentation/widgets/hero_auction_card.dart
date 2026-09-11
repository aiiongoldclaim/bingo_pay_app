// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the Auctions-screen hero card: image and info pane stack
// vertically on phones and only sit side-by-side above ~650dp, kept for
// reference. The redesigned card always renders side-by-side (matching the
// new mockup) and adds the LIVE badge / page dots / "bids placed" pill
// overlaid on the image — see the active HeroAuctionCard implementation
// below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
//
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';
//
// import 'hero_information.dart';
// import 'hero_image.dart';
//
// class HeroAuctionCard extends StatelessWidget {
//   final AuctionEntity auction;
//   final VoidCallback onTap;
//
//   const HeroAuctionCard({
//     super.key,
//     required this.auction,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     final imageUrl =
//         auction.images != null && auction.images!.isNotEmpty
//             ? auction.images!.first
//             : null;
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
//       decoration: BoxDecoration(
//         color: colors.auctionHeroBackground,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: colors.isDark
//             ? null
//             : [
//                 BoxShadow(
//                   color: colors.textPrimary.withValues(alpha: 0.10),
//                   blurRadius: 20,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final isWide = constraints.maxWidth > 650;
//
//           if (isWide) {
//             return Row(
//               children: [
//                 Expanded(
//                   child: HeroInformation(
//                     auction: auction,
//                     onTap: onTap,
//                   ),
//                 ),
//                 Expanded(
//                   child: HeroImage(
//                     imageUrl: imageUrl,
//                   ),
//                 ),
//               ],
//             );
//           }
//
//           return Column(
//             children: [
//               HeroImage(
//                 imageUrl: imageUrl,
//               ),
//               HeroInformation(
//                 auction: auction,
//                 onTap: onTap,
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

import 'hero_information.dart';

/// Redesigned hero card: image pane (LIVE badge, page dots and a "bids
/// placed" pill overlaid) always side-by-side with the info pane, matching
/// the new Auctions screen mockup.
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.1.w),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.border),
          boxShadow: colors.isDark
              ? null
              : [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _HeroImagePane(auction: auction),
              ),
              Expanded(
                child: HeroInformation(auction: auction),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroImagePane extends StatefulWidget {
  const _HeroImagePane({required this.auction});

  final AuctionEntity auction;

  @override
  State<_HeroImagePane> createState() => _HeroImagePaneState();
}

class _HeroImagePaneState extends State<_HeroImagePane> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final auction = widget.auction;
    final images = auction.images ?? const <String>[];
    final isLive = auction.status.toUpperCase() == 'LIVE';

    return Stack(
      fit: StackFit.expand,
      children: [
        images.isEmpty
            ? _placeholder(colors)
            : PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  return Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(colors),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(color: colors.brand),
                      );
                    },
                  );
                },
              ),

        if (isLive)
          Positioned(
            top: 1.42.h,
            left: 2.56.w,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.05.w,
                vertical: 0.71.h,
              ),
              decoration: BoxDecoration(
                color: colors.brand,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 12.sp,
                    color: colors.onBrand,
                  ),
                  SizedBox(width: 1.03.w),
                  Text(
                    'LIVE AUCTION',
                    style: TextStyle(
                      color: colors.onBrand,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (auction.bidCount > 0)
          Positioned(
            left: 2.56.w,
            bottom: 1.42.h,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.05.w,
                vertical: 0.59.h,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_rounded, size: 12.sp, color: Colors.white),
                  SizedBox(width: 1.03.w),
                  Text(
                    '${auction.bidCount} '
                    '${auction.bidCount == 1 ? 'bid' : 'bids'} placed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (images.length > 1)
          Positioned(
            bottom: 1.42.h,
            right: 0,
            left: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                final selected = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(horizontal: 0.51.w),
                  height: 1.03.w,
                  width: selected ? 3.08.w : 1.03.w,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _placeholder(AppThemeColors colors) {
    return Container(
      color: colors.surfaceAlt,
      child: Icon(
        Icons.image_outlined,
        size: 40.sp,
        color: colors.textMuted,
      ),
    );
  }
}
