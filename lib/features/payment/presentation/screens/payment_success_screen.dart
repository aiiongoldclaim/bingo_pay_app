import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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
                                            'INV-${state.orderId}',
                                            style: AppTextStyles.titleMedium,
                                          ),
                                          Text(
                                            DateFormat('d MMM yyyy').format(DateTime.now()),
                                            style: AppTextStyles.bodySmall,
                                          ),
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
                                        _billedToName(context),
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
                                      for (final item in state.cartItems)
                                        _buildItemRow(
                                          item.product.name,
                                          'Qty ${item.quantity}',
                                          '₹${item.lineTotal.toStringAsFixed(0)}',
                                        ),
                                    ],
                                  ),
                                ),

                                const Divider(height: 1, color: AppColors.line),

                                Padding(
                                  padding: EdgeInsets.all(AppDimensions.md),
                                  child: Column(
                                    children: [
                                      _buildSummaryRow('Subtotal', '₹${state.itemTotal.toStringAsFixed(0)}'),
                                      if (state.savings > 0)
                                        _buildSummaryRow(
                                          'Discount',
                                          '- ₹${state.savings.toStringAsFixed(0)}',
                                          isGreen: true,
                                        ),
                                      _buildSummaryRow(
                                        'Delivery',
                                        state.deliveryCharge == 0
                                            ? 'FREE'
                                            : '₹${state.deliveryCharge.toStringAsFixed(0)}',
                                        isGreen: state.deliveryCharge == 0,
                                      ),
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

  String _billedToName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Guest';
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