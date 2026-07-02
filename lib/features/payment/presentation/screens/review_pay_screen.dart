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
//             '\$${state.itemTotal.toStringAsFixed(0)}',
//           ),
//           _buildSummaryRow(
//             'Savings',
//             '- \$${state.savings.toStringAsFixed(0)}',
//             isGreen: true,
//           ),
//           _buildSummaryRow(
//             'Delivery',
//             state.deliveryCharge == 0 ? 'FREE' : '\$${state.deliveryCharge}',
//             isGreen: true,
//           ),
//           _buildSummaryRow(
//             'Taxes & fees',
//             '\$${state.taxes.toStringAsFixed(0)}',
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
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class CouponAndNotesCard extends StatefulWidget {
  const CouponAndNotesCard({super.key});

  @override
  State<CouponAndNotesCard> createState() => _CouponAndNotesCardState();
}

class _CouponAndNotesCardState extends State<CouponAndNotesCard> {
  final _couponController = TextEditingController();
  final _notesController = TextEditingController();
  bool _couponApplied = false;

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyCoupon(BuildContext context) {
    final code = _couponController.text.trim();
    context.read<PaymentMethodCubit>().updateCouponCode(code);
    setState(() => _couponApplied = code.isNotEmpty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          code.isNotEmpty ? 'Coupon "$code" applied' : 'Coupon removed',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

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
          Text('Coupon Code', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    suffixIcon: _couponApplied
                        ? const Icon(
                            Icons.check_circle,
                            color: ThemeColors.green,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
                    ),
                  ),
                  onChanged: (_) {
                    if (_couponApplied) setState(() => _couponApplied = false);
                  },
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _applyCoupon(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.blue,
                  side: const BorderSide(color: ThemeColors.blue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMd),
          Text('Delivery Notes (optional)', style: AppTextStyles.titleMedium),
          const SizedBox(height: 10),
          TextField(
            controller: _notesController,
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: 'e.g. Leave at the door',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
              ),
            ),
            onChanged: (value) =>
                context.read<PaymentMethodCubit>().updateNotes(value.trim()),
          ),
        ],
      ),
    );
  }
}

class ReviewPaymentCard extends StatelessWidget {
  const ReviewPaymentCard({
    super.key,
    required this.methodName,
    required this.bigoldBalance,
  });

  final String methodName;
  final String bigoldBalance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1D4E).withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient header ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSizes.radius2Xl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 17,
                    color: ThemeColors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  methodName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: ThemeColors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 11,
                        color: ThemeColors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Secured',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: ThemeColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Balance ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR BALANCE',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: ThemeColors.inkDim,
                  ),
                ),
                const SizedBox(height: 12),
                _BalanceRow(
                  icon: Icons.currency_bitcoin,
                  label: 'Bigod Balance',
                  value: bigoldBalance,
                  color: const Color(0xFFF7A928),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _BalanceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: ThemeColors.inkMid),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: ThemeColors.ink,
          ),
        ),
      ],
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    this.productName = '',
    this.cartItems = const [],
    required this.itemTotal,
    required this.savings,
    required this.delivery,
    required this.tax,
    required this.total,
  });

  final String productName;
  final List<CartItemEntity> cartItems;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart items list
          if (cartItems.isNotEmpty) ...[
            ...cartItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            'Qty: ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: ThemeColors.inkDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 8),
            const SizedBox(height: 8),
          ] else if (productName.isNotEmpty) ...[
            Text(
              productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: ThemeColors.inkDim,
              ),
            ),
            const Divider(height: 20),
          ],

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
  final bool isCart;
  const ReviewPayScreen({super.key, required this.isCart});

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

                if (!context.mounted) return;

                if (cubit.state.status == PaymentStatus.success) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const PaymentSuccessScreen(),
                      ),
                    ),
                  );
                } else if (cubit.state.status == PaymentStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        cubit.state.errorMessage ??
                            'Payment failed. Please try again.',
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),

            body: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Delivery Address ──────────────────────────────────
                  if (state.deliveryName.isNotEmpty) ...[
                    _ReviewAddressCard(state: state),
                    const SizedBox(height: AppSizes.paddingLg),
                  ],

                  // ── Paying With ───────────────────────────────────────
                  ReviewPaymentCard(
                    methodName: state.methodDisplayName,
                    bigoldBalance: state.formattedBigoldBalance,
                  ),

                  const SizedBox(height: AppSizes.paddingLg),

                  // ── Coupon Code & Notes (Buy Now flow only) ────────────
                  if (!state.isCartFlow) ...[
                    const CouponAndNotesCard(),
                    const SizedBox(height: AppSizes.paddingLg),
                  ],

                  // ── Order Summary ─────────────────────────────────────
                  Text('Order summary', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSizes.paddingSm),

                  OrderSummaryCard(
                    productName: state.isCartFlow ? '' : state.productName,
                    cartItems: state.cartItems,
                    itemTotal: state.itemTotal > 0
                        ? '\$${state.itemTotal.toStringAsFixed(0)}'
                        : 'N/A',
                    savings: state.savings > 0
                        ? '- \$${state.savings.toStringAsFixed(0)}'
                        : '\$0',
                    delivery: state.deliveryCharge == 0
                        ? '\$0'
                        : '\$${state.deliveryCharge}',
                    tax: '\$${state.taxes.toStringAsFixed(0)}',
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

// ── Delivery Address Review Card ────────────────────────────────────────────

class _ReviewAddressCard extends StatelessWidget {
  final PaymentMethodState state;
  const _ReviewAddressCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final fullAddress =
        '${state.deliveryAddress}, ${state.deliveryCity} - ${state.deliveryPostal}';
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: ThemeColors.blue,
              ),
              const SizedBox(width: 6),
              Text(
                'DELIVERY ADDRESS',
                style: AppTextStyles.labelMedium.copyWith(
                  color: ThemeColors.inkMid,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(state.deliveryName, style: AppTextStyles.titleMedium),
          const SizedBox(height: 2),
          Text(
            state.deliveryPhone,
            style: AppTextStyles.bodySmall.copyWith(color: ThemeColors.inkDim),
          ),
          const SizedBox(height: 4),
          Text(
            fullAddress,
            style: AppTextStyles.bodyMedium.copyWith(color: ThemeColors.inkMid),
          ),
        ],
      ),
    );
  }
}
