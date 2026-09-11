// ─────────────────────────────────────────────────────────────────────────
// ORIGINAL — the My Bids screen (CustomAppBar header, plain summary cards,
// count-less filter chips, table-style bid rows with a desktop breakpoint,
// gold-on-navy Pay now button), kept for reference. The redesigned screen
// uses a custom serif header, colored icon summary cards, filter chips with
// live counts, and image-led purple-branded bid cards matching the new
// mockup — see the active MyBidsScreen implementation below.
// ─────────────────────────────────────────────────────────────────────────
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/theme/app_theme_colors.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../cubit/auction_cubit.dart';
// import '../cubit/auction_state.dart';
// import '../../domain/entities/my_bids_entity.dart';
//
// class MyBidsScreen extends StatefulWidget {
//   const MyBidsScreen({super.key});
//
//   @override
//   State<MyBidsScreen> createState() => _MyBidsScreenState();
// }
//
// class _MyBidsScreenState extends State<MyBidsScreen> {
//   String _selectedFilter = 'All';
//
//   @override
//   void initState() {
//     super.initState();
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AuctionCubit>().getMyBids(
//             take: 20,
//             skip: 0,
//           );
//     });
//   }
//
//   Future<void> _refresh() async {
//     await context.read<AuctionCubit>().getMyBids(
//           take: 20,
//           skip: 0,
//         );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Scaffold(
//       backgroundColor: colors.background,
//       appBar: const CustomAppBar(
//         title: 'My Bids',
//         centerTitle: true,
//       ),
//       body: BlocBuilder<AuctionCubit, AuctionState>(
//         builder: (context, state) {
//           if (state is MyBidsLoading) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: colors.auctionAccent,
//               ),
//             );
//           }
//
//           if (state is MyBidsError) {
//             return _buildError(state.message);
//           }
//
//           if (state is MyBidsLoaded) {
//             return RefreshIndicator(
//               color: colors.auctionAccent,
//               onRefresh: _refresh,
//               child: _buildContent(state.myBids),
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//
//   Widget _buildContent(MyBidsEntity myBids) {
//     final colors = context.colors;
//     final filteredItems = _filterItems(myBids.items);
//
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: EdgeInsets.fromLTRB(5.w, 2.5.h, 5.w, 3.8.h),
//       children: [
//         _buildHeader(),
//         SizedBox(height: 0.5.h),
//
//         Text(
//           'Every auction you have bid on, and where you stand in each.',
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: colors.textSecondary,
//           ),
//         ),
//
//         SizedBox(height: 2.75.h),
//
//
//         _buildSummary(myBids.summary),
//
//         SizedBox(height: 3.h),
//
//
//         _buildFilters(),
//
//         SizedBox(height: 2.25.h),
//
//
//         if (filteredItems.isEmpty)
//           _buildEmptyFilter()
//         else
//           _buildBidList(filteredItems),
//       ],
//     );
//   }
//
//
//   Widget _buildHeader() {
//     final colors = context.colors;
//
//     return Text(
//       'My bids',
//       style: TextStyle(
//         fontSize: 28.sp,
//         fontWeight: FontWeight.w800,
//         color: colors.textPrimary,
//       ),
//     );
//   }
//
//
//   Widget _buildSummary(MyBidsSummaryEntity summary) {
//     final colors = context.colors;
//
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isWide = constraints.maxWidth >= 700;
//
//         if (isWide) {
//           return Row(
//             children: [
//               Expanded(
//                 child: _SummaryCard(
//                   title: 'Leading',
//                   value: summary.leading,
//                   valueColor: colors.statusSuccess,
//                 ),
//               ),
//               SizedBox(width: 3.w),
//               Expanded(
//                 child: _SummaryCard(
//                   title: 'Outbid',
//                   value: summary.outbid,
//                   valueColor: colors.statusWarning,
//                 ),
//               ),
//               SizedBox(width: 3.w),
//               Expanded(
//                 child: _SummaryCard(
//                   title: 'Won',
//                   value: summary.won,
//                   valueColor: colors.textPrimary,
//                 ),
//               ),
//               SizedBox(width: 3.w),
//               Expanded(
//                 child: _SummaryCard(
//                   title: 'Payment due',
//                   value: summary.paymentDue,
//                   valueColor: colors.error,
//                 ),
//               ),
//             ],
//           );
//         }
//
//         return SizedBox(
//           height: 13.1.h,
//           child: ListView(
//             scrollDirection: Axis.horizontal,
//             children: [
//               SizedBox(
//                 width: 38.8.w,
//                 child: _SummaryCard(
//                   title: 'Leading',
//                   value: summary.leading,
//                   valueColor: colors.statusSuccess,
//                 ),
//               ),
//               SizedBox(width: 3.w),
//               SizedBox(
//                 width: 38.8.w,
//                 child: _SummaryCard(
//                   title: 'Outbid',
//                   value: summary.outbid,
//                   valueColor: colors.statusWarning,
//                 ),
//               ),
//               SizedBox(width: 3.w),
//               SizedBox(
//                 width: 38.8.w,
//                 child: _SummaryCard(
//                   title: 'Won',
//                   value: summary.won,
//                   valueColor: colors.textPrimary,
//                 ),
//               ),
//               SizedBox(width: 3.w),
//               SizedBox(
//                 width: 38.8.w,
//                 child: _SummaryCard(
//                   title: 'Payment due',
//                   value: summary.paymentDue,
//                   valueColor: colors.error,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
//   Widget _buildFilters() {
//     final colors = context.colors;
//
//     const filters = [
//       'All',
//       'Active',
//       'Payment due',
//       'Won',
//       'Not won',
//     ];
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: filters.map((filter) {
//           final selected = _selectedFilter == filter;
//
//           return Padding(
//             padding: EdgeInsets.only(right: 2.25.w),
//             child: GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedFilter = filter;
//                 });
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 4.3.w,
//                   vertical: 1.25.h,
//                 ),
//                 decoration: BoxDecoration(
//                   color: selected ? colors.brand : colors.surface,
//                   borderRadius: BorderRadius.circular(22),
//                   border: Border.all(
//                     color: selected ? colors.brand : colors.border,
//                   ),
//                 ),
//                 child: Text(
//                   filter,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w700,
//                     color: selected ? colors.onBrand : colors.textSecondary,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//
//
//   List<MyBidItemEntity> _filterItems(
//     List<MyBidItemEntity> items,
//   ) {
//     switch (_selectedFilter) {
//       case 'Active':
//         return items.where(_isActive).toList();
//
//       case 'Payment due':
//         return items.where(_isPaymentDue).toList();
//
//       case 'Won':
//         return items.where(_isWon).toList();
//
//       case 'Not won':
//         return items.where((item) {
//           return !_isWon(item);
//         }).toList();
//
//       case 'All':
//       default:
//         return items;
//     }
//   }
//
//   bool _isPaymentDue(MyBidItemEntity item) {
//     if (item.allotment == null) {
//       return item.myStatus.toLowerCase().contains('payment');
//     }
//
//     final status = item.allotment!.status.toLowerCase();
//
//     return status.contains('payment') ||
//         status.contains('due') ||
//         item.allotment!.isOverdue;
//   }
//
// bool _isWon(MyBidItemEntity item) {
//   final myStatus = item.myStatus.trim().toLowerCase();
//   final auctionStatus = item.status.trim().toLowerCase();
//   final allotmentStatus =
//       item.allotment?.status.trim().toLowerCase() ?? '';
//
//   // Explicit winning statuses
//   final hasWonStatus =
//       myStatus == 'won' ||
//       myStatus == 'winner' ||
//       myStatus == 'winning' ||
//       myStatus.contains('won') ||
//       myStatus.contains('winner');
//
//   final hasWonAllotment =
//       allotmentStatus == 'won' ||
//       allotmentStatus == 'winner' ||
//       allotmentStatus == 'winning' ||
//       allotmentStatus.contains('won') ||
//       allotmentStatus.contains('winner');
//
//   // A completed/closed auction with an allotment assigned
//   // to the user means the user won the auction.
//   final hasAllotment = item.allotment != null;
//
//   final auctionEnded =
//       auctionStatus == 'ended' ||
//       auctionStatus == 'completed' ||
//       auctionStatus == 'closed' ||
//       auctionStatus == 'sold' ||
//       auctionStatus.contains('ended') ||
//       auctionStatus.contains('completed');
//
//   return hasWonStatus ||
//       hasWonAllotment ||
//       (hasAllotment && auctionEnded);
// }
//   bool _isActive(MyBidItemEntity item) {
//     final status = item.status.toLowerCase();
//
//     return status.contains('active') ||
//         status.contains('running') ||
//         status.contains('live');
//   }
//
//
//
//   Widget _buildBidList(List<MyBidItemEntity> items) {
//     final colors = context.colors;
//
//     return Column(
//       children: [
//         ...items.map(
//           (item) => Padding(
//             padding: const EdgeInsets.only(bottom: 1),
//             child: _MyBidRow(
//               bid: item,
//               onPayNow: _isPaymentDue(item)
//                   ? () => _payNow(item)
//                   : null,
//               onDetails: () => _showDetails(item),
//             ),
//           ),
//         ),
//         SizedBox(height: 1.h),
//         Text(
//           'Select a row for the full bidding history, who won, and any payment owed.',
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: colors.textSecondary,
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//   void _payNow(MyBidItemEntity item) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Payment for ${item.title}',
//         ),
//       ),
//     );
//
//
//   }
//
//
//   void _showDetails(MyBidItemEntity item) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return _BidDetailsSheet(
//           bid: item,
//         );
//       },
//     );
//   }
//
//
//   Widget _buildEmptyFilter() {
//     final colors = context.colors;
//
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: 5.w,
//         vertical: 6.9.h,
//       ),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: colors.border,
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.gavel_outlined,
//             size: 50.sp,
//             color: colors.textMuted,
//           ),
//           SizedBox(height: 1.75.h),
//           Text(
//             _selectedFilter == 'All'
//                 ? 'No bids yet'
//                 : 'No $_selectedFilter bids',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w700,
//               color: colors.textPrimary,
//             ),
//           ),
//           SizedBox(height: 0.75.h),
//           Text(
//             'Your bids will appear here.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: colors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   Widget _buildError(String message) {
//     final colors = context.colors;
//
//     return RefreshIndicator(
//       color: colors.auctionAccent,
//       onRefresh: _refresh,
//       child: ListView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.25,
//           ),
//           Icon(
//             Icons.error_outline_rounded,
//             size: 60.sp,
//             color: colors.error,
//           ),
//           SizedBox(height: 2.25.h),
//           Text(
//             'Something went wrong',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w700,
//               color: colors.textPrimary,
//             ),
//           ),
//           SizedBox(height: 1.h),
//           Text(
//             message,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14.sp,
//               height: 1.5,
//               color: colors.textSecondary,
//             ),
//           ),
//           SizedBox(height: 2.5.h),
//           Center(
//             child: ElevatedButton(
//               onPressed: _refresh,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: colors.auctionAccent,
//                 foregroundColor: colors.onAuctionAccent,
//                 elevation: 0,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 7.w,
//                   vertical: 1.6.h,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 'Try Again',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// class _SummaryCard extends StatelessWidget {
//   final String title;
//   final int value;
//   final Color valueColor;
//
//   const _SummaryCard({
//     required this.title,
//     required this.value,
//     required this.valueColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Container(
//       height: 13.1.h,
//       padding: EdgeInsets.fromLTRB(4.w, 1.9.h, 4.w, 1.5.h),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: colors.border,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 13.sp,
//               fontWeight: FontWeight.w500,
//               color: colors.textSecondary,
//             ),
//           ),
//           const Spacer(),
//           Text(
//             value.toString(),
//             style: TextStyle(
//               fontSize: 25.sp,
//               fontWeight: FontWeight.w800,
//               color: valueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// class _MyBidRow extends StatelessWidget {
//   final MyBidItemEntity bid;
//   final VoidCallback? onPayNow;
//   final VoidCallback onDetails;
//
//   const _MyBidRow({
//     required this.bid,
//     required this.onPayNow,
//     required this.onDetails,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final currency = bid.currency.isEmpty ? 'US\$' : bid.currency;
//
//     final highest = bid.myHighestBid;
//     final current = bid.finalBid ?? bid.currentBid;
//
//     return Material(
//       color: colors.surface,
//       child: InkWell(
//         onTap: onDetails,
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: 5.w,
//             vertical: 2.1.h,
//           ),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: colors.border,
//               ),
//             ),
//           ),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               if (constraints.maxWidth < 760) {
//                 return _buildMobileRow(
//                   context,
//                   currency,
//                   highest,
//                   current,
//                 );
//               }
//
//               return _buildDesktopRow(
//                 context,
//                 currency,
//                 highest,
//                 current,
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _buildDesktopRow(
//     BuildContext context,
//     String currency,
//     String? highest,
//     String? current,
//   ) {
//     final colors = context.colors;
//
//     return Row(
//       children: [
//         // LOT
//         Expanded(
//           flex: 4,
//           child: _buildLot(context),
//         ),
//
//         // STANDING
//         Expanded(
//           flex: 2,
//           child: _StandingBadge(
//             status: bid.myStatus,
//           ),
//         ),
//
//         // HIGHEST
//         Expanded(
//           flex: 2,
//           child: _MoneyText(
//             value: highest,
//             currency: currency,
//           ),
//         ),
//
//         // CURRENT / SOLD
//         Expanded(
//           flex: 2,
//           child: _MoneyText(
//             value: current,
//             currency: currency,
//           ),
//         ),
//
//         // BIDS
//         SizedBox(
//           width: 15.w,
//           child: Text(
//             bid.myBidCount.toString(),
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: colors.textSecondary,
//             ),
//           ),
//         ),
//
//         // ACTION
//         SizedBox(
//           width: 26.3.w,
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: onPayNow != null
//                 ? _PayButton(
//                     onPressed: onPayNow!,
//                   )
//                 : _DetailsButton(
//                     onPressed: onDetails,
//                   ),
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget _buildMobileRow(
//     BuildContext context,
//     String currency,
//     String? highest,
//     String? current,
//   ) {
//     final colors = context.colors;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: _buildLot(context),
//             ),
//             SizedBox(width: 3.w),
//             _StandingBadge(
//               status: bid.myStatus,
//             ),
//           ],
//         ),
//
//         SizedBox(height: 2.h),
//
//         Container(
//           height: 1,
//           color: colors.border,
//         ),
//
//         SizedBox(height: 1.75.h),
//
//         Row(
//           children: [
//             Expanded(
//               child: _InfoColumn(
//                 title: 'Your highest',
//                 value: _formatMoney(
//                   currency,
//                   highest,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: _InfoColumn(
//                 title: 'Current / sold',
//                 value: _formatMoney(
//                   currency,
//                   current,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: _InfoColumn(
//                 title: 'Bids',
//                 value: bid.myBidCount.toString(),
//               ),
//             ),
//           ],
//         ),
//
//         SizedBox(height: 1.75.h),
//
//         SizedBox(
//           width: double.infinity,
//           child: onPayNow != null
//               ? _PayButton(
//                   onPressed: onPayNow!,
//                   expanded: true,
//                 )
//               : _DetailsButton(
//                   onPressed: onDetails,
//                   expanded: true,
//                 ),
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget _buildLot(BuildContext context) {
//     final colors = context.colors;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           bid.title.isEmpty ? 'Auction' : bid.title,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w700,
//             color: colors.textPrimary,
//           ),
//         ),
//         SizedBox(height: 0.75.h),
//         Text(
//           bid.number.isEmpty
//               ? bid.uuid
//               : bid.number,
//           style: TextStyle(
//             fontSize: 11.sp,
//             color: colors.textSecondary,
//           ),
//         ),
//       ],
//     );
//   }
//
//   String _formatMoney(
//     String currency,
//     String? value,
//   ) {
//     if (value == null || value.isEmpty) {
//       return '-';
//     }
//
//     return '$currency$value';
//   }
// }
//
//
//
// class _MoneyText extends StatelessWidget {
//   final String? value;
//   final String currency;
//
//   const _MoneyText({
//     required this.value,
//     required this.currency,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Text(
//       value == null || value!.isEmpty
//           ? '-'
//           : '$currency$value',
//       textAlign: TextAlign.center,
//       style: TextStyle(
//         fontSize: 13.sp,
//         fontWeight: FontWeight.w600,
//         color: colors.textPrimary,
//       ),
//     );
//   }
// }
//
//
//
// class _InfoColumn extends StatelessWidget {
//   final String title;
//   final String value;
//
//   const _InfoColumn({
//     required this.title,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 11.sp,
//             color: colors.textSecondary,
//           ),
//         ),
//         SizedBox(height: 0.6.h),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 13.sp,
//             fontWeight: FontWeight.w700,
//             color: colors.textPrimary,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// class _StandingBadge extends StatelessWidget {
//   final String status;
//
//   const _StandingBadge({
//     required this.status,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final normalized = status.toLowerCase();
//
//     final isLeading =
//         normalized.contains('lead') ||
//         normalized.contains('highest');
//
//     final isWon =
//         normalized.contains('won') ||
//         normalized.contains('winner');
//
//     final isPayment =
//         normalized.contains('payment') ||
//         normalized.contains('due');
//
//     final isLost =
//         normalized.contains('lost') ||
//         normalized.contains('outbid') ||
//         normalized.contains('lose');
//
//     String text;
//     Color background;
//     Color foreground;
//
//     if (isPayment) {
//       text = 'Payment due';
//       background = colors.statusWarningSoft;
//       foreground = colors.statusWarning;
//     } else if (isWon) {
//       text = 'Won';
//       background = colors.statusSuccessSoft;
//       foreground = colors.statusSuccess;
//     } else if (isLeading) {
//       text = 'You lead';
//       background = colors.statusSuccessSoft;
//       foreground = colors.statusSuccess;
//     } else if (isLost) {
//       text = 'Outbid';
//       background = colors.error.withValues(alpha: 0.1);
//       foreground = colors.error;
//     } else {
//       text = _prettyStatus(status);
//       background = colors.surfaceAlt;
//       foreground = colors.textSecondary;
//     }
//
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: 2.5.w,
//         vertical: 0.75.h,
//       ),
//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(18),
//       ),
//       child: Text(
//         text,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: TextStyle(
//           fontSize: 11.sp,
//           fontWeight: FontWeight.w700,
//           color: foreground,
//         ),
//       ),
//     );
//   }
//
//   String _prettyStatus(String value) {
//     if (value.isEmpty) {
//       return 'Placed';
//     }
//
//     return value
//         .replaceAll('_', ' ')
//         .split(' ')
//         .map(
//           (word) => word.isEmpty
//               ? ''
//               : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
//         )
//         .join(' ');
//   }
// }
//
//
// class _PayButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final bool expanded;
//
//   const _PayButton({
//     required this.onPressed,
//     this.expanded = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return SizedBox(
//       width: expanded ? double.infinity : null,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: colors.auctionHeroBackground,
//           foregroundColor: colors.auctionAccent,
//           elevation: 0,
//           padding: EdgeInsets.symmetric(
//             horizontal: 3.8.w,
//             vertical: 1.25.h,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(9),
//           ),
//         ),
//         child: Text(
//           'Pay now',
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class _DetailsButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final bool expanded;
//
//   const _DetailsButton({
//     required this.onPressed,
//     this.expanded = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return SizedBox(
//       width: expanded ? double.infinity : null,
//       child: TextButton(
//         onPressed: onPressed,
//         style: TextButton.styleFrom(
//           backgroundColor: colors.surfaceAlt,
//           foregroundColor: colors.textSecondary,
//           padding: EdgeInsets.symmetric(
//             horizontal: 3.8.w,
//             vertical: 1.25.h,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(9),
//           ),
//         ),
//         child: Text(
//           'Details',
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
//
// class _BidDetailsSheet extends StatelessWidget {
//   final MyBidItemEntity bid;
//
//   const _BidDetailsSheet({
//     required this.bid,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final currency =
//         bid.currency.isEmpty ? 'US\$' : bid.currency;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         5.w,
//         1.75.h,
//         5.w,
//         3.75.h,
//       ),
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: const BorderRadius.vertical(
//           top: Radius.circular(22),
//         ),
//       ),
//       child: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 42,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: colors.border,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 2.75.h),
//
//               Text(
//                 bid.title,
//                 style: TextStyle(
//                   fontSize: 20.sp,
//                   fontWeight: FontWeight.w800,
//                   color: colors.textPrimary,
//                 ),
//               ),
//
//               SizedBox(height: 0.6.h),
//
//               Text(
//                 bid.number,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: colors.textSecondary,
//                 ),
//               ),
//
//               SizedBox(height: 2.75.h),
//
//               _DetailItem(
//                 title: 'Standing',
//                 value: bid.myStatus,
//               ),
//
//               _DetailItem(
//                 title: 'Your highest bid',
//                 value: bid.myHighestBid == null
//                     ? '-'
//                     : '$currency${bid.myHighestBid}',
//               ),
//
//               _DetailItem(
//                 title: 'Current bid',
//                 value: bid.currentBid == null
//                     ? '-'
//                     : '$currency${bid.currentBid}',
//               ),
//
//               _DetailItem(
//                 title: 'Final bid',
//                 value: bid.finalBid == null
//                     ? '-'
//                     : '$currency${bid.finalBid}',
//               ),
//
//               _DetailItem(
//                 title: 'Minimum next bid',
//                 value:
//                     '$currency${bid.minimumNextBid}',
//               ),
//
//               _DetailItem(
//                 title: 'Bid increment',
//                 value:
//                     '$currency${bid.bidIncrement}',
//               ),
//
//               _DetailItem(
//                 title: 'Your bid count',
//                 value: bid.myBidCount.toString(),
//               ),
//
//               _DetailItem(
//                 title: 'Total auction bids',
//                 value: bid.bidCount.toString(),
//               ),
//
//               _DetailItem(
//                 title: 'Start',
//                 value: _formatDate(bid.startAt),
//               ),
//
//               _DetailItem(
//                 title: 'End',
//                 value: _formatDate(bid.endAt),
//               ),
//
//               if (bid.vendor != null)
//                 _DetailItem(
//                   title: 'Vendor',
//                   value: bid.vendor!.shopName,
//                 ),
//
//               if (bid.category != null)
//                 _DetailItem(
//                   title: 'Category',
//                   value: bid.category!.name,
//                 ),
//
//               if (bid.allotment != null) ...[
//                 SizedBox(height: 1.h),
//
//                 Text(
//                   'Allotment',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w800,
//                     color: colors.textPrimary,
//                   ),
//                 ),
//
//                 SizedBox(height: 1.25.h),
//
//                 _DetailItem(
//                   title: 'Status',
//                   value: bid.allotment!.status,
//                 ),
//
//                 _DetailItem(
//                   title: 'Amount',
//                   value:
//                       '$currency${bid.allotment!.amount}',
//                 ),
//
//                 _DetailItem(
//                   title: 'Rank',
//                   value:
//                       bid.allotment!.rank.toString(),
//                 ),
//
//                 _DetailItem(
//                   title: 'Payment due',
//                   value:
//                       _formatDate(
//                         bid.allotment!.paymentDueAt,
//                       ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(String value) {
//     if (value.isEmpty) {
//       return '-';
//     }
//
//     try {
//       final date = DateTime.parse(value);
//
//       return '${date.day.toString().padLeft(2, '0')}/'
//           '${date.month.toString().padLeft(2, '0')}/'
//           '${date.year} '
//           '${date.hour.toString().padLeft(2, '0')}:'
//           '${date.minute.toString().padLeft(2, '0')}';
//     } catch (_) {
//       return value;
//     }
//   }
// }
//
//
// class _DetailItem extends StatelessWidget {
//   final String title;
//   final String value;
//
//   const _DetailItem({
//     required this.title,
//     required this.value,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.1.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 color: colors.textSecondary,
//               ),
//             ),
//           ),
//           SizedBox(width: 3.8.w),
//           Flexible(
//             child: Text(
//               value,
//               textAlign: TextAlign.right,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w700,
//                 color: colors.textPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/auction_cubit.dart';
import '../cubit/auction_state.dart';
import '../../domain/entities/my_bids_entity.dart';
import '../widgets/hero_wishlist_button.dart';
import '../widgets/my_bids_shimmer.dart';

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
      context.read<AuctionCubit>().getMyBids(take: 20, skip: 0);
    });
  }

  Future<void> _refresh() async {
    await context.read<AuctionCubit>().getMyBids(take: 20, skip: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(title: 'My Bids', centerTitle: true),
      body: SafeArea(
        top: false,
        child: BlocBuilder<AuctionCubit, AuctionState>(
          builder: (context, state) {
            if (state is MyBidsLoading) {
              return const MyBidsShimmer();
            }

            if (state is MyBidsError) {
              return _buildError(state.message);
            }

            if (state is MyBidsLoaded) {
              return RefreshIndicator(
                color: colors.brand,
                backgroundColor: colors.surface,
                onRefresh: _refresh,
                child: _buildContent(state.myBids),
              );
            }

            return const MyBidsShimmer();
          },
        ),
      ),
    );
  }

  Widget _buildContent(MyBidsEntity myBids) {
    final colors = context.colors;
    final filteredItems = _filterItems(myBids.items);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(4.1.w, 1.42.h, 4.1.w, 3.8.h),
      children: [
        Text(
          'Every auction you have bid on, and where you stand in each.',
          style: TextStyle(fontSize: 13.5.sp, color: colors.textSecondary),
        ),

        SizedBox(height: 2.13.h),

        _buildSummary(myBids.summary),

        SizedBox(height: 2.6.h),

        _buildFilters(myBids.items),

        SizedBox(height: 2.13.h),

        if (filteredItems.isEmpty)
          _buildEmptyFilter()
        else
          _buildBidList(filteredItems),
      ],
    );
  }

  Widget _buildSummary(MyBidsSummaryEntity summary) {
    final colors = context.colors;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.workspace_premium_rounded,
            title: 'Leading',
            value: summary.leading,
            iconColor: colors.brand,
            iconBg: colors.brandSoft,
          ),
        ),
        SizedBox(width: 2.05.w),
        Expanded(
          child: _SummaryCard(
            icon: Icons.gavel_rounded,
            title: 'Outbid',
            value: summary.outbid,
            iconColor: colors.statusWarning,
            iconBg: colors.statusWarningSoft,
          ),
        ),
        SizedBox(width: 2.05.w),
        Expanded(
          child: _SummaryCard(
            icon: Icons.emoji_events_rounded,
            title: 'Won',
            value: summary.won,
            iconColor: colors.statusSuccess,
            iconBg: colors.statusSuccessSoft,
          ),
        ),
        SizedBox(width: 2.05.w),
        Expanded(
          child: _SummaryCard(
            icon: Icons.schedule_rounded,
            title: 'Payment due',
            value: summary.paymentDue,
            iconColor: colors.error,
            iconBg: colors.error.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(List<MyBidItemEntity> items) {
    final colors = context.colors;

    final filters = <String, int>{
      'All': items.length,
      'Active': items.where(_isActive).length,
      'Payment due': items.where(_isPaymentDue).length,
      'Won': items.where(_isWon).length,
      'Not won': items.where((item) => !_isWon(item)).length,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.entries.map((entry) {
          final filter = entry.key;
          final count = entry.value;
          final selected = _selectedFilter == filter;

          return Padding(
            padding: EdgeInsets.only(right: 2.05.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(
                  horizontal: 3.85.w,
                  vertical: 1.07.h,
                ),
                decoration: BoxDecoration(
                  color: selected ? colors.brand : colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected ? colors.brand : colors.border,
                  ),
                ),
                child: Text(
                  '$filter ($count)',
                  style: TextStyle(
                    fontSize: 13.5.sp,
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

  List<MyBidItemEntity> _filterItems(List<MyBidItemEntity> items) {
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
    final allotmentStatus = item.allotment?.status.trim().toLowerCase() ?? '';

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

    return hasWonStatus || hasWonAllotment || (hasAllotment && auctionEnded);
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
            padding: EdgeInsets.only(bottom: 1.9.h),
            child: _MyBidCard(
              bid: item,
              onPayNow: _isPaymentDue(item) ? () => _payNow(item) : null,
              onDetails: () => _showDetails(item),
            ),
          ),
        ),
        SizedBox(height: 0.47.h),
        Text(
          'Select a row for the full bidding history, who won, and any payment owed.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5.sp, color: colors.textSecondary),
        ),
      ],
    );
  }

  void _payNow(MyBidItemEntity item) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Payment for ${item.title}')));
  }

  void _showDetails(MyBidItemEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _BidDetailsSheet(bid: item);
      },
    );
  }

  Widget _buildEmptyFilter() {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.9.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.gavel_outlined, size: 44.sp, color: colors.textMuted),
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
            style: TextStyle(fontSize: 13.sp, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    final colors = context.colors;

    return RefreshIndicator(
      color: colors.brand,
      backgroundColor: colors.surface,
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Icon(Icons.error_outline_rounded, size: 55.sp, color: colors.error),
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
                backgroundColor: colors.brand,
                foregroundColor: colors.onBrand,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final Color iconColor;
  final Color iconBg;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.31.w, vertical: 1.66.h),
      decoration: BoxDecoration(
        color: iconBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8.72.w,
            height: 8.72.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16.sp, color: iconColor),
          ),
          SizedBox(height: 1.42.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: 0.24.h),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Standing {
  final String text;
  final Color background;
  final Color foreground;

  const _Standing({
    required this.text,
    required this.background,
    required this.foreground,
  });

  static _Standing of(AppThemeColors colors, String status) {
    final normalized = status.toLowerCase();

    final isLeading =
        normalized.contains('lead') || normalized.contains('highest');

    final isWon = normalized.contains('won') || normalized.contains('winner');

    final isPayment =
        normalized.contains('payment') || normalized.contains('due');

    final isLost =
        normalized.contains('lost') ||
        normalized.contains('outbid') ||
        normalized.contains('lose');

    if (isPayment) {
      return _Standing(
        text: 'Payment due',
        background: colors.statusWarningSoft,
        foreground: colors.statusWarning,
      );
    }

    if (isWon) {
      return _Standing(
        text: 'Won',
        background: colors.statusSuccessSoft,
        foreground: colors.statusSuccess,
      );
    }

    if (isLeading) {
      return _Standing(
        text: 'You lead',
        background: colors.statusSuccessSoft,
        foreground: colors.statusSuccess,
      );
    }

    if (isLost) {
      return _Standing(
        text: 'Outbid',
        background: colors.error.withValues(alpha: 0.1),
        foreground: colors.error,
      );
    }

    return _Standing(
      text: _prettyStatus(status),
      background: colors.surfaceAlt,
      foreground: colors.textSecondary,
    );
  }

  static String _prettyStatus(String value) {
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

class _StandingBadge extends StatelessWidget {
  final String status;

  const _StandingBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final standing = _Standing.of(colors, status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.31.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: standing.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        standing.text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: standing.foreground,
        ),
      ),
    );
  }
}

class _MyBidCard extends StatelessWidget {
  final MyBidItemEntity bid;
  final VoidCallback? onPayNow;
  final VoidCallback onDetails;

  const _MyBidCard({
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
    final isLive = bid.status.toUpperCase() == 'LIVE';

    final imageUrl = bid.images != null && bid.images!.isNotEmpty
        ? bid.images!.first
        : null;

    final tag = [
      if (bid.vendor?.shopName.trim().isNotEmpty == true)
        bid.vendor!.shopName.trim(),
      if (bid.category?.name.trim().isNotEmpty == true)
        bid.category!.name.trim(),
    ].join('  |  ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDetails,
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
                      color: colors.textPrimary.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 28.2.w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder(colors),
                            )
                          : _imagePlaceholder(colors),

                      Positioned(
                        top: 1.18.h,
                        left: 2.05.w,
                        child: _ImageStatusBadge(
                          isLive: isLive,
                          status: bid.myStatus,
                        ),
                      ),

                      Positioned(
                        top: 1.18.h,
                        right: 2.05.w,
                        child: HeroWishlistButton(auctionUuid: bid.uuid),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(3.6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bid.title.isEmpty ? 'Auction' : bid.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 0.36.h),
                                  Text(
                                    bid.number.isEmpty ? bid.uuid : bid.number,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5.sp,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 1.28.w),
                            _StandingBadge(status: bid.myStatus),
                          ],
                        ),

                        if (tag.isNotEmpty) ...[
                          SizedBox(height: 0.83.h),
                          Row(
                            children: [
                              Icon(
                                Icons.sell_outlined,
                                size: 11.sp,
                                color: colors.textSecondary,
                              ),
                              SizedBox(width: 1.03.w),
                              Flexible(
                                child: Text(
                                  tag,
                                  maxLines: 1,
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

                        SizedBox(height: 1.42.h),

                        Container(height: 1, color: colors.border),

                        SizedBox(height: 1.18.h),

                        Row(
                          children: [
                            Expanded(
                              child: _InfoColumn(
                                title: 'Your highest',
                                value: _formatMoney(currency, highest),
                              ),
                            ),
                            Expanded(
                              child: _InfoColumn(
                                title: 'Current / sold',
                                value: _formatMoney(currency, current),
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

                        SizedBox(height: 1.42.h),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 11.sp,
                                    color: colors.textSecondary,
                                  ),
                                  SizedBox(width: 1.03.w),
                                  Expanded(
                                    child:
                                        isLive && bid.secondsRemaining != null
                                        ? _EndsInText(
                                            secondsRemaining:
                                                bid.secondsRemaining!,
                                          )
                                        : Text(
                                            'Ended on ${_formatEndedOn(bid.endAt)}',
                                            maxLines: 1,
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
                            ),
                            SizedBox(width: 1.79.w),
                            onPayNow != null
                                ? _PayButton(onPressed: onPayNow!)
                                : _DetailsButton(onPressed: onDetails),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder(AppThemeColors colors) {
    return Container(
      color: colors.surfaceAlt,
      child: Center(
        child: Icon(Icons.image_outlined, size: 22.sp, color: colors.textMuted),
      ),
    );
  }

  String _formatMoney(String currency, String? value) {
    if (value == null || value.isEmpty) {
      return '-';
    }

    return '$currency$value';
  }

  String _formatEndedOn(String value) {
    if (value.isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(value).toLocal();

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      final hour24 = date.hour;
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      final minute = date.minute.toString().padLeft(2, '0');

      return '${date.day.toString().padLeft(2, '0')} '
          '${months[date.month - 1]} ${date.year}, '
          '$hour12:$minute $period';
    } catch (_) {
      return value;
    }
  }
}

class _ImageStatusBadge extends StatelessWidget {
  final bool isLive;
  final String status;

  const _ImageStatusBadge({required this.isLive, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final text = isLive ? 'LIVE' : _Standing.of(colors, status).text;
    final dotColor = isLive
        ? colors.statusSuccess
        : _Standing.of(colors, status).foreground;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.05.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 1.54.w,
            height: 1.54.w,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          SizedBox(width: 1.03.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live-ticking "Ends in Xd : XXh : XXm : XXs" text for a still-live bid.
class _EndsInText extends StatefulWidget {
  const _EndsInText({required this.secondsRemaining});

  final int secondsRemaining;

  @override
  State<_EndsInText> createState() => _EndsInTextState();
}

class _EndsInTextState extends State<_EndsInText> {
  Timer? _timer;
  late int _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.secondsRemaining;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant _EndsInText oldWidget) {
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
        'Ends in ${days}d : '
        '${hours.toString().padLeft(2, '0')}h : '
        '${minutes.toString().padLeft(2, '0')}m : '
        '${seconds.toString().padLeft(2, '0')}s';

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: colors.brand,
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _InfoColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.5.sp, color: colors.textSecondary),
        ),
        SizedBox(height: 0.36.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15.5.sp,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _PayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          gradient: colors.buttonPrimaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.07.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pay now',
                  style: TextStyle(
                    color: colors.onBrand,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 1.03.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 13.sp,
                  color: colors.onBrand,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DetailsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.brand,
        side: BorderSide(color: colors.brand, width: 1.2),
        padding: EdgeInsets.symmetric(horizontal: 3.6.w, vertical: 1.07.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'View details',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 1.03.w),
          Icon(Icons.arrow_forward_rounded, size: 13.sp),
        ],
      ),
    );
  }
}

class _BidDetailsSheet extends StatelessWidget {
  final MyBidItemEntity bid;

  const _BidDetailsSheet({required this.bid});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currency = bid.currency.isEmpty ? 'US\$' : bid.currency;

    return Container(
      padding: EdgeInsets.fromLTRB(5.w, 1.75.h, 5.w, 3.75.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
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
                  fontSize: 21.sp,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),

              SizedBox(height: 0.6.h),

              Text(
                bid.number,
                style: TextStyle(fontSize: 13.sp, color: colors.textSecondary),
              ),

              SizedBox(height: 2.75.h),

              _DetailItem(title: 'Standing', value: bid.myStatus),

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
                value: bid.finalBid == null ? '-' : '$currency${bid.finalBid}',
              ),

              _DetailItem(
                title: 'Minimum next bid',
                value: '$currency${bid.minimumNextBid}',
              ),

              _DetailItem(
                title: 'Bid increment',
                value: '$currency${bid.bidIncrement}',
              ),

              _DetailItem(
                title: 'Your bid count',
                value: bid.myBidCount.toString(),
              ),

              _DetailItem(
                title: 'Total auction bids',
                value: bid.bidCount.toString(),
              ),

              _DetailItem(title: 'Start', value: _formatDate(bid.startAt)),

              _DetailItem(title: 'End', value: _formatDate(bid.endAt)),

              if (bid.vendor != null)
                _DetailItem(title: 'Vendor', value: bid.vendor!.shopName),

              if (bid.category != null)
                _DetailItem(title: 'Category', value: bid.category!.name),

              if (bid.allotment != null) ...[
                SizedBox(height: 1.h),

                Text(
                  'Allotment',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),

                SizedBox(height: 1.25.h),

                _DetailItem(title: 'Status', value: bid.allotment!.status),

                _DetailItem(
                  title: 'Amount',
                  value: '$currency${bid.allotment!.amount}',
                ),

                _DetailItem(
                  title: 'Rank',
                  value: bid.allotment!.rank.toString(),
                ),

                _DetailItem(
                  title: 'Payment due',
                  value: _formatDate(bid.allotment!.paymentDueAt),
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

  const _DetailItem({required this.title, required this.value});

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
              style: TextStyle(fontSize: 14.5.sp, color: colors.textSecondary),
            ),
          ),
          SizedBox(width: 3.8.w),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14.5.sp,
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
