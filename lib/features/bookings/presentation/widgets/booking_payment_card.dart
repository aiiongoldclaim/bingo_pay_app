import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_detail_card.dart';
import 'booking_details_formatters.dart';
import 'booking_details_metrics.dart';

class BookingPaymentCard extends StatelessWidget {
  const BookingPaymentCard({
    super.key,
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

    final formattedPrice = formatBookingPrice(
      price,
      currency,
    );

    final paymentMode = booking.paymentMode
        .replaceAll('_', ' ')
        .toLowerCase();

    final paymentModeText = paymentMode.isEmpty
        ? AppStrings.paymentLabel
        : capitalizeBookingWords(paymentMode);

    return BookingDetailCard(
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
                        ? AppStrings.paidViaPrepaidPayment
                        : AppStrings.paymentModeText(booking.paymentMode),
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
      return AppStrings.paymentCompletedStatus;
    }

    if (booking.service.allowPayAfterService) {
      return AppStrings.payAfterServiceStatus;
    }

    return AppStrings.paymentInformationStatus;
  }
}
