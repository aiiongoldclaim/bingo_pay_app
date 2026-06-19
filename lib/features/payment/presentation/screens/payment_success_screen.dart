import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../cubit/payment_cubit.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Color(0xFF1E3A8A),
            statusBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: const Color(0xFF1E3A8A),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
                      child: Column(
                        children: [
                          SizedBox(height: 5.h),

                          // Success Icon
                          Container(
                            width: 85,
                            height: 85,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 55,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),

                          SizedBox(height: AppDimensions.lg),

                          Text(
                            'Payment successful',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),

                          SizedBox(height: AppDimensions.sm),

                          Text(
                            'Order #${state.orderId} • ${state.formattedTotal} paid',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white70,
                            ),
                          ),

                          SizedBox(height: AppDimensions.lg),

                          // Coins Earned
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.lg,
                              vertical: AppDimensions.sm,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeColors.accent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.currency_bitcoin,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: AppDimensions.sm),
                                Text(
                                  '+${state.coinsEarned} BINGOLD coins earned',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppDimensions.xl),

                          // Invoice Card
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(AppDimensions.md),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('BINGO Pay', style: AppTextStyles.titleLarge),
                                          Text(
                                            'Tax Invoice • GSTIN 27ABCDE1234F1Z5',
                                            style: AppTextStyles.bodySmall,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('Invoice no.', style: AppTextStyles.labelMedium),
                                          Text(
                                            'INV-${state.orderId.substring(3)}',
                                            style: AppTextStyles.titleMedium,
                                          ),
                                          Text('12 Jun 2026', style: AppTextStyles.bodySmall),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1, color: AppColors.line),

                                Padding(
                                  padding: EdgeInsets.all(AppDimensions.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('BILLED TO', style: AppTextStyles.labelMedium),
                                      SizedBox(height: AppDimensions.xs),
                                      Text(
                                        'Aarav Mehta\n14 Lotus Residency, Bandra West,\nMumbai 400050',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1, color: AppColors.line),

                                Padding(
                                  padding: EdgeInsets.all(AppDimensions.md),
                                  child: Column(
                                    children: [
                                      _buildItemRow('Aurora Pro Wireless Headphones', 'Qty 1 • incl. 18% GST', '₹18,990'),
                                      _buildItemRow('Velvet Runner Knit Sneakers', 'Qty 1 • incl. 18% GST', '₹6,490'),
                                      _buildItemRow('Nimbus Smart Desk Lamp', 'Qty 1 • incl. 18% GST', '₹3,490'),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1, color: AppColors.line),

                                Padding(
                                  padding: EdgeInsets.all(AppDimensions.md),
                                  child: Column(
                                    children: [
                                      _buildSummaryRow('Subtotal', '₹28,980'),
                                      _buildSummaryRow('Discount & coins', '- ₹6,338', isGreen: true),
                                      _buildSummaryRow('Delivery', 'FREE', isGreen: true),
                                      const Divider(height: 24),
                                      _buildSummaryRow('Amount paid', state.formattedTotal, isBold: true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Buttons
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppDimensions.md,
                      AppDimensions.lg,
                      AppDimensions.md,
                      AppDimensions.xl,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Invoice'),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
                              side: const BorderSide(color: AppColors.line),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invoice downloaded')),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: AppDimensions.md),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.local_shipping_outlined),
                            label: const Text('Track order'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeColors.blue,
                              padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                              ),
                            ),
                            onPressed: () {
                              // TODO: Navigate to tracking screen
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemRow(String name, String subtitle, String price) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.titleMedium),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(price, style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount, {bool isGreen = false, bool isBold = false}) {
    final textColor = isGreen ? ThemeColors.green : ThemeColors.ink;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          Text(
            amount,
            style: isBold
                ? AppTextStyles.titleMedium.copyWith(color: textColor)
                : AppTextStyles.bodyMedium.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}