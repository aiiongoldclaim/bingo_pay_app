import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_items_card.dart';
import '../widgets/delivery_banner.dart';
import '../widgets/price_details.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartCubit, CartState>(
      listenWhen: (previous, current) =>
          current.error != null && current.error != previous.error,
      listener: (context, state) {
        AppSnackbar.showError(context, state.error!);
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
        final cubit = context.read<CartCubit>();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Color(0xFF1A1D4E), size: 20),
                        ),
                        Text(
                          'My Cart',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: const Color(0xFF1A1D4E),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (state.totalItems > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B2FA8).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${state.totalItems} item${state.totalItems == 1 ? '' : 's'}',
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: const Color(0xFF2B2FA8)),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (state.items.isNotEmpty)
                          TextButton(
                            onPressed: () => _confirmClear(context, cubit),
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: ThemeColors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.items.isEmpty
                        ? _EmptyCart()
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const FreeDeliveryBanner(),
                                const SizedBox(height: 16),

                                CartItemsCard(
                                  items: state.items,
                                  onIncrease: cubit.increaseQuantity,
                                  onDecrease: cubit.decreaseQuantity,
                                  onDelete: (item) => cubit.removeItem(item.id),
                                ),

                                const SizedBox(height: 16),

                                PriceDetailsCard(
                                  subtotal: state.totalAmount,
                                  itemCount: state.totalItems,
                                ),

                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
              ),

              if (state.items.isNotEmpty) const CartBottomBar(),
            ],
          ),
        );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, CartCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('All items will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              cubit.clearCart();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: ThemeColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: ThemeColors.inkDim),
          const SizedBox(height: 16),
          Text('Your cart is empty',
              style: TextStyle(color: ThemeColors.inkDim, fontSize: 16)),
        ],
      ),
    );
  }
}
