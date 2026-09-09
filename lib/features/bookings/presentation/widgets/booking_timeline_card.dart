import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_detail_card.dart';
import 'booking_details_formatters.dart';
import 'booking_details_metrics.dart';

class BookingTimelineCard extends StatelessWidget {
  const BookingTimelineCard({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);
    final timeline = booking.timeline;

    return BookingDetailCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.bookingTimeline,
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
              AppStrings.noTimelineEvents,
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

                return BookingTimelineItem(
                  title: _timelineTitle(
                    item.status,
                    item.note,
                  ),
                  subtitle: formatTimelineDate(
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
        return AppStrings.timelineBookingCreated;
      case 'RESCHEDULED':
        return AppStrings.timelineBookingRescheduled;
      case 'CONFIRMED':
        return AppStrings.timelineBookingConfirmed;
      case 'CHECKED_IN':
        return AppStrings.timelineCheckedIn;
      case 'STARTED':
        return AppStrings.timelineServiceStarted;
      case 'COMPLETED':
        return AppStrings.timelineServiceCompleted;
      case 'CANCELLED':
        return AppStrings.timelineBookingCancelled;
      default:
        if (note.isNotEmpty) {
          return note;
        }

        return formatBookingStatus(status);
    }
  }
}

class BookingTimelineItem extends StatelessWidget {
  const BookingTimelineItem({
    super.key,
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
