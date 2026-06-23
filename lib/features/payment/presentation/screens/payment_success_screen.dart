import 'package:bingo_pay/features/payment/presentation/screens/widgets/earned_coin_badge.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/invoice_card.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/success_action_bar.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/success_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: ThemeColors.blue,
          bottomNavigationBar: AppBottomActionBar(
            primaryLabel: 'Track Order',
            secondaryLabel: 'Invoice',
            secondaryIcon: Icons.download_outlined,
            secondaryIconColor: ThemeColors.black,
            secondaryTextColor: ThemeColors.black,

            onPrimaryPressed: () {
              // Navigate to order tracking screen
            },

            onSecondaryPressed: () {
              // Download invoice
            },
          ),

          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SuccessHeader(
                          orderId: state.orderId,
                          amount: state.formattedTotal,
                        ),

                        EarnedCoinBadge(coins: state.coinsEarned),

                        InvoiceCard(
                          orderId: state.orderId,
                          totalAmount: state.formattedTotal,
                          customerName: 'Aarav Mehta',
                          customerAddress:
                              '14 Lotus Residency, Bandra West, Mumbai 400050',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
