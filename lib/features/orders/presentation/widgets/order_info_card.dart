import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({super.key, required this.tiles});

  final List<OrderInfoTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i != tiles.length - 1) Divider(height: 1, color: ThemeColors.line),
          ],
        ],
      ),
    );
  }
}

class OrderInfoTile extends StatelessWidget {
  const OrderInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
      child: Row(
        children: [
          Icon(icon, color: ThemeColors.blue, size: 20.sp),

          SizedBox(width: 3.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 14.sp,
                    color: ThemeColors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 0.2.h),

                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14.sp,
                    color: ThemeColors.inkDim,
                  ),
                ),
              ],
            ),
          ),

          ?trailing,
        ],
      ),
    );
  }
}
