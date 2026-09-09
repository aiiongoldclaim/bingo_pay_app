import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../../domain/entities/booking_details_entity.dart';
import '../cubit/booking_cubit.dart';
import '../cubit/booking_state.dart';
import 'booking_cancel_dialog.dart';
import 'booking_change_time_slots.dart';
import 'booking_details_metrics.dart';
import 'booking_slide_to_cancel.dart';

class BookingBottomActions extends StatefulWidget {
  const BookingBottomActions({
    super.key,
    required this.booking,
  });

  final BookingDetailsEntity booking;

  @override
  State<BookingBottomActions> createState() =>
      _BookingBottomActionsState();
}

class _BookingBottomActionsState extends State<BookingBottomActions> {
  bool _isChangeTimeExpanded = false;
  late AvailabilityState _availabilityState;

  @override
  void initState() {
    super.initState();
    _availabilityState = const AvailabilityState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    final status = widget.booking.status.toUpperCase();

    final canCancel =
        status != 'CANCELLED' &&
        status != 'COMPLETED';

    return BlocListener<AvailabilityCubit, AvailabilityState>(
      listener: (context, state) {
        setState(() {
          _availabilityState = state;
        });
      },
      child: BlocBuilder<BookingCubit, BookingState>(
      buildWhen: (previous, current) {
        return current is BookingCancelLoading ||
            current is BookingCancelError ||
            current is BookingCancelSuccess ||
            current is BookingRescheduleLoading ||
            current is BookingRescheduleSuccess ||
            current is BookingRescheduleError ||
            current is BookingDetailLoaded;
      },
      builder: (context, state) {
        final isCancelling =
            state is BookingCancelLoading;
        final isRescheduling =
            state is BookingRescheduleLoading;

        final bookingStatus = widget.booking.status.toUpperCase();
        final canChangeTime = bookingStatus != 'CANCELLED' &&
                              bookingStatus != 'COMPLETED' &&
                              bookingStatus != 'RESCHEDULED';

        if (state is BookingRescheduleSuccess) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _isChangeTimeExpanded = false;
          });
        }

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              if (canChangeTime) ...[
                SizedBox(
                  width: double.infinity,
                  height: m.changeTimeBtnHeight,
                  child: OutlinedButton.icon(
                    onPressed: (isCancelling || isRescheduling)
                        ? null
                        : () {
                            setState(() {
                              _isChangeTimeExpanded =
                                  !_isChangeTimeExpanded;
                            });

                            if (_isChangeTimeExpanded &&
                                _availabilityState.status == AvailabilityStatus.initial) {
                              _loadAvailability(context);
                            }
                          },
                    icon: Icon(
                      Icons.sync_rounded,
                      size: m.changeTimeIconSize,
                    ),
                    label: const Text(
                      AppStrings.changeTimeCta,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.brand,
                      disabledForegroundColor:
                      colors.textMuted,
                      side: BorderSide(
                        color: colors.brand,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(m.changeTimeRadius),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: m.changeTimeFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              if (_isChangeTimeExpanded) ...[
                SizedBox(height: m.actionsGap),
                BookingChangeTimeSlots(
                  booking: widget.booking,
                  availabilityState: _availabilityState,
                  onSlotSelected: _onSlotSelected,
                ),
              ],
              if (canCancel && !_isChangeTimeExpanded) ...[
                SizedBox(height: m.actionsGap),
                IgnorePointer(
                  ignoring: isCancelling || isRescheduling,
                  child: Opacity(
                    opacity: isCancelling || isRescheduling
                        ? 0.65
                        : 1,
                    child: BookingSlideToCancel(
                      onCompleted: () {
                        _showCancelDialog(
                          context,
                          widget.booking,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: m.slideHintGapH),
                Text(
                  isCancelling
                      ? AppStrings.cancellingYourBooking
                      : AppStrings.slideAllTheWayToCancel,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.slideHintSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (isRescheduling) ...[
                SizedBox(height: m.actionsGap),
                Text(
                  AppStrings.reschedulingYourBooking,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: m.reschedulingTextSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      ),
    );
  }

  void _loadAvailability(BuildContext context) {
    context.read<AvailabilityCubit>().loadAvailability(
      serviceUuid: widget.booking.service.uuid,
      offeringUuid: widget.booking.offering.uuid,
      participants: widget.booking.participants,
    );
  }

  void _onSlotSelected(
    String slotUuid,
    BuildContext context,
  ) {
    context.read<BookingCubit>().rescheduleBooking(
      widget.booking.uuid,
      slotUuid,
    );
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    BookingDetailsEntity booking,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const BookingCancelDialog();
      },
    );

    if (!context.mounted) return;

    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    context.read<BookingCubit>().cancelBooking(
          booking.uuid,
          reason.trim(),
        );
  }
}
