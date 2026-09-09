import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_detail_card.dart';
import 'booking_details_metrics.dart';

class BookingProviderCard extends StatelessWidget {
  const BookingProviderCard({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return BookingDetailCard(
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
                      : AppStrings.serviceProviderFallback,
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
                  AppStrings.serviceProviderSubtitle,
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
