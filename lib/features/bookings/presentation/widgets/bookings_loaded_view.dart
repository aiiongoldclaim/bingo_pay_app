import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/bookings_entity.dart';
import '../cubit/booking_cubit.dart';
import 'booking_card.dart';
import 'booking_filter.dart';
import 'bookings_header.dart';
import 'empty_bookings_view.dart';
import 'filter_chips_row.dart';

class BookingsLoadedView extends StatelessWidget {
  const BookingsLoadedView({
    super.key,
    required this.bookings,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<BookingEntity> bookings;
  final BookingFilter filter;
  final ValueChanged<BookingFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final visible = bookings.where((booking) {
      return _matchesFilter(booking, filter);
    }).toList();

    return RefreshIndicator(
      color: colors.brand,
      backgroundColor: colors.surface,
      onRefresh: () async {
        await context.read<BookingCubit>().fetchBookings();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: BookingsHeader()),

          SliverToBoxAdapter(
            child: FilterChipsRow(
              selected: filter,
              onChanged: onFilterChanged,
            ),
          ),

          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyBookingsView(filter: filter),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(4.1.w, 0.71.h, 4.1.w, 4.74.h),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, __) {
                  return SizedBox(height: 1.66.h);
                },
                itemBuilder: (context, index) {
                  return BookingCard(booking: visible[index], index: index);
                },
              ),
            ),
        ],
      ),
    );
  }

  bool _matchesFilter(BookingEntity booking, BookingFilter filter) {
    final status = booking.status.toUpperCase();

    switch (filter) {
      case BookingFilter.all:
        return true;

      case BookingFilter.completed:
        return status == 'COMPLETED';

      case BookingFilter.cancelled:
        return status == 'CANCELLED' || status == 'REJECTED';

      case BookingFilter.rescheduled:
        return status == 'RESCHEDULED';
    }
  }
}
