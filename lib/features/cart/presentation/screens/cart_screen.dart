import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_body.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_empty_view.dart';
import '../widgets/cart_metrics.dart';
import '../widgets/cart_shimmer.dart';
import '../widgets/cart_wishlist_bridge.dart';

import '../../domain/entities/cart_item_entity.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Set<int> _deselected = {};

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCart();
  }

  void _toggleSelect(CartItemEntity item) {
    setState(() {
      _deselected.contains(item.id)
          ? _deselected.remove(item.id)
          : _deselected.add(item.id);
    });
  }

  void _moveToWishlist(CartItemEntity item) {
    CartWishlistBridge.moveOne(context, item);
    context.read<CartCubit>().removeItem(item.id);
    AppSnackbar.showSuccess(context, AppStrings.movedToWishlist);
  }

  void _moveAllToWishlist(List<CartItemEntity> items) {
    for (final item in items) {
      CartWishlistBridge.moveOne(context, item);
    }
    final cubit = context.read<CartCubit>();
    for (final item in items) {
      cubit.removeItem(item.id);
    }
    AppSnackbar.showSuccess(context, AppStrings.allItemsMovedToWishlist);
  }

  Future<void> _confirmClearCart(BuildContext context) async {
    final colors = context.c;
    final cubit = context.read<CartCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          AppStrings.clearCartTitle,
          style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          AppStrings.clearCartContent,
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              AppStrings.clear,
              style: TextStyle(color: colors.statusWarning),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await cubit.clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return BlocListener<CartCubit, CartState>(
      listenWhen: (previous, current) =>
          current.error != null && current.error != previous.error,
      listener: (context, state) {
        AppSnackbar.showError(context, state.error!);
      },
      child: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          final cubit = context.read<CartCubit>();
          final m = CartMetrics.of(context);

          final selectedItems = state.items
              .where((e) => !_deselected.contains(e.id))
              .toList();
          final selectedTotal = selectedItems.fold<double>(
            0,
            (sum, e) => sum + e.totalPrice,
          );
          final selectedCount = selectedItems.fold<int>(
            0,
            (sum, e) => sum + e.quantity,
          );

          return Scaffold(
            backgroundColor: colors.background,
            appBar: CustomAppBar(
              title: AppStrings.myCart,
              actionIcon1: Icons.favorite_border_rounded,
              onAction1: () => context.push(AppRoutes.buyerWishlist),
              actionIcon2: state.items.isEmpty
                  ? null
                  : Icons.delete_sweep_outlined,
              onAction2: state.items.isEmpty
                  ? null
                  : () => _confirmClearCart(context),
            ),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: state.isLoading
                        ? CartShimmer(metrics: m)
                        : state.items.isEmpty
                        ? RefreshIndicator(
                            color: colors.brand,
                            backgroundColor: colors.surface,
                            onRefresh: () => cubit.loadCart(),
                            child: CartEmptyView(metrics: m),
                          )
                        : RefreshIndicator(
                            color: colors.brand,
                            backgroundColor: colors.surface,
                            onRefresh: () => cubit.loadCart(),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: m.maxContentWidth,
                                ),
                                child: m.isLandscape
                                    ? CartLandscapeBody(
                                        state: state,
                                        cubit: cubit,
                                        metrics: m,
                                        deselected: _deselected,
                                        selectedTotal: selectedTotal,
                                        selectedCount: selectedCount,
                                        selectedItems: selectedItems,
                                        onToggleSelect: _toggleSelect,
                                        onMoveToWishlist: _moveToWishlist,
                                        onMoveAll: () =>
                                            _moveAllToWishlist(state.items),
                                      )
                                    : CartPortraitBody(
                                        state: state,
                                        cubit: cubit,
                                        metrics: m,
                                        deselected: _deselected,
                                        selectedTotal: selectedTotal,
                                        selectedCount: selectedCount,
                                        onToggleSelect: _toggleSelect,
                                        onMoveToWishlist: _moveToWishlist,
                                        onMoveAll: () =>
                                            _moveAllToWishlist(state.items),
                                      ),
                              ),
                            ),
                          ),
                  ),

                  if (state.items.isNotEmpty && !m.isLandscape)
                    CartBottomBar(
                      items: selectedItems,
                      total: selectedTotal,
                      itemCount: selectedCount,
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
