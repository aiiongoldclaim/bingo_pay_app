import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../data/models/product_details_model.dart';

class ProductPoliciesSection extends StatelessWidget {
  final DeliveryInfo deliveryInfo;

  const ProductPoliciesSection({super.key, required this.deliveryInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      color: ThemeColors.surface,
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            _buildPolicy(
              icon: Icons.local_shipping_outlined,
              title: deliveryInfo.deliveryLabel,
              subtitle: deliveryInfo.deliverySubtitle,
            ),

            Divider(color: ThemeColors.line, height: 3.h),

            _buildPolicy(
              icon: Icons.refresh_rounded,
              title: deliveryInfo.returnLabel,
              subtitle: deliveryInfo.returnSubtitle,
            ),

            Divider(color: ThemeColors.line, height: 3.h),

            _buildPolicy(
              icon: Icons.verified_outlined,
              title: deliveryInfo.warrantyLabel,
              subtitle: deliveryInfo.warrantySubtitle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicy({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: ThemeColors.blue, size: 20.sp),

        SizedBox(width: 4.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 0.3.h),

              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 13.sp,
                  color: ThemeColors.inkDim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
