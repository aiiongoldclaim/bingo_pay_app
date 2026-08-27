

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/theme_colors.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import '../screens/service_checkout_screen.dart';

class AvailabilitySection extends StatefulWidget {
  final String serviceUuid;
  final String offeringUuid;

  const AvailabilitySection({
    super.key,
    required this.serviceUuid,
    required this.offeringUuid,
  });

  @override
  State<AvailabilitySection> createState() => _AvailabilitySectionState();
}

class _AvailabilitySectionState extends State<AvailabilitySection> {
  int selectedDateIndex = 0;

  String? selectedSlotUuid;
  String? selectedTime;
  String? selectedDisplayTime;

  // ===========================================================================
  // SELECTED BOOKING DATE
  // ===========================================================================

  String _getSelectedBookingDate(dynamic availability) {
    if (selectedDateIndex < 0 ||
        selectedDateIndex >= availability.days.length) {
      return '';
    }

    final dateString = availability.days[selectedDateIndex].date;

    try {
      final dateTime = DateTime.parse(dateString);

      return DateFormat('EEE dd MMM').format(dateTime);
    } catch (_) {
      return dateString;
    }
  }

  // ===========================================================================
  // SELECTED BOOKING TIME
  // ===========================================================================

  String _getSelectedBookingTime(dynamic availability) {
    if (selectedSlotUuid == null) {
      return '';
    }

    if (selectedDateIndex < 0 ||
        selectedDateIndex >= availability.days.length) {
      return '';
    }

    final selectedDay = availability.days[selectedDateIndex];

    for (final slot in selectedDay.slots) {
      if (slot.uuid != selectedSlotUuid) {
        continue;
      }

      return _getSlotDisplayTime(slot);
    }

    return selectedTime ?? selectedDisplayTime ?? '';
  }

  // ===========================================================================
  // SLOT START TIME
  // ===========================================================================

  DateTime? _getSlotStartTime(dynamic slot) {
    try {
      if (slot.startsAt == null || slot.startsAt.toString().trim().isEmpty) {
        return null;
      }

      return DateTime.parse(slot.startsAt.toString()).toLocal();
    } catch (e) {
      debugPrint('Error parsing slot startsAt: $e');
      return null;
    }
  }

  // ===========================================================================
  // SLOT END TIME
  // ===========================================================================

  DateTime? _getSlotEndTime(dynamic slot) {
    try {
      if (slot.endsAt == null || slot.endsAt.toString().trim().isEmpty) {
        return null;
      }

      return DateTime.parse(slot.endsAt.toString()).toLocal();
    } catch (e) {
      debugPrint('Error parsing slot endsAt: $e');
      return null;
    }
  }

  // ===========================================================================
  // SLOT DISPLAY TIME
  //
  // Always prefer startsAt + endsAt so the UI represents the actual
  // appointment interval returned by the API.
  // ===========================================================================

  String _getSlotDisplayTime(dynamic slot) {
    final start = _getSlotStartTime(slot);
    final end = _getSlotEndTime(slot);

    if (start != null && end != null) {
      final startText = DateFormat('hh:mm a').format(start);

      final endText = DateFormat('hh:mm a').format(end);

      return '$startText – $endText';
    }

    if (start != null) {
      return DateFormat('hh:mm a').format(start);
    }

    // Fallback to API-provided display value.
    try {
      if (slot.timeDisplay != null &&
          slot.timeDisplay.toString().trim().isNotEmpty) {
        return slot.timeDisplay.toString();
      }
    } catch (_) {}

    return 'N/A';
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailabilityCubit, AvailabilityState>(
      builder: (context, state) {
        // =====================================================================
        // LOADING
        // =====================================================================

        if (state.status == AvailabilityStatus.loading ||
            state.status == AvailabilityStatus.initial) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: const CircularProgressIndicator(),
            ),
          );
        }

        // =====================================================================
        // ERROR
        // =====================================================================

        if (state.status == AvailabilityStatus.error) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 8.w),
                SizedBox(height: 1.h),
                Text(
                  'Failed to load availability',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.5.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AvailabilityCubit>().loadAvailability(
                        serviceUuid: widget.serviceUuid,
                        offeringUuid: widget.offeringUuid,
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.2.h),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // =====================================================================
        // EMPTY
        // =====================================================================

        if (state.availability == null || state.availability!.days.isEmpty) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 6.w),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'No availability for this service',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final availability = state.availability!;

        // Protect against an invalid index.
        if (selectedDateIndex >= availability.days.length) {
          selectedDateIndex = 0;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // HEADER
            // =================================================================
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeColors.blue.withValues(alpha: 0.2),
                        ThemeColors.blue.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: ThemeColors.blue,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date & Time',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.black,
                        ),
                      ),
                      Text(
                        'Choose your preferred appointment slot',
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.5.h),

            // =================================================================
            // DATE SELECTOR
            // =================================================================
            SizedBox(
              height: 10.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availability.days.length,
                itemBuilder: (context, index) {
                  final day = availability.days[index];

                  final isSelected = index == selectedDateIndex;

                  try {
                    final dateTime = DateTime.parse(day.date);

                    final formattedDate = DateFormat(
                      'MMM\ndd',
                    ).format(dateTime);

                    final dayName = DateFormat('EEE').format(dateTime);

                    return GestureDetector(
                      onTap: () {
                        if (index == selectedDateIndex) {
                          return;
                        }

                        setState(() {
                          selectedDateIndex = index;

                          // A slot belongs to a specific
                          // date, therefore clear it when
                          // changing date.
                          selectedSlotUuid = null;
                          selectedTime = null;
                          selectedDisplayTime = null;
                        });
                      },
                      child: Container(
                        width: 19.w,
                        margin: EdgeInsets.only(right: 2.5.w),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    ThemeColors.blue,
                                    ThemeColors.blue.withValues(alpha: 0.8),
                                  ],
                                )
                              : LinearGradient(
                                  colors: [Colors.white, Colors.grey.shade50],
                                ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? ThemeColors.blue.withValues(alpha: 0.4)
                                  : Colors.grey.withValues(alpha: 0.1),
                              blurRadius: isSelected ? 12 : 6,
                              offset: Offset(0, isSelected ? 6 : 2),
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 0.8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.5.w,
                                vertical: 0.4.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : ThemeColors.blue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                formattedDate,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : ThemeColors.blue,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } catch (_) {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),

            SizedBox(height: 2.5.h),

            // =================================================================
            // TIME SLOTS
            // =================================================================
            if (selectedDateIndex < availability.days.length) ...[
              Text(
                'Available Time Slots',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.black,
                ),
              ),
              SizedBox(height: 1.5.h),
              _buildTimeSlotsByPeriod(
                availability.days[selectedDateIndex].slots,
              ),
            ],

            SizedBox(height: 2.h),

            // =================================================================
            // SELECTED APPOINTMENT
            // =================================================================
            if (selectedDateIndex < availability.days.length)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeColors.blue.withValues(alpha: 0.08),
                      ThemeColors.blue.withValues(alpha: 0.03),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ThemeColors.blue.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Appointment',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 1.3.h),
                    Row(
                      children: [
                        // -----------------------------------------------------
                        // DATE
                        // -----------------------------------------------------
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: ThemeColors.blue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.calendar_today_rounded,
                                  color: ThemeColors.blue,
                                  size: 4.5.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _formatDateDisplay(
                                        availability
                                            .days[selectedDateIndex]
                                            .date,
                                      ),
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: ThemeColors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 2.w),

                        // -----------------------------------------------------
                        // TIME
                        // -----------------------------------------------------
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: ThemeColors.blue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.access_time_rounded,
                                  color: ThemeColors.blue,
                                  size: 4.5.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      selectedDisplayTime ?? 'Select',
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: selectedDisplayTime != null
                                            ? ThemeColors.blue
                                            : Colors.grey.shade400,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            SizedBox(height: 3.h),

            // =================================================================
            // BOOK NOW
            // =================================================================
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: selectedSlotUuid != null
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeColors.blue,
                            ThemeColors.blue.withValues(alpha: 0.85),
                          ],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selectedSlotUuid != null
                      ? [
                          BoxShadow(
                            color: ThemeColors.blue.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: selectedSlotUuid != null
                        ? () {
                            final bookingDate = _getSelectedBookingDate(
                              availability,
                            );

                            final bookingTime = _getSelectedBookingTime(
                              availability,
                            );

                            debugPrint(
                              '========== BOOKING ==========\n'
                              'Service UUID: ${widget.serviceUuid}\n'
                              'Offering UUID: ${widget.offeringUuid}\n'
                              'Date: $bookingDate\n'
                              'Time: $bookingTime\n'
                              'Slot UUID: $selectedSlotUuid\n'
                              '=============================',
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceCheckoutScreen(
                                  serviceUuid: widget.serviceUuid,
                                  offeringUuid: widget.offeringUuid,
                                  bookingDate: bookingDate,
                                  bookingTime: bookingTime,
                                  slotUuid: selectedSlotUuid,
                                  participants: 1,
                                ),
                              ),
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.2.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (selectedSlotUuid != null)
                            Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 5.w,
                            ),
                          if (selectedSlotUuid != null) SizedBox(width: 1.5.w),
                          Text(
                            selectedSlotUuid != null
                                ? 'Book Now'
                                : 'Select a Time Slot',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // GROUP TIME SLOTS
  //
  // IMPORTANT:
  // The grouping uses the SAME local time that is displayed to the user.
  // ===========================================================================

  Widget _buildTimeSlotsByPeriod(List<dynamic> slots) {
    final earlyMorning = <dynamic>[];
    final morning = <dynamic>[];
    final afternoon = <dynamic>[];
    final evening = <dynamic>[];
    final night = <dynamic>[];

    for (final slot in slots) {
      final startTime = _getSlotStartTime(slot);

      if (startTime == null) {
        continue;
      }

      final hour = startTime.hour;

      if (hour >= 0 && hour < 6) {
        earlyMorning.add(slot);
      } else if (hour >= 6 && hour < 12) {
        morning.add(slot);
      } else if (hour >= 12 && hour < 17) {
        afternoon.add(slot);
      } else if (hour >= 17 && hour < 21) {
        evening.add(slot);
      } else {
        night.add(slot);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (earlyMorning.isNotEmpty) ...[
          _buildPeriodSection(
            '🌙 Early Morning',
            '12:00 AM - 6:00 AM',
            earlyMorning,
          ),
          SizedBox(height: 2.h),
        ],

        if (morning.isNotEmpty) ...[
          _buildPeriodSection('🌅 Morning', '6:00 AM - 12:00 PM', morning),
          SizedBox(height: 2.h),
        ],

        if (afternoon.isNotEmpty) ...[
          _buildPeriodSection('☀️ Afternoon', '12:00 PM - 5:00 PM', afternoon),
          SizedBox(height: 2.h),
        ],

        if (evening.isNotEmpty) ...[
          _buildPeriodSection('🌆 Evening', '5:00 PM - 9:00 PM', evening),
          SizedBox(height: 2.h),
        ],

        if (night.isNotEmpty)
          _buildPeriodSection('🌃 Night', '9:00 PM - 12:00 AM', night),
      ],
    );
  }

  // ===========================================================================
  // PERIOD SECTION
  // ===========================================================================

  Widget _buildPeriodSection(
    String title,
    String timeRange,
    List<dynamic> slots,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.3.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade50, Colors.grey.shade100],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.black,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                timeRange,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 1.5.h),

        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 1.5.h,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];

            final isSelected = slot.uuid == selectedSlotUuid;

            // ===============================================================
            // ACTUAL INTERVAL
            // ===============================================================

            final displayTime = _getSlotDisplayTime(slot);

            return GestureDetector(
              onTap: slot.isAvailable
                  ? () {
                      setState(() {
                        selectedSlotUuid = slot.uuid;

                        // Store the COMPLETE interval,
                        // not only the start time.
                        selectedTime = displayTime;

                        selectedDisplayTime = displayTime;
                      });

                      debugPrint(
                        'Selected slot:\n'
                        'UUID: ${slot.uuid}\n'
                        'Time: $displayTime\n'
                        'Starts: ${slot.startsAt}\n'
                        'Ends: ${slot.endsAt}',
                      );
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeColors.blue,
                            ThemeColors.blue.withValues(alpha: 0.85),
                          ],
                        )
                      : slot.isAvailable
                      ? LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade100, Colors.grey.shade50],
                        ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : slot.isAvailable
                        ? ThemeColors.blue.withValues(alpha: 0.2)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? ThemeColors.blue.withValues(alpha: 0.4)
                          : slot.isAvailable
                          ? ThemeColors.blue.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.05),
                      blurRadius: isSelected ? 10 : 4,
                      offset: Offset(0, isSelected ? 4 : 1),
                      spreadRadius: isSelected ? 1 : 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // =========================================================
                    // COMPLETE TIME INTERVAL
                    // =========================================================
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Text(
                        displayTime,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : slot.isAvailable
                              ? ThemeColors.blue
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),

                    SizedBox(height: 0.7.h),

                    if (slot.isAvailable)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.4.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : ThemeColors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${slot.remaining} available',
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: isSelected ? Colors.white : ThemeColors.blue,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Fully Booked',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // DATE DISPLAY
  // ===========================================================================

  String _formatDateDisplay(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);

      return DateFormat('EEEE, MMM dd, yyyy').format(dateTime);
    } catch (_) {
      return dateString;
    }
  }

  // ===========================================================================
  // BOOKING CONFIRMATION
  // ===========================================================================

  void _showBookingConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking confirmed for $selectedTime',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: ThemeColors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
