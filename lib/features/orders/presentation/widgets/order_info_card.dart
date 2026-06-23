import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class OrderInfoCard extends StatelessWidget {
  const OrderInfoCard({
    super.key,
    required this.address,
    required this.payment,
    required this.invoiceNo,
    this.onDownloadInvoice,
  });

  final String address;
  final String payment;
  final String invoiceNo;
  final VoidCallback? onDownloadInvoice;

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
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: 'Delivery address',
            subtitle: address,
          ),

          Divider(height: 1, color: ThemeColors.line),

          _InfoTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment',
            subtitle: payment,
          ),

          Divider(height: 1, color: ThemeColors.line),

          _InfoTile(
            icon: Icons.receipt_long_outlined,
            title: 'Invoice',
            subtitle: invoiceNo,
            trailing: IconButton(
              onPressed: onDownloadInvoice,
              icon: Icon(
                Icons.download_rounded,
                color: ThemeColors.blue,
                size: 18.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
                    fontSize: 15.sp,
                    color: ThemeColors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 0.1.h),

                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.sp,
                    color: ThemeColors.inkDim,
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
