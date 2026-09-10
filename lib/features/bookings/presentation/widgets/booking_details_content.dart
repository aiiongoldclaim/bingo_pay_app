import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import '../cubit/booking_cubit.dart';
import 'booking_address_card.dart';
import 'booking_appointment_card.dart';
import 'booking_bottom_actions.dart';
import 'booking_details_header.dart';
import 'booking_details_metrics.dart';
import 'booking_hero_card.dart';
import 'booking_information_card.dart';
import 'booking_payment_card.dart';
import 'booking_provider_card.dart';
import 'booking_section_title.dart';
import 'booking_service_card.dart';
import 'booking_timeline_card.dart';

class BookingDetailsContent extends StatelessWidget {
  const BookingDetailsContent({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return RefreshIndicator(
      color: colors.brand,
      backgroundColor: colors.surface,
      onRefresh: () {
        return context.read<BookingCubit>().fetchBookingDetails(booking.uuid);
      },
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: BookingDetailsHeader(
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            m.pagePadH,
            m.pagePadTop,
            m.pagePadH,
            m.pagePadBottom,
          ),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BookingHeroCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    BookingSectionTitle(
                      title: AppStrings.sectionAppointment,
                      icon: Icons.calendar_today_rounded,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    BookingAppointmentCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    BookingSectionTitle(
                      title: AppStrings.sectionService,
                      icon: Icons.auto_awesome_rounded,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    BookingServiceCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    BookingSectionTitle(
                      title: AppStrings.sectionProvider,
                      icon: Icons.storefront_rounded,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    BookingProviderCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    BookingSectionTitle(
                      title: AppStrings.sectionServiceAddress,
                      icon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    BookingAddressCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    BookingSectionTitle(
                      title: AppStrings.paymentLabel,
                      icon: Icons.payments_outlined,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    BookingPaymentCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    BookingSectionTitle(
                      title: AppStrings.sectionBookingInformation,
                      icon: Icons.receipt_long_outlined,
                    ),
                    SizedBox(height: m.sectionTitleGap),
                    BookingInformationCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.sectionGap),
                    BookingTimelineCard(
                      booking: booking,
                    ),
                    SizedBox(height: m.bottomActionsGap),
                    BookingBottomActions(
                      booking: booking,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }
}
