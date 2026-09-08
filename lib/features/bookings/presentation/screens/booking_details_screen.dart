import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../widgets/booking_details_metrics.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({
    super.key,
    required this.bookingUuid,
  });

  final String bookingUuid;

  @override
  Widget build(BuildContext context) {
    context.read<BookingCubit>().fetchBookingDetails(bookingUuid);

    return _BookingDetailsView(
      bookingUuid: bookingUuid,
    );
  }
}



class _BookingDetailsView extends StatefulWidget {
  const _BookingDetailsView({
    required this.bookingUuid,
  });

  final String bookingUuid;

  @override
  State<_BookingDetailsView> createState() =>
      _BookingDetailsViewState();
}

class _BookingDetailsViewState
    extends State<_BookingDetailsView> {
  BookingDetailsEntity? _lastLoadedBooking;

  Future<void> _showRescheduleSuccessDialog(BuildContext context) async {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(m.dialogRadius),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: m.dialogIconBox,
                height: m.dialogIconBox,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.brand,
                  size: m.dialogIconSize,
                ),
              ),
              SizedBox(height: m.dialogGapLg),
              Text(
                'Booking Rescheduled',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogTitleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: m.dialogGapSm),
              Text(
                'Your appointment has been rescheduled successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogBodySize,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog

                  // Refresh bookings list before navigating back
                  context.read<BookingCubit>().fetchBookings();

                  // Wait for the data to load
                  await Future.delayed(const Duration(milliseconds: 800));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                ),
                child: const Text(
                  'Back to Bookings',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancelSuccessDialog(BuildContext context) async {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(m.dialogRadius),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: m.dialogIconBox,
                height: m.dialogIconBox,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.brand,
                  size: m.dialogIconSize,
                ),
              ),
              SizedBox(height: m.dialogGapLg),
              Text(
                'Booking Cancelled',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogTitleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: m.dialogGapSm),
              Text(
                'Your booking has been cancelled successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogBodySize,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog

                  // Refresh bookings list before navigating back
                  context.read<BookingCubit>().fetchBookings();

                  // Wait for the data to load
                  await Future.delayed(const Duration(milliseconds: 800));

                  if (context.mounted) {
                    Navigator.of(context).pop(); // Go back to my bookings
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                ),
                child: const Text(
                  'Back to Bookings',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: BlocConsumer<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingDetailLoaded) {
              _lastLoadedBooking = state.bookingDetails;
            }

            if (state is BookingCancelSuccess) {
              if (!mounted) return;

              _showCancelSuccessDialog(context);
            }

            if (state is BookingCancelError) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is BookingRescheduleSuccess) {
              if (!mounted) return;

              _lastLoadedBooking = state.bookingDetails;

              _showRescheduleSuccessDialog(context);
            }

            if (state is BookingRescheduleError) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            // -----------------------------------------------------------------
            // Initial/detail loading
            //
            // If a booking is already loaded (e.g. pull-to-refresh re-triggers
            // fetchBookingDetails), keep it on screen so the RefreshIndicator's
            // own spinner is what the user sees, instead of swapping the whole
            // scroll view out for the skeleton and losing scroll position.
            // -----------------------------------------------------------------

            if (state is BookingDetailLoading) {
              final booking = _lastLoadedBooking;

              if (booking != null) {
                return _BookingDetailsContent(
                  booking: booking,
                );
              }

              return const _BookingDetailsLoading();
            }

            // -----------------------------------------------------------------
            // Detail error
            // -----------------------------------------------------------------

            if (state is BookingDetailError) {
              return _BookingDetailsError(
                message: state.message,
                onRetry: () {
                  context
                      .read<BookingCubit>()
                      .fetchBookingDetails(widget.bookingUuid);
                },
              );
            }

            // -----------------------------------------------------------------
            // Detail loaded
            // -----------------------------------------------------------------

            if (state is BookingDetailLoaded) {
              _lastLoadedBooking = state.bookingDetails;

              return _BookingDetailsContent(
                booking: state.bookingDetails,
              );
            }

            // -----------------------------------------------------------------
            // IMPORTANT:
            // During cancellation/rescheduling, keep the existing booking UI visible.
            // Do NOT replace the whole screen with loading.
            // -----------------------------------------------------------------

            if (state is BookingCancelLoading ||
                state is BookingCancelError ||
                state is BookingCancelSuccess ||
                state is BookingRescheduleLoading ||
                state is BookingRescheduleError ||
                state is BookingRescheduleSuccess) {
              final booking = _lastLoadedBooking;

              if (booking != null) {
                return _BookingDetailsContent(
                  booking: booking,
                );
              }
            }

            // -----------------------------------------------------------------
            // Fallback
            // -----------------------------------------------------------------

            if (_lastLoadedBooking != null) {
              return _BookingDetailsContent(
                booking: _lastLoadedBooking!,
              );
            }

            return const _BookingDetailsLoading();
          },
        ),
      ),
    );
  }
}



class _BookingDetailsContent extends StatelessWidget {
  const _BookingDetailsContent({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return RefreshIndicator(
      color: c.brand,
      backgroundColor: c.surface,
      onRefresh: () {
        return context.read<BookingCubit>().fetchBookingDetails(booking.uuid);
      },
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: _BookingDetailsHeader(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            m.pagePadH,
            m.pagePadTop,
            m.pagePadH,
            m.pagePadBottom,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BookingHeroCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    _SectionTitle(
                      title: 'Appointment',
                      icon: Icons.calendar_today_rounded,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    _AppointmentCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    _SectionTitle(
                      title: 'Service',
                      icon: Icons.auto_awesome_rounded,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    _ServiceCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    _SectionTitle(
                      title: 'Provider',
                      icon: Icons.storefront_rounded,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    _ProviderCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    _SectionTitle(
                      title: 'Service Address',
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    _AddressCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    _SectionTitle(
                      title: 'Payment',
                      icon: Icons.payments_outlined,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    _PaymentCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    _SectionTitle(
                      title: 'Booking Information',
                      icon: Icons.receipt_long_outlined,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    _BookingInformationCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    _TimelineCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.bottomActionsGap),
                    _BottomActions(
                      booking: booking,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}


class _BookingDetailsHeader extends StatelessWidget {
  const _BookingDetailsHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = BookingDetailsMetrics.of(context);

    return SizedBox(
      height: m.headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(m.headerPadLeft, 0, m.headerPadRight, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              splashRadius: m.headerBackSplash,
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: m.headerBackIconSize,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(width: m.headerTitleGapW),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Details',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontSize: m.headerTitleSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: m.headerTitleGapH),
                  Text(
                    'Review your appointment',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.headerSubtitleSize,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
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




class _BookingHeroCard extends StatelessWidget {
  const _BookingHeroCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.heroRadius),
        border: Border.all(
          color: c.border,
        ),
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(
                    alpha: 0.055,
                  ),
                  blurRadius: m.heroShadowBlur,
                  offset: Offset(0, m.heroShadowOffsetY),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(m.heroRadius),
        child: Column(
          children: [
            Container(
              height: m.heroTopBarHeight,
              width: double.infinity,
              color: c.brand,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                m.heroPadH,
                m.heroPadTop,
                m.heroPadH,
                m.heroPadBottom,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: m.heroIconBox,
                        height: m.heroIconBox,
                        decoration: BoxDecoration(
                          color: c.brandSoft,
                          borderRadius:
                              BorderRadius.circular(m.heroIconRadius),
                        ),
                        child: Icon(
                          Icons.content_cut_rounded,
                          size: m.heroIconSize,
                        ),
                      ),
                      SizedBox(width: m.heroTitleGapW),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.service.title.isNotEmpty
                                  ? booking.service.title
                                  : 'Service',
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: AppTextStyles.titleLarge
                                  .copyWith(
                                color: c.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: -0.35,
                              ),
                            ),
                            SizedBox(height: m.heroSubtitleGapH),
                            Text(
                              booking.offering.offeringName
                                      .isNotEmpty
                                  ? booking
                                      .offering.offeringName
                                  : booking.offering.title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall
                                  .copyWith(
                                color: c.textSecondary,
                                fontFamily: 'Inter',
                                fontSize: m.heroSubtitleSize,
                                fontWeight:
                                    FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: m.heroBadgeGapW),
                      _StatusBadge(
                        label: _formatStatus(
                          booking.status,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: m.heroMetaGapH),
                  Container(
                    padding: EdgeInsets.all(m.heroMetaPad),
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius:
                          BorderRadius.circular(m.heroMetaRadius),
                      border: Border.all(
                        color: c.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroMeta(
                            icon: Icons
                                .confirmation_number_outlined,
                            label: 'Booking',
                            value:
                                booking.bookingNumber,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: m.heroDividerHeight,
                          color: c.border,
                        ),
                        Expanded(
                          child: _HeroMeta(
                            icon:
                                Icons.people_outline_rounded,
                            label: 'Participants',
                            value:
                                '${booking.participants} ${booking.participants == 1 ? 'person' : 'people'}',
                          ),
                        ),
                      ],
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

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({
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
    final m = BookingDetailsMetrics.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.heroMetaHPad,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: m.heroMetaIconSize,
            color: c.brand,
          ),
          SizedBox(width: m.heroMetaIconGapW),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: c.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.heroMetaLabelSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: m.heroMetaLabelGapH),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.heroMetaValueSize,
                    fontWeight: FontWeight.w700,
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



class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: m.sectionIconSize,
          color: c.brand,
        ),
        SizedBox(width: m.sectionIconGapW),
        Text(
          title,
          style: TextStyle(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontSize: m.sectionTitleTextSize,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}



class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    final start = _parseApiDate(
      booking.scheduledStartAt,
    );

    final end = _parseApiDate(
      booking.scheduledEndAt,
    );

    final startDate = start ?? DateTime.now();
    final endDate = end;

    final dateText = DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(startDate);

    final timeText = endDate == null
        ? DateFormat('hh:mm a').format(startDate)
        : '${DateFormat('hh:mm a').format(startDate)} – ${DateFormat('hh:mm a').format(endDate)}';

    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: m.apptBoxW,
                height: m.apptBoxH,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  borderRadius:
                      BorderRadius.circular(m.apptBoxRadius),
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM')
                          .format(startDate)
                          .toUpperCase(),
                      style: TextStyle(
                        color: c.brand,
                        fontFamily: 'Inter',
                        fontSize: m.apptMonthSize,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    SizedBox(height: m.apptDateGapH),
                    Text(
                      DateFormat('dd').format(startDate),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontSize: m.apptDaySize,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: m.apptTextGapW),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontSize: m.apptDateTextSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: m.apptTimeGapH),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: m.apptTimeIconSize,
                          color: c.brand,
                        ),
                        SizedBox(width: m.apptTimeIconGapW),
                        Expanded(
                          child: Text(
                            timeText,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: m.apptTimeTextSize,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: m.apptDividerGapH),
          Container(
            height: 1,
            color: c.border,
          ),
          SizedBox(height: m.apptInfoGapH),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: m.apptInfoIconSize,
                color: c.textMuted,
              ),
              SizedBox(width: m.apptInfoIconGapW),
              Expanded(
                child: Text(
                  _appointmentMessage(booking),
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.apptInfoTextSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _appointmentMessage(
    BookingDetailsEntity booking,
  ) {
    switch (booking.status.toUpperCase()) {
      case 'RESCHEDULED':
        return 'This appointment was rescheduled.';
      case 'CANCELLED':
        return 'This appointment has been cancelled.';
      case 'COMPLETED':
        return 'This appointment has been completed.';
      default:
        return 'Your appointment is scheduled.';
    }
  }
}



class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final service = booking.service;
    final offering = booking.offering;

    return _Card(
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.auto_awesome_rounded,
            label: 'Service',
            value: service.title.isNotEmpty
                ? service.title
                : '-',
          ),
          const _Divider(),
          _DetailRow(
            icon: Icons.cut_rounded,
            label: 'Offering',
            value: offering.offeringName.isNotEmpty
                ? offering.offeringName
                : offering.title,
          ),
          const _Divider(),
          _DetailRow(
            icon: Icons.timelapse_rounded,
            label: 'Duration',
            value:
                '${offering.durationMinutes > 0 ? offering.durationMinutes : service.durationMinutes} minutes',
          ),
        ],
      ),
    );
  }
}



class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return _Card(
      child: Row(
        children: [
          Container(
            width: m.providerIconBox,
            height: m.providerIconBox,
            decoration: BoxDecoration(
              color: colors.brandSoft,
              borderRadius:
                  BorderRadius.circular(m.providerIconRadius),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: colors.brand,
              size: m.providerIconSize,
            ),
          ),
          SizedBox(width: m.providerTextGapW),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  booking.vendor.shopName.isNotEmpty
                      ? booking.vendor.shopName
                      : 'Service Provider',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.providerTitleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: m.providerSubtitleGapH),
                Text(
                  'Service provider',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.providerSubtitleSize,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            color: colors.brand,
            size: m.providerCheckSize,
          ),
        ],
      ),
    );
  }
}



class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);
    final address = booking.address;

    final addressParts = <String>[
      address.addressLine1,
      if (address.addressLine2 != null &&
          address.addressLine2!.trim().isNotEmpty)
        address.addressLine2!,
      if (address.city.isNotEmpty) address.city,
      if (address.state.isNotEmpty) address.state,
      if (address.country.isNotEmpty) address.country,
      if (address.postalCode.isNotEmpty)
        address.postalCode,
    ]
        .where(
          (value) => value.trim().isNotEmpty,
        )
        .toList();

    return _Card(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: m.addressIconBox,
            height: m.addressIconBox,
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius:
                  BorderRadius.circular(m.addressIconRadius),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: c.brand,
              size: m.addressIconSize,
            ),
          ),
          SizedBox(width: m.addressTextGapW),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  address.fullName.isNotEmpty
                      ? address.fullName
                      : 'Address',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.addressNameSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: m.addressLineGapH),
                Text(
                  addressParts.isNotEmpty
                      ? addressParts.join(', ')
                      : '-',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.addressLineSize,
                    height: 1.4,
                  ),
                ),
                if (address.phone.isNotEmpty) ...[
                  SizedBox(height: m.addressLineGapH),
                  Text(
                    _formatPhone(address.phone),
                    style: TextStyle(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.addressPhoneSize,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);
    final offering = booking.offering;

    final price = offering.salePrice != null &&
            offering.salePrice!.trim().isNotEmpty
        ? offering.salePrice!
        : offering.basePrice;

    final currency = offering.currency.isNotEmpty
        ? offering.currency
        : 'INR';

    final formattedPrice = _formatPrice(
      price,
      currency,
    );

    final paymentMode = booking.paymentMode
        .replaceAll('_', ' ')
        .toLowerCase();

    final paymentModeText = paymentMode.isEmpty
        ? 'Payment'
        : _capitalizeWords(paymentMode);

    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: m.addressIconBox,
                height: m.addressIconBox,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  borderRadius:
                      BorderRadius.circular(m.addressIconRadius),
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  color: colors.brand,
                  size: m.addressIconSize,
                ),
              ),
              SizedBox(width: m.addressTextGapW),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentModeText,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontSize: m.paymentModeSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: m.paymentStatusGapH),
                    Text(
                      _paymentStatusText(booking),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.paymentStatusSize,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedPrice,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: m.paymentPriceSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: m.paymentBannerGapH),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: m.paymentBannerHPad,
              vertical: m.paymentBannerVPad,
            ),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius:
                  BorderRadius.circular(m.paymentBannerRadius),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: m.paymentBannerIconSize,
                  color: colors.brand,
                ),
                SizedBox(width: m.paymentBannerIconGapW),
                Expanded(
                  child: Text(
                    booking.paymentMode.toUpperCase() ==
                            'PREPAID'
                        ? 'Paid via prepaid payment'
                        : 'Payment mode: ${booking.paymentMode}',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.paymentBannerTextSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _paymentStatusText(
    BookingDetailsEntity booking,
  ) {
    if (booking.paymentMode.toUpperCase() ==
        'PREPAID') {
      return 'Payment completed';
    }

    if (booking.service.allowPayAfterService) {
      return 'Pay after service';
    }

    return 'Payment information';
  }
}



class _BookingInformationCard extends StatelessWidget {
  const _BookingInformationCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.receipt_long_outlined,
            label: 'Booking number',
            value: booking.bookingNumber.isNotEmpty
                ? booking.bookingNumber
                : '-',
          ),
          const _Divider(),
          _DetailRow(
            icon: Icons.shopping_bag_outlined,
            label: 'Order number',
            value:
                booking.order.orderNumber.isNotEmpty
                    ? booking.order.orderNumber
                    : '-',
          ),
          const _Divider(),
          _DetailRow(
            icon: Icons.refresh_rounded,
            label: 'Reschedules',
            value:
                booking.rescheduleCount.toString(),
          ),
        ],
      ),
    );
  }
}



class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);
    final timeline = booking.timeline;

    return _Card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Timeline',
            style: TextStyle(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontSize: m.timelineTitleSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: m.timelineTitleGapH),
          if (timeline.isEmpty)
            Text(
              'No timeline events available.',
              style: TextStyle(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.timelineEmptySize,
              ),
            )
          else
            ...List.generate(
              timeline.length,
              (index) {
                final item = timeline[index];

                return _TimelineItem(
                  title: _timelineTitle(
                    item.status,
                    item.note,
                  ),
                  subtitle: _formatTimelineDate(
                    item.eventTime,
                  ),
                  active: true,
                  isLast:
                      index == timeline.length - 1,
                );
              },
            ),
        ],
      ),
    );
  }

  String _timelineTitle(
    String status,
    String note,
  ) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Booking created';
      case 'RESCHEDULED':
        return 'Booking rescheduled';
      case 'CONFIRMED':
        return 'Booking confirmed';
      case 'CHECKED_IN':
        return 'Checked in';
      case 'STARTED':
        return 'Service started';
      case 'COMPLETED':
        return 'Service completed';
      case 'CANCELLED':
        return 'Booking cancelled';
      default:
        if (note.isNotEmpty) {
          return note;
        }

        return _formatStatus(status);
    }
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.isLast,
  });

  final String title;
  final String subtitle;
  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: m.timelineDotColW,
          child: Column(
            children: [
              Container(
                width: m.timelineDotSize,
                height: m.timelineDotSize,
                decoration: BoxDecoration(
                  color: active
                      ? colors.brand
                      : colors.border,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: m.timelineLineH,
                  color: colors.border,
                ),
            ],
          ),
        ),
        SizedBox(width: m.timelineTextGapW),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: m.timelineItemPadBottom,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.timelineItemTitleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: m.timelineItemGapH),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.timelineItemSubtitleSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}



class _Card extends StatelessWidget {
  const _Card({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(
          color: colors.border,
        ),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(
                    alpha: 0.035,
                  ),
                  blurRadius: m.cardShadowBlur,
                  offset: Offset(0, m.cardShadowOffsetY),
                ),
              ],
      ),
      child: child,
    );
  }
}



class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Row(
      children: [
        Container(
          width: m.detailIconBox,
          height: m.detailIconBox,
          decoration: BoxDecoration(
            color: colors.brandSoft,
            borderRadius:
                BorderRadius.circular(m.detailIconRadius),
          ),
          child: Icon(
            icon,
            size: m.detailIconSize,
            color: colors.brand,
          ),
        ),
        SizedBox(width: m.detailGapW),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.detailLabelSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: m.detailGapW),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontSize: m.detailValueSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}


class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: m.dividerVPad,
      ),
      child: Container(
        height: 1,
        color: colors.border,
      ),
    );
  }
}



class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      constraints: BoxConstraints(
        maxWidth: m.badgeMaxWidth,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: m.badgeHPad,
        vertical: m.badgeVPad,
      ),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius:
            BorderRadius.circular(m.badgeRadius),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colors.brand,
          fontFamily: 'Inter',
          fontSize: m.badgeFontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}



class _BottomActions extends StatefulWidget {
  const _BottomActions({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  State<_BottomActions> createState() =>
      _BottomActionsState();
}

class _BottomActionsState extends State<_BottomActions> {
  bool _isChangeTimeExpanded = false;
  late AvailabilityState _availabilityState;

  @override
  void initState() {
    super.initState();
    _availabilityState = const AvailabilityState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    final status = widget.booking.status.toUpperCase();

    final canCancel =
        status != 'CANCELLED' &&
        status != 'COMPLETED';

    return BlocListener<AvailabilityCubit, AvailabilityState>(
      listener: (context, state) {
        setState(() {
          _availabilityState = state;
        });
      },
      child: BlocBuilder<BookingCubit, BookingState>(
      buildWhen: (previous, current) {
        return current is BookingCancelLoading ||
            current is BookingCancelError ||
            current is BookingCancelSuccess ||
            current is BookingRescheduleLoading ||
            current is BookingRescheduleSuccess ||
            current is BookingRescheduleError ||
            current is BookingDetailLoaded;
      },
      builder: (context, state) {
        final isCancelling =
            state is BookingCancelLoading;
        final isRescheduling =
            state is BookingRescheduleLoading;

        final bookingStatus = widget.booking.status.toUpperCase();
        final canChangeTime = bookingStatus != 'CANCELLED' &&
                              bookingStatus != 'COMPLETED' &&
                              bookingStatus != 'RESCHEDULED';

        if (state is BookingRescheduleSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _isChangeTimeExpanded = false;
          });
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              if (canChangeTime) ...[
                SizedBox(
                  width: double.infinity,
                  height: m.changeTimeBtnHeight,
                  child: OutlinedButton.icon(
                    onPressed: (isCancelling || isRescheduling)
                        ? null
                        : () {
                            setState(() {
                              _isChangeTimeExpanded =
                                  !_isChangeTimeExpanded;
                            });

                            if (_isChangeTimeExpanded &&
                                _availabilityState.status == AvailabilityStatus.initial) {
                              _loadAvailability(context);
                            }
                          },
                    icon: Icon(
                      Icons.sync_rounded,
                      size: m.changeTimeIconSize,
                    ),
                    label: const Text(
                      'Change time',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.brand,
                      disabledForegroundColor:
                      colors.textMuted,
                      side: BorderSide(
                        color: colors.brand,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(m.changeTimeRadius),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: m.changeTimeFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              if (_isChangeTimeExpanded) ...[
                SizedBox(height: m.actionsGap),
                _ChangeTimeSlots(
                  booking: widget.booking,
                  availabilityState: _availabilityState,
                  onSlotSelected: _onSlotSelected,
                ),
              ],
              if (canCancel && !_isChangeTimeExpanded) ...[
                SizedBox(height: m.actionsGap),
                IgnorePointer(
                  ignoring: isCancelling || isRescheduling,
                  child: Opacity(
                    opacity: isCancelling || isRescheduling
                        ? 0.65
                        : 1,
                    child: _SlideToCancel(
                      onCompleted: () {
                        _showCancelDialog(
                          context,
                          widget.booking,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: m.slideHintGapH),
                Text(
                  isCancelling
                      ? 'Cancelling your booking...'
                      : 'Slide all the way to cancel your booking',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.slideHintSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (isRescheduling) ...[
                SizedBox(height: m.actionsGap),
                Text(
                  'Rescheduling your booking...',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.reschedulingTextSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      ),
    );
  }

  void _loadAvailability(BuildContext context) {
    context.read<AvailabilityCubit>().loadAvailability(
      serviceUuid: widget.booking.service.uuid,
      offeringUuid: widget.booking.offering.uuid,
      participants: widget.booking.participants,
    );
  }

  void _onSlotSelected(
    String slotUuid,
    BuildContext context,
  ) {
    context.read<BookingCubit>().rescheduleBooking(
      widget.booking.uuid,
      slotUuid,
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    BookingDetailsEntity booking,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const _CancelBookingDialog();
      },
    );

    if (!context.mounted) return;

    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    context.read<BookingCubit>().cancelBooking(
          booking.uuid,
          reason.trim(),
        );
  }
}



class _ChangeTimeSlots extends StatelessWidget {
  const _ChangeTimeSlots({
    required this.booking,
    required this.availabilityState,
    required this.onSlotSelected,
  });

  final BookingDetailsEntity booking;
  final AvailabilityState availabilityState;
  final Function(String, BuildContext) onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);
    final state = availabilityState;

    if (state.status == AvailabilityStatus.loading) {
      return Container(
        padding: EdgeInsets.all(m.cardPad),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            SizedBox(
              height: m.slotsLoadingHeight,
              child: Center(
                child: SizedBox(
                  width: m.slotsSpinnerSize,
                  height: m.slotsSpinnerSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      c.brand,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: m.slotsMsgGapH),
            Text(
              'Loading available slots...',
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.slotsMsgSize,
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == AvailabilityStatus.error) {
      return Container(
        padding: EdgeInsets.all(m.cardPad),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: c.brand,
              size: m.slotsErrorIconSize,
            ),
            SizedBox(height: m.slotsMsgGapH),
            Text(
              'Failed to load availability',
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.slotsMsgSize,
              ),
            ),
          ],
        ),
      );
    }

    final availability = state.availability;
    if (availability == null || availability.days.isEmpty) {
      return Container(
        padding: EdgeInsets.all(m.cardPad),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: c.border),
        ),
        child: Text(
          'No available slots',
          style: TextStyle(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.slotsMsgSize,
          ),
        ),
      );
    }

    return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  m.slotsHeaderPadH,
                  m.slotsHeaderPadTop,
                  m.slotsHeaderPadH,
                  m.slotsHeaderPadBottom,
                ),
                child: Text(
                  'Pick a new time',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.slotsHeaderTitleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: m.slotsListHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: availability.days
                        .asMap()
                        .entries
                        .map((entry) {
                      final dayIndex = entry.key;
                      final day = entry.value;

                      return _DaySlots(
                        day: day,
                        booking: booking,
                        onSlotSelected:
                            onSlotSelected,
                        isFirst: dayIndex == 0,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
  }
}

class _DaySlots extends StatelessWidget {
  const _DaySlots({
    required this.day,
    required this.booking,
    required this.onSlotSelected,
    required this.isFirst,
  });

  final dynamic day;
  final BookingDetailsEntity booking;
  final Function(String, BuildContext)
      onSlotSelected;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    try {
      final dateTime = DateTime.parse(day.date).toLocal();
      final dateStr = DateFormat('EEE d MMM')
          .format(dateTime);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFirst)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: m.slotsHeaderPadH,
              ),
              child: Container(
                height: 1,
                color: c.border,
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              m.slotsHeaderPadH,
              m.slotsHeaderPadTop,
              m.slotsHeaderPadH,
              m.dayHeaderPadBottom,
            ),
            child: Text(
              dateStr,
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.dayLabelSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: m.slotsHeaderPadH,
            ),
            child: Wrap(
              spacing: m.daySlotsSpacing,
              runSpacing: m.daySlotsSpacing,
              children: day.slots
                  .map<Widget>(
                    (slot) => _TimeSlotButton(
                      slot: slot,
                      onPressed: () {
                        onSlotSelected(
                          slot.uuid,
                          context,
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          SizedBox(height: m.dayBottomGapH),
        ],
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}

class _TimeSlotButton extends StatelessWidget {
  const _TimeSlotButton({
    required this.slot,
    required this.onPressed,
  });

  final dynamic slot;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    final isAvailable = slot.remaining != null &&
        slot.remaining > 0;

    try {
      final start = DateTime.parse(
        slot.startsAt,
      ).toLocal();
      final timeStr = DateFormat('hh:mm a')
          .format(start);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable
              ? onPressed
              : null,
          borderRadius:
              BorderRadius.circular(m.slotRadius),
          child: Container(
            padding:
                EdgeInsets.symmetric(
              horizontal: m.slotHPad,
              vertical: m.slotVPad,
            ),
            decoration: BoxDecoration(
              color: isAvailable
                  ? c.brand.withValues(
                    alpha: 0.08,
                  )
                  : c.border.withValues(
                    alpha: 0.3,
                  ),
              borderRadius:
                  BorderRadius.circular(m.slotRadius),
              border: Border.all(
                color: isAvailable
                    ? c.brand.withValues(
                      alpha: 0.4,
                    )
                    : c.border,
              ),
            ),
            child: Text(
              timeStr,
              style: TextStyle(
                color: isAvailable
                    ? c.brand
                    : c.textMuted,
                fontFamily: 'Inter',
                fontSize: m.slotTextSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}



class _CancelBookingDialog extends StatefulWidget {
  const _CancelBookingDialog();

  @override
  State<_CancelBookingDialog> createState() =>
      _CancelBookingDialogState();
}

class _CancelBookingDialogState
    extends State<_CancelBookingDialog> {
  late final TextEditingController _reasonController;
  late final FocusNode _reasonFocusNode;

  String? _errorText;

  @override
  void initState() {
    super.initState();

    _reasonController = TextEditingController();
    _reasonFocusNode = FocusNode();

    _reasonController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorText != null &&
        _reasonController.text.trim().isNotEmpty) {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.removeListener(_clearError);
    _reasonController.dispose();
    _reasonFocusNode.dispose();

    super.dispose();
  }

  void _submit() {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      setState(() {
        _errorText =
            'Please enter a cancellation reason.';
      });

      _reasonFocusNode.requestFocus();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(reason);
  }

  void _close() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(m.dialogRadius),
      ),
      title: Text(
        'Cancel booking?',
        style: TextStyle(
          color: c.textPrimary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for cancellation.',
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.dialogBodySize,
              ),
            ),
            SizedBox(height: m.cancelFieldGapH),
            TextField(
              controller: _reasonController,
              focusNode: _reasonFocusNode,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Cancellation reason',
                errorText: _errorText,
                filled: true,
                fillColor: c.background,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: c.border,
                  ),
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: c.border,
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: c.brand,
                  ),
                ),
                errorBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: c.brand,
                  ),
                ),
                focusedErrorBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: c.brand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _close,
          child: Text(
            'Keep booking',
            style: TextStyle(
              color: c.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: c.brand,
          ),
          child: const Text(
            'Cancel booking',
          ),
        ),
      ],
    );
  }
}



class _SlideToCancel extends StatefulWidget {
  const _SlideToCancel({
    required this.onCompleted,
  });

  final VoidCallback onCompleted;

  @override
  State<_SlideToCancel> createState() =>
      _SlideToCancelState();
}

class _SlideToCancelState
    extends State<_SlideToCancel>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _completed = false;

  late final AnimationController _resetController;
  Animation<double>? _resetAnimation;

  @override
  void initState() {
    super.initState();

    _resetController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 420),
    );

    _resetController.addListener(_onResetAnimation);
  }

  void _onResetAnimation() {
    final animation = _resetAnimation;

    if (!mounted || animation == null) {
      return;
    }

    setState(() {
      _dragX = animation.value;
    });
  }

  @override
  void dispose() {
    _resetController
      ..removeListener(_onResetAnimation)
      ..dispose();

    super.dispose();
  }

  void _animateBack() {
    if (!mounted) return;

    _resetController.stop();

    final animation = Tween<double>(
      begin: _dragX,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _resetController,
        curve: Curves.elasticOut,
      ),
    );

    _resetAnimation = animation;

    _resetController
      ..reset()
      ..forward();
  }

  void _finish(double maxDrag) {
    if (_completed || !mounted) {
      return;
    }

    setState(() {
      _completed = true;
      _dragX = maxDrag;
    });

    Future.delayed(
      const Duration(milliseconds: 220),
      () {
        if (!mounted) return;

        widget.onCompleted();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);
    final handleSize = m.slideHandleSize;
    final horizontalPadding = m.slideHPad;

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        final maxDrag = (trackWidth -
                handleSize -
                (horizontalPadding * 2))
            .clamp(0.0, double.infinity);

        final progress = maxDrag <= 0
            ? 0.0
            : (_dragX / maxDrag)
                .clamp(0.0, 1.0);

        return Container(
          height: m.slideHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius:
                BorderRadius.circular(m.slideRadius),
            border: Border.all(
              color: c.border,
            ),
            boxShadow: c.isDark
                ? null
                : [
                    BoxShadow(
                      color: c.textPrimary.withValues(
                        alpha: 0.045,
                      ),
                      blurRadius: m.slideShadowBlur,
                      offset: Offset(0, m.slideShadowOffsetY),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(m.slideRadius),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  child: Container(
                    margin: EdgeInsets.all(
                      horizontalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius:
                          BorderRadius.circular(m.slideInnerRadius),
                    ),
                  ),
                ),
                Center(
                  child: AnimatedOpacity(
                    duration:
                        const Duration(milliseconds: 100),
                    opacity: (1 - progress * 2)
                        .clamp(0.0, 1.0),
                    child: Text(
                      'Slide to cancel',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.slideTextSize,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: m.slideChevronRightPad,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity:
                          (1 - progress).clamp(
                        0.0,
                        1.0,
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          _SlideChevron(
                            color: c.textMuted,
                            opacity: 0.25,
                          ),
                          _SlideChevron(
                            color: c.textMuted,
                            opacity: 0.45,
                          ),
                          _SlideChevron(
                            color: c.brand,
                            opacity: 0.75,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left:
                      horizontalPadding + _dragX,
                  top: horizontalPadding,
                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onHorizontalDragUpdate:
                        _completed
                            ? null
                            : (details) {
                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  _dragX =
                                      (_dragX +
                                              details
                                                  .delta
                                                  .dx)
                                          .clamp(
                                    0.0,
                                    maxDrag,
                                  );
                                });
                              },
                    onHorizontalDragEnd:
                        _completed
                            ? null
                            : (_) {
                                if (!mounted) {
                                  return;
                                }

                                final currentProgress =
                                    maxDrag <= 0
                                        ? 0.0
                                        : _dragX /
                                            maxDrag;

                                if (currentProgress >=
                                    0.82) {
                                  _finish(maxDrag);
                                } else {
                                  _animateBack();
                                }
                              },
                    child: AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds: 120,
                      ),
                      width: handleSize,
                      height: handleSize,
                      decoration:
                          BoxDecoration(
                        color: c.brand,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.brand.withValues(
                              alpha: 0.22,
                            ),
                            blurRadius: m.slideHandleShadowBlur,
                            offset:
                                Offset(0, m.slideHandleShadowOffsetY),
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration:
                            const Duration(
                          milliseconds: 150,
                        ),
                        child: _completed
                            ? Icon(
                                Icons.check_rounded,
                                key: const ValueKey(
                                  'completed',
                                ),
                                color: c.surface,
                                size: m.slideCheckIconSize,
                              )
                            : Icon(
                                Icons
                                    .arrow_forward_rounded,
                                key: const ValueKey(
                                  'arrow',
                                ),
                                color: c.surface,
                                size: m.slideArrowIconSize,
                              ),
                      ),
                    ),
                  ),
                ),
                if (_completed)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration:
                            BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(
                            m.slideRadius,
                          ),
                          border: Border.all(
                            color: c.brand.withValues(
                              alpha: 0.35,
                            ),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _SlideChevron extends StatelessWidget {
  const _SlideChevron({
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final m = BookingDetailsMetrics.of(context);

    return Opacity(
      opacity: opacity,
      child: Icon(
        Icons.chevron_right_rounded,
        size: m.chevronIconSize,
        color: color,
      ),
    );
  }
}



class _BookingDetailsLoading extends StatelessWidget {
  const _BookingDetailsLoading();

  @override
  Widget build(BuildContext context) {
    final m = BookingDetailsMetrics.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            m.loadingHeaderPadH,
            m.loadingHeaderPadTop,
            m.loadingHeaderPadH,
            m.loadingHeaderPadBottom,
          ),
          child: Row(
            children: [
              _LoadingBox(
                width: m.loadingAvatarBox,
                height: m.loadingAvatarBox,
                radius: m.loadingAvatarRadius,
              ),
              SizedBox(width: m.loadingAvatarGapW),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _LoadingBox(
                      width: m.loadingTitleWidth,
                      height: m.loadingTitleHeight,
                      radius: m.loadingTitleRadius,
                    ),
                    SizedBox(height: m.loadingTitleGapH),
                    _LoadingBox(
                      width: m.loadingSubWidth,
                      height: m.loadingSubHeight,
                      radius: m.loadingSubRadius,
                    ),
                  ],
                ),
              ),
              SizedBox(width: m.loadingAvatarGapW),
              _LoadingBox(
                width: m.loadingAvatarBox,
                height: m.loadingAvatarBox,
                radius: m.loadingAvatarRadius,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              m.loadingListPadH,
              m.loadingListPadTop,
              m.loadingListPadH,
              m.loadingListPadBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const _LoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const _LoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const _LoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const _LoadingCard(),
                SizedBox(height: m.loadingCardGapH),
                const _LoadingCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(m.loadingCardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.loadingCardRadius),
        border: Border.all(
          color: c.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _LoadingBox(
            width: m.loadingLine1Width,
            height: m.loadingLine1Height,
            radius: m.loadingLine1Radius,
          ),
          SizedBox(height: m.loadingGap1),
          _LoadingBox(
            width: double.infinity,
            height: m.loadingLine2Height,
            radius: m.loadingLine2Radius,
          ),
          SizedBox(height: m.loadingGap2),
          _LoadingBox(
            width: m.loadingLine3Width,
            height: m.loadingLine2Height,
            radius: m.loadingLine2Radius,
          ),
          SizedBox(height: m.loadingGap3),
          _LoadingBox(
            width: double.infinity,
            height: 1,
            radius: 1,
          ),
          SizedBox(height: m.loadingGap4),
          _LoadingBox(
            width: m.loadingLine4Width,
            height: m.loadingLine4Height,
            radius: m.loadingLine4Radius,
          ),
        ],
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.border.withValues(
          alpha: 0.45,
        ),
        borderRadius:
            BorderRadius.circular(radius),
      ),
    );
  }
}


class _BookingDetailsError extends StatelessWidget {
  const _BookingDetailsError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(m.cardPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.errorIconBox,
              height: m.errorIconBox,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: c.brand,
                size: m.errorIconSize,
              ),
            ),
            SizedBox(height: m.errorGap1),
            Text(
              'Unable to load booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontSize: m.errorTitleSize,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: m.errorGap2),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.errorBodySize,
                height: 1.4,
              ),
            ),
            SizedBox(height: m.errorGap3),
            SizedBox(
              height: m.errorBtnHeight,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.brand,
                  foregroundColor: c.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(m.errorBtnRadius),
                  ),
                ),
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


DateTime? _parseApiDate(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  try {
    return DateTime.parse(value).toLocal();
  } catch (_) {
    return null;
  }
}

String _formatTimelineDate(String value) {
  final date = _parseApiDate(value);

  if (date == null) {
    return value.isNotEmpty ? value : '-';
  }

  return DateFormat(
    'dd MMM yyyy • hh:mm a',
  ).format(date);
}

String _formatStatus(String value) {
  if (value.trim().isEmpty) {
    return '-';
  }

  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _capitalizeWords(String value) {
  return value
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _formatPhone(String phone) {
  if (phone.isEmpty) {
    return '-';
  }

  if (phone.startsWith('+')) {
    return phone;
  }

  return '+91 $phone';
}

String _formatPrice(
  String value,
  String currency,
) {
  final amount = double.tryParse(value);

  if (amount == null) {
    return value.isEmpty ? '-' : value;
  }

  final formatted = NumberFormat(
    '#,##0.##',
  ).format(amount);

  switch (currency.toUpperCase()) {
    case 'INR':
      return '₹$formatted';

    case 'USD':
      return '\$$formatted';

    case 'EUR':
      return '€$formatted';

    case 'GBP':
      return '£$formatted';

    default:
      return '$currency $formatted';
  }
}