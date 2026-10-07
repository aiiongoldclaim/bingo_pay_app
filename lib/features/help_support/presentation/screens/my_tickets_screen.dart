import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../cubit/support_ticket_cubit.dart';
import '../cubit/support_ticket_state.dart';
import '../widgets/raise_ticket_sheet.dart';

const String _anyStatusValue = 'ANY';

const List<({String value, String label})> _statusOptions = [
  (value: _anyStatusValue, label: 'Any Status'),
  (value: 'OPEN', label: 'Open'),
  (value: 'IN_PROGRESS', label: 'In Process'),
  (value: 'WAITING_FOR_CUSTOMER', label: 'Waiting for you'),
  (value: 'RESOLVED', label: 'Resolved'),
  (value: 'CLOSED', label: 'Closed'),
];

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  final _searchController = TextEditingController();
  final _statusButtonKey = GlobalKey();
  String _query = '';
  String _statusFilter = _anyStatusValue;

  @override
  void initState() {
    super.initState();
    context.read<SupportTicketCubit>().loadMyTickets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickStatus(BuildContext context) async {
    final buttonBox =
        _statusButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (buttonBox == null || overlayBox == null) return;

    final topLeft =
        buttonBox.localToGlobal(Offset(0, buttonBox.size.height + 6),
            ancestor: overlayBox);
    final bottomRight = buttonBox.localToGlobal(
        buttonBox.size.bottomRight(Offset.zero),
        ancestor: overlayBox);

    final colors = context.c;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlayBox.size,
      ),
      constraints: BoxConstraints(minWidth: buttonBox.size.width),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      items: _statusOptions.map((o) {
        final isSelected = o.value == _statusFilter;
        return PopupMenuItem<String>(
          value: o.value,
          height: 5.h,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  o.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, size: 18.sp, color: colors.brand),
            ],
          ),
        );
      }).toList(),
    );
    if (selected == null) return;
    setState(() => _statusFilter = selected);
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _searchController.clear();
      _statusFilter = _anyStatusValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: BlocConsumer<SupportTicketCubit, SupportTicketState>(
                // RaiseTicketSheet resets this shared cubit after submitting,
                // so reload the list or it stays stuck on the shimmer.
                listenWhen: (_, state) => state is SupportTicketSubmitted,
                listener: (context, _) =>
                    context.read<SupportTicketCubit>().loadMyTickets(),
                builder: (context, state) {
                  if (state is SupportTicketError) {
                    return _ErrorView(
                      message: state.errorMessage,
                      onRetry: () =>
                          context.read<SupportTicketCubit>().loadMyTickets(),
                    );
                  }

                  if (state is SupportTicketListLoaded) {
                    final tickets = state.list.items;

                    if (tickets.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () => context
                            .read<SupportTicketCubit>()
                            .loadMyTickets(),
                        child: const _EmptyView(),
                      );
                    }

                    final query = _query.trim().toLowerCase();
                    final filtered = tickets.where((t) {
                      final matchesQuery = query.isEmpty ||
                          t.ref.toLowerCase().contains(query) ||
                          t.subject.toLowerCase().contains(query);
                      final matchesStatus =
                          _statusFilter == _anyStatusValue ||
                              t.status.toUpperCase() == _statusFilter;
                      return matchesQuery && matchesStatus;
                    }).toList();

                    return Column(
                      children: [
                        _SearchAndFilterBar(
                          searchController: _searchController,
                          onSearchChanged: (v) => setState(() => _query = v),
                          statusFilter: _statusFilter,
                          statusButtonKey: _statusButtonKey,
                          onStatusTap: () => _pickStatus(context),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => context
                                .read<SupportTicketCubit>()
                                .loadMyTickets(),
                            child: filtered.isEmpty
                                ? _NoResultsView(onClear: _clearFilters)
                                : ListView.separated(
                                    padding: EdgeInsets.fromLTRB(
                                        4.w, 1.4.h, 4.w, 4.h),
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, _) =>
                                        SizedBox(height: 1.4.h),
                                    itemBuilder: (context, index) =>
                                        _TicketCard(ticket: filtered[index]),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const _TicketsLoadingShimmer();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String statusFilter;
  final Key statusButtonKey;
  final VoidCallback onStatusTap;

  const _SearchAndFilterBar({
    required this.searchController,
    required this.onSearchChanged,
    required this.statusFilter,
    required this.statusButtonKey,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final statusLabel = _statusOptions
        .firstWhere((o) => o.value == statusFilter,
            orElse: () => _statusOptions.first)
        .label;

    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 1.6.h, 4.w, 1.2.h),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontSize: 15.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Search tickets...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textMuted,
                  fontFamily: 'Inter',
                  fontSize: 15.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 22.sp,
                  color: colors.textMuted,
                ),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20.sp,
                          color: colors.textMuted,
                        ),
                        onPressed: () {
                          searchController.clear();
                          onSearchChanged('');
                        },
                      ),
                filled: true,
                fillColor: colors.surface,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: colors.brand, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(width: 2.4.w),
          Material(
            key: statusButtonKey,
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onStatusTap,
              child: Container(
                height: 6.h,
                padding: EdgeInsets.symmetric(horizontal: 2.8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                constraints: BoxConstraints(maxWidth: 30.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: 19.sp,
                      color: colors.textSecondary,
                    ),
                    SizedBox(width: 1.4.w),
                    Flexible(
                      child: Text(
                        statusLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20.sp,
                      color: colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResultsView extends StatelessWidget {
  final VoidCallback onClear;

  const _NoResultsView({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 15.w,
                      color: colors.textMuted,
                    ),
                    SizedBox(height: 1.6.h),
                    Text(
                      'No tickets match your filters',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(height: 1.8.h),
                    SizedBox(
                      height: 6.h,
                      child: OutlinedButton(
                        onPressed: onClear,
                        style: OutlinedButton.styleFrom(
                          textStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                        child: const Text('Clear Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(AppRoutes.help),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 22.sp,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'My Tickets',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 3.w),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 46.sp, color: colors.error),
            SizedBox(height: 1.6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 1.6.h),
            SizedBox(
              height: 6.h,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  textStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: colors.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.confirmation_num_outlined,
                        size: 11.w,
                        color: colors.brand,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No tickets yet',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 19.sp,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Text(
                      'Raise a ticket and our support team will get back to you.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 15.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 2.2.h),
                    SizedBox(
                      height: 6.5.h,
                      child: FilledButton(
                        onPressed: () => RaiseTicketSheet.show(context),
                        style: FilledButton.styleFrom(
                          textStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                        ),
                        child: const Text('Raise a Ticket'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicketEntity ticket;

  const _TicketCard({required this.ticket});

  Color _statusColor(BuildContext context) {
    final colors = context.c;
    switch (ticket.status.toUpperCase()) {
      case 'RESOLVED':
        return AppColors.success;
      case 'CLOSED':
        return colors.textMuted;
      case 'IN_PROGRESS':
        return AppColors.warning;
      default:
        return colors.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final statusColor = _statusColor(context);
    final dateFormat = DateFormat('dd MMM, hh:mm a');
    final lastActivity = ticket.lastMessageAt ?? ticket.createdAt;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.ticketDetailPath(ticket.uuid)),
        child: Container(
          padding: EdgeInsets.all(3.6.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.ref,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.6.w, vertical: 0.6.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.status.replaceAll('_', ' '),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: statusColor,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.8.h),
              Text(
                ticket.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 1.2.h),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 15.sp,
                    color: colors.textMuted,
                  ),
                  SizedBox(width: 1.2.w),
                  Text(
                    '${ticket.messagesCount}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textMuted,
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      dateFormat.format(lastActivity.toLocal()),
                      textAlign: TextAlign.end,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textMuted,
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketsLoadingShimmer extends StatelessWidget {
  const _TicketsLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
        itemCount: 5,
        separatorBuilder: (_, _) => SizedBox(height: 1.4.h),
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.all(3.6.w),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ShimmerBlock(width: 26.w, height: 2.h, colors: colors),
                  const Spacer(),
                  _ShimmerBlock(width: 20.w, height: 2.6.h, colors: colors, radius: 20),
                ],
              ),
              SizedBox(height: 1.2.h),
              _ShimmerBlock(width: 60.w, height: 2.h, colors: colors),
              SizedBox(height: 1.8.h),
              Row(
                children: [
                  _ShimmerBlock(width: 14.w, height: 1.6.h, colors: colors),
                  const Spacer(),
                  _ShimmerBlock(width: 24.w, height: 1.6.h, colors: colors),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final AppThemeColors colors;
  final double radius;

  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.colors,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
