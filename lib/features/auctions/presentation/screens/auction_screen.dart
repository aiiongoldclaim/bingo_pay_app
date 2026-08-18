import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bingo_pay/features/auctions/domain/entities/auction_entity.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_cubit.dart';
import 'package:bingo_pay/features/auctions/presentation/cubit/auction_state.dart';

class AuctionScreen extends StatefulWidget {
  const AuctionScreen({super.key});

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionCubit>().getAuctions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Auctions',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: BlocBuilder<AuctionCubit, AuctionState>(
        builder: (context, state) {
          if (state is AuctionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AuctionError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                context.read<AuctionCubit>().getAuctions();
              },
            );
          }

          if (state is AuctionLoaded) {
            return RefreshIndicator(
              onRefresh: () {
                return context.read<AuctionCubit>().getAuctions();
              },
              child: _AuctionContent(
                liveAuctions: state.liveAuctions,
                endingSoonAuctions: state.endingSoonAuctions,
                upcomingAuctions: state.upcomingAuctions,
              ),
            );
          }

          return const Center(
            child: Text('No auctions loaded'),
          );
        },
      ),
    );
  }
}

// ============================================================
// MAIN CONTENT
// ============================================================

class _AuctionContent extends StatelessWidget {
  final List<AuctionEntity> liveAuctions;
  final List<AuctionEntity> endingSoonAuctions;
  final List<AuctionEntity> upcomingAuctions;

  const _AuctionContent({
    required this.liveAuctions,
    required this.endingSoonAuctions,
    required this.upcomingAuctions,
  });

  @override
  Widget build(BuildContext context) {
    final heroAuction = _getHeroAuction();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        // ======================================================
        // HERO AUCTION
        // ======================================================

        if (heroAuction != null)
          _HeroAuctionCard(
            auction: heroAuction,
          ),

        const SizedBox(height: 28),

        // ======================================================
        // LIVE
        // ======================================================

        if (liveAuctions.isNotEmpty)
          _AuctionSection(
            title: 'Live',
            subtitle: 'Bidding open now',
            auctions: liveAuctions,
          ),

        // ======================================================
        // ENDING SOON
        // ======================================================

        if (endingSoonAuctions.isNotEmpty)
          _AuctionSection(
            title: 'Ending Soon',
            subtitle: 'Don\'t miss these auctions',
            auctions: endingSoonAuctions,
          ),

        // ======================================================
        // UPCOMING
        // ======================================================

        if (upcomingAuctions.isNotEmpty)
          _AuctionSection(
            title: 'Upcoming',
            subtitle: 'Get ready to bid',
            auctions: upcomingAuctions,
          ),

        if (liveAuctions.isEmpty &&
            endingSoonAuctions.isEmpty &&
            upcomingAuctions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No auctions available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
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

    sorted.sort(
      (a, b) {
        final aTime = a.secondsRemaining ?? 999999999;
        final bTime = b.secondsRemaining ?? 999999999;

        return aTime.compareTo(bTime);
      },
    );

    return sorted.first;
  }
}

// ============================================================
// HERO AUCTION
// ============================================================

class _HeroAuctionCard extends StatelessWidget {
  final AuctionEntity auction;

  const _HeroAuctionCard({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        auction.images != null && auction.images!.isNotEmpty
            ? auction.images!.first
            : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1324),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 650;

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  child: _HeroInformation(
                    auction: auction,
                  ),
                ),
                Expanded(
                  child: _HeroImage(
                    imageUrl: imageUrl,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _HeroImage(
                imageUrl: imageUrl,
              ),
              _HeroInformation(
                auction: auction,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// HERO IMAGE
// ============================================================

class _HeroImage extends StatelessWidget {
  final String? imageUrl;

  const _HeroImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _imagePlaceholder();
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
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              },
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_outlined,
        size: 60,
        color: Colors.grey,
      ),
    );
  }
}

// ============================================================
// HERO INFORMATION
// ============================================================

class _HeroInformation extends StatelessWidget {
  final AuctionEntity auction;

  const _HeroInformation({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LIVE BADGE

          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE4B94F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BIDDING OPEN NOW',
                style: TextStyle(
                  color: Color(0xFFE4B94F),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // TITLE

          Text(
            auction.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 22),

          Container(
            width: 70,
            height: 1,
            color: const Color(0xFFE4B94F),
          ),

          const SizedBox(height: 22),

          // BID + TIMER

          Wrap(
            spacing: 30,
            runSpacing: 18,
            children: [
              _HeroBidInfo(
                auction: auction,
              ),
              _HeroCountdown(
                secondsRemaining:
                    auction.secondsRemaining ?? 0,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // BUTTON

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to auction details
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFE4B94F),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PLACE A BID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HERO BID
// ============================================================

class _HeroBidInfo extends StatelessWidget {
  final AuctionEntity auction;

  const _HeroBidInfo({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final price =
        auction.currentBid ?? auction.startingPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CURRENT BID',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹$price',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${auction.bidCount} ${auction.bidCount == 1 ? 'bid' : 'bids'} placed',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HERO COUNTDOWN
// ============================================================

class _HeroCountdown extends StatefulWidget {
  final int secondsRemaining;

  const _HeroCountdown({
    required this.secondsRemaining,
  });

  @override
  State<_HeroCountdown> createState() =>
      _HeroCountdownState();
}

class _HeroCountdownState extends State<_HeroCountdown> {
  Timer? _timer;

  late int _remaining;

  @override
  void initState() {
    super.initState();

    _remaining = widget.secondsRemaining;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (_remaining <= 0) {
          _timer?.cancel();
          return;
        }

        if (mounted) {
          setState(() {
            _remaining--;
          });
        }
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

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CLOSES IN',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _TimeValue(
              value: days,
              label: 'DAY',
            ),
            const _Colon(),
            _TimeValue(
              value: hours,
              label: 'HRS',
            ),
            const _Colon(),
            _TimeValue(
              value: minutes,
              label: 'MIN',
            ),
            const _Colon(),
            _TimeValue(
              value: seconds,
              label: 'SEC',
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeValue extends StatelessWidget {
  final int value;
  final String label;

  const _TimeValue({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _Colon extends StatelessWidget {
  const _Colon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
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

// ============================================================
// AUCTION SECTION
// ============================================================

class _AuctionSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AuctionEntity> auctions;

  const _AuctionSection({
    required this.title,
    required this.subtitle,
    required this.auctions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                Text(
                  'View all',
                  style: TextStyle(
                    color: Colors.deepPurple.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 350,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: auctions.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _AuctionProductCard(
                  auction: auctions[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

class _AuctionProductCard extends StatelessWidget {
  final AuctionEntity auction;

  const _AuctionProductCard({
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        auction.images != null &&
                auction.images!.isNotEmpty
            ? auction.images!.first
            : null;

    final price =
        auction.currentBid ?? auction.startingPrice;

    return SizedBox(
      width: 245,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // IMAGE

            SizedBox(
              height: 175,
              width: double.infinity,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) {
                        return _placeholder();
                      },
                    )
                  : _placeholder(),
            ),

            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // STATUS

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _StatusBadge(
                          status: auction.status,
                        ),
                        Text(
                          '${auction.bidCount} bids',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    // TITLE

                    Text(
                      auction.title,
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const Spacer(),

                    // PRICE

                    Text(
                      auction.currentBid != null
                          ? 'Current Bid'
                          : 'Starting Price',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        if (auction.status ==
                            'LIVE')
                          const Icon(
                            Icons.arrow_forward,
                            size: 18,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 45,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
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

      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 52,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}