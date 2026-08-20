import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auction_cubit.dart';
import '../cubit/auction_state.dart';
import '../../domain/entities/my_bids_entity.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionCubit>().getMyBids(
            take: 20,
            skip: 0,
          );
    });
  }

  Future<void> _refresh() async {
    await context.read<AuctionCubit>().getMyBids(
          take: 20,
          skip: 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
        //   onPressed: () {
        //     // Navigator.of(context).pop();
        //     log('Back button pressed',stackTrace: StackTrace.fromString("Satyam"),name: "MyBidsScreen");
        //   },
        // ),
        title: const Text(
          'My Bids',
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(
          color: Color(0xFF101828),
        ),
      ),
      body: BlocBuilder<AuctionCubit, AuctionState>(
        builder: (context, state) {
          if (state is MyBidsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE4B94F),
              ),
            );
          }

          if (state is MyBidsError) {
            return _buildError(state.message);
          }

          if (state is MyBidsLoaded) {
            return RefreshIndicator(
              color: const Color(0xFFE4B94F),
              onRefresh: _refresh,
              child: _buildContent(state.myBids),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(MyBidsEntity myBids) {
    final filteredItems = _filterItems(myBids.items);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        _buildHeader(),
        const SizedBox(height: 4),

        const Text(
          'Every auction you have bid on, and where you stand in each.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF667085),
          ),
        ),

        const SizedBox(height: 22),

        // ========================================================
        // SUMMARY
        // ========================================================

        _buildSummary(myBids.summary),

        const SizedBox(height: 24),

        // ========================================================
        // FILTERS
        // ========================================================

        _buildFilters(),

        const SizedBox(height: 18),

        // ========================================================
        // LIST
        // ========================================================

        if (filteredItems.isEmpty)
          _buildEmptyFilter()
        else
          _buildBidList(filteredItems),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return const Text(
      'My bids',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Color(0xFF10264D),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(MyBidsSummaryEntity summary) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Leading',
                  value: summary.leading,
                  valueColor: const Color(0xFF16803C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Outbid',
                  value: summary.outbid,
                  valueColor: const Color(0xFFB76E00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Won',
                  value: summary.won,
                  valueColor: const Color(0xFF10264D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Payment due',
                  value: summary.paymentDue,
                  valueColor: const Color(0xFFB4232F),
                ),
              ),
            ],
          );
        }

        return SizedBox(
          height: 105,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 155,
                child: _SummaryCard(
                  title: 'Leading',
                  value: summary.leading,
                  valueColor: const Color(0xFF16803C),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 155,
                child: _SummaryCard(
                  title: 'Outbid',
                  value: summary.outbid,
                  valueColor: const Color(0xFFB76E00),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 155,
                child: _SummaryCard(
                  title: 'Won',
                  value: summary.won,
                  valueColor: const Color(0xFF10264D),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 155,
                child: _SummaryCard(
                  title: 'Payment due',
                  value: summary.paymentDue,
                  valueColor: const Color(0xFFB4232F),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    const filters = [
      'All',
      'Active',
      'Payment due',
      'Won',
      'Not won',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 9),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF061D43)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF0074FF)
                        : const Color(0xFFD0D5DD),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF667085),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // FILTER LOGIC
  // ============================================================

  List<MyBidItemEntity> _filterItems(
    List<MyBidItemEntity> items,
  ) {
    switch (_selectedFilter) {
      case 'Active':
        return items.where(_isActive).toList();

      case 'Payment due':
        return items.where(_isPaymentDue).toList();

      case 'Won':
        return items.where(_isWon).toList();

      case 'Not won':
        return items.where((item) {
          return !_isWon(item);
        }).toList();

      case 'All':
      default:
        return items;
    }
  }

  bool _isPaymentDue(MyBidItemEntity item) {
    if (item.allotment == null) {
      return item.myStatus.toLowerCase().contains('payment');
    }

    final status = item.allotment!.status.toLowerCase();

    return status.contains('payment') ||
        status.contains('due') ||
        item.allotment!.isOverdue;
  }

  // bool _isWon(MyBidItemEntity item) {
  //   final myStatus = item.myStatus.toLowerCase();
  //   final allotmentStatus =
  //       item.allotment?.status.toLowerCase() ?? '';

  //   return myStatus.contains('won') ||
  //       myStatus.contains('winner') ||
  //       allotmentStatus.contains('won') ||
  //       allotmentStatus.contains('winner');
  // }

bool _isWon(MyBidItemEntity item) {
  final myStatus = item.myStatus.trim().toLowerCase();
  final auctionStatus = item.status.trim().toLowerCase();
  final allotmentStatus =
      item.allotment?.status.trim().toLowerCase() ?? '';

  // Explicit winning statuses
  final hasWonStatus =
      myStatus == 'won' ||
      myStatus == 'winner' ||
      myStatus == 'winning' ||
      myStatus.contains('won') ||
      myStatus.contains('winner');

  final hasWonAllotment =
      allotmentStatus == 'won' ||
      allotmentStatus == 'winner' ||
      allotmentStatus == 'winning' ||
      allotmentStatus.contains('won') ||
      allotmentStatus.contains('winner');

  // A completed/closed auction with an allotment assigned
  // to the user means the user won the auction.
  final hasAllotment = item.allotment != null;

  final auctionEnded =
      auctionStatus == 'ended' ||
      auctionStatus == 'completed' ||
      auctionStatus == 'closed' ||
      auctionStatus == 'sold' ||
      auctionStatus.contains('ended') ||
      auctionStatus.contains('completed');

  return hasWonStatus ||
      hasWonAllotment ||
      (hasAllotment && auctionEnded);
}
  bool _isActive(MyBidItemEntity item) {
    final status = item.status.toLowerCase();

    return status.contains('active') ||
        status.contains('running') ||
        status.contains('live');
  }

  // ============================================================
  // BID LIST
  // ============================================================

  Widget _buildBidList(List<MyBidItemEntity> items) {
    return Column(
      children: [
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: _MyBidRow(
              bid: item,
              onPayNow: _isPaymentDue(item)
                  ? () => _payNow(item)
                  : null,
              onDetails: () => _showDetails(item),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select a row for the full bidding history, who won, and any payment owed.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF667085),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAY NOW
  // ============================================================

  void _payNow(MyBidItemEntity item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment for ${item.title}',
        ),
      ),
    );

    // TODO:
    // Navigate to your payment screen here.
  }

  // ============================================================
  // DETAILS
  // ============================================================

  void _showDetails(MyBidItemEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BidDetailsSheet(
          bid: item,
        );
      },
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD9DEE8),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.gavel_outlined,
            size: 50,
            color: Color(0xFF98A2B3),
          ),
          const SizedBox(height: 14),
          Text(
            _selectedFilter == 'All'
                ? 'No bids yet'
                : 'No $_selectedFilter bids',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your bids will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(String message) {
    return RefreshIndicator(
      color: const Color(0xFFE4B94F),
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          const Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: Color(0xFFD92D20),
          ),
          const SizedBox(height: 18),
          const Text(
            'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4B94F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final Color valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD9DEE8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF667085),
            ),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BID ROW
// ============================================================

class _MyBidRow extends StatelessWidget {
  final MyBidItemEntity bid;
  final VoidCallback? onPayNow;
  final VoidCallback onDetails;

  const _MyBidRow({
    required this.bid,
    required this.onPayNow,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final currency = bid.currency.isEmpty ? 'US\$' : bid.currency;

    final highest = bid.myHighestBid;
    final current = bid.finalBid ?? bid.currentBid;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onDetails,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 17,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD9DEE8),
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return _buildMobileRow(
                  currency,
                  highest,
                  current,
                );
              }

              return _buildDesktopRow(
                currency,
                highest,
                current,
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopRow(
    String currency,
    String? highest,
    String? current,
  ) {
    return Row(
      children: [
        // LOT
        Expanded(
          flex: 4,
          child: _buildLot(),
        ),

        // STANDING
        Expanded(
          flex: 2,
          child: _StandingBadge(
            status: bid.myStatus,
          ),
        ),

        // HIGHEST
        Expanded(
          flex: 2,
          child: _MoneyText(
            value: highest,
            currency: currency,
          ),
        ),

        // CURRENT / SOLD
        Expanded(
          flex: 2,
          child: _MoneyText(
            value: current,
            currency: currency,
          ),
        ),

        // BIDS
        SizedBox(
          width: 60,
          child: Text(
            bid.myBidCount.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
        ),

        // ACTION
        SizedBox(
          width: 105,
          child: Align(
            alignment: Alignment.centerRight,
            child: onPayNow != null
                ? _PayButton(
                    onPressed: onPayNow!,
                  )
                : _DetailsButton(
                    onPressed: onDetails,
                  ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileRow(
    String currency,
    String? highest,
    String? current,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLot(),
            ),
            const SizedBox(width: 12),
            _StandingBadge(
              status: bid.myStatus,
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          height: 1,
          color: const Color(0xFFF0F1F4),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _InfoColumn(
                title: 'Your highest',
                value: _formatMoney(
                  currency,
                  highest,
                ),
              ),
            ),
            Expanded(
              child: _InfoColumn(
                title: 'Current / sold',
                value: _formatMoney(
                  currency,
                  current,
                ),
              ),
            ),
            Expanded(
              child: _InfoColumn(
                title: 'Bids',
                value: bid.myBidCount.toString(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: onPayNow != null
              ? _PayButton(
                  onPressed: onPayNow!,
                  expanded: true,
                )
              : _DetailsButton(
                  onPressed: onDetails,
                  expanded: true,
                ),
        ),
      ],
    );
  }

  // ============================================================
  // LOT
  // ============================================================

  Widget _buildLot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bid.title.isEmpty ? 'Auction' : bid.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF10264D),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          bid.number.isEmpty
              ? bid.uuid
              : bid.number,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF667085),
          ),
        ),
      ],
    );
  }

  String _formatMoney(
    String currency,
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return '-';
    }

    return '$currency$value';
  }
}

// ============================================================
// MONEY
// ============================================================

class _MoneyText extends StatelessWidget {
  final String? value;
  final String currency;

  const _MoneyText({
    required this.value,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value == null || value!.isEmpty
          ? '-'
          : '$currency$value',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF101828),
      ),
    );
  }
}

// ============================================================
// INFO COLUMN
// ============================================================

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _InfoColumn({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF101828),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STANDING BADGE
// ============================================================

class _StandingBadge extends StatelessWidget {
  final String status;

  const _StandingBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();

    final isLeading =
        normalized.contains('lead') ||
        normalized.contains('highest');

    final isWon =
        normalized.contains('won') ||
        normalized.contains('winner');

    final isPayment =
        normalized.contains('payment') ||
        normalized.contains('due');

    final isLost =
        normalized.contains('lost') ||
        normalized.contains('outbid') ||
        normalized.contains('lose');

    String text;
    Color background;
    Color foreground;

    if (isPayment) {
      text = 'Payment due';
      background = const Color(0xFFFFF2DF);
      foreground = const Color(0xFF9A5B00);
    } else if (isWon) {
      text = 'Won';
      background = const Color(0xFFE8F7EE);
      foreground = const Color(0xFF16803C);
    } else if (isLeading) {
      text = 'You lead';
      background = const Color(0xFFE7F6ED);
      foreground = const Color(0xFF16803C);
    } else if (isLost) {
      text = 'Outbid';
      background = const Color(0xFFFDECEC);
      foreground = const Color(0xFFD92D20);
    } else {
      text = _prettyStatus(status);
      background = const Color(0xFFF2F4F7);
      foreground = const Color(0xFF475467);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  String _prettyStatus(String value) {
    if (value.isEmpty) {
      return 'Placed';
    }

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

// ============================================================
// PAY BUTTON
// ============================================================

class _PayButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool expanded;

  const _PayButton({
    required this.onPressed,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF061D43),
          foregroundColor: const Color(0xFFE4B94F),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: const Text(
          'Pay now',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DETAILS BUTTON
// ============================================================

class _DetailsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool expanded;

  const _DetailsButton({
    required this.onPressed,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF2F4F7),
          foregroundColor: const Color(0xFF344054),
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: const Text(
          'Details',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DETAILS SHEET
// ============================================================

class _BidDetailsSheet extends StatelessWidget {
  final MyBidItemEntity bid;

  const _BidDetailsSheet({
    required this.bid,
  });

  @override
  Widget build(BuildContext context) {
    final currency =
        bid.currency.isEmpty ? 'US\$' : bid.currency;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        30,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                bid.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10264D),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                bid.number,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
              ),

              const SizedBox(height: 22),

              _DetailItem(
                title: 'Standing',
                value: bid.myStatus,
              ),

              _DetailItem(
                title: 'Your highest bid',
                value: bid.myHighestBid == null
                    ? '-'
                    : '$currency${bid.myHighestBid}',
              ),

              _DetailItem(
                title: 'Current bid',
                value: bid.currentBid == null
                    ? '-'
                    : '$currency${bid.currentBid}',
              ),

              _DetailItem(
                title: 'Final bid',
                value: bid.finalBid == null
                    ? '-'
                    : '$currency${bid.finalBid}',
              ),

              _DetailItem(
                title: 'Minimum next bid',
                value:
                    '$currency${bid.minimumNextBid}',
              ),

              _DetailItem(
                title: 'Bid increment',
                value:
                    '$currency${bid.bidIncrement}',
              ),

              _DetailItem(
                title: 'Your bid count',
                value: bid.myBidCount.toString(),
              ),

              _DetailItem(
                title: 'Total auction bids',
                value: bid.bidCount.toString(),
              ),

              _DetailItem(
                title: 'Start',
                value: _formatDate(bid.startAt),
              ),

              _DetailItem(
                title: 'End',
                value: _formatDate(bid.endAt),
              ),

              if (bid.vendor != null)
                _DetailItem(
                  title: 'Vendor',
                  value: bid.vendor!.shopName,
                ),

              if (bid.category != null)
                _DetailItem(
                  title: 'Category',
                  value: bid.category!.name,
                ),

              if (bid.allotment != null) ...[
                const SizedBox(height: 8),

                const Text(
                  'Allotment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10264D),
                  ),
                ),

                const SizedBox(height: 10),

                _DetailItem(
                  title: 'Status',
                  value: bid.allotment!.status,
                ),

                _DetailItem(
                  title: 'Amount',
                  value:
                      '$currency${bid.allotment!.amount}',
                ),

                _DetailItem(
                  title: 'Rank',
                  value:
                      bid.allotment!.rank.toString(),
                ),

                _DetailItem(
                  title: 'Payment due',
                  value:
                      _formatDate(
                        bid.allotment!.paymentDueAt,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String value) {
    if (value.isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }
}

// ============================================================
// DETAIL ITEM
// ============================================================

class _DetailItem extends StatelessWidget {
  final String title;
  final String value;

  const _DetailItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF667085),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
