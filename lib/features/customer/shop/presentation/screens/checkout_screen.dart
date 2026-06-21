import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../widgets/shop_widgets.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShopBloc, ShopState>(
      listenWhen: (previous, current) =>
          previous.checkoutStatus != current.checkoutStatus,
      listener: (context, state) {
        if (state.checkoutStatus == CheckoutStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order placed! ID: ${state.lastOrderId}')),
          );
          context.read<ShopBloc>().add(const ShopCheckoutReset());
          context.go(AppRoutes.buyerDashboard);
        } else if (state.checkoutStatus == CheckoutStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.checkoutError ?? 'Failed to place order'),
            ),
          );
        }
      },
      child: BlocBuilder<ShopBloc, ShopState>(
        builder: (context, state) {
          final isSubmitting = state.checkoutStatus == CheckoutStatus.submitting;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Checkout', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'Review your order below. Payment is collected on delivery.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppDimensions.md),
                        _LineItem(label: 'Items', value: '${state.cartCount}'),
                        _LineItem(
                          label: 'Payment method',
                          value: 'Cash on delivery',
                        ),
                        _LineItem(
                          label: 'Total',
                          value: formatCurrency(state.cartTotal),
                          emphasize: true,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Place order',
                    isLoading: isSubmitting,
                    onPressed: state.cartItems.isEmpty
                        ? null
                        : () {
                            final authState = context.read<AuthBloc>().state;
                            final user = authState is AuthAuthenticated
                                ? authState.user
                                : null;
                            context.read<ShopBloc>().add(
                                  ShopCheckoutSubmitted(
                                    customerName: user?.name ?? '',
                                    customerPhone: user?.phone ?? '',
                                  ),
                                );
                          },
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  TextButton(
                    onPressed: isSubmitting
                        ? null
                        : () => context.go(AppRoutes.buyerCart),
                    child: const Text('Back to cart'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _LineItem({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: emphasize ? FontWeight.w700 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}
