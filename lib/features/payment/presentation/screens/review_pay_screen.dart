// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_dimensions.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../cubit/payment_cubit.dart';
// import '../cubit/payment_state.dart';
// import 'payment_success_screen.dart';
//
// class ReviewPayScreen extends StatelessWidget {
//   const ReviewPayScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: AppColors.surface,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//       child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
//         builder: (context, state) {
//           return Scaffold(
//             backgroundColor: AppColors.background,
//             appBar: CustomAppBar(
//               // leading: Icon(Icons.arrow_back_ios_new_outlined),
//               title: 'Review & Pay',
//             ),
//
//             body: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: AppDimensions.lg),
//
//                   // Paying With Section
//                   _buildPayingWithSection(state, context),
//
//                   SizedBox(height: AppDimensions.xl),
//
//                   // Order Summary
//                   _buildOrderSummary(state),
//
//                   SizedBox(height: AppDimensions.lg),
//
//                   // Security Note
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.verified_user,
//                         color: ThemeColors.green,
//                         size: 20.sp,
//                       ),
//                       SizedBox(width: AppDimensions.sm),
//                       Expanded(
//                         child: Text(
//                           '100% secure payment • PCI-DSS encrypted',
//                           style: AppTextStyles.bodyMedium,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: AppDimensions.md),
//
//                   // Payment Logos
//                   const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'VISA ',
//                         style: TextStyle(color: ThemeColors.inkMid),
//                       ),
//                       Text('UPI ', style: TextStyle(color: ThemeColors.inkMid)),
//                       Text(
//                         'RuPay ',
//                         style: TextStyle(color: ThemeColors.inkMid),
//                       ),
//                       Text(
//                         'Mastercard',
//                         style: TextStyle(color: ThemeColors.inkMid),
//                       ),
//                     ],
//                   ),
//
//                   SizedBox(height: AppDimensions.xxl),
//
//                   // Pay Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: AppDimensions.buttonHeight,
//                     child: ElevatedButton(
//                       onPressed: state.isProcessing
//                           ? null
//                           : () async {
//                               final cubit = context.read<PaymentMethodCubit>();
//                               await cubit.makePayment();
//
//                               if (context.mounted) {
//                                 Navigator.pushAndRemoveUntil(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => BlocProvider.value(
//                                       value: cubit,
//                                       child: const PaymentSuccessScreen(),
//                                     ),
//                                   ),
//                                   (route) => route.isFirst,
//                                 );
//                               }
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: ThemeColors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(
//                             AppDimensions.radiusLg,
//                           ),
//                         ),
//                       ),
//                       child: state.isProcessing
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               'Pay ${state.formattedTotal}',
//                               style: AppTextStyles.buttonText,
//                             ),
//                     ),
//                   ),
//
//                   SizedBox(height: AppDimensions.xxl),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildPayingWithSection(
//     PaymentMethodState state,
//     BuildContext context,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(AppDimensions.md),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
//         border: Border.all(color: AppColors.line),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'PAYING WITH',
//             style: AppTextStyles.labelLarge.copyWith(color: ThemeColors.inkMid),
//           ),
//           SizedBox(height: AppDimensions.md),
//
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppColors.blueSoft,
//                   borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//                 ),
//                 child: Icon(
//                   Icons.account_balance_wallet,
//                   color: ThemeColors.blue,
//                   size: 28.sp,
//                 ),
//               ),
//               SizedBox(width: AppDimensions.md),
//
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('BINGOLD Wallet', style: AppTextStyles.titleMedium),
//                     Text(
//                       'Balance ${state.formattedWalletBalance}',
//                       style: AppTextStyles.bodyMedium,
//                     ),
//                   ],
//                 ),
//               ),
//
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('Change', style: AppTextStyles.labelLarge),
//               ),
//             ],
//           ),
//
//           SizedBox(height: AppDimensions.md),
//
//           // Remaining Amount Banner
//           Container(
//             padding: EdgeInsets.all(AppDimensions.sm),
//             decoration: BoxDecoration(
//               color: AppColors.accentSoft,
//               borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.flash_on, color: ThemeColors.accentInk, size: 20.sp),
//                 SizedBox(width: AppDimensions.sm),
//                 Expanded(
//                   child: Text(
//                     'Wallet covers ${state.formattedWalletBalance} • remaining ${state.formattedRemaining} via UPI',
//                     style: AppTextStyles.bodyMedium,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderSummary(PaymentMethodState state) {
//     return Container(
//       padding: EdgeInsets.all(AppDimensions.md),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Order summary', style: AppTextStyles.titleLarge),
//
//           SizedBox(height: AppDimensions.md),
//
//           _buildSummaryRow(
//             'Item total',
//             '₹${state.itemTotal.toStringAsFixed(0)}',
//           ),
//           _buildSummaryRow(
//             'Savings',
//             '- ₹${state.savings.toStringAsFixed(0)}',
//             isGreen: true,
//           ),
//           _buildSummaryRow(
//             'Delivery',
//             state.deliveryCharge == 0 ? 'FREE' : '₹${state.deliveryCharge}',
//             isGreen: true,
//           ),
//           _buildSummaryRow(
//             'Taxes & fees',
//             '₹${state.taxes.toStringAsFixed(0)}',
//           ),
//           const Divider(height: 32),
//
//           _buildSummaryRow('Total', state.formattedTotal, isBold: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(
//     String title,
//     String amount, {
//     bool isGreen = false,
//     bool isBold = false,
//   }) {
//     final color = isGreen ? ThemeColors.green : ThemeColors.ink;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: AppDimensions.xs),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: AppTextStyles.bodyMedium),
//           Text(
//             amount,
//             style: isBold
//                 ? AppTextStyles.titleMedium.copyWith(color: color)
//                 : AppTextStyles.bodyMedium.copyWith(color: color),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:bingo_pay/features/payment/presentation/screens/payment_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class ReviewPaymentCard extends StatelessWidget {
  const ReviewPaymentCard({
    super.key,
    required this.walletBalance,
    required this.remainingAmount,
    required this.onChange,
  });

  final String walletBalance;
  final String remainingAmount;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PAYING WITH', style: AppTextStyles.labelMedium),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: ThemeColors.blue.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: ThemeColors.blue,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BINGOLD Wallet', style: AppTextStyles.titleMedium),
                    Text(
                      'Balance $walletBalance',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: onChange,
                child: Text(
                  'Change',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: ThemeColors.blue,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 32),

          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 18),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Wallet covers $walletBalance • remaining $remainingAmount via UPI',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.itemTotal,
    required this.savings,
    required this.delivery,
    required this.tax,
    required this.total,
  });

  final String itemTotal;
  final String savings;
  final String delivery;
  final String tax;
  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
      ),
      child: Column(
        children: [
          _row('Item total', itemTotal),
          const SizedBox(height: 12),

          _row('Savings', savings, color: ThemeColors.green),

          const SizedBox(height: 12),

          _row('Delivery', delivery, color: ThemeColors.green),

          const SizedBox(height: 12),

          _row('Taxes & fees', tax),

          const Divider(height: 32),

          _row('Total', total, isBold: true),
        ],
      ),
    );
  }

  Widget _row(String title, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.titleLarge
              : AppTextStyles.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }
}

class SecurePaymentInfo extends StatelessWidget {
  const SecurePaymentInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              color: ThemeColors.green,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '100% secure payment • PCI-DSS encrypted',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 16),

        Text(
          'VISA   UPI   RuPay   Mastercard',
          style: AppTextStyles.labelLarge.copyWith(color: ThemeColors.inkDim),
        ),
      ],
    );
  }
}

class PayNowBottomBar extends StatelessWidget {
  const PayNowBottomBar({
    super.key,
    required this.amount,
    required this.isLoading,
    required this.onPay,
  });

  final String amount;
  final bool isLoading;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: SizedBox(
          height: AppSizes.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onPay,
            icon: isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.lock_outline, color: Colors.white),
            label: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text('Pay $amount', style: AppTextStyles.buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewPayScreen extends StatelessWidget {
  const ReviewPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.background,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,

            appBar: const CustomAppBar(title: 'Review & Pay'),

            bottomNavigationBar: PayNowBottomBar(
              amount: state.formattedTotal,
              isLoading: state.isProcessing,
              onPay: () async {
                final cubit = context.read<PaymentMethodCubit>();

                await cubit.makePayment();

                if (context.mounted &&
                    cubit.state.status == PaymentStatus.success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const PaymentSuccessScreen(),
                      ),
                    ),
                  );
                }
              },
            ),

            body: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReviewPaymentCard(
                    walletBalance: state.formattedWalletBalance,
                    remainingAmount: state.formattedRemaining,
                    onChange: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: AppSizes.paddingLg),

                  Text('Order summary', style: AppTextStyles.titleLarge),

                  const SizedBox(height: AppSizes.paddingSm),

                  OrderSummaryCard(
                    itemTotal: '₹${state.itemTotal.toStringAsFixed(0)}',
                    savings: '- ₹${state.savings.toStringAsFixed(0)}',
                    delivery: state.deliveryCharge == 0
                        ? 'FREE'
                        : '₹${state.deliveryCharge}',
                    tax: '₹${state.taxes.toStringAsFixed(0)}',
                    total: state.formattedTotal,
                  ),

                  const SizedBox(height: AppSizes.paddingLg),

                  const SecurePaymentInfo(),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
