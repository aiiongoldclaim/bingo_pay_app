import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/bookings_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/booking_error_view.dart';
import '../widgets/booking_filter.dart';
import '../widgets/bookings_loaded_view.dart';
import '../widgets/bookings_loading_view.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<BookingCubit>().fetchBookings();

    return const _MyBookingsBody();
  }
}

class _MyBookingsBody extends StatefulWidget {
  const _MyBookingsBody();

  @override
  State<_MyBookingsBody> createState() => _MyBookingsBodyState();
}

class _MyBookingsBodyState extends State<_MyBookingsBody> {
  late List<BookingEntity> _lastLoadedBookings;
  bool _hasLoadedOnce = false;
  BookingFilter _filter = BookingFilter.all;

  @override
  void initState() {
    super.initState();
    _lastLoadedBookings = [];
  }

  void _onFilterChanged(BookingFilter value) {
    if (_filter == value) return;
    setState(() => _filter = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocBuilder<BookingCubit, BookingState>(
          builder: (context, state) {
            if (state is BookingListLoaded) {
              _lastLoadedBookings = state.bookings;
              _hasLoadedOnce = true;
              return BookingsLoadedView(
                bookings: state.bookings,
                filter: _filter,
                onFilterChanged: _onFilterChanged,
              );
            }

            if (state is BookingInitial || state is BookingLoading) {
              if (_hasLoadedOnce && _lastLoadedBookings.isNotEmpty) {
                return BookingsLoadedView(
                  bookings: _lastLoadedBookings,
                  filter: _filter,
                  onFilterChanged: _onFilterChanged,
                );
              }
              return const BookingsLoadingView();
            }

            if (state is BookingError) {
              if (_hasLoadedOnce && _lastLoadedBookings.isNotEmpty) {
                return BookingsLoadedView(
                  bookings: _lastLoadedBookings,
                  filter: _filter,
                  onFilterChanged: _onFilterChanged,
                );
              }
              return BookingErrorView(message: state.message);
            }

            if (_hasLoadedOnce && _lastLoadedBookings.isNotEmpty) {
              return BookingsLoadedView(
                bookings: _lastLoadedBookings,
                filter: _filter,
                onFilterChanged: _onFilterChanged,
              );
            }

            return const BookingsLoadingView();
          },
        ),
      ),
    );
  }
}
