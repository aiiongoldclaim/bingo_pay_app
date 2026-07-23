import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/product_mock_data.dart';

/// Opens the product filter bottom sheet. Returns the chosen filter,
/// or null if the sheet was dismissed without applying.
Future<ProductFilter?> showProductFilterSheet(
  BuildContext context, {
  required ProductFilter selected,
}) {
  return showModalBottomSheet<ProductFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _ProductFilterSheet(initial: selected),
  );
}

class _ProductFilterSheet extends StatefulWidget {
  final ProductFilter initial;

  const _ProductFilterSheet({required this.initial});

  @override
  State<_ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<_ProductFilterSheet> {
  late ProductFilter _selected = widget.initial;

  (IconData, Color) _iconFor(ProductFilter filter) => switch (filter) {
        ProductFilter.all => (Icons.apps_rounded, AppColors.primary),
        ProductFilter.active => (Icons.check_circle_outline, AppColors.success),
        ProductFilter.pending => (Icons.hourglass_top_rounded, context.colors.warningFg),
        ProductFilter.draft => (Icons.edit_note_outlined, context.colors.textSecondary),
        ProductFilter.rejected => (Icons.cancel_outlined, AppColors.error),
        ProductFilter.outOfStock => (Icons.remove_shopping_cart_outlined, AppColors.error),
      };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.md,
          AppDimensions.sm,
          AppDimensions.md,
          AppDimensions.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selected == ProductFilter.all
                      ? null
                      : () => setState(() => _selected = ProductFilter.all),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              'PRODUCT STATUS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            ...ProductFilter.values.map((filter) {
              final isSelected = filter == _selected;
              final (icon, color) = _iconFor(filter);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.xs + 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  onTap: () => setState(() => _selected = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.sm + 4,
                      vertical: AppDimensions.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: color),
                        const SizedBox(width: AppDimensions.sm + 4),
                        Expanded(
                          child: Text(
                            filter.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: isSelected ? AppColors.primary : context.colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: AppDimensions.sm),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(_selected),
              child: const Text(
                'Apply Filter',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
