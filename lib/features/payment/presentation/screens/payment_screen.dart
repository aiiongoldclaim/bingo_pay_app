import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../cubit/payment_cubit.dart';
import 'review_pay_screen.dart';
import 'widgets/payment_address_card.dart';
import 'widgets/payment_method_option.dart';
import 'widgets/payment_progress_stepper.dart';


class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentCubit(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColors.surface,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              'Payment',
              style: AppTextStyles.titleLarge,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: ThemeColors.ink),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 18, color: ThemeColors.green),
                    SizedBox(width: 4),
                    Text(
                      'Secure',
                      style: TextStyle(
                        color: ThemeColors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: BlocBuilder<PaymentCubit, PaymentState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppDimensions.lg),

                    // Progress Stepper
                    const PaymentProgressStepper(currentStep: 3),

                    SizedBox(height: AppDimensions.xl),

                    // Address Card
                    const PaymentAddressCard(),

                    SizedBox(height: AppDimensions.xl),

                    // Title
                    Text(
                      'CHOOSE PAYMENT METHOD',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: ThemeColors.inkMid,
                      ),
                    ),

                    SizedBox(height: AppDimensions.md),

                    // Payment Methods
                    PaymentMethodOption(
                      icon: Icons.account_balance_wallet,
                      title: 'BINGOLD Wallet',
                      subtitle: 'Balance ₹12,480 · Instant',
                      trailing: 'Earn 2x coins',
                      method: PaymentMethod.bingoldWallet,
                      selectedMethod: state.selectedMethod,
                      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(PaymentMethod.bingoldWallet),
                    ),

                    PaymentMethodOption(
                      icon: Icons.language,
                      title: 'UPI',
                      subtitle: 'GPay, PhonePe, Paytm',
                      method: PaymentMethod.upi,
                      selectedMethod: state.selectedMethod,
                      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(PaymentMethod.upi),
                    ),

                    PaymentMethodOption(
                      icon: Icons.credit_card,
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa •••• 4291',
                      method: PaymentMethod.creditDebit,
                      selectedMethod: state.selectedMethod,
                      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(PaymentMethod.creditDebit),
                    ),

                    PaymentMethodOption(
                      icon: Icons.timer,
                      title: 'Pay Later',
                      subtitle: '0% EMI · 3 months',
                      method: PaymentMethod.payLater,
                      selectedMethod: state.selectedMethod,
                      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(PaymentMethod.payLater),
                    ),

                    PaymentMethodOption(
                      icon: Icons.local_shipping_outlined,
                      title: 'Cash on Delivery',
                      subtitle: '₹20 handling fee',
                      method: PaymentMethod.cashOnDelivery,
                      selectedMethod: state.selectedMethod,
                      onTap: () => context.read<PaymentCubit>().selectPaymentMethod(PaymentMethod.cashOnDelivery),
                    ),

                    SizedBox(height: AppDimensions.xl),

                    // Payable Amount
                    Container(
                      padding: EdgeInsets.all(AppDimensions.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payable',
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            state.formattedTotal,
                            style: AppTextStyles.titleLarge.copyWith(
                              color: ThemeColors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppDimensions.xxl),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          final cubit = context.read<PaymentCubit>();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: const ReviewPayScreen(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          ),
                        ),
                        child: Text(
                          'Continue to pay',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),

                    SizedBox(height: AppDimensions.xxl),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}