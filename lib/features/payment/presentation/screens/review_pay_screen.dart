// import 'package:bingo_pay/features/payment/presentation/screens/transaction_success_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../../core/constants/app_sizes.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../../core/theme/theme_colors.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../../../cart/domain/entities/cart_item_entity.dart';
// import '../cubit/payment_cubit.dart';
// import '../cubit/payment_state.dart';
// import 'widgets/payment_method_picker.dart';
//
// class CouponAndNotesCard extends StatefulWidget {
//   const CouponAndNotesCard({super.key});
//
//   @override
//   State<CouponAndNotesCard> createState() => _CouponAndNotesCardState();
// }
//
// class _CouponAndNotesCardState extends State<CouponAndNotesCard> {
//   final _couponController = TextEditingController();
//   final _notesController = TextEditingController();
//   bool _couponApplied = false;
//
//   @override
//   void dispose() {
//     _couponController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
//
//   void _applyCoupon(BuildContext context) {
//     final code = _couponController.text.trim();
//     context.read<PaymentMethodCubit>().updateCouponCode(code);
//     setState(() => _couponApplied = code.isNotEmpty);
//     if(code.isNotEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           code.isNotEmpty ? 'Coupon "$code" applied' : 'Coupon removed',
//         ),
//         duration: const Duration(seconds: 2),
//         backgroundColor: ThemeColors.green,
//       ),
//     );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(AppSizes.paddingMd),
//       decoration: BoxDecoration(
//         color: ThemeColors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Coupon Code', style: AppTextStyles.titleMedium),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: TextField(
//                   controller: _couponController,
//                   textCapitalization: TextCapitalization.characters,
//                   decoration: InputDecoration(
//                     hintText: 'Enter coupon code',
//                     isDense: true,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 12,
//                     ),
//                     suffixIcon: _couponApplied
//                         ? const Icon(
//                             Icons.check_circle,
//                             color: ThemeColors.green,
//                           )
//                         : null,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
//                     ),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
//                     ),
//                   ),
//                   onChanged: (_) {
//                     if (_couponApplied) setState(() => _couponApplied = false);
//                   },
//                 ),
//               ),
//               const SizedBox(width: 10),
//               OutlinedButton(
//                 onPressed: () => _applyCoupon(context),
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: ThemeColors.blue,
//                   side: const BorderSide(color: ThemeColors.blue),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 14,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Apply'),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppSizes.paddingMd),
//           Text('Delivery Notes (optional)', style: AppTextStyles.titleMedium),
//           const SizedBox(height: 10),
//           TextField(
//             controller: _notesController,
//             maxLines: 2,
//             maxLength: 200,
//             decoration: InputDecoration(
//               hintText: 'e.g. Leave at the door',
//               isDense: true,
//               contentPadding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//                 vertical: 12,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//                 borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
//               ),
//             ),
//             onChanged: (value) =>
//                 context.read<PaymentMethodCubit>().updateNotes(value.trim()),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class ReviewPaymentCard extends StatelessWidget {
//   const ReviewPaymentCard({
//     super.key,
//     required this.methodName,
//     required this.bigoldBalance,
//     required this.selectedMethod,
//     required this.onChangeTap,
//   });
//
//   final String methodName;
//   final String bigoldBalance;
//   final PaymentMethod selectedMethod;
//   final VoidCallback onChangeTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: ThemeColors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1A1D4E).withValues(alpha: 0.10),
//             blurRadius: 24,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Gradient header ───────────────────────────────────────────
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(AppSizes.radius2Xl),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(7),
//                   decoration: BoxDecoration(
//                     color: ThemeColors.white.withValues(alpha: 0.18),
//                     borderRadius: BorderRadius.circular(9),
//                   ),
//                   child: const Icon(
//                     Icons.account_balance_wallet_outlined,
//                     size: 17,
//                     color: ThemeColors.white,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   methodName,
//                   style: AppTextStyles.titleMedium.copyWith(
//                     color: ThemeColors.white,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: ThemeColors.white.withValues(alpha: 0.15),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.lock_outline,
//                         size: 15,
//                         color: ThemeColors.white,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Secured',
//                         style: AppTextStyles.labelLarge.copyWith(
//                           color: ThemeColors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 TextButton(
//                   onPressed: onChangeTap,
//                   style: TextButton.styleFrom(
//                     foregroundColor: ThemeColors.white,
//                     padding: EdgeInsets.zero,
//                     minimumSize: const Size(0, 0),
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: Text(
//                     'Change',
//                     style: AppTextStyles.labelLarge.copyWith(
//                       color: ThemeColors.white,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Balance (wallet only) / COD note ─────────────────────────────
//           Padding(
//             padding: const EdgeInsets.all(18),
//             child: selectedMethod == PaymentMethod.wallet
//                 ? Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'YOUR BALANCE',
//                         style: AppTextStyles.labelMedium.copyWith(
//                           color: ThemeColors.inkMid,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       _BalanceRow(
//                         icon: Icons.account_balance_wallet_outlined,
//                         label: 'Bigod Balance',
//                         value: bigoldBalance,
//                         color: const Color(0xFFF7A928),
//                       ),
//                     ],
//                   )
//                 : Row(
//                     children: [
//                       const Icon(
//                         Icons.payments_outlined,
//                         size: 18,
//                         color: ThemeColors.inkMid,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           'Pay with cash when your order arrives',
//                           style: AppTextStyles.bodyMedium.copyWith(
//                             color: ThemeColors.inkMid,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _BalanceRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;
//   const _BalanceRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, size: 18, color: color),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             label,
//             style: AppTextStyles.bodyMedium.copyWith(color: ThemeColors.inkMid),
//           ),
//         ),
//         Text(
//           value,
//           style: AppTextStyles.titleMedium.copyWith(
//             fontWeight: FontWeight.w700,
//             color: ThemeColors.ink,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class OrderSummaryCard extends StatelessWidget {
//   const OrderSummaryCard({
//     super.key,
//     this.productName = '',
//     this.cartItems = const [],
//     required this.itemTotal,
//     required this.savings,
//     required this.delivery,
//     required this.tax,
//     required this.total,
//   });
//
//   final String productName;
//   final List<CartItemEntity> cartItems;
//   final String itemTotal;
//   final String savings;
//   final String delivery;
//   final String tax;
//   final String total;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(AppSizes.paddingMd),
//       decoration: BoxDecoration(
//         color: ThemeColors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Cart items list
//           if (cartItems.isNotEmpty) ...[
//             ...cartItems.map(
//               (item) => Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.product.title,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: AppTextStyles.bodyLarge,
//                           ),
//                           Text(
//                             'Qty: ${item.quantity}',
//                             style: AppTextStyles.bodySmall.copyWith(
//                               color: ThemeColors.inkMid,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       '\$${item.totalPrice.toStringAsFixed(0)}',
//                       style: AppTextStyles.bodyLarge,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const Divider(height: 8),
//             const SizedBox(height: 8),
//           ] else if (productName.isNotEmpty) ...[
//             Text(
//               productName,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: AppTextStyles.bodyLarge.copyWith(
//                 color: ThemeColors.inkMid,
//               ),
//             ),
//             const Divider(height: 20),
//           ],
//
//           _row('Item total', itemTotal),
//           const SizedBox(height: 12),
//           _row('Savings', savings, color: ThemeColors.green),
//           const SizedBox(height: 12),
//           _row('Delivery', delivery, color: ThemeColors.green),
//           const SizedBox(height: 12),
//           _row('Taxes & fees', tax),
//           const Divider(height: 32),
//           _row('Total', total, isBold: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _row(String title, String value, {Color? color, bool isBold = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium,
//         ),
//         Text(
//           value,
//           style: isBold
//               ? AppTextStyles.titleLarge
//               : AppTextStyles.bodyMedium.copyWith(color: color),
//         ),
//       ],
//     );
//   }
// }
//
// class SecurePaymentInfo extends StatelessWidget {
//   const SecurePaymentInfo({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.verified_user_outlined,
//               color: ThemeColors.green,
//               size: 18,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               '100% secure payment • PCI-DSS encrypted',
//               style: AppTextStyles.bodyMedium,
//             ),
//           ],
//         ),
//
//         const SizedBox(height: 16),
//
//         Text(
//           'VISA   UPI   RuPay   Mastercard',
//           style: AppTextStyles.labelLarge.copyWith(color: ThemeColors.inkDim),
//         ),
//       ],
//     );
//   }
// }
//
// class PayNowBottomBar extends StatelessWidget {
//   const PayNowBottomBar({
//     super.key,
//     required this.amount,
//     required this.buttonLabel,
//     required this.isLoading,
//     required this.onPay,
//   });
//
//   final String amount;
//   final String buttonLabel;
//   final bool isLoading;
//   final VoidCallback onPay;
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(AppSizes.paddingMd),
//         child: SizedBox(
//           height: AppSizes.buttonHeight,
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(AppSizes.radiusLg),
//             ),
//             child: ElevatedButton.icon(
//               onPressed: isLoading ? null : onPay,
//               icon: isLoading
//                   ? const SizedBox.shrink()
//                   : const Icon(Icons.lock_outline, color: Colors.white),
//               label: isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text('$buttonLabel $amount', style: AppTextStyles.buttonText),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.transparent,
//                 shadowColor: Colors.transparent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(AppSizes.radiusLg),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class ReviewPayScreen extends StatelessWidget {
//   final bool isCart;
//   const ReviewPayScreen({super.key, required this.isCart});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: AppColors.background,
//         statusBarIconBrightness: Brightness.dark,
//       ),
//       child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
//         builder: (context, state) {
//           return Scaffold(
//             backgroundColor: AppColors.background,
//
//             appBar: const CustomAppBar(title: 'Review & Pay'),
//
//             bottomNavigationBar: PayNowBottomBar(
//               amount: state.formattedTotal,
//               buttonLabel: state.selectedMethod == PaymentMethod.cashOnDelivery
//                   ? 'Place Order'
//                   : 'Pay Now',
//               isLoading: state.isProcessing,
//               onPay: () async {
//                 final cubit = context.read<PaymentMethodCubit>();
//                 await cubit.makePayment();
//
//                 if (!context.mounted) return;
//
//                 if (cubit.state.status == PaymentStatus.success) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => BlocProvider.value(
//                         value: cubit,
//                         child: const PaymentSuccessScreen(),
//                       ),
//                     ),
//                   );
//                 } else if (cubit.state.status == PaymentStatus.failure) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         cubit.state.errorMessage ??
//                             'Payment failed. Please try again.',
//                       ),
//                       backgroundColor: Colors.red,
//                       duration: const Duration(seconds: 4),
//                     ),
//                   );
//                 }
//               },
//             ),
//
//             body: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd, vertical: 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ── Delivery Address ──────────────────────────────────
//                   if (state.deliveryName.isNotEmpty) ...[
//                     _ReviewAddressCard(state: state),
//                     const SizedBox(height: AppSizes.paddingMd),
//                   ],
//
//                   // ── Paying With ───────────────────────────────────────
//                   ReviewPaymentCard(
//                     methodName: state.methodDisplayName,
//                     bigoldBalance: state.formattedBigoldBalance,
//                     selectedMethod: state.selectedMethod ?? PaymentMethod.wallet,
//                     onChangeTap: () => showPaymentMethodPicker(
//                       context,
//                       state.selectedMethod ?? PaymentMethod.wallet,
//                     ),
//                   ),
//
//                   const SizedBox(height: AppSizes.paddingMd),
//
//                   // ── Coupon Code & Notes (Buy Now flow only) ────────────
//                   if (!state.isCartFlow) ...[
//                     const CouponAndNotesCard(),
//                     const SizedBox(height: AppSizes.paddingSm),
//                   ],
//
//                   // ── Order Summary ─────────────────────────────────────
//                   Text('Order summary', style: AppTextStyles.titleLarge),
//                   const SizedBox(height: AppSizes.paddingSm),
//
//                   OrderSummaryCard(
//                     productName: state.isCartFlow ? '' : state.productName,
//                     cartItems: state.cartItems,
//                     itemTotal: state.itemTotal > 0
//                         ? '\$${state.itemTotal.toStringAsFixed(0)}'
//                         : 'N/A',
//                     savings: state.savings > 0
//                         ? '- \$${state.savings.toStringAsFixed(0)}'
//                         : '\$0',
//                     delivery: state.deliveryCharge == 0
//                         ? '\$0'
//                         : '\$${state.deliveryCharge}',
//                     tax: '\$${state.taxes.toStringAsFixed(0)}',
//                     total: state.formattedTotal,
//                   ),
//
//                   const SizedBox(height: AppSizes.paddingLg),
//                   const SecurePaymentInfo(),
//                   const SizedBox(height: 60),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // ── Delivery Address Review Card ────────────────────────────────────────────
//
// class _ReviewAddressCard extends StatelessWidget {
//   final PaymentMethodState state;
//   const _ReviewAddressCard({required this.state});
//
//   @override
//   Widget build(BuildContext context) {
//     final fullAddress =
//         '${state.deliveryAddress}, ${state.deliveryCity} - ${state.deliveryPostal}';
//     return Container(
//       padding: const EdgeInsets.all(AppSizes.paddingMd),
//       decoration: BoxDecoration(
//         color: ThemeColors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.location_on_outlined,
//                 size: 18,
//                 color: ThemeColors.blue,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 'DELIVERY ADDRESS',
//                 style: AppTextStyles.labelMedium.copyWith(
//                   color: ThemeColors.inkMid,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(state.deliveryName, style: AppTextStyles.titleMedium),
//           const SizedBox(height: 2),
//           Text(
//             state.deliveryPhone,
//             style: AppTextStyles.bodyMedium.copyWith(color: ThemeColors.inkMid),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             fullAddress,
//             style: AppTextStyles.bodyMedium.copyWith(color: ThemeColors.inkMid),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:bingo_pay/features/payment/presentation/screens/widgets/review_pay_metrics.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/review_pay_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../address/domain/repositories/address_respository.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../address/presentation/screens/address_list_screen.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'payment_success_screen.dart';
import 'widgets/payment_method_picker.dart';

class ReviewPayScreen extends StatelessWidget {
  final bool isCart;
  const ReviewPayScreen({super.key, required this.isCart});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: c.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: c.isDark ? Brightness.dark : Brightness.light,
      ),
      child: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
        builder: (context, state) {
          final m = ReviewPayMetrics.of(context);

          // ── Sections ────────────────────────────────────────────────
          final address = state.deliveryName.isEmpty
              ? null
              : _AddressCard(metrics: m, state: state);

          final wallet = _PayingWithCard(
            metrics: m,
            methodName: state.methodDisplayName,
            bigoldBalance: state.formattedBigoldBalance,
            selectedMethod: state.selectedMethod ?? PaymentMethod.wallet,
            onChangeTap: () => showPaymentMethodPicker(
              context,
              state.selectedMethod ?? PaymentMethod.wallet,
            ),
          );

          final summary = _OrderSummaryCard(
            metrics: m,
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
          );


          final offers = ReviewOffersCard(
            metrics: m,
            offers: const [
              ReviewOffer(
                title: '10% Instant Discount on Bank Cards',
                subtitle: 'Min. spend \$50 | T&C',
              ),
              ReviewOffer(
                title: 'Extra 5% off on Wallet',
                subtitle: 'Max. discount \$10',
              ),
            ],
            onViewAll: () {},
          );
          final secure = ReviewInfoStrip(
            metrics: m,
            icon: Icons.verified_user_outlined,
            title: '100% Secure Payment',
            subtitle: 'PCI DSS encrypted & safe checkout',
          );

          final payBar = _PayBar(
            metrics: m,
            amount: state.formattedTotal,
            label: state.selectedMethod == PaymentMethod.cashOnDelivery
                ? 'PLACE ORDER'
                : 'PAY NOW',
            isLoading: state.isProcessing,
            onPay: () => _onPay(context),
          );

          return Scaffold(
            backgroundColor: c.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _ReviewTopBar(metrics: m, cartCount: state.cartItems.length),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.maxContentWidth,
                        ),
                        child: m.isLandscape
                            ? _LandscapeBody(
                          metrics: m,
                          state: state,
                          address: address,
                          wallet: wallet,
                          summary: summary,
                          secure: secure,
                          offers: offers,
                          payBar: payBar,
                        )
                            : _PortraitBody(
                          metrics: m,
                          state: state,
                          address: address,
                          wallet: wallet,
                          summary: summary,
                          secure: secure,
                          offers: offers,
                        ),
                      ),
                    ),
                  ),

                  if (!m.isLandscape)
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        m.pageHPad,
                        m.gapSm,
                        m.pageHPad,
                        m.gapSm * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: c.background,
                        border: Border(
                          top: BorderSide(color: c.border, width: 1),
                        ),
                      ),
                      child: SafeArea(top: false, child: payBar),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Payment logic — unchanged ─────────────────────────────────────────
  Future<void> _onPay(BuildContext context) async {
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
      AppSnackbar.showError(
        context,
        cubit.state.errorMessage ?? 'Payment failed. Please try again.',
      );
    }
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _ReviewTopBar extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final int cartCount;

  const _ReviewTopBar({required this.metrics, required this.cartCount});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    Widget boxed({required Widget child, required VoidCallback onTap}) =>
        Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: m.walletIconBox,
              height: m.walletIconBox,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border, width: 1),
              ),
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.pageVPad * 0.5,
        m.pageHPad,
        m.pageVPad * 0.5,
      ),
      child: Row(
        children: [
          boxed(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: c.textPrimary,
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'TheVaults',
                style: AppTextStyles.titleLarge.copyWith(
                  color: c.brand,
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.w600,
                  fontSize: m.logoSize,
                  height: 1.1,
                ),
              ),
            ),
          ),

          Stack(
            clipBehavior: Clip.none,
            children: [
              boxed(
                onTap: () {},
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: m.topIconSize,
                  color: c.textPrimary,
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: -m.badgeSize * 0.25,
                  top: -m.badgeSize * 0.25,
                  child: Container(
                    width: m.badgeSize,
                    height: m.badgeSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.brand,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.background, width: 1.5),
                    ),
                    child: Text(
                      '$cartCount',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontSize: m.badgeFontSize,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Page title ─────────────────────────────────────────────────────────────
class _PageTitle extends StatelessWidget {
  final ReviewPayMetrics metrics;

  const _PageTitle({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Review & Pay',
          style: AppTextStyles.titleLarge.copyWith(
            color: c.textPrimary,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w700,
            fontSize: m.pageTitleSize,
            height: 1.2,
          ),
        ),
        SizedBox(height: m.gapXs),
        Text(
          'Review your order details and proceed to payment',
          style: AppTextStyles.bodyMedium.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.pageSubtitleSize,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ── Portrait ───────────────────────────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final PaymentMethodState state;
  final Widget? address;
  final Widget wallet;
  final Widget summary;
  final Widget secure;
  final Widget offers;

  const _PortraitBody({
    required this.metrics,
    required this.state,
    required this.address,
    required this.wallet,
    required this.summary,
    required this.secure,
    required this.offers,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageTitle(metrics: m),
          SizedBox(height: m.gapLg),

          if (address != null) ...[address!, SizedBox(height: m.gapMd)],

          wallet,
          SizedBox(height: m.gapLg),

          if (!state.isCartFlow) ...[
            _CouponAndNotesCard(metrics: m),
            SizedBox(height: m.gapMd),
          ],

          ReviewSectionLabel(metrics: m, label: 'Order Summary'),
          SizedBox(height: m.gapSm),
          summary,

          SizedBox(height: m.gapMd),
          secure,

          SizedBox(height: m.gapMd),
          offers,
        ],
      ),
    );
  }
}

// ── Landscape ──────────────────────────────────────────────────────────────
class _LandscapeBody extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final PaymentMethodState state;
  final Widget? address;
  final Widget wallet;
  final Widget summary;
  final Widget secure;
  final Widget offers;
  final Widget payBar;

  const _LandscapeBody({
    required this.metrics,
    required this.state,
    required this.address,
    required this.wallet,
    required this.summary,
    required this.secure,
    required this.offers,
    required this.payBar,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PageTitle(metrics: m),
                  SizedBox(height: m.gapLg),
                  if (address != null) ...[address!, SizedBox(height: m.gapMd)],
                  wallet,
                  if (!state.isCartFlow) ...[
                    SizedBox(height: m.gapMd),
                    _CouponAndNotesCard(metrics: m),
                  ],
                  SizedBox(height: m.gapMd),
                  offers,
                ],
              ),
            ),
          ),

          SizedBox(width: m.gapLg),

          SizedBox(
            width: m.railWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReviewSectionLabel(metrics: m, label: 'Order Summary'),
                  SizedBox(height: m.gapSm),
                  summary,
                  SizedBox(height: m.gapMd),
                  secure,
                  SizedBox(height: m.gapMd),
                  payBar,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Delivery address ───────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final PaymentMethodState state;

  const _AddressCard({required this.metrics, required this.state});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final fullAddress =
        '${state.deliveryAddress}, ${state.deliveryCity} - ${state.deliveryPostal}';

    Future<void> _openAddressList(
        BuildContext context,
        PaymentMethodState state,
        ) async {
      final paymentCubit = context.read<PaymentMethodCubit>();

      final picked = await Navigator.push<AddressEntity>(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => AddressCubit(getIt<AddressRepository>()),
            child: AddressListScreen(
              selectedAddressId: state.deliveryAddressId,
            ),
          ),
        ),
      );

      if (picked == null) return;

      paymentCubit.updateDeliveryAddress(
        name: picked.fullName,
        phone: picked.phoneNumber,
        address: picked.addressLine1,
        city: picked.city,
        postal: picked.postalCode,
        addressId: picked.id,
      );
    }

    return ReviewCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReviewSectionLabel(
            metrics: m,
            label: 'Delivery Address',
            icon: Icons.location_on_outlined,
          ),

          SizedBox(height: m.gapMd),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.deliveryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.addrNameSize,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      state.deliveryPhone,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.addrBodySize,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      fullAddress,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.addrBodySize,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: m.gapSm),

              SizedBox(
                height: m.changeBtnHeight,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openAddressList(context, state),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.brand, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Change',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: c.brand,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: m.changeBtnFontSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Paying with (wallet / COD) ─────────────────────────────────────────────
class _PayingWithCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String methodName;
  final String bigoldBalance;
  final PaymentMethod selectedMethod;
  final VoidCallback onChangeTap;

  const _PayingWithCard({
    required this.metrics,
    required this.methodName,
    required this.bigoldBalance,
    required this.selectedMethod,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final isWallet = selectedMethod == PaymentMethod.wallet;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.brand,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: m.walletIconBox,
                height: m.walletIconBox,
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isWallet
                      ? Icons.account_balance_wallet_outlined
                      : Icons.payments_outlined,
                  size: m.walletIconSize,
                  color: c.surface,
                ),
              ),

              SizedBox(width: m.cardPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      methodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.walletTitleSize,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.8),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: m.walletSubSize + 3,
                          color: c.surface.withValues(alpha: 0.85),
                        ),
                        SizedBox(width: m.gapXs),
                        Text(
                          'Secured & Encrypted',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: c.surface.withValues(alpha: 0.85),
                            fontFamily: 'Inter',
                            fontSize: m.walletSubSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onChangeTap,
                  child: Padding(
                    padding: EdgeInsets.all(m.gapXs * 1.4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Change',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: c.surface,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: m.changeBtnFontSize,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: m.changeBtnFontSize + 6,
                          color: c.surface,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          Container(
            padding: EdgeInsets.all(m.cardPad * 0.8),
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(m.cardRadius * 0.75),
              border: Border.all(
                color: c.surface.withValues(alpha: 0.18),
                width: 1,
              ),
            ),
            child: isWallet
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'YOUR BALANCE',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: c.surface.withValues(alpha: 0.75),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.balanceLabelSize,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: m.gapSm),
                Row(
                  children: [
                    Container(
                      width: m.coinBadgeSize,
                      height: m.coinBadgeSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7A928),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'B',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: m.balanceLabelSize + 2,
                        ),
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    Expanded(
                      child: Text(
                        'Bigod Balance',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: c.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: m.rowLabelSize,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        bigoldBalance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: const Color(0xFFF7A928),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.balanceValueSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
                : Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: m.rowLabelSize + 4,
                  color: c.surface.withValues(alpha: 0.85),
                ),
                SizedBox(width: m.gapSm),
                Expanded(
                  child: Text(
                    'Pay with cash when your order arrives',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.surface.withValues(alpha: 0.9),
                      fontFamily: 'Inter',
                      fontSize: m.rowLabelSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order summary ──────────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String productName;
  final List<CartItemEntity> cartItems;
  final String itemTotal;
  final String savings;
  final String delivery;
  final String tax;
  final String total;

  const _OrderSummaryCard({
    required this.metrics,
    required this.productName,
    required this.cartItems,
    required this.itemTotal,
    required this.savings,
    required this.delivery,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return ReviewCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (cartItems.isNotEmpty) ...[
            ...cartItems.map(
                  (item) => Padding(
                padding: EdgeInsets.only(bottom: m.gapMd),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(m.cardRadius * 0.6),
                      child: Container(
                        width: m.thumbSize,
                        height: m.thumbSize,
                        color: c.surfaceAlt,
                        child: item.product.thumbnail != null
                            ? Image.network(
                          item.product.thumbnail!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.shopping_bag_outlined,
                            size: m.thumbSize * 0.4,
                            color: c.brand,
                          ),
                        )
                            : Icon(
                          Icons.shopping_bag_outlined,
                          size: m.thumbSize * 0.4,
                          color: c.brand,
                        ),
                      ),
                    ),
                    SizedBox(width: m.cardPad * 0.7),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: c.textPrimary,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: m.itemTitleSize,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: m.gapXs * 0.6),
                          Text(
                            'Qty: ${item.quantity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: c.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: m.itemMetaSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.itemTitleSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: c.border),
            SizedBox(height: m.gapMd),
          ] else if (productName.isNotEmpty) ...[
            Text(
              productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelLarge.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: m.itemTitleSize,
              ),
            ),
            SizedBox(height: m.gapMd),
            Divider(height: 1, thickness: 1, color: c.border),
            SizedBox(height: m.gapMd),
          ],

          ReviewRow(metrics: m, label: 'Item Total', value: itemTotal),
          SizedBox(height: m.gapSm),
          ReviewRow(
            metrics: m,
            label: 'Savings',
            value: savings,
            valueColor: c.statusSuccess,
          ),
          SizedBox(height: m.gapSm),
          ReviewRow(
            metrics: m,
            label: 'Delivery',
            value: delivery,
            valueColor: c.statusSuccess,
          ),
          SizedBox(height: m.gapSm),
          ReviewRow(metrics: m, label: 'Taxes & Fees', value: tax),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapMd * 0.8),
            child: Divider(height: 1, thickness: 1, color: c.border),
          ),

          ReviewRow(
            metrics: m,
            label: 'Total Amount',
            value: total,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

// ── Coupon + notes (Buy Now flow only) — logic unchanged ───────────────────
class _CouponAndNotesCard extends StatefulWidget {
  final ReviewPayMetrics metrics;

  const _CouponAndNotesCard({required this.metrics});

  @override
  State<_CouponAndNotesCard> createState() => _CouponAndNotesCardState();
}

class _CouponAndNotesCardState extends State<_CouponAndNotesCard> {
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
    if (code.isNotEmpty) {
      AppSnackbar.showSuccess(context, 'Coupon "$code" applied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = widget.metrics;

    return ReviewCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReviewSectionLabel(
            metrics: m,
            label: 'Coupon Code',
            icon: Icons.confirmation_number_outlined,
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              Expanded(
                child: ReviewField(
                  metrics: m,
                  controller: _couponController,
                  hint: 'Enter coupon code',
                  textCapitalization: TextCapitalization.characters,
                  suffix: _couponApplied
                      ? Icon(
                    Icons.check_circle,
                    size: m.fieldTextSize + 6,
                    color: c.statusSuccess,
                  )
                      : null,
                  onChanged: (_) {
                    if (_couponApplied) setState(() => _couponApplied = false);
                  },
                ),
              ),

              SizedBox(width: m.gapSm),

              SizedBox(
                height: m.fieldHeight,
                child: Material(
                  color: c.brandSoft,
                  borderRadius: BorderRadius.circular(m.fieldRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _applyCoupon(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: m.cardPad * 0.9,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Apply',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: c.brand,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.fieldTextSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapLg),

          ReviewSectionLabel(
            metrics: m,
            label: 'Delivery Notes (optional)',
            icon: Icons.sticky_note_2_outlined,
          ),

          SizedBox(height: m.gapMd),

          ReviewField(
            metrics: m,
            controller: _notesController,
            hint: 'e.g. Leave at the door',
            maxLines: 2,
            maxLength: 200,
            onChanged: (value) =>
                context.read<PaymentMethodCubit>().updateNotes(value.trim()),
          ),
        ],
      ),
    );
  }
}

// ── Pay bar ────────────────────────────────────────────────────────────────
class _PayBar extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final String amount;
  final String label;
  final bool isLoading;
  final VoidCallback onPay;

  const _PayBar({
    required this.metrics,
    required this.amount,
    required this.label,
    required this.isLoading,
    required this.onPay,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return SizedBox(
      height: m.payHeight,
      child: Material(
        color: c.brand,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPay,
          child: Center(
            child: isLoading
                ? SizedBox(
              width: m.payFontSize + 4,
              height: m.payFontSize + 4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(c.surface),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: m.payFontSize + 4,
                  color: c.surface,
                ),
                SizedBox(width: m.gapSm),
                Text(
                  '$label  $amount',
                  style: AppTextStyles.buttonText.copyWith(
                    color: c.surface,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.payFontSize,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}