import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/order_mock_data.dart';

class OrderDateFilterChips extends StatelessWidget {
  final DateRangeFilter selected;
  final ValueChanged<DateRangeFilter> onSelected;

  const OrderDateFilterChips({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DateRangeFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final range = DateRangeFilter.values[index];
          final isSelected = range == selected;
          return ChoiceChip(
            label: Text(range.label),
            selected: isSelected,
            onSelected: (_) => onSelected(range),
            selectedColor: AppColors.primary,
            backgroundColor: const Color(0xFFF1F2F4),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            shape: const StadiumBorder(),
            side: BorderSide.none,
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
