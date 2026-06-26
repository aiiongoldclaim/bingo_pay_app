import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class ReviewPaymentScreen extends StatefulWidget {
  final String? merchantName;
  final String merchantEmail;

  const ReviewPaymentScreen({
    super.key,
    required this.merchantName,
    required this.merchantEmail,
  });

  @override
  State<ReviewPaymentScreen> createState() => _ReviewPaymentScreenState();
}

class _ReviewPaymentScreenState extends State<ReviewPaymentScreen> {
  final TextEditingController _amountController = TextEditingController();

  double _paymentAmount = 0;
  String _reference = "";

  static const double _maxAmount = 100000; // 1 Lakh USD
  static const double _minAmount = 1;

  static const double _usdToBigod = 0.00001772;
  String _selectedCurrency = "USD";

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _changeCurrency(String? value) {
    if (value == null || value == _selectedCurrency) return;

    double amount = double.tryParse(_amountController.text) ?? 0;

    if (_selectedCurrency == "USD" && value == "BIGOD") {
      amount *= _usdToBigod;
    } else if (_selectedCurrency == "BIGOD" && value == "USD") {
      amount /= _usdToBigod;
    }

    setState(() {
      _selectedCurrency = value;
      _amountController.text = amount.toStringAsFixed(value == "USD" ? 2 : 8);

      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    });
  }

  Future<void> _pay() async {
    final customerEmail = await getIt<SecureStorageService>().getEmail();

    if (customerEmail == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Customer email not found")));
      return;
    }

    final paymentAmount = double.tryParse(_amountController.text);

    if (paymentAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    if (paymentAmount < _minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimum payment amount is \$1")),
      );
      return;
    }

    if (paymentAmount > _maxAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum payment amount is \$100,000")),
      );
      return;
    }

    _paymentAmount = paymentAmount;
    _reference = DateTime.now().millisecondsSinceEpoch.toString();

    context.read<PaymentCubit>().pay(
      customerEmail: customerEmail,
      merchantEmail: widget.merchantEmail,
      amount: _paymentAmount,
      reference: _reference,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Payment Successful")));
          context.push(
            AppRoutes.transferSuccess,
            extra: {
              "merchantName": widget.merchantName,
              "amount": double.parse(_amountController.text),
              "reference": DateTime.now().millisecondsSinceEpoch.toString(),
            },
          );
        }

        if (state is PaymentFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: ThemeColors.white,
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SafeArea(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    splashRadius: AppSizes.radius2Xl,
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: AppSizes.iconMd,
                      color: AppColors.black,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 8.w,
                backgroundColor: AppColors.accentSoft,
                child: Text(
                  widget.merchantEmail.substring(0, 2).toUpperCase(),
                  style: AppTextStyles.titleLarge.copyWith(fontSize: 18.sp),
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                widget.merchantName?.isNotEmpty == true
                    ? widget.merchantName!
                    : widget.merchantEmail,
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 21.sp),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: .7.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified,
                    color: AppColors.blue,
                    size: AppSizes.iconSm,
                  ),
                  SizedBox(width: 1.w),
                  Text("Verified Merchant", style: AppTextStyles.bodyMedium),
                ],
              ),
              SizedBox(height: 5.h),

              _amountSection(),

              const Spacer(),

              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  final loading = state is PaymentLoading;

                  return SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: loading ? "Processing..." : "Pay Now",
                      isLoading: loading,
                      onPressed: loading ? null : _pay,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 45.w,
          child: AppTextField(
            label: "",
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            cursorColor: ThemeColors.ink,

            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 50.sp,
              fontWeight: FontWeight.bold,
              color: ThemeColors.black,
            ),

            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}\$')),
            ],

            onChanged: (value) {
              final amount = double.tryParse(value);

              if (amount != null && amount > _maxAmount) {
                _amountController.text = _maxAmount.toStringAsFixed(2);

                _amountController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _amountController.text.length),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Maximum amount is \$100,000")),
                );
              }
            },

            decoration: InputDecoration(
              hintText: "0",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          // TextField(
          //   controller: _amountController,
          //   keyboardType: const TextInputType.numberWithOptions(decimal: true),
          //   textAlign: TextAlign.center,
          //   cursorColor: AppColors.black,
          //   style: AppTextStyles.displayLarge.copyWith(
          //     fontSize: 35.sp,
          //     fontWeight: FontWeight.w700,
          //     color: AppColors.black,
          //
          //   ),
          //   decoration: InputDecoration(
          //     hintText: "0",
          //     hintStyle: AppTextStyles.displayLarge.copyWith(
          //       fontSize: 40.sp,
          //       fontWeight: FontWeight.w700,
          //       color: Colors.grey.shade300,
          //     ),
          //     border: InputBorder.none,
          //     enabledBorder: InputBorder.none,
          //     focusedBorder: InputBorder.none,
          //     isDense: true,
          //     contentPadding: EdgeInsets.zero,
          //   ),
          // ),
        ),

        SizedBox(width: 3.w),

        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCurrency,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            style: AppTextStyles.titleMedium.copyWith(color: ThemeColors.ink),
            items: const [
              DropdownMenuItem(value: "USD", child: Text("USD")),
              DropdownMenuItem(value: "BIGOD", child: Text("BIGOD")),
            ],
            onChanged: _changeCurrency,
          ),
        ),
      ],
    );
  }
}
