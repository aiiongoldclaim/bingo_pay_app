import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

class LowStockBanner extends StatelessWidget {
  final int count;
  final VoidCallback onManageTap;

  const LowStockBanner({super.key, required this.count, required this.onManageTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      onTap: onManageTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.warningTint,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colors.warningFg.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, color: context.colors.warningFg, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
                  children: [
                    TextSpan(text: '$count products are running low on stock. '),
                    TextSpan(
                      text: 'Manage inventory',
                      style: TextStyle(color: context.colors.warningFg, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.warningFg),
          ],
        ),
      ),
    );
  }
}
