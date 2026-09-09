import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_detail_card.dart';
import 'booking_details_formatters.dart';
import 'booking_details_metrics.dart';

class BookingAddressCard extends StatelessWidget {
  const BookingAddressCard({
    super.key,
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

    return BookingDetailCard(
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
                      : AppStrings.addressFallback,
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
                    formatBookingPhone(address.phone),
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
