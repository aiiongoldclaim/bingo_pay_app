import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_detail_card.dart';
import 'booking_details_formatters.dart';
import 'booking_details_metrics.dart';

class BookingAppointmentCard extends StatelessWidget {
  const BookingAppointmentCard({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    final start = parseApiDate(
      booking.scheduledStartAt,
    );

    final end = parseApiDate(
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

    return BookingDetailCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: m.apptBoxW,
                height: m.apptBoxH,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
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
                        color: colors.brand,
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
                        color: colors.textPrimary,
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
                        color: colors.textPrimary,
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
                          color: colors.brand,
                        ),
                        SizedBox(width: m.apptTimeIconGapW),
                        Expanded(
                          child: Text(
                            timeText,
                            style: TextStyle(
                              color: colors.textSecondary,
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
            color: colors.border,
          ),
          SizedBox(height: m.apptInfoGapH),
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: m.apptInfoIconSize,
                color: colors.textMuted,
              ),
              SizedBox(width: m.apptInfoIconGapW),
              Expanded(
                child: Text(
                  _appointmentMessage(booking),
                  style: TextStyle(
                    color: colors.textSecondary,
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
        return AppStrings.appointmentRescheduledMsg;
      case 'CANCELLED':
        return AppStrings.appointmentCancelledMsg;
      case 'COMPLETED':
        return AppStrings.appointmentCompletedMsg;
      default:
        return AppStrings.appointmentScheduledMsg;
    }
  }
}
