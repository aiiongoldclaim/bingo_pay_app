import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/order_mock_data.dart';

typedef OrderFilterResult = ({OrderStatus? status, DateRangeFilter dateRange});

/// Opens the order filter bottom sheet. Returns the chosen status + date
/// range, or null if the sheet was dismissed without applying.
Future<OrderFilterResult?> showOrderFilterSheet(
  BuildContext context, {
  required OrderStatus? status,
  required DateRangeFilter dateRange,
}) {
  return showModalBottomSheet<OrderFilterResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _OrderFilterSheet(status: status, dateRange: dateRange),
  );
}

class _OrderFilterSheet extends StatefulWidget {
  final OrderStatus? status;
  final DateRangeFilter dateRange;

  const _OrderFilterSheet({required this.status, required this.dateRange});

  @override
  State<_OrderFilterSheet> createState() => _OrderFilterSheetState();
}

class _OrderFilterSheetState extends State<_OrderFilterSheet> {
  late OrderStatus? _status = widget.status;
  late DateRangeFilter _dateRange = widget.dateRange;

  bool get _isDefault =>
      _status == null && _dateRange == DateRangeFilter.all;

  (IconData, Color) _iconFor(OrderStatus? status) => switch (status) {
        null => (Icons.apps_rounded, AppColors.primary),
        OrderStatus.pending => (Icons.hourglass_top_rounded, context.colors.warningFg),
        OrderStatus.confirmed => (Icons.thumb_up_alt_outlined, AppColors.primary),
        OrderStatus.processing => (Icons.autorenew_rounded, AppColors.accentPurple),
        OrderStatus.shipped => (Icons.local_shipping_outlined, AppColors.primary),
        OrderStatus.delivered => (Icons.check_circle_outline, AppColors.success),
      };

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: context.colors.textSecondary,
      ),
    );
  }

  Widget _statusTile(OrderStatus? status) {
    final isSelected = status == _status;
    final (icon, color) = _iconFor(status);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.xs + 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: () => setState(() => _status = status),
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
              color: isSelected ? AppColors.primary : context.colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppDimensions.sm + 4),
              Expanded(
                child: Text(
                  status?.label ?? 'All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: isSelected ? AppColors.primary : context.colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
                    onPressed: _isDefault
                        ? null
                        : () => setState(() {
                              _status = null;
                              _dateRange = DateRangeFilter.all;
                            }),
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.xs),
              _sectionLabel('ORDER STATUS'),
              const SizedBox(height: AppDimensions.sm),
              _statusTile(null),
              ...OrderStatus.values.map(_statusTile),
              const SizedBox(height: AppDimensions.sm),
              _sectionLabel('DATE RANGE'),
              const SizedBox(height: AppDimensions.sm),
              Wrap(
                spacing: AppDimensions.sm,
                runSpacing: AppDimensions.sm,
                children: DateRangeFilter.values.map((range) {
                  final isSelected = range == _dateRange;
                  return ChoiceChip(
                    label: Text(range.label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _dateRange = range),
                    selectedColor: AppColors.primary,
                    backgroundColor: context.colors.inputFill,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : context.colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: const StadiumBorder(),
                    side: BorderSide.none,
                    showCheckmark: false,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.md),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                onPressed: () => Navigator.of(context)
                    .pop((status: _status, dateRange: _dateRange)),
                child: const Text(
                  'Apply Filter',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
