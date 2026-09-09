import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_details_metrics.dart';

class BookingChangeTimeSlots extends StatelessWidget {
  const BookingChangeTimeSlots({
    super.key,
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
              AppStrings.loadingAvailableSlots,
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
              AppStrings.failedToLoadAvailability,
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
          AppStrings.noAvailableSlots,
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
                  AppStrings.pickANewTime,
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

                      return BookingDaySlots(
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

class BookingDaySlots extends StatelessWidget {
  const BookingDaySlots({
    super.key,
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
                    (slot) => BookingTimeSlotButton(
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

class BookingTimeSlotButton extends StatelessWidget {
  const BookingTimeSlotButton({
    super.key,
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
