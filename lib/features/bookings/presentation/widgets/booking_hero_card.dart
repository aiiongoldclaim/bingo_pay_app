import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import 'booking_details_formatters.dart';
import 'booking_details_metrics.dart';
import 'booking_status_pill.dart';

class BookingHeroCard extends StatelessWidget {
  const BookingHeroCard({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.heroRadius),
        border: Border.all(
          color: colors.border,
        ),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(
                    alpha: 0.055,
                  ),
                  blurRadius: m.heroShadowBlur,
                  offset: Offset(0, m.heroShadowOffsetY),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(m.heroRadius),
        child: Column(
          children: [
            Container(
              height: m.heroTopBarHeight,
              width: double.infinity,
              color: colors.brand,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                m.heroPadH,
                m.heroPadTop,
                m.heroPadH,
                m.heroPadBottom,
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: m.heroIconBox,
                        height: m.heroIconBox,
                        decoration: BoxDecoration(
                          color: colors.brandSoft,
                          borderRadius:
                              BorderRadius.circular(m.heroIconRadius),
                        ),
                        child: Icon(
                          Icons.content_cut_rounded,
                          size: m.heroIconSize,
                        ),
                      ),
                      SizedBox(width: m.heroTitleGapW),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.service.title.isNotEmpty
                                  ? booking.service.title
                                  : AppStrings.sectionService,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: AppTextStyles.titleLarge
                                  .copyWith(
                                color: colors.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight:
                                    FontWeight.w800,
                                letterSpacing: -0.35,
                              ),
                            ),
                            SizedBox(height: m.heroSubtitleGapH),
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
                                color: colors.textSecondary,
                                fontFamily: 'Inter',
                                fontSize: m.heroSubtitleSize,
                                fontWeight:
                                    FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: m.heroBadgeGapW),
                      BookingStatusPill(
                        label: formatBookingStatus(
                          booking.status,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: m.heroMetaGapH),
                  Container(
                    padding: EdgeInsets.all(m.heroMetaPad),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius:
                          BorderRadius.circular(m.heroMetaRadius),
                      border: Border.all(
                        color: colors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: HeroMetaTile(
                            icon: Icons
                                .confirmation_number_outlined,
                            label: AppStrings.bookingLabel,
                            value:
                                booking.bookingNumber,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: m.heroDividerHeight,
                          color: colors.border,
                        ),
                        Expanded(
                          child: HeroMetaTile(
                            icon:
                                Icons.people_outline_rounded,
                            label: AppStrings.participantsLabel,
                            value: AppStrings.participantsCountText(
                              booking.participants,
                            ),
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

class HeroMetaTile extends StatelessWidget {
  const HeroMetaTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.heroMetaHPad,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: m.heroMetaIconSize,
            color: colors.brand,
          ),
          SizedBox(width: m.heroMetaIconGapW),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.heroMetaLabelSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: m.heroMetaLabelGapH),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.heroMetaValueSize,
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
