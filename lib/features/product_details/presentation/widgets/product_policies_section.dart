import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/product_details_model.dart';

/// Delivery, returns and warranty policy rows.
class ProductPoliciesSection extends StatelessWidget {
  final DeliveryInfo deliveryInfo;

  const ProductPoliciesSection({super.key, required this.deliveryInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
      color: ThemeColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _PolicyItem(
              icon: Icons.local_shipping_outlined,
              title: deliveryInfo.deliveryLabel,
              subtitle: deliveryInfo.deliverySubtitle,
            ),
            Divider(color: ThemeColors.line, height: 3.h),
            _PolicyItem(
              icon: Icons.refresh,
              title: deliveryInfo.returnLabel,
              subtitle: deliveryInfo.returnSubtitle,
            ),
            Divider(color: ThemeColors.line, height: 3.h),
            _PolicyItem(
              icon: Icons.verified_outlined,
              title: deliveryInfo.warrantyLabel,
              subtitle: deliveryInfo.warrantySubtitle,
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ThemeColors.blue, size: 20.sp),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14.sp, color: ThemeColors.inkDim),
            ),
          ],
        ),
      ],
    );
  }
}
