import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_detail_card.dart';

class BookingServiceCard extends StatelessWidget {
  const BookingServiceCard({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final service = booking.service;
    final offering = booking.offering;

    return BookingDetailCard(
      child: Column(
        children: [
          BookingDetailRow(
            icon: Icons.auto_awesome_rounded,
            label: AppStrings.sectionService,
            value: service.title.isNotEmpty
                ? service.title
                : '-',
          ),
          const BookingDetailDivider(),
          BookingDetailRow(
            icon: Icons.cut_rounded,
            label: AppStrings.offeringLabel,
            value: offering.offeringName.isNotEmpty
                ? offering.offeringName
                : offering.title,
          ),
          const BookingDetailDivider(),
          BookingDetailRow(
            icon: Icons.timelapse_rounded,
            label: AppStrings.durationLabel,
            value:
                '${offering.durationMinutes > 0 ? offering.durationMinutes : service.durationMinutes} minutes',
          ),
        ],
      ),
    );
  }
}
