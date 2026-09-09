import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'booking_filter.dart';

class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({super.key, required this.selected, required this.onChanged});

  final BookingFilter selected;
  final ValueChanged<BookingFilter> onChanged;

  static const _labels = <BookingFilter, String>{
    BookingFilter.all: AppStrings.bookingFilterAll,
    BookingFilter.completed: AppStrings.bookingFilterCompleted,
    BookingFilter.cancelled: AppStrings.bookingFilterCancelled,
    BookingFilter.rescheduled: AppStrings.bookingFilterRescheduled,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 5.45.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(4.1.w, 0, 4.1.w, 0),
        itemCount: _labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 2.31.w),
        itemBuilder: (context, index) {
          final entry = _labels.entries.elementAt(index);

          return BookingFilterChip(
            label: entry.value,
            active: entry.key == selected,
            onTap: () => onChanged(entry.key),
          );
        },
      ),
    );
  }
}

class BookingFilterChip extends StatelessWidget {
  const BookingFilterChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4.62.w),
          decoration: BoxDecoration(
            color: active ? colors.brand : colors.brandSoft,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: active ? colors.brand : colors.border),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? colors.onBrand : colors.brand,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}
