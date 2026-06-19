import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../cubit/payment_cubit.dart';
import 'payment_success_screen.dart';

class ReviewPayScreen extends StatelessWidget {
  const ReviewPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.surface,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: Text(
                'Review & Pay',
                style: AppTextStyles.titleLarge,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: ThemeColors.ink),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimensions.lg),

                  // Paying With Section
                  _buildPayingWithSection(state,context),

                  SizedBox(height: AppDimensions.xl),

                  // Order Summary
                  _buildOrderSummary(state),

                  SizedBox(height: AppDimensions.lg),

                  // Security Note
                  Row(
                    children: [
                      Icon(Icons.verified_user, color: ThemeColors.green, size: 20.sp),
                      SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          '100% secure payment • PCI-DSS encrypted',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppDimensions.md),

                  // Payment Logos
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('VISA ', style: TextStyle(color: ThemeColors.inkMid)),
                      Text('UPI ', style: TextStyle(color: ThemeColors.inkMid)),
                      Text('RuPay ', style: TextStyle(color: ThemeColors.inkMid)),
                      Text('Mastercard', style: TextStyle(color: ThemeColors.inkMid)),
                    ],
                  ),

                  SizedBox(height: AppDimensions.xxl),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: state.isProcessing
                          ? null
                          : () async {
                              final cubit = context.read<PaymentCubit>();
                              await cubit.makePayment();

                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: cubit,
                                      child: const PaymentSuccessScreen(),
                                    ),
                                  ),
                                  (route) => route.isFirst,
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                        ),
                      ),
                      child: state.isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Pay ${state.formattedTotal}',
                              style: AppTextStyles.buttonText,
                            ),
                    ),
                  ),

                  SizedBox(height: AppDimensions.xxl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPayingWithSection(PaymentState state, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAYING WITH',
            style: AppTextStyles.labelLarge.copyWith(color: ThemeColors.inkMid),
          ),
          SizedBox(height: AppDimensions.md),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: ThemeColors.blue,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: AppDimensions.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BINGOLD Wallet', style: AppTextStyles.titleMedium),
                    Text(
                      'Balance ${state.formattedWalletBalance}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Change', style: AppTextStyles.labelLarge),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.md),

          // Remaining Amount Banner
          Container(
            padding: EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on, color: ThemeColors.accentInk, size: 20.sp),
                SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    'Wallet covers ${state.formattedWalletBalance} • remaining ${state.formattedRemaining} via UPI',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(PaymentState state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order summary', style: AppTextStyles.titleLarge),

          SizedBox(height: AppDimensions.md),

          _buildSummaryRow('Item total', '₹${state.itemTotal.toStringAsFixed(0)}'),
          _buildSummaryRow('Savings', '- ₹${state.savings.toStringAsFixed(0)}', isGreen: true),
          _buildSummaryRow(
            'Delivery',
            state.deliveryCharge == 0 ? 'FREE' : '₹${state.deliveryCharge}',
            isGreen: true,
          ),
          _buildSummaryRow('Taxes & fees', '₹${state.taxes.toStringAsFixed(0)}'),
          const Divider(height: 32),

          _buildSummaryRow('Total', state.formattedTotal, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount, {bool isGreen = false, bool isBold = false}) {
    final color = isGreen ? ThemeColors.green : ThemeColors.ink;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium),
          Text(
            amount,
            style: isBold
                ? AppTextStyles.titleMedium.copyWith(color: color)
                : AppTextStyles.bodyMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}