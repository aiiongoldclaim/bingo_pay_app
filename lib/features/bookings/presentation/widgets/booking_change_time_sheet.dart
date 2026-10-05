import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../../domain/entities/bookings_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import 'booking_change_time_slots.dart';
import 'booking_details_metrics.dart';

/// Number of days (including today) fetched from the availability API.
const int _availabilityWindowDays = 7;

/// Opens a bottom sheet that loads the service availability for [booking]
/// and reschedules it to the slot the user picks.
Future<void> showBookingChangeTimeSheet(
  BuildContext context,
  BookingEntity booking,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider<AvailabilityCubit>(
      create: (_) => getIt<AvailabilityCubit>(),
      child: _BookingChangeTimeSheet(booking: booking),
    ),
  );
}

class _BookingChangeTimeSheet extends StatefulWidget {
  const _BookingChangeTimeSheet({required this.booking});

  final BookingEntity booking;

  @override
  State<_BookingChangeTimeSheet> createState() =>
      _BookingChangeTimeSheetState();
}

class _BookingChangeTimeSheetState extends State<_BookingChangeTimeSheet> {
  bool _rescheduling = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final format = DateFormat('yyyy-MM-dd');
    final today = DateTime.now();

    context.read<AvailabilityCubit>().loadAvailability(
          serviceUuid: widget.booking.service.uuid,
          offeringUuid: widget.booking.offering.uuid,
          participants:
              widget.booking.participants > 0 ? widget.booking.participants : 1,
          from: format.format(today),
          to: format.format(
            today.add(const Duration(days: _availabilityWindowDays - 1)),
          ),
        );
  }

  void _onSlotSelected(String slotUuid, BuildContext _) {
    if (_rescheduling) return;
    setState(() {
      _rescheduling = true;
      _error = null;
    });
    context
        .read<BookingCubit>()
        .rescheduleBooking(widget.booking.uuid, slotUuid);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return BlocListener<BookingCubit, BookingState>(
      listener: (context, state) {
        if (!_rescheduling) return;

        if (state is BookingRescheduleSuccess) {
          final messenger = ScaffoldMessenger.of(context);
          final bookingCubit = context.read<BookingCubit>();
          Navigator.of(context).pop();
          messenger.showSnackBar(
            const SnackBar(
              content: Text(AppStrings.bookingRescheduledTitle),
              behavior: SnackBarBehavior.floating,
            ),
          );
          bookingCubit.fetchBookings();
        }

        if (state is BookingRescheduleError) {
          setState(() {
            _rescheduling = false;
            _error = state.message;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(m.cardRadius),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          m.pagePadH,
          m.sectionTitleGap,
          m.pagePadH,
          m.pagePadBottom + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: m.sectionTitleGap),
            Text(
              widget.booking.service.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontSize: m.slotsHeaderTitleSize,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: m.sectionTitleGap),
            IgnorePointer(
              ignoring: _rescheduling,
              child: Opacity(
                opacity: _rescheduling ? 0.6 : 1,
                child: BlocBuilder<AvailabilityCubit, AvailabilityState>(
                  builder: (context, state) => BookingChangeTimeSlots(
                    availabilityState: state,
                    onSlotSelected: _onSlotSelected,
                  ),
                ),
              ),
            ),
            if (_rescheduling || _error != null) ...[
              SizedBox(height: m.actionsGap),
              Text(
                _rescheduling ? AppStrings.reschedulingYourBooking : _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _rescheduling ? colors.textMuted : colors.error,
                  fontFamily: 'Inter',
                  fontSize: m.reschedulingTextSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
