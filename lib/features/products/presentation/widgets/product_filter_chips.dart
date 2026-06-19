import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/product_mock_data.dart';

class ProductFilterChips extends StatelessWidget {
  final ProductFilter selected;
  final ValueChanged<ProductFilter> onSelected;

  const ProductFilterChips({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ProductFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = ProductFilter.values[index];
          final isSelected = filter == selected;
          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => onSelected(filter),
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
