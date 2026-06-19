import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/order_mock_data.dart';

class OrderStatusTabs extends StatelessWidget {
  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onSelected;

  const OrderStatusTabs({super.key, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _StatusTab(label: 'All', isSelected: selected == null, onTap: () => onSelected(null)),
          for (final status in OrderStatus.values)
            _StatusTab(
              label: status.label,
              isSelected: selected == status,
              onTap: () => onSelected(status),
            ),
        ],
      ),
    );
  }
}

class _StatusTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusTab({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 28,
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
