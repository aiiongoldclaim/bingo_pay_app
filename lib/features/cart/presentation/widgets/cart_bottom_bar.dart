import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../payment/presentation/screens/payment_screen.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final totalStr = '\$${state.subtotal.toStringAsFixed(0)}';
        // final totalStr = '\$${500}';

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Payable',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: ThemeColors.inkMid)),
                      Text(totalStr,
                          style: AppTextStyles.headlineMedium
                              .copyWith(color: const Color(0xFF1A1D4E))),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: 'Checkout',
                    onPressed: state.items.isEmpty
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  cartItems: state.items,
                                  productName:
                                      'Cart (${state.totalItems} items)',
                                ),
                              ),
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
