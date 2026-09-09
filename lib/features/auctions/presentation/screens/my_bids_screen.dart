import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(
        title: 'My Bids',
        centerTitle: true,
      ),
      body: BlocBuilder<AuctionCubit, AuctionState>(
        builder: (context, state) {
          if (state is MyBidsLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: colors.auctionAccent,
              ),
            );
          }

          if (state is MyBidsError) {
            return _buildError(state.message);
          }

          if (state is MyBidsLoaded) {
            return RefreshIndicator(
              color: colors.auctionAccent,
              onRefresh: _refresh,
              child: _buildContent(state.myBids),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }


  Widget _buildContent(MyBidsEntity myBids) {
    final colors = context.colors;
    final filteredItems = _filterItems(myBids.items);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 3.8.h),
      children: [
        _buildHeader(),
        SizedBox(height: 0.5.h),

        Text(
          'Every auction you have bid on, and where you stand in each.',
          style: TextStyle(
            fontSize: 14.sp,
            color: colors.textSecondary,
          ),
        ),

        SizedBox(height: 2.75.h),


        _buildSummary(myBids.summary),

        SizedBox(height: 3.h),


        _buildFilters(),

        SizedBox(height: 2.25.h),


        if (filteredItems.isEmpty)
          _buildEmptyFilter()
        else
          _buildBidList(filteredItems),
      ],
    );
  }


  Widget _buildHeader() {
    final colors = context.colors;

    return Text(
      'My bids',
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: colors.textPrimary,
      ),
    );
  }


  Widget _buildSummary(MyBidsSummaryEntity summary) {
    final colors = context.colors;

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
                  valueColor: colors.statusSuccess,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _SummaryCard(
                  title: 'Outbid',
                  value: summary.outbid,
                  valueColor: colors.statusWarning,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _SummaryCard(
                  title: 'Won',
                  value: summary.won,
                  valueColor: colors.textPrimary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _SummaryCard(
                  title: 'Payment due',
                  value: summary.paymentDue,
                  valueColor: colors.error,
                ),
              ),
            ],
          );
        }

        return SizedBox(
          height: 13.1.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                width: 38.8.w,
                child: _SummaryCard(
                  title: 'Leading',
                  value: summary.leading,
                  valueColor: colors.statusSuccess,
                ),
              ),
              SizedBox(width: 3.w),
              SizedBox(
                width: 38.8.w,
                child: _SummaryCard(
                  title: 'Outbid',
                  value: summary.outbid,
                  valueColor: colors.statusWarning,
                ),
              ),
              SizedBox(width: 3.w),
              SizedBox(
                width: 38.8.w,
                child: _SummaryCard(
                  title: 'Won',
                  value: summary.won,
                  valueColor: colors.textPrimary,
                ),
              ),
              SizedBox(width: 3.w),
              SizedBox(
                width: 38.8.w,
                child: _SummaryCard(
                  title: 'Payment due',
                  value: summary.paymentDue,
                  valueColor: colors.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildFilters() {
    final colors = context.colors;

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
            padding: EdgeInsets.only(right: 2.25.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: 4.3.w,
                  vertical: 1.25.h,
                ),
                decoration: BoxDecoration(
                  color: selected ? colors.brand : colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? colors.brand : colors.border,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: selected ? colors.onBrand : colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }



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



  Widget _buildBidList(List<MyBidItemEntity> items) {
    final colors = context.colors;

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
        SizedBox(height: 1.h),
        Text(
          'Select a row for the full bidding history, who won, and any payment owed.',
          style: TextStyle(
            fontSize: 12.sp,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }



  void _payNow(MyBidItemEntity item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment for ${item.title}',
        ),
      ),
    );


  }


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


  Widget _buildEmptyFilter() {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5.w,
        vertical: 6.9.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.gavel_outlined,
            size: 50.sp,
            color: colors.textMuted,
          ),
          SizedBox(height: 1.75.h),
          Text(
            _selectedFilter == 'All'
                ? 'No bids yet'
                : 'No $_selectedFilter bids',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 0.75.h),
          Text(
            'Your bids will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildError(String message) {
    final colors = context.colors;

    return RefreshIndicator(
      color: colors.auctionAccent,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          Icon(
            Icons.error_outline_rounded,
            size: 60.sp,
            color: colors.error,
          ),
          SizedBox(height: 2.25.h),
          Text(
            'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 2.5.h),
          Center(
            child: ElevatedButton(
              onPressed: _refresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.auctionAccent,
                foregroundColor: colors.onAuctionAccent,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 7.w,
                  vertical: 1.6.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14.sp,
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
    final colors = context.colors;

    return Container(
      height: 13.1.h,
      padding: EdgeInsets.fromLTRB(4.w, 1.9.h, 4.w, 1.5.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}



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
    final colors = context.colors;
    final currency = bid.currency.isEmpty ? 'US\$' : bid.currency;

    final highest = bid.myHighestBid;
    final current = bid.finalBid ?? bid.currentBid;

    return Material(
      color: colors.surface,
      child: InkWell(
        onTap: onDetails,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 5.w,
            vertical: 2.1.h,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colors.border,
              ),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return _buildMobileRow(
                  context,
                  currency,
                  highest,
                  current,
                );
              }

              return _buildDesktopRow(
                context,
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



  Widget _buildDesktopRow(
    BuildContext context,
    String currency,
    String? highest,
    String? current,
  ) {
    final colors = context.colors;

    return Row(
      children: [
        // LOT
        Expanded(
          flex: 4,
          child: _buildLot(context),
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
          width: 15.w,
          child: Text(
            bid.myBidCount.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: colors.textSecondary,
            ),
          ),
        ),

        // ACTION
        SizedBox(
          width: 26.3.w,
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



  Widget _buildMobileRow(
    BuildContext context,
    String currency,
    String? highest,
    String? current,
  ) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildLot(context),
            ),
            SizedBox(width: 3.w),
            _StandingBadge(
              status: bid.myStatus,
            ),
          ],
        ),

        SizedBox(height: 2.h),

        Container(
          height: 1,
          color: colors.border,
        ),

        SizedBox(height: 1.75.h),

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

        SizedBox(height: 1.75.h),

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



  Widget _buildLot(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bid.title.isEmpty ? 'Auction' : bid.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: 0.75.h),
        Text(
          bid.number.isEmpty
              ? bid.uuid
              : bid.number,
          style: TextStyle(
            fontSize: 11.sp,
            color: colors.textSecondary,
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



class _MoneyText extends StatelessWidget {
  final String? value;
  final String currency;

  const _MoneyText({
    required this.value,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Text(
      value == null || value!.isEmpty
          ? '-'
          : '$currency$value',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }
}



class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _InfoColumn({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: 0.6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}


class _StandingBadge extends StatelessWidget {
  final String status;

  const _StandingBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
      background = colors.statusWarningSoft;
      foreground = colors.statusWarning;
    } else if (isWon) {
      text = 'Won';
      background = colors.statusSuccessSoft;
      foreground = colors.statusSuccess;
    } else if (isLeading) {
      text = 'You lead';
      background = colors.statusSuccessSoft;
      foreground = colors.statusSuccess;
    } else if (isLost) {
      text = 'Outbid';
      background = colors.error.withValues(alpha: 0.1);
      foreground = colors.error;
    } else {
      text = _prettyStatus(status);
      background = colors.surfaceAlt;
      foreground = colors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2.5.w,
        vertical: 0.75.h,
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
          fontSize: 11.sp,
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


class _PayButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool expanded;

  const _PayButton({
    required this.onPressed,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.auctionHeroBackground,
          foregroundColor: colors.auctionAccent,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 3.8.w,
            vertical: 1.25.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: Text(
          'Pay now',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}



class _DetailsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool expanded;

  const _DetailsButton({
    required this.onPressed,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: expanded ? double.infinity : null,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: colors.surfaceAlt,
          foregroundColor: colors.textSecondary,
          padding: EdgeInsets.symmetric(
            horizontal: 3.8.w,
            vertical: 1.25.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
        child: Text(
          'Details',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}



class _BidDetailsSheet extends StatelessWidget {
  final MyBidItemEntity bid;

  const _BidDetailsSheet({
    required this.bid,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency =
        bid.currency.isEmpty ? 'US\$' : bid.currency;

    return Container(
      padding: EdgeInsets.fromLTRB(
        5.w,
        1.75.h,
        5.w,
        3.75.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
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
                    color: colors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              SizedBox(height: 2.75.h),

              Text(
                bid.title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),

              SizedBox(height: 0.6.h),

              Text(
                bid.number,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colors.textSecondary,
                ),
              ),

              SizedBox(height: 2.75.h),

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
                SizedBox(height: 1.h),

                Text(
                  'Allotment',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),

                SizedBox(height: 1.25.h),

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


class _DetailItem extends StatelessWidget {
  final String title;
  final String value;

  const _DetailItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 3.8.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
