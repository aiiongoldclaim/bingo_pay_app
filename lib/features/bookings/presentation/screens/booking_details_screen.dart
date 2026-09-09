import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/booking_details_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import '../widgets/booking_details_content.dart';
import '../widgets/booking_details_error_view.dart';
import '../widgets/booking_details_loading_view.dart';
import '../widgets/booking_details_metrics.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({
    super.key,
    required this.bookingUuid,
  });

  final String bookingUuid;

  @override
  Widget build(BuildContext context) {
    context.read<BookingCubit>().fetchBookingDetails(bookingUuid);

    return _BookingDetailsView(
      bookingUuid: bookingUuid,
    );
  }
}



class _BookingDetailsView extends StatefulWidget {
  const _BookingDetailsView({
    required this.bookingUuid,
  });

  final String bookingUuid;

  @override
  State<_BookingDetailsView> createState() =>
      _BookingDetailsViewState();
}

class _BookingDetailsViewState
    extends State<_BookingDetailsView> {
  BookingDetailsEntity? _lastLoadedBooking;

  Future<void> _showRescheduleSuccessDialog(BuildContext context) async {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(m.dialogRadius),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: m.dialogIconBox,
                height: m.dialogIconBox,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.brand,
                  size: m.dialogIconSize,
                ),
              ),
              SizedBox(height: m.dialogGapLg),
              Text(
                AppStrings.bookingRescheduledTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogTitleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: m.dialogGapSm),
              Text(
                AppStrings.bookingRescheduledMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogBodySize,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog

                  // Refresh bookings list before navigating back
                  context.read<BookingCubit>().fetchBookings();

                  // Wait for the data to load
                  await Future.delayed(const Duration(milliseconds: 800));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                ),
                child: const Text(
                  AppStrings.backToBookings,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCancelSuccessDialog(BuildContext context) async {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(m.dialogRadius),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: m.dialogIconBox,
                height: m.dialogIconBox,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colors.brand,
                  size: m.dialogIconSize,
                ),
              ),
              SizedBox(height: m.dialogGapLg),
              Text(
                AppStrings.bookingCancelledTitle,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogTitleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: m.dialogGapSm),
              Text(
                AppStrings.bookingCancelledMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.dialogBodySize,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog

                  // Refresh bookings list before navigating back
                  context.read<BookingCubit>().fetchBookings();

                  // Wait for the data to load
                  await Future.delayed(const Duration(milliseconds: 800));

                  if (context.mounted) {
                    Navigator.of(context).pop(); // Go back to my bookings
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                ),
                child: const Text(
                  AppStrings.backToBookings,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: BlocConsumer<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state is BookingDetailLoaded) {
              _lastLoadedBooking = state.bookingDetails;
            }

            if (state is BookingCancelSuccess) {
              if (!mounted) return;

              _showCancelSuccessDialog(context);
            }

            if (state is BookingCancelError) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

            if (state is BookingRescheduleSuccess) {
              if (!mounted) return;

              _lastLoadedBooking = state.bookingDetails;

              _showRescheduleSuccessDialog(context);
            }

            if (state is BookingRescheduleError) {
              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {

            if (state is BookingDetailLoading) {
              final booking = _lastLoadedBooking;

              if (booking != null) {
                return BookingDetailsContent(
                  booking: booking,
                );
              }

              return const BookingDetailsLoadingView();
            }



            if (state is BookingDetailError) {
              return BookingDetailsErrorView(
                message: state.message,
                onRetry: () {
                  context
                      .read<BookingCubit>()
                      .fetchBookingDetails(widget.bookingUuid);
                },
              );
            }



            if (state is BookingDetailLoaded) {
              _lastLoadedBooking = state.bookingDetails;

              return BookingDetailsContent(
                booking: state.bookingDetails,
              );
            }



            if (state is BookingCancelLoading ||
                state is BookingCancelError ||
                state is BookingCancelSuccess ||
                state is BookingRescheduleLoading ||
                state is BookingRescheduleError ||
                state is BookingRescheduleSuccess) {
              final booking = _lastLoadedBooking;

              if (booking != null) {
                return BookingDetailsContent(
                  booking: booking,
                );
              }
            }



            if (_lastLoadedBooking != null) {
              return BookingDetailsContent(
                booking: _lastLoadedBooking!,
              );
            }

            return const BookingDetailsLoadingView();
          },
        ),
      ),
    );
  }
}
