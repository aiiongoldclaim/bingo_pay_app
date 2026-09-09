import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_detail_card.dart';

class BookingInformationCard extends StatelessWidget {
  const BookingInformationCard({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    return BookingDetailCard(
      child: Column(
        children: [
          BookingDetailRow(
            icon: Icons.receipt_long_outlined,
            label: AppStrings.bookingNumberLabel,
            value: booking.bookingNumber.isNotEmpty
                ? booking.bookingNumber
                : '-',
          ),
          const BookingDetailDivider(),
          BookingDetailRow(
            icon: Icons.shopping_bag_outlined,
            label: AppStrings.orderNumberLabel,
            value:
                booking.order.orderNumber.isNotEmpty
                    ? booking.order.orderNumber
                    : '-',
          ),
          const BookingDetailDivider(),
          BookingDetailRow(
            icon: Icons.refresh_rounded,
            label: AppStrings.reschedulesLabel,
            value:
                booking.rescheduleCount.toString(),
          ),
        ],
      ),
    );
  }
}
