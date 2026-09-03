


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

// -----------------------------------------------------------------------------
// MAIN VIEW
// -----------------------------------------------------------------------------

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
    final c = context.c;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: c.brand,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Rescheduled',
                style: TextStyle(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment has been rescheduled successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 12,
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
                  backgroundColor: c.brand,
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
    final c = context.c;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: c.brand,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Cancelled',
                style: TextStyle(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your booking has been cancelled successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 12,
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
                  backgroundColor: c.brand,
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
            // -----------------------------------------------------------------

            if (state is BookingDetailLoading) {
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

// -----------------------------------------------------------------------------
// MAIN CONTENT
// -----------------------------------------------------------------------------

class _BookingDetailsContent extends StatelessWidget {
  const _BookingDetailsContent({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _BookingDetailsHeader(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            20,
            4,
            20,
            40,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                _BookingHeroCard(
                  booking: booking,
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Appointment',
                  icon: Icons.calendar_today_rounded,
                ),
                const SizedBox(height: 10),
                _AppointmentCard(
                  booking: booking,
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Service',
                  icon: Icons.auto_awesome_rounded,
                ),
                const SizedBox(height: 10),
                _ServiceCard(
                  booking: booking,
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Provider',
                  icon: Icons.storefront_rounded,
                ),
                const SizedBox(height: 10),
                _ProviderCard(
                  booking: booking,
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Service Address',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 10),
                _AddressCard(
                  booking: booking,
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Payment',
                  icon: Icons.payments_outlined,
                ),
                const SizedBox(height: 10),
                _PaymentCard(
                  booking: booking,
                ),
                const SizedBox(height: 18),
                const _SectionTitle(
                  title: 'Booking Information',
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 10),
                _BookingInformationCard(
                  booking: booking,
                ),
                const SizedBox(height: 18),
                _TimelineCard(
                  booking: booking,
                ),
                const SizedBox(height: 24),
                _BottomActions(
                  booking: booking,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HEADER
// -----------------------------------------------------------------------------

class _BookingDetailsHeader extends StatelessWidget {
  const _BookingDetailsHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        16,
      ),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Details',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Review your appointment',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          _HeaderButton(
            icon: Icons.more_horiz_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: c.border,
            ),
            boxShadow: c.isDark
                ? null
                : [
                    BoxShadow(
                      color: c.textPrimary.withValues(
                        alpha: 0.04,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Icon(
            icon,
            size: 17,
            color: c.textPrimary,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HERO
// -----------------------------------------------------------------------------

class _BookingHeroCard extends StatelessWidget {
  const _BookingHeroCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(25),
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
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [
            Container(
              height: 5,
              width: double.infinity,
              color: c.brand,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                19,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: c.brandSoft,
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.content_cut_rounded,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 14),
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
                            const SizedBox(height: 5),
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
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(
                        label: _formatStatus(
                          booking.status,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius:
                          BorderRadius.circular(17),
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
                          height: 32,
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

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: c.brand,
          ),
          const SizedBox(width: 8),
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
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 11,
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

// -----------------------------------------------------------------------------
// SECTION TITLE
// -----------------------------------------------------------------------------

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

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: c.brand,
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: TextStyle(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// APPOINTMENT
// -----------------------------------------------------------------------------

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

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
                width: 62,
                height: 68,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  borderRadius:
                      BorderRadius.circular(16),
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
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd').format(startDate),
                      style: TextStyle(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: c.brand,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            timeText,
                            style: TextStyle(
                              color: c.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 12,
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
          const SizedBox(height: 15),
          Container(
            height: 1,
            color: c.border,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: c.textMuted,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _appointmentMessage(booking),
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 11,
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

// -----------------------------------------------------------------------------
// SERVICE
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// PROVIDER
// -----------------------------------------------------------------------------

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return _Card(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius:
                  BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: c.brand,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
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
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Service provider',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.verified_rounded,
            color: c.brand,
            size: 19,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADDRESS
// -----------------------------------------------------------------------------

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: c.brand,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  addressParts.isNotEmpty
                      ? addressParts.join(', ')
                      : '-',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    height: 1.4,
                  ),
                ),
                if (address.phone.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    _formatPhone(address.phone),
                    style: TextStyle(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: 11,
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

// -----------------------------------------------------------------------------
// PAYMENT
// -----------------------------------------------------------------------------

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  color: c.brand,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentModeText,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _paymentStatusText(booking),
                      style: TextStyle(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedPrice,
                style: TextStyle(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: c.brand,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    booking.paymentMode.toUpperCase() ==
                            'PREPAID'
                        ? 'Paid via prepaid payment'
                        : 'Payment mode: ${booking.paymentMode}',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: 10.5,
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

// -----------------------------------------------------------------------------
// BOOKING INFORMATION
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// TIMELINE
// -----------------------------------------------------------------------------

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final timeline = booking.timeline;

    return _Card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Timeline',
            style: TextStyle(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          if (timeline.isEmpty)
            Text(
              'No timeline events available.',
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: 11,
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
    final c = context.c;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: active
                      ? c.brand
                      : c.border,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: 43,
                  color: c.border,
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 18,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 10.5,
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

// -----------------------------------------------------------------------------
// COMMON CARD
// -----------------------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: c.border,
        ),
        boxShadow: c.isDark
            ? null
            : [
                BoxShadow(
                  color: c.textPrimary.withValues(
                    alpha: 0.035,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// DETAIL ROW
// -----------------------------------------------------------------------------

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
    final c = context.c;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c.brandSoft,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 15,
            color: c.brand,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// DIVIDER
// -----------------------------------------------------------------------------

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Container(
        height: 1,
        color: c.border,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STATUS
// -----------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      constraints: const BoxConstraints(
        maxWidth: 95,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: c.brand,
          fontFamily: 'Inter',
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BOTTOM ACTIONS
// -----------------------------------------------------------------------------

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
    final c = context.c;

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
                  height: 46,
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
                    icon: const Icon(
                      Icons.sync_rounded,
                      size: 17,
                    ),
                    label: const Text(
                      'Change time',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.brand,
                      disabledForegroundColor:
                          c.textMuted,
                      side: BorderSide(
                        color: c.brand,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              if (_isChangeTimeExpanded) ...[
                const SizedBox(height: 14),
                _ChangeTimeSlots(
                  booking: widget.booking,
                  availabilityState: _availabilityState,
                  onSlotSelected: _onSlotSelected,
                ),
              ],
              if (canCancel && !_isChangeTimeExpanded) ...[
                const SizedBox(height: 14),
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
                const SizedBox(height: 7),
                Text(
                  isCancelling
                      ? 'Cancelling your booking...'
                      : 'Slide all the way to cancel your booking',
                  style: TextStyle(
                    color: c.textMuted,
                    fontFamily: 'Inter',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (isRescheduling) ...[
                const SizedBox(height: 14),
                Text(
                  'Rescheduling your booking...',
                  style: TextStyle(
                    color: c.textMuted,
                    fontFamily: 'Inter',
                    fontSize: 11,
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

// -----------------------------------------------------------------------------
// CHANGE TIME SLOTS
// -----------------------------------------------------------------------------

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
    final state = availabilityState;

    if (state.status == AvailabilityStatus.loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                      c.brand,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loading available slots...',
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    if (state.status == AvailabilityStatus.error) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: c.border),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: c.brand,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load availability',
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    final availability = state.availability;
    if (availability == null || availability.days.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: c.border),
        ),
        child: Text(
          'No available slots',
          style: TextStyle(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: 11,
          ),
        ),
      );
    }

    return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: c.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  8,
                ),
                child: Text(
                  'Pick a new time',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: 320,
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

    try {
      final dateTime = DateTime.parse(day.date).toLocal();
      final dateStr = DateFormat('EEE d MMM')
          .format(dateTime);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFirst)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Container(
                height: 1,
                color: c.border,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              10,
            ),
            child: Text(
              dateStr,
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
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
          const SizedBox(height: 4),
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
              BorderRadius.circular(12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
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
                  BorderRadius.circular(12),
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
                fontSize: 11,
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

// CANCEL DIALOG
// -----------------------------------------------------------------------------
//
// IMPORTANT:
// The TextEditingController belongs to this StatefulWidget.
// It is created in initState() and disposed ONLY in dispose().
// It is therefore never disposed while the dialog route is rebuilding.
// -----------------------------------------------------------------------------

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

    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),
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
                      BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: c.border,
                  ),
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: c.border,
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: c.brand,
                  ),
                ),
                errorBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: c.brand,
                  ),
                ),
                focusedErrorBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
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

// -----------------------------------------------------------------------------
// SLIDE TO CANCEL
// -----------------------------------------------------------------------------

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

  static const double _handleSize = 50;
  static const double _horizontalPadding = 4;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;

        final maxDrag = (trackWidth -
                _handleSize -
                (_horizontalPadding * 2))
            .clamp(0.0, double.infinity);

        final progress = maxDrag <= 0
            ? 0.0
            : (_dragX / maxDrag)
                .clamp(0.0, 1.0);

        return Container(
          height: 58,
          width: double.infinity,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius:
                BorderRadius.circular(30),
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
                      blurRadius: 18,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(30),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(
                      _horizontalPadding,
                    ),
                    decoration: BoxDecoration(
                      color: c.background,
                      borderRadius:
                          BorderRadius.circular(26),
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
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
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
                      _horizontalPadding + _dragX,
                  top: _horizontalPadding,
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
                      width: _handleSize,
                      height: _handleSize,
                      decoration:
                          BoxDecoration(
                        color: c.brand,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: c.brand.withValues(
                              alpha: 0.22,
                            ),
                            blurRadius: 12,
                            offset:
                                const Offset(0, 4),
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
                                size: 22,
                              )
                            : Icon(
                                Icons
                                    .arrow_forward_rounded,
                                key: const ValueKey(
                                  'arrow',
                                ),
                                color: c.surface,
                                size: 21,
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
                            30,
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

// -----------------------------------------------------------------------------
// CHEVRON
// -----------------------------------------------------------------------------

class _SlideChevron extends StatelessWidget {
  const _SlideChevron({
    required this.color,
    required this.opacity,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: color,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// LOADING
// -----------------------------------------------------------------------------

class _BookingDetailsLoading extends StatelessWidget {
  const _BookingDetailsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            16,
          ),
          child: Row(
            children: [
              const _LoadingBox(
                width: 42,
                height: 42,
                radius: 13,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: const [
                    _LoadingBox(
                      width: 150,
                      height: 18,
                      radius: 6,
                    ),
                    SizedBox(height: 7),
                    _LoadingBox(
                      width: 110,
                      height: 11,
                      radius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const _LoadingBox(
                width: 42,
                height: 42,
                radius: 13,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _LoadingCard(),
                SizedBox(height: 18),
                _LoadingCard(),
                SizedBox(height: 18),
                _LoadingCard(),
                SizedBox(height: 18),
                _LoadingCard(),
                SizedBox(height: 18),
                _LoadingCard(),
                SizedBox(height: 18),
                _LoadingCard(),
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: c.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: const [
          _LoadingBox(
            width: 130,
            height: 15,
            radius: 6,
          ),
          SizedBox(height: 16),
          _LoadingBox(
            width: double.infinity,
            height: 12,
            radius: 5,
          ),
          SizedBox(height: 10),
          _LoadingBox(
            width: 220,
            height: 12,
            radius: 5,
          ),
          SizedBox(height: 20),
          _LoadingBox(
            width: double.infinity,
            height: 1,
            radius: 1,
          ),
          SizedBox(height: 18),
          _LoadingBox(
            width: 160,
            height: 11,
            radius: 5,
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

// -----------------------------------------------------------------------------
// ERROR
// -----------------------------------------------------------------------------

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

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: c.brand,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.brand,
                  foregroundColor: c.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(24),
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

// -----------------------------------------------------------------------------
// HELPERS
// -----------------------------------------------------------------------------

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