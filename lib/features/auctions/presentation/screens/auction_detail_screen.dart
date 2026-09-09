import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/features/auctions/domain/entities/auction_detail_entity.dart';
import 'package:bingo_pay/features/auctions/domain/entities/bid_entity.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_state.dart';

import '../../../../core/widgets/custom_app_bar.dart';

class AuctionDetailScreen extends StatefulWidget {
  final String auctionId;

  const AuctionDetailScreen({
    super.key,
    required this.auctionId,
  });

  @override
  State<AuctionDetailScreen> createState() =>
      _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AuctionCubit>().getAuctionDetail(
            widget.auctionId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(
        title: 'Auction Details',
        centerTitle: true,
      ),
      body: BlocBuilder<AuctionCubit, AuctionState>(
        builder: (context, state) {
          if (state is AuctionDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AuctionDetailError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<AuctionCubit>().getAuctionDetail(
                      widget.auctionId,
                    );
              },
            );
          }

          if (state is AuctionDetailLoaded) {
            return _AuctionDetailContent(
              auction: state.auction,
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}



class _AuctionDetailContent extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _AuctionDetailContent({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AuctionCubit>().getAuctionDetail(
              auction.uuid,
            );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          4.1.w,
          2.37.h,
          4.1.w,
          5.92.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _ProductSection(
              auction: auction,
            ),

            SizedBox(height: 2.84.h),

            _BidPanel(
              auction: auction,
            ),

            SizedBox(height: 3.55.h),

            _ModernAboutSection(
              auction: auction,
            ),

            SizedBox(height: 3.32.h),

            _ModernBidActivitySection(
              auction: auction,
            ),

            SizedBox(height: 3.32.h),

            _ModernAuctionDetailsSection(
              auction: auction,
            ),

            SizedBox(height: 2.84.h),

            _ModernTrustCard(),
          ],
        ),
      ),
    );
  }
}


class _ProductSection extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _ProductSection({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuctionImage(
          images: auction.images,
        ),

        SizedBox(height: 2.13.h),

        Row(
          children: [
            _StatusBadge(
              status: auction.status,
            ),

            SizedBox(width: 2.56.w),

            if (auction.badge.isNotEmpty)
              Flexible(
                child: Text(
                  auction.badge,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: colors.textSecondary,
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 1.42.h),

        Text(
          auction.title,
          style: TextStyle(
            fontSize: 27.sp,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),

        if (auction.itemName != null &&
            auction.itemName!.trim().isNotEmpty) ...[
          SizedBox(height: 1.07.h),
          Text(
            auction.itemName!,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.textSecondary,
            ),
          ),
        ],

        if (auction.vendor != null) ...[
          SizedBox(height: 1.42.h),
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 17.sp,
                color: colors.textSecondary,
              ),
              SizedBox(width: 1.79.w),
              Flexible(
                child: Text(
                  auction.vendor!.shopName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}



class _AuctionImage extends StatefulWidget {
  final List<String>? images;

  const _AuctionImage({
    required this.images,
  });

  @override
  State<_AuctionImage> createState() => _AuctionImageState();
}

class _AuctionImageState extends State<_AuctionImage> {
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
    final images = widget.images ?? [];

    if (images.isEmpty) {
      return _placeholder(colors);
    }

    return Column(
      children: [
        Container(
          height: 42.65.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: colors.border,
            ),
            boxShadow: colors.isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.textPrimary.withValues(alpha: 0.035),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return _placeholder(colors);
                },
                loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
            },
          ),
        ),

        if (images.length > 1) ...[
          SizedBox(height: 1.42.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) {
                final selected = index == _currentIndex;

                return AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: 0.77.w,
                  ),
                  height: 1.54.w,
                  width: selected ? 5.64.w : 1.54.w,
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.auctionAccent
                        : colors.border,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _placeholder(AppThemeColors colors) {
    return Container(
      height: 42.65.h,
      width: double.infinity,
      color: colors.surfaceAlt,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 60.sp,
          color: colors.textMuted,
        ),
      ),
    );
  }
}


class _BidPanel extends StatefulWidget {
  final AuctionDetailEntity auction;

  const _BidPanel({
    required this.auction,
  });

  @override
  State<_BidPanel> createState() => _BidPanelState();
}

class _BidPanelState extends State<_BidPanel> {
  late final TextEditingController _bidController;

  String? _lastHandledBidUuid;
  String? _lastHandledBidError;

  @override
  void initState() {
    super.initState();

    _bidController = TextEditingController(
      text: widget.auction.minimumNextBid,
    );
  }

  @override
  void didUpdateWidget(
    covariant _BidPanel oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.auction.minimumNextBid !=
        widget.auction.minimumNextBid) {
      if (_bidController.text.trim().isEmpty ||
          _bidController.text.trim() ==
              oldWidget.auction.minimumNextBid.trim()) {
        _bidController.text =
            widget.auction.minimumNextBid;
      }
    }
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auction = widget.auction;

    final currentBid =
        auction.currentBid ?? auction.startingPrice;

    final isLive = auction.status == 'LIVE';

    final isEligible =
        auction.viewer?.isEligible == true;

    return BlocConsumer<AuctionCubit, AuctionState>(
      listenWhen: (previous, current) {
        if (current is! AuctionDetailLoaded) {
          return false;
        }

        final previousState =
            previous is AuctionDetailLoaded
                ? previous
                : null;

        return previousState?.placedBid !=
                current.placedBid ||
            previousState?.placeBidError !=
                current.placeBidError;
      },
      listener: (context, state) {
        if (state is! AuctionDetailLoaded) {
          return;
        }

        final error = state.placeBidError;

        if (error != null &&
            error.isNotEmpty &&
            error != _lastHandledBidError) {
          _lastHandledBidError = error;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: context.colors.error,
              ),
            );
        }

        final placedBid = state.placedBid;

        if (placedBid != null &&
            placedBid.bidUuid.isNotEmpty &&
            placedBid.bidUuid !=
                _lastHandledBidUuid) {
          _lastHandledBidUuid =
              placedBid.bidUuid;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content:
                    Text('Bid placed successfully'),
              ),
            );

          if (placedBid.minimumNextBid
              .trim()
              .isNotEmpty) {
            _bidController.text =
                placedBid.minimumNextBid;
          }
        }
      },
      buildWhen: (previous, current) {
        if (previous is AuctionDetailLoaded &&
            current is AuctionDetailLoaded) {
          return previous.isPlacingBid !=
                  current.isPlacingBid ||
              previous.placedBid !=
                  current.placedBid ||
              previous.placeBidError !=
                  current.placeBidError;
        }

        return true;
      },
      builder: (context, state) {
        final colors = context.colors;

        final isPlacingBid =
            state is AuctionDetailLoaded
                ? state.isPlacingBid
                : false;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(5.64.w),
          decoration: BoxDecoration(
            color: colors.auctionHeroBackground,
            borderRadius:
                BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: colors.auctionHeroBackground
                    .withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT BID',
                style: TextStyle(
                  color: colors.onHeroBanner.withValues(alpha: 0.54),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),

              SizedBox(height: 0.71.h),

              Text(
                '${auction.currency} $currentBid',
                style: TextStyle(
                  color: colors.onHeroBanner,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 0.47.h),

              Text(
                '${auction.bidCount} '
                '${auction.bidCount == 1 ? 'bid' : 'bids'} placed',
                style: TextStyle(
                  color: colors.onHeroBanner.withValues(alpha: 0.54),
                  fontSize: 14.sp,
                ),
              ),

              if (isLive &&
                  auction.secondsRemaining != null) ...[
                SizedBox(height: 2.84.h),
                _Countdown(
                  secondsRemaining:
                      auction.secondsRemaining!,
                ),
              ],

              SizedBox(height: 2.84.h),

              Text(
                'NEXT VALID BID — '
                '${auction.currency} ${auction.minimumNextBid}',
                style: TextStyle(
                  color: colors.onHeroBanner.withValues(alpha: 0.70),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),

              SizedBox(height: 1.18.h),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall =
                      constraints.maxWidth < 360;

                  if (isSmall) {
                    return Column(
                      children: [
                        _NextBidBox(
                          value:
                              auction.minimumNextBid,
                          currency:
                              auction.currency,
                          minimumValue:
                              auction.minimumNextBid,
                          controller:
                              _bidController,
                        ),
                        SizedBox(height: 1.18.h),
                        SizedBox(
                          width: double.infinity,
                          height: 6.16.h,
                          child: _BidButton(
                            enabled:
                                isLive &&
                                    isEligible,
                            isLoading:
                                isPlacingBid,
                            onPressed: () {
                              _placeBid(
                                context,
                                auction,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _NextBidBox(
                          value:
                              auction.minimumNextBid,
                          currency:
                              auction.currency,
                          minimumValue:
                              auction.minimumNextBid,
                          controller:
                              _bidController,
                        ),
                      ),
                      SizedBox(width: 3.08.w),
                      SizedBox(
                        width: 32.05.w,
                        height: 6.16.h,
                        child: _BidButton(
                          enabled:
                              isLive &&
                                  isEligible,
                          isLoading:
                              isPlacingBid,
                          onPressed: () {
                            _placeBid(
                              context,
                              auction,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              SizedBox(height: 0.95.h),

              Text(
                'Minimum bid is '
                '${auction.currency} '
                '${auction.minimumNextBid}',
                style: TextStyle(
                  color: colors.onHeroBanner.withValues(alpha: 0.54),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (!isEligible &&
                  auction.viewer?.ineligibleReason !=
                      null) ...[
                SizedBox(height: 1.42.h),
                Text(
                  auction.viewer!.ineligibleReason!,
                  style: TextStyle(
                    color: colors.onHeroBanner.withValues(alpha: 0.54),
                    fontSize: 11.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _placeBid(
    BuildContext context,
    AuctionDetailEntity auction,
  ) {
    final amount =
        _bidController.text.trim();

    if (amount.isEmpty) {
      _showError(
        context,
        'Please enter a bid amount.',
      );
      return;
    }

    final enteredAmount =
        double.tryParse(
      amount.replaceAll(',', ''),
    );

    final minimumAmount =
        double.tryParse(
      auction.minimumNextBid
          .replaceAll(',', ''),
    );

    if (enteredAmount == null) {
      _showError(
        context,
        'Please enter a valid bid amount.',
      );
      return;
    }

    if (minimumAmount != null &&
        enteredAmount < minimumAmount) {
      _showError(
        context,
        'Bid must be at least '
        '${auction.currency} '
        '${auction.minimumNextBid}.',
      );
      return;
    }

    final currentState =
        context.read<AuctionCubit>().state;

    if (currentState is AuctionDetailLoaded &&
        currentState.isPlacingBid) {
      return;
    }

    context.read<AuctionCubit>().placeBid(
      auctionId: auction.uuid,
      amount: amount,
    );
  }

  void _showError(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              context.colors.error,
        ),
      );
  }
}


class _NextBidBox extends StatefulWidget {
  final String value;
  final String currency;
  final String minimumValue;
  final TextEditingController controller;

  const _NextBidBox({
    required this.value,
    required this.currency,
    required this.minimumValue,
    required this.controller,
  });

  @override
  State<_NextBidBox> createState() =>
      _NextBidBoxState();
}

class _NextBidBoxState
    extends State<_NextBidBox> {
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(
      _validateBid,
    );

    _validateBid();
  }

  @override
  void didUpdateWidget(
    covariant _NextBidBox oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller !=
        widget.controller) {
      oldWidget.controller.removeListener(
        _validateBid,
      );

      widget.controller.addListener(
        _validateBid,
      );
    }

    if (oldWidget.value != widget.value) {
      if (widget.controller.text.trim().isEmpty ||
          widget.controller.text.trim() ==
              oldWidget.value.trim()) {
        widget.controller.text =
            widget.value;
      }
    }
  }

  double _toNumber(String value) {
    final cleaned = value
        .replaceAll(',', '')
        .replaceAll(widget.currency, '')
        .trim();

    return double.tryParse(cleaned) ?? 0;
  }

  void _validateBid() {
    final minimum =
        _toNumber(widget.minimumValue);

    final entered =
        _toNumber(widget.controller.text);

    final hasError =
        widget.controller.text.trim().isEmpty ||
            entered < minimum;

    if (_hasError != hasError &&
        mounted) {
      setState(() {
        _hasError = hasError;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(
      _validateBid,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          height: 6.16.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.onHeroBanner.withValues(alpha: 0.08),
            border: Border.all(
              color: _hasError
                  ? colors.error
                      .withValues(alpha: 0.7)
                  : colors.onHeroBanner.withValues(alpha: 0.14),
            ),
            borderRadius:
                BorderRadius.circular(5),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme:
                  TextSelectionThemeData(
                selectionColor:
                    colors.auctionAccent.withValues(alpha: 0.4),
                selectionHandleColor:
                    colors.auctionAccent,
              ),
            ),
            child: TextField(
              controller:
                  widget.controller,
              cursorColor:
                  colors.auctionAccent,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(
                    r'^\d*\.?\d{0,2}',
                  ),
                ),
              ],
              textInputAction:
                  TextInputAction.done,
              style: TextStyle(
                color: colors.onHeroBanner,
                fontSize: 18.sp,
                fontWeight:
                    FontWeight.w600,
              ),
              decoration:
                  InputDecoration(
                filled: true,
                fillColor:
                    Colors.black.withValues(alpha: 0.078),
                border:
                    InputBorder.none,
                enabledBorder:
                    InputBorder.none,
                focusedBorder:
                    InputBorder.none,
                disabledBorder:
                    InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(
                  horizontal: 4.1.w,
                  vertical: 1.66.h,
                ),
              ),
            ),
          ),
        ),

        if (_hasError) ...[
          SizedBox(height: 0.59.h),
          Text(
            'Bid must be at least '
            '${widget.currency} '
            '${widget.minimumValue}',
            style: TextStyle(
              color: colors.error,
              fontSize: 10.sp,
            ),
          ),
        ],
      ],
    );
  }
}



class _BidButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const _BidButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ElevatedButton(
      onPressed:
          enabled && !isLoading
              ? onPressed
              : null,
      style:
          ElevatedButton.styleFrom(
        backgroundColor:
            colors.auctionAccent,
        foregroundColor: colors.onAuctionAccent,
        disabledBackgroundColor:
            colors.textMuted,
        disabledForegroundColor:
            colors.onHeroBanner.withValues(alpha: 0.54),
        elevation: 0,
        padding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(5),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 4.87.w,
              height: 4.87.w,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<
                        Color>(
                  colors.onAuctionAccent,
                ),
              ),
            )
          : Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.gavel,
                  size: 17.sp,
                ),
                SizedBox(width: 1.79.w),
                Text(
                  'PLACE BID',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: 1.3,
                  ),
                ),
              ],
            ),
    );
  }
}



class _Countdown extends StatefulWidget {
  final int secondsRemaining;

  const _Countdown({
    required this.secondsRemaining,
  });

  @override
  State<_Countdown> createState() =>
      _CountdownState();
}

class _CountdownState
    extends State<_Countdown> {
  Timer? _timer;

  late int _remaining;

  @override
  void initState() {
    super.initState();

    _remaining =
        widget.secondsRemaining;

    _startTimer();
  }

  @override
  void didUpdateWidget(
    covariant _Countdown oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.secondsRemaining !=
        widget.secondsRemaining) {
      _remaining =
          widget.secondsRemaining;

      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        if (_remaining <= 0) {
          _timer?.cancel();

          setState(() {
            _remaining = 0;
          });

          return;
        }

        setState(() {
          _remaining--;
        });
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration =
        Duration(seconds: _remaining);

    final days =
        duration.inDays;

    final hours =
        duration.inHours % 24;

    final minutes =
        duration.inMinutes % 60;

    final seconds =
        duration.inSeconds % 60;

    final colors = context.colors;

    return Container(
      padding:
          EdgeInsets.symmetric(
        vertical: 1.9.h,
        horizontal: 4.1.w,
      ),
      decoration:
          BoxDecoration(
        color:
            colors.onHeroBanner.withValues(alpha: 0.055),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              colors.onHeroBanner.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'BIDDING CLOSES IN',
            style: TextStyle(
              color: colors.onHeroBanner.withValues(alpha: 0.60),
              fontSize: 12.sp,
              letterSpacing: 2,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(height: 1.18.h),

          Row(
            children: [
              _CountdownValue(
                value: days,
                label: 'DAYS',
              ),
              const _CountdownColon(),
              _CountdownValue(
                value: hours,
                label: 'HRS',
              ),
              const _CountdownColon(),
              _CountdownValue(
                value: minutes,
                label: 'MIN',
              ),
              const _CountdownColon(),
              _CountdownValue(
                value: seconds,
                label: 'SEC',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownValue
    extends StatelessWidget {
  final int value;
  final String label;

  const _CountdownValue({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          value
              .toString()
              .padLeft(2, '0'),
          style: TextStyle(
            color: colors.onHeroBanner,
            fontSize: 25.sp,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.24.h),
        Text(
          label,
          style: TextStyle(
            color: colors.onHeroBanner.withValues(alpha: 0.54),
            fontSize: 12.sp,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _CountdownColon
    extends StatelessWidget {
  const _CountdownColon();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal: 1.79.w,
      ),
      child: Text(
        ':',
        style: TextStyle(
          color: colors.onHeroBanner.withValues(alpha: 0.38),
          fontSize: 22.sp,
        ),
      ),
    );
  }
}


class _ModernAboutSection
    extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _ModernAboutSection({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final description =
        auction.description
            ?.trim() ??
        '';

    final itemName =
        auction.itemName
            ?.trim() ??
        '';

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const _ModernSectionHeader(
          title: 'About this lot',
          icon: Icons
              .auto_awesome_outlined,
        ),

        SizedBox(height: 1.42.h),

        Container(
          width: double.infinity,
          padding:
              EdgeInsets.all(4.62.w),
          decoration:
              BoxDecoration(
            color: colors.surface,
            borderRadius:
                BorderRadius.circular(20),
            boxShadow: colors.isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.textPrimary
                          .withValues(alpha: 0.035),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 7),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (itemName.isNotEmpty) ...[
                Text(
                  itemName,
                  style:
                       TextStyle(
                    color:
                        colors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight:
                        FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 0.95.h),
              ],

              Text(
                description.isNotEmpty
                    ? description
                    : 'No description available for this auction.',
                style:
                    TextStyle(
                  color:
                      colors.textSecondary,
                  fontSize: 13.sp,
                  height: 1.65,
                ),
              ),

              SizedBox(height: 1.9.h),

              Wrap(
                spacing: 1.79.w,
                runSpacing: 0.83.h,
                children: [
                  if (auction
                      .listingLevel
                      .isNotEmpty)
                    _ModernChip(
                      icon:
                          Icons.verified_outlined,
                      text:
                          auction.listingLevel,
                    ),
                  if (auction.type
                      .isNotEmpty)
                    _ModernChip(
                      icon:
                          Icons.sell_outlined,
                      text:
                          auction.type,
                    ),
                  _ModernChip(
                    icon:
                        Icons.visibility_outlined,
                    text:
                        '${auction.viewCount} views',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _ModernBidActivitySection
    extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _ModernBidActivitySection({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _ModernSectionHeader(
          title: 'Bid activity',
          icon:
              Icons.trending_up_rounded,
          trailing:
              auction.bidCount > 0
                  ? '${auction.bidCount} bids'
                  : null,
        ),

        SizedBox(height: 1.42.h),

        BlocBuilder<
            AuctionCubit,
            AuctionState>(
          buildWhen:
              (previous, current) {
            if (previous
                    is AuctionDetailLoaded &&
                current
                    is AuctionDetailLoaded) {
              return previous.bids !=
                      current.bids ||
                  previous.isBidsLoading !=
                      current.isBidsLoading ||
                  previous.bidsError !=
                      current.bidsError;
            }

            return true;
          },
          builder:
              (context, state) {
            if (state
                    is AuctionDetailLoaded &&
                state.isBidsLoading) {
              return const _ModernLoadingCard();
            }

            if (state
                    is AuctionDetailLoaded &&
                state.bidsError != null &&
                state.bidsError!
                    .isNotEmpty) {
              return _ModernErrorCard(
                message:
                    state.bidsError!,
                onRetry: () {
                  context
                      .read<AuctionCubit>()
                      .getBidsHistory(
                        auction.uuid,
                      );
                },
              );
            }

            if (state
                is AuctionDetailLoaded) {
              final bids =
                  state.bids;

              if (bids.isEmpty) {
                return _ModernEmptyBidCard(
                  bidCount:
                      auction.bidCount,
                );
              }

              final colors = context.colors;

              return Container(
                width: double.infinity,
                padding:
                    EdgeInsets
                        .symmetric(
                  vertical: 0.59.h,
                ),
                decoration:
                    BoxDecoration(
                  color: colors.surface,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  boxShadow: colors.isDark
                      ? null
                      : [
                          BoxShadow(
                            color: colors.textPrimary
                                .withValues(
                              alpha: 0.035,
                            ),
                            blurRadius: 18,
                            offset:
                                const Offset(
                              0,
                              7,
                            ),
                          ),
                        ],
                ),
                child: Column(
                  children:
                      List.generate(
                    bids.length,
                    (index) {
                      return _ModernBidItem(
                        bid:
                            bids[index],
                        currency:
                            auction.currency,
                        isLeading:
                            index == 0,
                        isLast:
                            index ==
                                bids.length -
                                    1,
                      );
                    },
                  ),
                ),
              );
            }

            return const _ModernLoadingCard();
          },
        ),
      ],
    );
  }
}


class _ModernBidItem
    extends StatelessWidget {
  final BidEntity bid;
  final String currency;
  final bool isLeading;
  final bool isLast;

  const _ModernBidItem({
    required this.bid,
    required this.currency,
    required this.isLeading,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(
        4.1.w,
        1.54.h,
        4.1.w,
        1.54.h,
      ),
      child: Row(
        children: [
          Container(
            width: 10.26.w,
            height: 10.26.w,
            decoration:
                BoxDecoration(
              color: isLeading
                  ? colors.auctionAccent
                      .withValues(alpha: 0.16)
                  : colors.surfaceAlt,
              shape:
                  BoxShape.circle,
            ),
            child: Icon(
              isLeading
                  ? Icons
                      .emoji_events_outlined
                  : Icons
                      .person_outline_rounded,
              size: 18.sp,
              color: isLeading
                  ? colors.textPrimary
                  : colors.textSecondary,
            ),
          ),

          SizedBox(width: 2.82.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _bidderName(),
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            TextStyle(
                          color:
                              colors.textPrimary,
                          fontSize: 13.sp,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ),

                    if (isLeading) ...[
                      SizedBox(
                        width: 1.54.w,
                      ),
                      Container(
                        padding:
                            EdgeInsets
                                .symmetric(
                          horizontal: 1.54.w,
                          vertical: 0.36.h,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              colors.auctionAccent
                                  .withValues(
                            alpha: 0.15,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            6,
                          ),
                        ),
                        child:
                            Text(
                          'LEADING',
                          style:
                              TextStyle(
                            color:
                                colors.auctionAccentInk,
                            fontSize: 10.sp,
                            fontWeight:
                                FontWeight
                                    .w800,
                            letterSpacing:
                                .4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 0.47.h),

                Text(
                  _date(),
                  style:
                      TextStyle(
                    color:
                        colors.textMuted,
                    fontSize: 11.5.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 2.56.w),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '$currency ${bid.amount}',
                style:
                    TextStyle(
                  color: isLeading
                      ? colors.statusSuccess
                      : colors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              SizedBox(height: 0.36.h),

              Text(
                isLeading
                    ? 'CURRENT'
                    : 'BID',
                style:
                    TextStyle(
                  color:
                      colors.textMuted,
                  fontSize: 10.sp,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing:
                      .8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _bidderName() {
    final bidder =
        bid.bidder;

    if (bidder == null) {
      return 'Anonymous bidder';
    }

    if (bidder.maskedName
        .trim()
        .isNotEmpty) {
      return bidder.maskedName.trim();
    }

    if (bidder.alias
        .trim()
        .isNotEmpty) {
      return bidder.alias.trim();
    }

    return 'Anonymous bidder';
  }

  String _date() {
    if (bid.placedAt
        .trim()
        .isEmpty) {
      return '';
    }

    try {
      final date =
          DateTime.parse(
        bid.placedAt,
      ).toLocal();

      final day =
          date.day
              .toString()
              .padLeft(2, '0');

      final month =
          date.month
              .toString()
              .padLeft(2, '0');

      final year =
          date.year;

      final hour =
          date.hour
              .toString()
              .padLeft(2, '0');

      final minute =
          date.minute
              .toString()
              .padLeft(2, '0');

      return '$day/$month/$year • $hour:$minute';
    } catch (_) {
      return bid.placedAt;
    }
  }
}




class _ModernAuctionDetailsSection
    extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _ModernAuctionDetailsSection({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final details = [
      _AuctionDetailItem(
        icon:
            Icons.account_balance_wallet_outlined,
        title: 'Opening bid',
        value:
            '${auction.currency} ${auction.startingPrice}',
      ),

      _AuctionDetailItem(
        icon:
            Icons.trending_up_rounded,
        title: 'Bid increment',
        value:
            '${auction.currency} ${auction.bidIncrement}',
      ),

      _AuctionDetailItem(
        icon:
            Icons.shield_outlined,
        title: 'Reserve',
        value:
            _reserveText(),
      ),

      _AuctionDetailItem(
        icon:
            Icons.schedule_outlined,
        title: 'Payment',
        value:
            '${auction.paymentWindowHours} hrs',
      ),

      _AuctionDetailItem(
        icon:
            Icons.confirmation_number_outlined,
        title: 'Auction no.',
        value:
            auction.number,
      ),

      _AuctionDetailItem(
        icon:
            Icons.category_outlined,
        title: 'Auction type',
        value:
            auction.type,
      ),

      _AuctionDetailItem(
        icon:
            Icons.layers_outlined,
        title: 'Listing',
        value:
            auction.listingLevel,
      ),

      _AuctionDetailItem(
        icon:
            Icons.people_outline_rounded,
        title: 'Bidders',
        value:
            auction.uniqueBidderCount
                .toString(),
      ),

      _AuctionDetailItem(
        icon:
            Icons.visibility_outlined,
        title: 'Views',
        value:
            auction.viewCount
                .toString(),
      ),
    ];

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const _ModernSectionHeader(
          title: 'Auction details',
          icon:
              Icons.tune_rounded,
        ),

        SizedBox(height: 1.42.h),

        Container(
          width: double.infinity,
          padding:
              EdgeInsets.all(2.56.w),
          decoration:
              BoxDecoration(
            color: colors.surface,
            borderRadius:
                BorderRadius.circular(20),
            boxShadow: colors.isDark
                ? null
                : [
                    BoxShadow(
                      color: colors.textPrimary
                          .withValues(alpha: 0.035),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 7),
                    ),
                  ],
          ),
          child:
              LayoutBuilder(
            builder:
                (context, constraints) {
              final columns =
                  constraints.maxWidth >
                          520
                      ? 3
                      : 2;

              return GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    details.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      columns,
                  crossAxisSpacing:
                      1.79.w,
                  mainAxisSpacing:
                      0.83.h,
                  childAspectRatio:
                      columns == 3
                          ? 2.25
                          : 2.15,
                ),
                itemBuilder:
                    (context, index) {
                  return _AuctionDetailTile(
                    item:
                        details[index],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _reserveText() {
    if (!auction.hasReserve) {
      return 'No reserve';
    }

    if (auction.reserveStatus ==
        'MET') {
      return 'Met';
    }

    return 'Not met';
  }
}


class _AuctionDetailItem {
  final IconData icon;
  final String title;
  final String value;

  const _AuctionDetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });
}

class _AuctionDetailTile
    extends StatelessWidget {
  final _AuctionDetailItem item;

  const _AuctionDetailTile({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding:
          EdgeInsets.symmetric(
        horizontal: 2.56.w,
        vertical: 1.07.h,
      ),
      decoration:
          BoxDecoration(
        color:
            colors.surfaceAlt,
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 7.69.w,
            height: 7.69.w,
            decoration:
                BoxDecoration(
              color:
                  colors.auctionAccent.withValues(
                alpha: .13,
              ),
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
            ),
            child: Icon(
              item.icon,
              size: 15.sp,
              color:
                  colors.textPrimary,
            ),
          ),

          SizedBox(width: 2.05.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        colors.textMuted,
                    fontSize: 12.5.sp,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                SizedBox(height: 0.36.h),

                Text(
                  item.value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      TextStyle(
                    color:
                        colors.textPrimary,
                    fontSize: 11.5.sp,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ModernSectionHeader
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? trailing;

  const _ModernSectionHeader({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 8.72.w,
          height: 8.72.w,
          decoration:
              BoxDecoration(
            color:
                colors.auctionAccent
                    .withValues(alpha: .14),
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
          child: Icon(
            icon,
            size: 17.sp,
            color:
                colors.textPrimary,
          ),
        ),

        SizedBox(width: 2.56.w),

        Text(
          title,
          style:
              TextStyle(
            color:
                colors.textPrimary,
            fontSize: 17.sp,
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const Spacer(),

        if (trailing != null)
          Text(
            trailing!,
            style:
                TextStyle(
              color:
                  colors.textSecondary,
              fontSize: 12.sp,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
      ],
    );
  }
}


class _ModernChip
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ModernChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding:
          EdgeInsets.symmetric(
        horizontal: 2.31.w,
        vertical: 0.83.h,
      ),
      decoration:
          BoxDecoration(
        color:
            colors.surfaceAlt,
        borderRadius:
            BorderRadius.circular(
          9,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color:
                colors.textSecondary,
          ),

          SizedBox(width: 1.28.w),

          Text(
            text,
            style:
                 TextStyle(
              color:
                  colors.textSecondary,
              fontSize: 11.sp,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _ModernLoadingCard
    extends StatelessWidget {
  const _ModernLoadingCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(
        vertical: 4.15.h,
      ),
      decoration:
          BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 6.67.w,
            height: 6.67.w,
            child:
                const CircularProgressIndicator(
              strokeWidth: 2.2,
            ),
          ),
          SizedBox(height: 1.42.h),
          Text(
            'Loading bid activity...',
            style:
                TextStyle(
              color:
                  colors.textSecondary,
              fontSize: 11.sp,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


class _ModernErrorCard
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ModernErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(5.13.w),
      decoration:
          BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 11.28.w,
            height: 11.28.w,
            decoration:
                BoxDecoration(
              color:
                  colors.error.withValues(
                alpha: .08,
              ),
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              Icons.cloud_off_outlined,
              color: colors.error,
              size: 21.sp,
            ),
          ),

          SizedBox(height: 1.18.h),

          Text(
            'Unable to load bid activity',
            style:
                TextStyle(
              color:
                  colors.textPrimary,
              fontSize: 13.sp,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(height: 0.59.h),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  colors.textSecondary,
              fontSize: 10.sp,
              height: 1.4,
            ),
          ),

          SizedBox(height: 1.42.h),

          TextButton(
            onPressed: onRetry,
            child:
                Text(
              'Try again',
              style:
                  TextStyle(
                color:
                    colors.textPrimary,
                fontSize: 11.sp,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ModernEmptyBidCard
    extends StatelessWidget {
  final int bidCount;

  const _ModernEmptyBidCard({
    required this.bidCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(
        horizontal: 5.13.w,
        vertical: 3.32.h,
      ),
      decoration:
          BoxDecoration(
        color: colors.surface,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.31.w,
            height: 12.31.w,
            decoration:
                BoxDecoration(
              color:
                  colors.surfaceAlt,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              Icons.gavel_outlined,
              color:
                  colors.textSecondary,
            ),
          ),

          SizedBox(height: 1.42.h),

          Text(
            'No bids yet',
            style:
                TextStyle(
              color:
                  colors.textPrimary,
              fontSize: 14.sp,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(height: 0.59.h),

          Text(
            bidCount == 0
                ? 'Be the first to place a bid on this item.'
                : 'Bidding activity is currently unavailable.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  colors.textSecondary,
              fontSize: 10.5.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}


class _ModernTrustCard
    extends StatelessWidget {
  const _ModernTrustCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.all(3.85.w),
      decoration:
          BoxDecoration(
        color:
            colors.statusSuccessSoft,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 9.74.w,
            height: 9.74.w,
            decoration:
                BoxDecoration(
              color: colors.surface,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              Icons
                  .verified_user_outlined,
              color:
                  colors.statusSuccess,
              size: 19.sp,
            ),
          ),

          SizedBox(width: 2.82.w),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure auction experience',
                  style:
                      TextStyle(
                    color:
                        colors.statusSuccess,
                    fontSize: 12.5.sp,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.36.h),
                Text(
                  'Your bids and auction activity are handled securely.',
                  style:
                      TextStyle(
                    color:
                        colors.textSecondary,
                    fontSize: 12.5.sp,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Color color;

    switch (status) {
      case 'LIVE':
        color = colors.statusSuccess;
        break;

      case 'ENDING_SOON':
        color = colors.statusWarning;
        break;

      case 'STARTING_SOON':
        color = colors.statusInfo;
        break;

      case 'CLOSED':
        color = colors.textMuted;
        break;

      default:
        color = colors.textMuted;
    }

    return Container(
      padding:
          EdgeInsets.symmetric(
        horizontal: 2.56.w,
        vertical: 0.71.h,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withValues(alpha: 0.10),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 1.54.w,
            height: 1.54.w,
            decoration:
                BoxDecoration(
              color: color,
              shape:
                  BoxShape.circle,
            ),
          ),

          SizedBox(width: 1.54.w),

          Text(
            status.replaceAll(
              '_',
              ' ',
            ),
            style:
                TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


class _ErrorView
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding:
            EdgeInsets.all(6.15.w),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 17.95.w,
              height: 17.95.w,
              decoration:
                  BoxDecoration(
                color: colors.error
                    .withValues(alpha: 0.08),
                shape:
                    BoxShape.circle,
              ),
              child:
                  Icon(
                Icons.error_outline,
                size: 38.sp,
                color: colors.error,
              ),
            ),

            SizedBox(height: 2.13.h),

            Text(
              'Unable to load auction',
              style:
                  TextStyle(
                fontSize: 18.sp,
                fontWeight:
                    FontWeight.w700,
                color:
                    colors.textPrimary,
              ),
            ),

            SizedBox(height: 0.95.h),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    colors.textSecondary,
                height: 1.4,
              ),
            ),

            SizedBox(height: 2.37.h),

            ElevatedButton(
              onPressed: onRetry,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    colors.auctionAccent,
                foregroundColor:
                    colors.onAuctionAccent,
                elevation: 0,
                padding:
                    EdgeInsets
                        .symmetric(
                  horizontal: 6.41.w,
                  vertical: 1.54.h,
                ),
              ),
              child:
                  const Text(
                'Retry',
                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}