// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the Auctions-screen list item: a fixed-width vertical card
// (image on top, details below) meant for a horizontally-scrolling row,
// kept for reference. The redesigned list uses a full-width horizontal row
// card instead (thumbnail left, details right) — see the active
// AuctionProductCard implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
//
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';
//
// import 'status_badge.dart';
//
// class AuctionProductCard extends StatelessWidget {
//   final AuctionEntity auction;
//   final VoidCallback onTap;
//
//   const AuctionProductCard({
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
//     final price = auction.currentBid ?? auction.startingPrice;
//
//     return SizedBox(
//       width: 245,
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(18),
//           child: Container(
//             decoration: BoxDecoration(
//               color: colors.surface,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(
//                 color: colors.border,
//               ),
//               boxShadow: colors.isDark
//                   ? null
//                   : [
//                       BoxShadow(
//                         color: colors.textPrimary.withValues(alpha: 0.04),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//             ),
//             clipBehavior: Clip.antiAlias,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   height: 175,
//                   width: double.infinity,
//                   child: imageUrl != null
//                       ? Image.network(
//                           imageUrl,
//                           fit: BoxFit.cover,
//                           errorBuilder: (_, __, ___) {
//                             return _placeholder(colors);
//                           },
//                         )
//                       : _placeholder(colors),
//                 ),
//
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(14),
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                           children: [
//                             StatusBadge(
//                               status: auction.status,
//                             ),
//                             Text(
//                               '${auction.bidCount} bids',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 color: colors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 9),
//
//                         Text(
//                           auction.title,
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: colors.textPrimary,
//                           ),
//                         ),
//
//                         const Spacer(),
//
//                         Text(
//                           auction.currentBid != null
//                               ? 'Current Bid'
//                               : 'Starting Price',
//                           style: TextStyle(
//                             fontSize: 10,
//                             color: colors.textSecondary,
//                           ),
//                         ),
//
//                         const SizedBox(height: 3),
//
//                         Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '\$$price',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w800,
//                                 color: colors.textPrimary,
//                               ),
//                             ),
//
//                             if (auction.status == 'LIVE')
//                               Icon(
//                                 Icons.arrow_forward,
//                                 size: 18,
//                                 color: colors.textPrimary,
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _placeholder(AppThemeColors colors) {
//     return Container(
//       color: colors.surfaceAlt,
//       child: Center(
//         child: Icon(
//           Icons.image_outlined,
//           size: 45,
//           color: colors.textMuted,
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

/// Redesigned Auctions-screen list item: a full-width horizontal row card
/// (thumbnail left, details right, LIVE badge + live countdown + chevron)
/// matching the new mockup.
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
    final isLive = auction.status.toUpperCase() == 'LIVE';
    final category = auction.category?.name.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.all(2.05.w),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 20.51.w,
                      height: 20.51.w,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(colors),
                            )
                          : _placeholder(colors),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      left: 0.51.w,
                      top: 0.47.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 1.54.w,
                          vertical: 0.36.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 1.28.w,
                              height: 1.28.w,
                              decoration: BoxDecoration(
                                color: colors.statusSuccess,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 0.77.w),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(width: 2.82.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            auction.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          '${auction.bidCount} '
                          '${auction.bidCount == 1 ? 'bid' : 'bids'}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),

                    if (category.isNotEmpty) ...[
                      SizedBox(height: 0.24.h),
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],

                    SizedBox(height: 0.83.h),

                    Text(
                      auction.currentBid != null
                          ? 'Current Bid'
                          : 'Starting Price',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$$price',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: colors.brand,
                      ),
                    ),

                    SizedBox(height: 0.71.h),

                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 12.sp,
                          color: colors.textMuted,
                        ),
                        SizedBox(width: 0.77.w),
                        Text(
                          'Closes in',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: colors.textMuted,
                          ),
                        ),
                        SizedBox(width: 0.77.w),
                        Expanded(
                          child: _LiveCountdownText(
                            secondsRemaining: auction.secondsRemaining ?? 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 1.03.w),

              Container(
                width: 7.69.w,
                height: 7.69.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.brand,
                  size: 17.sp,
                ),
              ),
            ],
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
          size: 20.sp,
          color: colors.textMuted,
        ),
      ),
    );
  }
}

/// Live-ticking "01d : 04h : 49m : 36s" countdown text for a list row.
class _LiveCountdownText extends StatefulWidget {
  const _LiveCountdownText({required this.secondsRemaining});

  final int secondsRemaining;

  @override
  State<_LiveCountdownText> createState() => _LiveCountdownTextState();
}

class _LiveCountdownTextState extends State<_LiveCountdownText> {
  Timer? _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.secondsRemaining;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _LiveCountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.secondsRemaining != widget.secondsRemaining) {
      _remaining = widget.secondsRemaining;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (_remaining <= 0) {
        _timer?.cancel();
        setState(() => _remaining = 0);
        return;
      }

      setState(() => _remaining--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = Duration(seconds: _remaining);

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    final text =
        '${days}d : ${hours.toString().padLeft(2, '0')}h : '
        '${minutes.toString().padLeft(2, '0')}m : '
        '${seconds.toString().padLeft(2, '0')}s';

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
        color: colors.brand,
      ),
    );
  }
}
