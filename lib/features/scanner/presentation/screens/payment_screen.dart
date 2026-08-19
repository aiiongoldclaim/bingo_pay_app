// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/storage/secure_storage_service.dart';
// import '../../../../core/theme/app_colors.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../cubit/payment_cubit.dart';
// import '../cubit/payment_state.dart';
//
// class ReviewPaymentScreen extends StatefulWidget {
//   final String? merchantName;
//   final String merchantEmail;
//
//   const ReviewPaymentScreen({
//     super.key,
//     required this.merchantName,
//     required this.merchantEmail,
//   });
//
//   @override
//   State<ReviewPaymentScreen> createState() => _ReviewPaymentScreenState();
// }
//
// class _ReviewPaymentScreenState extends State<ReviewPaymentScreen> {
//   final TextEditingController _amountController = TextEditingController();
//
//   double _paymentAmount = 0;
//   String _reference = "";
//
//   static const double _maxAmount = 100000; // 1 Lakh USD
//   static const double _minAmount = 1;
//
//   static const double _usdToBigod = 0.00001772;
//   String _selectedCurrency = "USD";
//
//   @override
//   void dispose() {
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   void _changeCurrency(String? value) {
//     if (value == null || value == _selectedCurrency) return;
//
//     double amount = double.tryParse(_amountController.text) ?? 0;
//
//     if (_selectedCurrency == "USD" && value == "BIGOD") {
//       amount *= _usdToBigod;
//     } else if (_selectedCurrency == "BIGOD" && value == "USD") {
//       amount /= _usdToBigod;
//     }
//
//     setState(() {
//       _selectedCurrency = value;
//       _amountController.text = amount.toStringAsFixed(value == "USD" ? 2 : 8);
//     });
//   }
//
//   String get _displayName {
//     final name = widget.merchantName;
//     if (name != null && name.trim().isNotEmpty) return name.trim();
//     return _deriveNameFromEmail(widget.merchantEmail);
//   }
//
//   String _deriveNameFromEmail(String email) {
//     final namePart = email.split('@').first;
//     final words = namePart
//         .replaceAll(RegExp(r'[._\-0-9]+'), ' ')
//         .trim()
//         .split(RegExp(r'\s+'))
//         .where((w) => w.isNotEmpty);
//     if (words.isEmpty) return email;
//     return words
//         .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
//         .join(' ');
//   }
//
//   String _initials(String name) {
//     final parts = name
//         .trim()
//         .split(RegExp(r'\s+'))
//         .where((p) => p.isNotEmpty)
//         .toList();
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) {
//       return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
//     }
//     return (parts[0][0] + parts[1][0]).toUpperCase();
//   }
//
//   // ---- keypad handlers ----
//
//   void _onKeypadDigit(String digit) {
//     final next = _amountController.text + digit;
//
//     if (next.contains('.')) {
//       final decimals = next.split('.').last;
//       if (decimals.length > 2) return;
//     }
//
//     final amount = double.tryParse(next);
//     if (amount != null && amount > _maxAmount) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("You cannot fill amount more than \$100,000"),
//         ),
//       );
//       return;
//     }
//
//     setState(() => _amountController.text = next);
//   }
//
//   void _onKeypadDecimal() {
//     if (_amountController.text.contains('.')) return;
//     setState(() {
//       _amountController.text = _amountController.text.isEmpty
//           ? "0."
//           : "${_amountController.text}.";
//     });
//   }
//
//   void _onKeypadBackspace() {
//     if (_amountController.text.isEmpty) return;
//     setState(() {
//       _amountController.text = _amountController.text.substring(
//         0,
//         _amountController.text.length - 1,
//       );
//     });
//   }
//
//   Future<void> _pay() async {
//     final customerEmail = await getIt<SecureStorageService>().getEmail();
//     if (!mounted) return;
//
//     if (customerEmail == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Customer email not found")));
//       return;
//     }
//
//     final paymentAmount = double.tryParse(_amountController.text);
//
//     if (paymentAmount == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter a valid amount")),
//       );
//       return;
//     }
//
//     if (paymentAmount < _minAmount) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Minimum payment amount is \$1")),
//       );
//       return;
//     }
//
//     if (paymentAmount > _maxAmount) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Maximum payment amount is \$100,000")),
//       );
//       return;
//     }
//
//     _paymentAmount = paymentAmount;
//     _reference = DateTime.now().millisecondsSinceEpoch.toString();
//
//     context.read<PaymentCubit>().pay(
//       customerEmail: customerEmail,
//       merchantEmail: widget.merchantEmail,
//       amount: _paymentAmount,
//       reference: _reference,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<PaymentCubit, PaymentState>(
//       listener: (context, state) {
//         if (state is PaymentSuccess) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(const SnackBar(content: Text("Payment Successful")));
//           context.push(
//             AppRoutes.transferSuccess,
//             extra: {
//               "merchantName": _displayName,
//               "amount": double.parse(_amountController.text),
//               "reference": DateTime.now().millisecondsSinceEpoch.toString(),
//             },
//           );
//         }
//
//         if (state is PaymentFailure) {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text(state.message)));
//         }
//       },
//       child: Scaffold(
//         backgroundColor: ThemeColors.white,
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(AppSizes.paddingXs),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Align(
//                   alignment: Alignment.centerLeft,
//                   child: IconButton(
//                     splashRadius: AppSizes.radius2Xl,
//                     icon: Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       size: AppSizes.iconMd,
//                       color: AppColors.black,
//                     ),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                 ),
//
//                 CircleAvatar(
//                   radius: 8.w,
//                   backgroundColor: AppColors.accentSoft,
//                   child: Text(
//                     _initials(_displayName),
//                     style: AppTextStyles.titleLarge.copyWith(fontSize: 18.sp),
//                   ),
//                 ),
//
//                 SizedBox(height: 2.h),
//
//                 Text(
//                   _displayName,
//                   style: AppTextStyles.headlineMedium.copyWith(fontSize: 21.sp),
//                   textAlign: TextAlign.center,
//                 ),
//
//                 SizedBox(height: .7.h),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.verified,
//                       color: AppColors.blue,
//                       size: AppSizes.iconSm,
//                     ),
//                     SizedBox(width: 1.w),
//                     Text("Verified Merchant", style: AppTextStyles.bodyMedium),
//                   ],
//                 ),
//
//                 Expanded(child: Center(child: _amountSection())),
//
//                 BlocBuilder<PaymentCubit, PaymentState>(
//                   builder: (context, state) {
//                     final loading = state is PaymentLoading;
//                     final disabled = loading || _isOverLimit;
//
//                     return SizedBox(
//                       width: double.infinity,
//                       child: AppButton(
//                         label: loading ? "Processing..." : "Proceed",
//                         prefixIcon: loading ? null : Icons.verified_rounded,
//                         isLoading: loading,
//                         onPressed: disabled ? null : _pay,
//                       ),
//                     );
//                   },
//                 ),
//
//                 SizedBox(height: 2.h),
//
//                 _keypad(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _amountSection() {
//     final symbol = _selectedCurrency == "USD" ? "\$" : "BIGOD";
//
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.only(top: 1.8.h, right: 1.w),
//               child: Text(
//                 symbol,
//                 style: AppTextStyles.displayLarge.copyWith(
//                   fontSize: symbol == "\$" ? 22.sp : 14.sp,
//                   color: AppColors.textSecondary,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             Flexible(
//               child: FittedBox(
//                 fit: BoxFit.scaleDown,
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   _amountController.text.isEmpty ? "0" : _amountController.text,
//                   style: AppTextStyles.displayLarge.copyWith(
//                     fontSize: 35.sp,
//                     fontWeight: FontWeight.bold,
//                     color: _amountController.text.isEmpty
//                         ? Colors.grey[400]
//                         : ThemeColors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         if (_isOverLimit)
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
//             child: Text(
//               "You can only send upto \$${_maxAmount.toStringAsFixed(1)} at a time.\nPlease enter a lower amount.",
//               textAlign: TextAlign.center,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: Colors.red,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//
//         SizedBox(height: 1.5.h),
//
//         GestureDetector(
//           onTap: () =>
//               _changeCurrency(_selectedCurrency == "USD" ? "BIGOD" : "USD"),
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
//             decoration: BoxDecoration(
//               color: AppColors.accentSoft,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   _selectedCurrency,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(width: 1.5.w),
//                 Icon(
//                   Icons.swap_horiz_rounded,
//                   size: 16.sp,
//                   color: AppColors.blue,
//                 ),
//                 SizedBox(width: 1.5.w),
//                 Text(
//                   _selectedCurrency == "USD" ? "BIGOD" : "USD",
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         SizedBox(height: 0.8.h),
//
//         Text(
//           _convertedAmountLabel,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: AppColors.textSecondary,
//           ),
//         ),
//       ],
//     );
//   }
//
//   bool get _isOverLimit {
//     final amount = double.tryParse(_amountController.text) ?? 0;
//     return amount > _maxAmount;
//   }
//
//   String get _convertedAmountLabel {
//     final amount = double.tryParse(_amountController.text) ?? 0;
//     if (_selectedCurrency == "USD") {
//       return "≈ ${(amount * _usdToBigod).toStringAsFixed(8)} BIGOD";
//     } else {
//       return "≈ \$${(amount / _usdToBigod).toStringAsFixed(2)} USD";
//     }
//   }
//
//   Widget _keypad() {
//     Widget row(List<Widget> keys) => Padding(
//       padding: EdgeInsets.symmetric(vertical: 0.8.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: keys,
//       ),
//     );
//
//     return Column(
//       children: [
//         row([
//           _keyButton("1", onTap: () => _onKeypadDigit("1")),
//           _keyButton("2", onTap: () => _onKeypadDigit("2")),
//           _keyButton("3", onTap: () => _onKeypadDigit("3")),
//         ]),
//         row([
//           _keyButton("4", onTap: () => _onKeypadDigit("4")),
//           _keyButton("5", onTap: () => _onKeypadDigit("5")),
//           _keyButton("6", onTap: () => _onKeypadDigit("6")),
//         ]),
//         row([
//           _keyButton("7", onTap: () => _onKeypadDigit("7")),
//           _keyButton("8", onTap: () => _onKeypadDigit("8")),
//           _keyButton("9", onTap: () => _onKeypadDigit("9")),
//         ]),
//         row([
//           _keyButton(".", onTap: _onKeypadDecimal),
//           _keyButton("0", onTap: () => _onKeypadDigit("0")),
//           _keyButton(
//             "",
//             icon: Icons.backspace_outlined,
//             background: Colors.black87,
//             iconColor: Colors.white,
//             onTap: _onKeypadBackspace,
//           ),
//         ]),
//       ],
//     );
//   }
//
//   Widget _keyButton(
//     String label, {
//     required VoidCallback onTap,
//     Color background = const Color(0xFFF2F2F5),
//     Color textColor = Colors.black,
//     IconData? icon,
//     Color? iconColor,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: 20.w,
//         height: 7.h,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: background,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: icon != null
//             ? Icon(icon, color: iconColor ?? Colors.black, size: 18.sp)
//             : Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.w600,
//                   color: textColor,
//                 ),
//               ),
//       ),
//     );
//   }
// }
