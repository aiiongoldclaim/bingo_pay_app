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
          color: AppColors.warningTint,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(color: Color(0xFFF8DDB0), shape: BoxShape.circle),
              child: const Icon(Icons.inventory_2_outlined, color: Color(0xFFB36B00), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    TextSpan(text: '$count products are running low on stock. '),
                    const TextSpan(
                      text: 'Manage inventory',
                      style: TextStyle(color: Color(0xFFB36B00), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB36B00)),
          ],
        ),
      ),
    );
  }
}
