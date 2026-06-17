import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_state.dart';
import '../widgets/shop_widgets.dart';

class CheckoutPlaceholderScreen extends StatelessWidget {
  const CheckoutPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checkout', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'This step is ready for payment and shipping integration.',
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
                        label: 'Total',
                        value: formatCurrency(state.cartTotal),
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AppButton(
                  label: 'Back to cart',
                  onPressed: () => context.go(AppRoutes.buyerCart),
                ),
              ],
            ),
          ),
        );
      },
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
