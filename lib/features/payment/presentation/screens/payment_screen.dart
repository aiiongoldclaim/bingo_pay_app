import 'package:bingo_pay/core/constants/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'review_pay_screen.dart';
import 'widgets/payment_address_card.dart';
import 'widgets/payment_method_option.dart';
import 'widgets/payment_progress_stepper.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    int selectedMethod = 0;

    return BlocProvider(
      create: (_) => PaymentMethodCubit(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColors.surface,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            // leading: Icon(Icons.arrow_back_ios_new_outlined),
            title: 'Payment',
            actionIcon1: Icons.security,
            onAction1: () {},
          ),

          bottomNavigationBar:
              BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
                builder: (context, state) {
                  return AppBottomActionBar(
                    primaryLabel: 'Continue to Pay',
                    secondaryLabel: 'Need Help',
                    secondaryIcon: Icons.headphones_outlined,

                    onPrimaryPressed: () {
                      final cubit = context.read<PaymentMethodCubit>();

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

                    onSecondaryPressed: () {
                      // Open support screen / chat
                    },
                  );
                },
              ),

          // AppBar(
          //   backgroundColor: AppColors.surface,
          //   elevation: 0,
          //   title: Text('Payment', style: AppTextStyles.titleLarge),
          //   leading: IconButton(
          //     icon: const Icon(Icons.arrow_back_ios, color: ThemeColors.ink),
          //     onPressed: () => Navigator.pop(context),
          //   ),
          //   actions: const [
          //     Padding(
          //       padding: EdgeInsets.only(right: 16),
          //       child: Row(
          //         children: [
          //           Icon(Icons.lock, size: 18, color: ThemeColors.green),
          //           SizedBox(width: 4),
          //           Text(
          //             'Secure',
          //             style: TextStyle(
          //               color: ThemeColors.green,
          //               fontWeight: FontWeight.w500,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          body: BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.radiusMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: AppDimensions.lg),

                    // Progress Stepper
                    const PaymentProgressStepper(currentStep: 3),

                    SizedBox(height: AppSizes.radiusSm),

                    // Address Card
                    PaymentAddressCard(
                      addressType: 'Home',
                      address: '14 Lotus Residency, Bandra West, Mumbai 400050',
                      onChange: () {
                        // Navigate to address screen
                      },
                    ),

                    SizedBox(height: AppSizes.radiusMd),

                    // Title
                    Text(
                      'CHOOSE PAYMENT METHOD',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: ThemeColors.inkMid,
                      ),
                    ),

                    SizedBox(height: AppDimensions.md),

                    //Payment Methods
                    PaymentMethodCard(
                      title: 'Bingo Wallet',
                      subtitle:
                          'Earn ${state.coinsEarned} Coins on this purchase',
                      icon: Icons.account_balance_wallet_outlined,
                      isSelected: state.selectedMethod == PaymentMethod.wallet,
                      onTap: () {
                        context.read<PaymentMethodCubit>().selectPaymentMethod(
                          PaymentMethod.wallet,
                        );
                      },
                    ),
                    SizedBox(height: AppDimensions.sm),
                    PaymentMethodCard(
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa •••• 4291',
                      icon: Icons.credit_card_outlined,
                      isSelected: state.selectedMethod == PaymentMethod.card,
                      onTap: () {
                        context.read<PaymentMethodCubit>().selectPaymentMethod(
                          PaymentMethod.card,
                        );
                      },
                    ),
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
