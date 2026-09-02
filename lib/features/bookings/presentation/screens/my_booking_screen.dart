import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/pdf_file_handler.dart';

import '../../data/datasources/booking_remote_datasources.dart';
import '../../domain/entities/bookings_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Load bookings when screen is opened
    context.read<BookingCubit>().fetchBookings();

    return const _MyBookingsBody();
  }
}

class _MyBookingsBody extends StatelessWidget {
  const _MyBookingsBody();

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,

      body: SafeArea(
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is BookingInitial || state is BookingLoading) {
              return const _BookingsLoadingView();
            }

            if (state is BookingError) {
              return _BookingErrorView(message: state.message);
            }

            if (state is BookingListLoaded) {
              return _BookingsLoadedView(bookings: state.bookings);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LOADED VIEW
// -----------------------------------------------------------------------------

class _BookingsLoadedView extends StatelessWidget {
  const _BookingsLoadedView({required this.bookings});

  final List<BookingEntity> bookings;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    if (bookings.isEmpty) {
      return const _EmptyBookingsView();
    }

    final upcomingCount = bookings.where(_isUpcoming).length;

    return RefreshIndicator(
      color: c.brand,
      backgroundColor: c.surface,
      onRefresh: () async {
        await context.read<BookingCubit>().fetchBookings();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _BookingsHeader(
              total: bookings.length,
              upcoming: upcomingCount,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            sliver: SliverList.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                return _BookingCard(booking: bookings[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isUpcoming(BookingEntity booking) {
    final status = booking.status.toUpperCase();

    if (status == 'CANCELLED' ||
        status == 'COMPLETED' ||
        status == 'REJECTED') {
      return false;
    }

    final date = DateTime.tryParse(booking.scheduledStartAt);

    if (date == null) return false;

    return date.isAfter(DateTime.now());
  }
}

// -----------------------------------------------------------------------------
// HEADER
// -----------------------------------------------------------------------------

class _BookingsHeader extends StatelessWidget {
  const _BookingsHeader({required this.total, required this.upcoming});

  final int total;
  final int upcoming;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
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
                      'My Bookings',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your upcoming and past appointments.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: c.border),
                  boxShadow: c.isDark
                      ? null
                      : [
                          BoxShadow(
                            color: c.textPrimary.withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: c.brand,
                  size: 21,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              _HeaderStat(
                icon: Icons.calendar_today_rounded,
                label: 'Upcoming',
                value: '$upcoming',
              ),
              const SizedBox(width: 10),
              _HeaderStat(
                icon: Icons.receipt_long_rounded,
                label: 'All bookings',
                value: '$total',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: c.border),
          boxShadow: c.isDark
              ? null
              : [
                  BoxShadow(
                    color: c.textPrimary.withValues(alpha: 0.035),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: c.brandSoft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 17, color: c.brand),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BOOKING CARD
// -----------------------------------------------------------------------------

class _BookingCard extends StatefulWidget {
  const _BookingCard({required this.booking, required this.index});

  final BookingEntity booking;
  final int index;

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _generatingPdf = false;

  Future<void> _downloadInvoice() async {
    if (widget.booking.uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice is not available for this booking yet.'),
        ),
      );
      return;
    }

    setState(() => _generatingPdf = true);
    try {
      final invoice = await GetIt.I<BookingRemoteDatasources>().downloadInvoice(
        // widget.booking.uuid,
        widget.booking.order.uuid,
      );
      await openOrSharePdf(invoice.bytes, invoice.filename);
    } catch (e, st) {
      debugPrint('[Booking Invoice] Download failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download invoice. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final status = _statusInfo(context, widget.booking.status);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: c.border),
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(alpha: 0.055),
                  blurRadius: 22,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Column(
          children: [
            // -----------------------------------------------------------------
            // TOP ACCENT
            // -----------------------------------------------------------------
            Container(height: 4, width: double.infinity, color: status.color),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------------------
                  // SERVICE + STATUS
                  // -----------------------------------------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: c.brandSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _serviceIcon(widget.booking.service.title),
                                color: c.brand,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.booking.service.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: c.textPrimary,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      letterSpacing: -0.15,
                                    ),
                                  ),

                                  if (widget.booking.offering.offeringName
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.booking.offering.offeringName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: c.textSecondary,
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      _StatusBadge(
                        label: _statusLabel(widget.booking.status),
                        color: status.color,
                        background: status.background,
                      ),
                      IconButton(
                        onPressed: () {
                          context.pushNamed(
                            AppRoutes.bookingDetailName,
                            pathParameters: {'uuid': widget.booking.uuid},
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // -----------------------------------------------------------
                  // DATE / TIME HERO
                  // -----------------------------------------------------------
                  _DateTimePanel(booking: widget.booking),

                  const SizedBox(height: 14),

                  // -----------------------------------------------------------
                  // VENDOR + BOOKING NUMBER
                  // -----------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: _InfoLine(
                          icon: Icons.storefront_rounded,
                          label: 'Provider',
                          value: widget.booking.vendor.shopName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoLine(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Booking',
                          value: widget.booking.bookingNumber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // -----------------------------------------------------------
                  // PAYMENT + PARTICIPANTS
                  // -----------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: _InfoLine(
                          icon: Icons.payments_outlined,
                          label: 'Payment',
                          value:
                              '${widget.booking.paymentMode}  •  ₹${widget.booking.orderItem.totalAmount}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoLine(
                          icon: Icons.people_outline_rounded,
                          label: 'Participants',
                          value: '${widget.booking.participants}',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 17),

                  // -----------------------------------------------------------
                  // DIVIDER
                  // -----------------------------------------------------------
                  Container(height: 1, color: c.border),

                  const SizedBox(height: 14),

                  // -----------------------------------------------------------
                  // BOTTOM ACTIONS
                  // -----------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: _BookingActionButton(
                          icon: Icons.sync_rounded,
                          label: 'Change time',
                          primary: true,
                          onTap: () {
                            _showComingSoon(context, 'Change time');
                          },
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _BookingActionButton(
                          icon: _generatingPdf
                              ? Icons.hourglass_top_outlined
                              : Icons.file_download_outlined,
                          label: _generatingPdf ? 'Generating…' : 'Invoice',
                          primary: false,
                          onTap: _generatingPdf
                              ? null
                              : () => _downloadInvoice(),
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
    );
  }

  IconData _serviceIcon(String title) {
    final value = title.toLowerCase();

    if (value.contains('hair') ||
        value.contains('salon') ||
        value.contains('cut')) {
      return Icons.content_cut_rounded;
    }

    if (value.contains('spa') || value.contains('massage')) {
      return Icons.spa_outlined;
    }

    if (value.contains('doctor') ||
        value.contains('health') ||
        value.contains('clinic')) {
      return Icons.medical_services_outlined;
    }

    if (value.contains('clean')) {
      return Icons.cleaning_services_outlined;
    }

    if (value.contains('repair')) {
      return Icons.build_outlined;
    }

    return Icons.auto_awesome_rounded;
  }

  _StatusInfo _statusInfo(BuildContext context, String status) {
    final c = context.c;
    final value = status.toUpperCase();

    if (value == 'CONFIRMED') {
      return _StatusInfo(
        color: Colors.green.shade700,
        background: Colors.green.withValues(alpha: 0.12),
      );
    }

    if (value == 'COMPLETED') {
      return _StatusInfo(
        color: Colors.blue.shade700,
        background: Colors.blue.withValues(alpha: 0.11),
      );
    }

    if (value == 'CANCELLED' || value == 'REJECTED') {
      return _StatusInfo(
        color: Colors.red.shade700,
        background: Colors.red.withValues(alpha: 0.10),
      );
    }

    if (value == 'IN_PROGRESS' || value == 'STARTED') {
      return _StatusInfo(color: c.brand, background: c.brandSoft);
    }

    return _StatusInfo(
      color: const Color(0xFFB77900),
      background: const Color(0xFFFFF2CC),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Awaiting confirmation';

      case 'CONFIRMED':
        return 'Confirmed';

      case 'IN_PROGRESS':
      case 'STARTED':
        return 'In progress';

      case 'COMPLETED':
        return 'Completed';

      case 'CANCELLED':
        return 'Cancelled';

      case 'REJECTED':
        return 'Rejected';

      default:
        return _prettyStatus(status);
    }
  }

  String _prettyStatus(String value) {
    if (value.trim().isEmpty) {
      return 'Pending';
    }

    return value
        .toLowerCase()
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  void _showComingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action will be available soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// DATE TIME PANEL
// -----------------------------------------------------------------------------

class _DateTimePanel extends StatelessWidget {
  const _DateTimePanel({required this.booking});

  final BookingEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final start = _parseDate(booking.scheduledStartAt);

    final end = _parseDate(booking.scheduledEndAt);

    final day = start != null
        ? DateFormat('EEE').format(start).toUpperCase()
        : '--';

    final date = start != null ? DateFormat('dd').format(start) : '--';

    final month = start != null
        ? DateFormat('MMM').format(start).toUpperCase()
        : '---';

    final time = start != null ? DateFormat('HH:mm').format(start) : '--:--';

    final endTime = end != null ? DateFormat('HH:mm').format(end) : null;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          // Calendar
          Container(
            width: 56,
            height: 61,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    color: c.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  date,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: c.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      endTime != null ? '$time – $endTime' : time,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              booking.participants == 1
                  ? '1 person'
                  : '${booking.participants} people',
              style: TextStyle(
                color: c.brand,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(String value) {
    try {
      return DateTime.parse(value).toLocal();
    } catch (_) {
      return null;
    }
  }
}

// -----------------------------------------------------------------------------
// INFO LINE
// -----------------------------------------------------------------------------

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: c.brandSoft,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: c.brand),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textMuted,
                  fontFamily: 'Inter',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// STATUS BADGE
// -----------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 9.5,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ACTION BUTTON
// -----------------------------------------------------------------------------

class _BookingActionButton extends StatelessWidget {
  const _BookingActionButton({
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: onTap == null ? 0.6 : 1.0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: primary ? c.background : c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: c.textPrimary),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EMPTY
// -----------------------------------------------------------------------------

class _EmptyBookingsView extends StatelessWidget {
  const _EmptyBookingsView();

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: c.brand,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No bookings yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Your appointments will appear here once you make a booking.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ERROR
// -----------------------------------------------------------------------------

class _BookingErrorView extends StatelessWidget {
  const _BookingErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: c.brand,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Unable to load bookings',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                context.read<BookingCubit>().fetchBookings();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.brand,
                side: BorderSide(color: c.brand),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LOADING
// -----------------------------------------------------------------------------

class _BookingsLoadingView extends StatelessWidget {
  const _BookingsLoadingView();

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 25, 24, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Skeleton(width: 155, height: 27),
                const SizedBox(height: 9),
                _Skeleton(width: 245, height: 15),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: _Skeleton(height: 61)),
                    const SizedBox(width: 10),
                    Expanded(child: _Skeleton(height: 61)),
                  ],
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (_, __) {
              return Container(
                height: 295,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: c.border),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const _Skeleton(width: 44, height: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              _Skeleton(height: 16),
                              const SizedBox(height: 8),
                              _Skeleton(width: 130, height: 11),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Skeleton(height: 76),
                    const SizedBox(height: 14),
                    _Skeleton(height: 43),
                    const SizedBox(height: 14),
                    _Skeleton(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width = double.infinity, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.border.withValues(alpha: c.isDark ? 0.35 : 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STATUS MODEL
// -----------------------------------------------------------------------------

class _StatusInfo {
  const _StatusInfo({required this.color, required this.background});

  final Color color;
  final Color background;
}
