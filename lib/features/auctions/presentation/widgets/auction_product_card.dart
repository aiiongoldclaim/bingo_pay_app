import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';

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

    final currentBid = auction.currentBid ?? auction.startingPrice;
    final isLive = auction.status.toUpperCase() == 'LIVE';
    final category = auction.category?.name.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
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
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 45.w,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(colors),
                          )
                        : _placeholder(colors),
                  ),
                  if (isLive)
                    Positioned(
                      left: 3.08.w,
                      top: 2.37.w,
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
                                fontSize: 10.sp,
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

              Padding(
                padding: EdgeInsets.all(3.08.w),
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
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 1.54.w),
                        Flexible(
                          child: Text(
                            '${auction.bidCount} '
                            '${auction.bidCount == 1 ? 'bid' : 'bids'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: colors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
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
                          fontSize: 12.sp,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],

                    SizedBox(height: 1.19.h),

                    Text(
                      'Starting Price',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${auction.startingPrice}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 1.19.h),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Bid',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '\$$currentBid',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w800,
                                  color: colors.brand,
                                ),
                              ),
                            ],
                          ),
                        ),
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

                    SizedBox(height: 0.83.h),

                    Row(
                      children: [
                        Text(
                          'Closes in',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: colors.textMuted,
                            fontWeight: FontWeight.w700,
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
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: colors.brand,
      ),
    );
  }
}
