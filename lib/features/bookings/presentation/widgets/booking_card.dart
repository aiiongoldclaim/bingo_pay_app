import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/pdf_file_handler.dart';
import '../../data/datasources/booking_remote_datasources.dart';
import '../../domain/entities/bookings_entity.dart';
import 'icon_line.dart';
import 'invoice_button.dart';
import 'meta_block.dart';
import 'schedule_line.dart';
import 'service_thumb.dart';
import 'status_badge.dart';

class BookingCard extends StatefulWidget {
  const BookingCard({super.key, required this.booking, required this.index});

  final BookingEntity booking;
  final int index;

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _generatingPdf = false;

  Future<void> _downloadInvoice() async {
    if (widget.booking.uuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.invoiceNotAvailable),
        ),
      );
      return;
    }

    setState(() => _generatingPdf = true);
    try {
      final invoice = await GetIt.I<BookingRemoteDatasources>().downloadInvoice(
        widget.booking.order.uuid,
      );
      await openOrSharePdf(invoice.bytes, invoice.filename);
    } catch (e, st) {
      debugPrint('[Booking Invoice] Download failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.invoiceDownloadFailed),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  void _openDetail() {
    context.pushNamed(
      AppRoutes.bookingDetailName,
      pathParameters: {'uuid': widget.booking.uuid},
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final status = _statusInfo(context, widget.booking.status);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openDetail,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: EdgeInsets.fromLTRB(3.59.w, 1.66.h, 3.59.w, 1.42.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ServiceThumb(booking: widget.booking),

                    SizedBox(width: 3.33.w),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.booking.service.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: colors.textPrimary,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16.sp,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.05.w),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  StatusBadge(
                                    icon: status.icon,
                                    label: _statusLabel(widget.booking.status),
                                    color: status.color,
                                    background: status.background,
                                  ),
                                  SizedBox(width: 0.77.w),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14.sp,
                                    color: colors.textMuted,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          if (widget.booking.offering.offeringName
                              .trim()
                              .isNotEmpty) ...[
                            SizedBox(height: 0.36.h),
                            Text(
                              widget.booking.offering.offeringName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.textSecondary,
                                fontFamily: 'Inter',
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ],

                          SizedBox(height: 1.07.h),

                          ScheduleLine(booking: widget.booking),

                          SizedBox(height: 0.71.h),

                          IconLine(
                            icon: Icons.location_on_outlined,
                            value: widget.booking.vendor.shopName,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 1.54.h),

                Container(height: 1, color: colors.border),

                SizedBox(height: 1.42.h),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 380;

                    final meta = Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: MetaBlock(
                            label: AppStrings.bookingIdLabel,
                            value: '#${widget.booking.bookingNumber}',
                          ),
                        ),
                        const MetaDivider(),
                        Expanded(
                          flex: 3,
                          child: MetaBlock(
                            label: AppStrings.participantsLabel,
                            value: '${widget.booking.participants}',
                            leading: Icons.people_alt_rounded,
                          ),
                        ),
                        const MetaDivider(),
                        Expanded(
                          flex: 4,
                          child: MetaBlock(
                            label: AppStrings.paymentLabel,
                            value: '₹ ${widget.booking.orderItem.totalAmount}',
                            pill: widget.booking.paymentMode,
                          ),
                        ),
                      ],
                    );

                    final action = SizedBox(
                      width: stacked ? double.infinity : 43.08.w,
                      child: InvoiceButton(
                        loading: _generatingPdf,
                        onTap: _generatingPdf ? null : _downloadInvoice,
                      ),
                    );

                    if (stacked) {
                      return Column(
                        children: [meta, SizedBox(height: 1.42.h), action],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: meta),
                        SizedBox(width: 3.08.w),
                        action,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _StatusInfo _statusInfo(BuildContext context, String status) {
    final colors = context.colors;
    final value = status.toUpperCase();

    if (value == 'COMPLETED') {
      return _StatusInfo(
        color: colors.statusSuccess,
        background: colors.statusSuccessSoft,
        icon: Icons.check_circle_rounded,
      );
    }

    if (value == 'CANCELLED' || value == 'REJECTED') {
      return _StatusInfo(
        color: colors.error,
        background: colors.error.withValues(alpha: 0.12),
        icon: Icons.cancel_rounded,
      );
    }

    if (value == 'RESCHEDULED') {
      return _StatusInfo(
        color: colors.brand,
        background: colors.brandSoft,
        icon: Icons.autorenew_rounded,
      );
    }

    if (value == 'CONFIRMED' || value == 'IN_PROGRESS' || value == 'STARTED') {
      return _StatusInfo(
        color: colors.brand,
        background: colors.brandSoft,
        icon: Icons.event_available_rounded,
      );
    }

    return _StatusInfo(
      color: colors.statusWarning,
      background: colors.statusWarningSoft,
      icon: Icons.schedule_rounded,
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return AppStrings.statusPending;

      case 'CONFIRMED':
        return AppStrings.statusUpcoming;

      case 'IN_PROGRESS':
      case 'STARTED':
        return AppStrings.statusInProgress;

      case 'COMPLETED':
        return AppStrings.statusCompleted;

      case 'CANCELLED':
        return AppStrings.statusCancelled;

      case 'REJECTED':
        return AppStrings.statusRejected;

      case 'RESCHEDULED':
        return AppStrings.statusRescheduled;

      default:
        return _prettyStatus(status);
    }
  }

  String _prettyStatus(String value) {
    if (value.trim().isEmpty) {
      return AppStrings.statusPending;
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
}

class _StatusInfo {
  const _StatusInfo({
    required this.color,
    required this.background,
    required this.icon,
  });

  final Color color;
  final Color background;
  final IconData icon;
}
