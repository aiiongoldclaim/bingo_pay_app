

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bingo_pay/features/auctions/domain/entities/auction_detail_entity.dart';
import 'package:bingo_pay/features/auctions/domain/entities/bid_entity.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_state.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF07152D),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Auction Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
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

// ============================================================================
// DETAIL CONTENT
// ============================================================================

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
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================================================================
            // PRODUCT
            // ================================================================

            _ProductSection(
              auction: auction,
            ),

            const SizedBox(height: 24),

            // ================================================================
            // BID PANEL
            // ================================================================

            _BidPanel(
              auction: auction,
            ),

            const SizedBox(height: 28),

            // ================================================================
            // ABOUT
            // ================================================================

            const _SectionTitle(
              title: 'About this lot',
            ),

            const SizedBox(height: 16),

            _AboutCard(
              auction: auction,
            ),

            const SizedBox(height: 32),

            // ================================================================
            // BIDDING HISTORY
            // ================================================================

            const _SectionTitle(
              title: 'Bidding history',
            ),

            const SizedBox(height: 16),

            _BiddingHistorySection(
              auction: auction,
            ),

            const SizedBox(height: 32),

            // ================================================================
            // AUCTION INFORMATION
            // ================================================================

            const _SectionTitle(
              title: 'Auction information',
            ),

            const SizedBox(height: 16),

            _AuctionMetaSection(
              auction: auction,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PRODUCT SECTION
// ============================================================================

class _ProductSection extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _ProductSection({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AuctionImage(
          images: auction.images,
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            _StatusBadge(
              status: auction.status,
            ),

            const SizedBox(width: 10),

            if (auction.badge.isNotEmpty)
              Flexible(
                child: Text(
                  auction.badge,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Color(0xFF697593),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          auction.title,
          style: const TextStyle(
            fontSize: 27,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF07152D),
          ),
        ),

        if (auction.itemName != null &&
            auction.itemName!.trim().isNotEmpty) ...[
          const SizedBox(height: 9),
          Text(
            auction.itemName!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],

        if (auction.vendor != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 17,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  auction.vendor!.shopName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
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

// ============================================================================
// IMAGE CAROUSEL
// ============================================================================

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
    final images = widget.images ?? [];

    if (images.isEmpty) {
      return _placeholder();
    }

    return Column(
      children: [
        Container(
          height: 360,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
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
                  return _placeholder();
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
          const SizedBox(height: 12),
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                  ),
                  height: 6,
                  width: selected ? 22 : 6,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFE4B94F)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      height: 360,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 60,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// ============================================================================
// BID PANEL
// ============================================================================

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
      // Update the amount after the minimum next bid changes,
      // but don't overwrite a value the user is currently editing.
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

        // --------------------------------------------------------------
        // PLACE BID ERROR
        // --------------------------------------------------------------

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
                backgroundColor: Colors.red.shade700,
              ),
            );
        }

        // --------------------------------------------------------------
        // PLACE BID SUCCESS
        // --------------------------------------------------------------

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

          // Keep the input synchronized with the
          // new minimum next bid returned by the API.
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
        final isPlacingBid =
            state is AuctionDetailLoaded
                ? state.isPlacingBid
                : false;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF07152D),
            borderRadius:
                BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF07152D)
                    .withOpacity(0.16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'CURRENT BID',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                '${auction.currency} $currentBid',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${auction.bidCount} '
                '${auction.bidCount == 1 ? 'bid' : 'bids'} placed',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),

              // ================================================================
              // TIMER
              // ================================================================

              if (isLive &&
                  auction.secondsRemaining != null) ...[
                const SizedBox(height: 24),
                _Countdown(
                  secondsRemaining:
                      auction.secondsRemaining!,
                ),
              ],

              const SizedBox(height: 24),

              // ================================================================
              // NEXT BID
              // ================================================================

              Text(
                'NEXT VALID BID — '
                '${auction.currency} ${auction.minimumNextBid}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 10),

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

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
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

                      const SizedBox(width: 12),

                      SizedBox(
                        width: 125,
                        height: 52,
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

              const SizedBox(height: 8),

              Text(
                'Minimum bid is '
                '${auction.currency} '
                '${auction.minimumNextBid}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),

              if (!isEligible &&
                  auction.viewer?.ineligibleReason !=
                      null) ...[
                const SizedBox(height: 12),
                Text(
                  auction.viewer!.ineligibleReason!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
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

  // ==========================================================================
  // PLACE BID
  // ==========================================================================

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
              Colors.red.shade700,
        ),
      );
  }
}

// ============================================================================
// NEXT BID INPUT
// ============================================================================

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

class _NextBidBoxState extends State<_NextBidBox> {
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

    // The controller belongs to _BidPanel.
    // Do not dispose it here.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: _hasError
                  ? Colors.redAccent
                      .withOpacity(0.7)
                  : Colors.white24,
            ),
            borderRadius:
                BorderRadius.circular(5),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme:
                  const TextSelectionThemeData(
                selectionColor:
                    Color(0x66E4B94F),
                selectionHandleColor:
                    Color(0xFFE4B94F),
              ),
            ),
            child: TextField(
              controller:
                  widget.controller,
              cursorColor:
                  const Color(0xFFE4B94F),
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}'),
                ),
              ],
              textInputAction:
                  TextInputAction.done,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
              decoration:
                  const InputDecoration(
                filled: true,
                fillColor:
                    Color(0x14000000),
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
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),

        if (_hasError) ...[
          const SizedBox(height: 5),
          Text(
            'Bid must be at least '
            '${widget.currency} '
            '${widget.minimumValue}',
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// BID BUTTON
// ============================================================================

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
    return ElevatedButton(
      onPressed:
          enabled && !isLoading
              ? onPressed
              : null,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            const Color(0xFFE4B94F),
        foregroundColor: Colors.black,
        disabledBackgroundColor:
            Colors.grey.shade700,
        disabledForegroundColor:
            Colors.white54,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(5),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 19,
              height: 19,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<
                        Color>(
                  Colors.black,
                ),
              ),
            )
          : const Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.gavel,
                  size: 17,
                ),
                SizedBox(width: 7),
                Text(
                  'PLACE BID',
                  style: TextStyle(
                    fontSize: 11,
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

// ============================================================================
// COUNTDOWN
// ============================================================================

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

    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(0.055),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'BIDDING CLOSES IN',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 9,
              letterSpacing: 2,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

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
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          value
              .toString()
              .padLeft(2, '0'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
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
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal: 7,
      ),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 22,
        ),
      ),
    );
  }
}

// ============================================================================
// ABOUT
// ============================================================================

class _AboutCard
    extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _AboutCard({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final description =
        auction.description
                ?.trim() ??
            '';

    final itemName =
        auction.itemName?.trim() ??
            '';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (itemName.isNotEmpty) ...[
            Text(
              itemName,
              style:
                  const TextStyle(
                color:
                    Color(0xFF07152D),
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
                height: 1.4,
              ),
            ),

            if (description.isNotEmpty)
              const SizedBox(
                height: 12,
              ),
          ],

          Text(
            description.isNotEmpty
                ? description
                : 'No description available for this auction.',
            style: TextStyle(
              fontSize: 14,
              height: 1.65,
              color:
                  Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BIDDING HISTORY
// ============================================================================

class _BiddingHistorySection
    extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _BiddingHistorySection({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
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
        // ================================================================
        // LOADING
        // ================================================================

        if (state
                is AuctionDetailLoaded &&
            state.isBidsLoading) {
          return const _BidsLoadingCard();
        }

        // ================================================================
        // ERROR
        // ================================================================

        if (state
                is AuctionDetailLoaded &&
            state.bidsError != null &&
            state.bidsError!.isNotEmpty) {
          return _BidsErrorCard(
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

        // ================================================================
        // BIDS FROM API
        // ================================================================

        if (state
            is AuctionDetailLoaded) {
          final List<BidEntity> bids =
              state.bids;

          if (bids.isEmpty) {
            return _EmptyHistoryCard(
              bidCount:
                  auction.bidCount,
            );
          }

          return Container(
            width: double.infinity,
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
              border: Border.all(
                color:
                    Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.025,
                  ),
                  blurRadius: 12,
                  offset:
                      const Offset(
                    0,
                    4,
                  ),
                ),
              ],
            ),
            child: Column(
              children:
                  List.generate(
                bids.length,
                (index) {
                  final bid =
                      bids[index];

                  return _HistoryItem(
                    bid: bid,
                    currency:
                        auction.currency,
                    isLast: index ==
                        bids.length - 1,
                  );
                },
              ),
            ),
          );
        }

        return const _BidsLoadingCard();
      },
    );
  }
}

// ============================================================================
// BID HISTORY ITEM
// ============================================================================

// ============================================================================
// BID HISTORY ITEM
// ============================================================================

class _HistoryItem extends StatelessWidget {
  final BidEntity bid;
  final String currency;
  final bool isLast;

  const _HistoryItem({
    required this.bid,
    required this.currency,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================================================================
          // AVATAR
          // ================================================================

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE4B94F).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF07152D),
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          // ================================================================
          // BIDDER
          // ================================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _bidderName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF07152D),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _date(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ================================================================
          // AMOUNT
          // ================================================================

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currency ${bid.amount}',
                style: const TextStyle(
                  color: Color(0xFF1F6B45),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              const Text(
                'BID',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // BIDDER NAME
  // ========================================================================

  String _bidderName() {
    final bidder = bid.bidder;

    if (bidder == null) {
      return 'Anonymous bidder';
    }

    if (bidder.maskedName.trim().isNotEmpty) {
      return bidder.maskedName.trim();
    }

    if (bidder.alias.trim().isNotEmpty) {
      return bidder.alias.trim();
    }

    return 'Anonymous bidder';
  }

  // ========================================================================
  // DATE
  // ========================================================================

  String _date() {
    if (bid.placedAt.trim().isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(
        bid.placedAt,
      ).toLocal();

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;

      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');

      return '$day/$month/$year • $hour:$minute';
    } catch (_) {
      // If API returns a date format that DateTime.parse
      // cannot understand, show the original value.
      return bid.placedAt;
    }
  }
}

// ============================================================================
// BIDS LOADING
// ============================================================================

class _BidsLoadingCard
    extends StatelessWidget {
  const _BidsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 35,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child:
                CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          ),

          SizedBox(height: 14),

          Text(
            'Loading bidding history...',
            style: TextStyle(
              color:
                  Color(0xFF697593),
              fontSize: 12,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BIDS ERROR
// ============================================================================

class _BidsErrorCard
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BidsErrorCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.shade100,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration:
                BoxDecoration(
              color: Colors.red
                  .withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Unable to load bidding history',
            style: TextStyle(
              color:
                  Color(0xFF07152D),
              fontSize: 14,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 11,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          OutlinedButton(
            onPressed: onRetry,
            style:
                OutlinedButton.styleFrom(
              foregroundColor:
                  const Color(
                0xFF07152D,
              ),
              side:
                  const BorderSide(
                color:
                    Color(0xFFE4B94F),
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 12,
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

// ============================================================================
// EMPTY HISTORY
// ============================================================================

class _EmptyHistoryCard
    extends StatelessWidget {
  final int bidCount;

  const _EmptyHistoryCard({
    required this.bidCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                const BoxDecoration(
              color:
                  Color(0xFFF3F5F8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.gavel_outlined,
              color:
                  Color(0xFF697593),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'No bidding history',
            style: TextStyle(
              color:
                  Color(0xFF07152D),
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            bidCount == 0
                ? 'Be the first person to place a bid.'
                : 'Bidding history is not available.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Colors.grey.shade600,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AUCTION META
// ============================================================================

class _AuctionMetaSection
    extends StatelessWidget {
  final AuctionDetailEntity auction;

  const _AuctionMetaSection({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            title: 'Opening bid',
            value:
                '${auction.currency} '
                '${auction.startingPrice}',
          ),

          _InfoRow(
            title: 'Current bid',
            value:
                auction.currentBid !=
                        null
                    ? '${auction.currency} '
                        '${auction.currentBid}'
                    : 'No bids',
          ),

          _InfoRow(
            title: 'Bid increment',
            value:
                '${auction.currency} '
                '${auction.bidIncrement}',
          ),

          _InfoRow(
            title: 'Reserve',
            value:
                _reserveText(),
          ),

          _InfoRow(
            title: 'Payment window',
            value:
                '${auction.paymentWindowHours} '
                'hours from close',
          ),

          _InfoRow(
            title: 'Anti-sniping',
            value:
                _antiSnipingText(),
          ),

          _InfoRow(
            title: 'Auction number',
            value:
                auction.number,
          ),

          _InfoRow(
            title: 'Status',
            value:
                auction.status,
          ),

          _InfoRow(
            title: 'Auction type',
            value:
                auction.type,
          ),

          _InfoRow(
            title: 'Listing level',
            value:
                auction.listingLevel,
          ),

          _InfoRow(
            title: 'Bid count',
            value:
                auction.bidCount
                    .toString(),
          ),

          _InfoRow(
            title: 'Unique bidders',
            value:
                auction
                    .uniqueBidderCount
                    .toString(),
          ),

          _InfoRow(
            title: 'Views',
            value:
                auction.viewCount
                    .toString(),
            isLast: true,
          ),
        ],
      ),
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

    return 'Not yet met';
  }

  String _antiSnipingText() {
    final extension =
        auction.extension;

    if (extension == null ||
        extension.enabled != true) {
      return 'Not enabled';
    }

    final windowMinutes =
        extension.windowSeconds ~/
            60;

    final durationMinutes =
        extension.durationSeconds ~/
            60;

    if (windowMinutes <= 0) {
      return 'Enabled';
    }

    return 'Extends '
        '$durationMinutes min if bid '
        'within $windowMinutes min '
        'of close';
  }
}

// ============================================================================
// SECTION TITLE
// ============================================================================

class _SectionTitle
    extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 1,
          color:
              const Color(0xFFE4B94F),
        ),

        const SizedBox(width: 9),

        Container(
          width: 6,
          height: 6,
          decoration:
              const BoxDecoration(
            color:
                Color(0xFFE4B94F),
            shape:
                BoxShape.circle,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Container(
            height: 1,
            color:
                const Color(0xFFE4B94F),
          ),
        ),

        const SizedBox(width: 14),

        Flexible(
          child: Text(
            title,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              color:
                  Color(0xFF07152D),
              fontSize: 22,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INFO ROW
// ============================================================================

class _InfoRow
    extends StatelessWidget {
  final String title;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          const BoxConstraints(
        minHeight: 54,
      ),
      padding:
          const EdgeInsets.symmetric(
        vertical: 14,
      ),
      decoration: isLast
          ? null
          : BoxDecoration(
              border:
                  Border(
                bottom:
                    BorderSide(
                  color:
                      Colors.grey.shade200,
                ),
              ),
            ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color:
                    Colors.grey.shade600,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign:
                  TextAlign.right,
              style:
                  const TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF07152D),
                fontWeight:
                    FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status) {
      case 'LIVE':
        color = Colors.green;
        break;

      case 'ENDING_SOON':
        color = Colors.orange;
        break;

      case 'STARTING_SOON':
        color = Colors.blue;
        break;

      case 'CLOSED':
        color = Colors.grey;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(0.10),
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
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(
              color: color,
              shape:
                  BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            status.replaceAll(
              '_',
              ' ',
            ),
            style:
                TextStyle(
              color: color,
              fontSize: 10,
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

// ============================================================================
// ERROR VIEW
// ============================================================================

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
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration:
                  BoxDecoration(
                color: Colors.red
                    .withOpacity(0.08),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.error_outline,
                size: 38,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load auction',
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
                color:
                    Color(0xFF07152D),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFE4B94F,
                ),
                foregroundColor:
                    Colors.black,
                elevation: 0,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 25,
                  vertical: 13,
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