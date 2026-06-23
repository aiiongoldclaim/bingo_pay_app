import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../product_categories_cubit/product_categories_state.dart';

/// Horizontal scrollable filter row:
/// [Filters] [Sort] [Under ₹20k] [4★ & up] …
class ListingFilterBar extends StatelessWidget {
  final SortOption selectedSort;
  final String? selectedPriceFilter;
  final String? selectedRatingFilter;
  final VoidCallback onFilterTap;
  final void Function(SortOption) onSortTap;
  final void Function(String) onPriceFilter;
  final void Function(String) onRatingFilter;

  const ListingFilterBar({
    super.key,
    required this.selectedSort,
    this.selectedPriceFilter,
    this.selectedRatingFilter,
    required this.onFilterTap,
    required this.onSortTap,
    required this.onPriceFilter,
    required this.onRatingFilter,
  });

  static const _priceFilters = ['Under ₹20k', '₹20k–₹50k', 'Above ₹50k'];
  static const _ratingFilters = ['4★ & up', '3★ & up'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.surface,
      padding: EdgeInsets.symmetric(vertical: 1.2.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          children: [
            // Filters button
            _ActionChip(label: 'Filters', icon: Icons.tune, onTap: onFilterTap),
            SizedBox(width: 2.w),
            // Sort button
            _ActionChip(
              label: 'Sort',
              icon: Icons.swap_vert,
              onTap: () => _showSortSheet(context),
            ),
            SizedBox(width: 2.w),
            // Price filters
            ..._priceFilters.map(
              (label) => Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: _FilterChip(
                  label: label,
                  isSelected: selectedPriceFilter == label,
                  onTap: () => onPriceFilter(label),
                ),
              ),
            ),
            // Rating filters
            ..._ratingFilters.map(
              (label) => Padding(
                padding: EdgeInsets.only(right: 2.w),
                child: _FilterChip(
                  label: label,
                  isSelected: selectedRatingFilter == label,
                  onTap: () => onRatingFilter(label),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SortSheet(
        selected: selectedSort,
        onSelect: (s) {
          Navigator.pop(context);
          onSortTap(s);
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: ThemeColors.ink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: ThemeColors.white, size: 14.sp),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: ThemeColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isSelected ? ThemeColors.blueSoft : ThemeColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ThemeColors.blue : ThemeColors.line,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? ThemeColors.blue : ThemeColors.inkMid,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final SortOption selected;
  final void Function(SortOption) onSelect;

  const _SortSheet({required this.selected, required this.onSelect});

  static const _options = [
    (SortOption.relevant, 'Most Relevant'),
    (SortOption.priceLow, 'Price: Low to High'),
    (SortOption.priceHigh, 'Price: High to Low'),
    (SortOption.rating, 'Highest Rated'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort by', style: AppTextStyles.titleLarge),
          SizedBox(height: 1.h),
          ..._options.map(
            (opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(opt.$2, style: AppTextStyles.bodyMedium),
              trailing: selected == opt.$1
                  ? const Icon(Icons.check, color: ThemeColors.blue)
                  : null,
              onTap: () => onSelect(opt.$1),
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}
