// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../cubit/cart_cubit.dart';
// import '../cubit/cart_state.dart';
// import '../widgets/cart_bottom_bar.dart';
// import '../widgets/cart_items_card.dart';
// import '../widgets/delivery_banner.dart';
// import '../widgets/price_details.dart';
//
// class CartPage extends StatefulWidget {
//   const CartPage({super.key});
//
//   @override
//   State<CartPage> createState() => _CartPageState();
// }
//
// class _CartPageState extends State<CartPage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<CartCubit>().loadCart();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CartCubit, CartState>(
//       listenWhen: (previous, current) =>
//           current.error != null && current.error != previous.error,
//       listener: (context, state) {
//         AppSnackbar.showError(context, state.error!);
//       },
//       child: BlocBuilder<CartCubit, CartState>(
//         builder: (context, state) {
//           final cubit = context.read<CartCubit>();
//
//           return Scaffold(
//             backgroundColor: const Color(0xFFF5F6FA),
//             body: Column(
//               children: [
//                 // ── Header ───────────────────────────────────────────────
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.06),
//                         blurRadius: 12,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: SafeArea(
//                     bottom: false,
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(4, 8, 16, 12),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: () => Navigator.pop(context),
//                             icon: const Icon(
//                               Icons.arrow_back_ios_new,
//                               color: Color(0xFF1A1D4E),
//                               size: 20,
//                             ),
//                           ),
//                           Text(
//                             'My Cart',
//                             style: AppTextStyles.headlineMedium.copyWith(
//                               color: const Color(0xFF1A1D4E),
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                           if (state.totalItems > 0) ...[
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 3,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: const Color(
//                                   0xFF2B2FA8,
//                                 ).withValues(alpha: 0.1),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 '${state.totalItems} item${state.totalItems == 1 ? '' : 's'}',
//                                 style: AppTextStyles.labelMedium.copyWith(
//                                   color: const Color(0xFF2B2FA8),
//                                 ),
//                               ),
//                             ),
//                           ],
//                           const Spacer(),
//                           if (state.items.isNotEmpty)
//                             TextButton(
//                               onPressed: () => _confirmClear(context, cubit),
//                               child: const Text(
//                                 'Clear',
//                                 style: TextStyle(color: ThemeColors.red),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 Expanded(
//                   child: state.isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : state.items.isEmpty
//                       ? _EmptyCart()
//                       : SingleChildScrollView(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             children: [
//                               const FreeDeliveryBanner(),
//                               const SizedBox(height: 16),
//
//                               CartItemsCard(
//                                 items: state.items,
//                                 pendingItemIds: state.pendingItemIds,
//                                 onIncrease: cubit.increaseQuantity,
//                                 onDecrease: cubit.decreaseQuantity,
//                                 onDelete: (item) => cubit.removeItem(item.id),
//                               ),
//
//                               const SizedBox(height: 16),
//
//                               PriceDetailsCard(
//                                 subtotal: state.totalAmount,
//                                 itemCount: state.totalItems,
//                               ),
//
//                               const SizedBox(height: 16),
//                             ],
//                           ),
//                         ),
//                 ),
//
//                 if (state.items.isNotEmpty) const CartBottomBar(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   void _confirmClear(BuildContext context, CartCubit cubit) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Clear cart?'),
//         content: const Text('All items will be removed.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               cubit.clearCart();
//             },
//             child: const Text(
//               'Clear',
//               style: TextStyle(color: ThemeColors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _EmptyCart extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.shopping_cart_outlined,
//             size: 64,
//             color: ThemeColors.inkDim,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Your cart is empty',
//             style: TextStyle(color: ThemeColors.inkDim, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_items_card.dart';
import '../widgets/cart_metrics.dart';
import '../widgets/cart_shimmer.dart';
import '../widgets/cart_wishlist_bridge.dart';
import '../widgets/coupen_card.dart';
import '../widgets/delivery_banner.dart';
import '../widgets/price_details.dart';

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

  // ── Wishlist actions ──────────────────────────────────────────────────
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
            child: Text(AppStrings.cancel, style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(AppStrings.clear, style: TextStyle(color: colors.statusWarning)),
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
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _CartTopBar(
                    metrics: m,
                    hasItems: state.items.isNotEmpty,
                    onClearCart: () => _confirmClearCart(context),
                  ),
                  Expanded(
                    child: state.isLoading
                        ? CartShimmer(metrics: m)
                        : state.items.isEmpty
                        ? CartEmptyView(metrics: m)
                        : Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: m.maxContentWidth,
                              ),
                              child: m.isLandscape
                                  ? _LandscapeBody(
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
                                  : _PortraitBody(
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

// ── Top bar: back + TheVaults + wishlist + clear cart ─────────────────────
class _CartTopBar extends StatelessWidget {
  final CartMetrics metrics;
  final bool hasItems;
  final VoidCallback? onClearCart;

  const _CartTopBar({
    required this.metrics,
    this.hasItems = false,
    this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.15,
        m.pageHPad * 0.6,
        m.pageVPad * 0.15,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            splashRadius: m.backIconSize * 1.2,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize + 4,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(width: m.gapSm),
          Expanded(
            child: Text(
              AppStrings.myCart,
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.logoSize * 0.78,
                height: 1.1,
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.buyerWishlist),
            splashRadius: m.topIconSize * 1.2,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.favorite_border_rounded,
              size: m.topIconSize + 2,
              color: colors.textPrimary,
            ),
          ),
          if (hasItems)
            IconButton(
              onPressed: onClearCart,
              splashRadius: m.topIconSize * 1.2,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.delete_sweep_outlined,
                size: m.topIconSize + 2,
                color: colors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Title + subtitle + "Move All to Wishlist" ─────────────────────────────
class _CartTitleBlock extends StatelessWidget {
  final CartMetrics metrics;
  final int totalItems;
  final VoidCallback onMoveAll;

  const _CartTitleBlock({
    required this.metrics,
    required this.totalItems,
    required this.onMoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            AppStrings.cartItemsInBag(totalItems),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: m.pageSubtitleSize,
              height: 1.2,
            ),
          ),
        ),
        InkWell(
          onTap: onMoveAll,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: m.gapSm * 0.6,
              vertical: m.gapXs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: m.linkSize + 3,
                  color: colors.brand,
                ),
                SizedBox(width: m.gapSm * 0.5),
                Text(
                  AppStrings.moveAllToWishlist,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.brand,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.linkSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Portrait / phone ──────────────────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final CartState state;
  final CartCubit cubit;
  final CartMetrics metrics;
  final Set<int> deselected;
  final double selectedTotal;
  final int selectedCount;
  final void Function(CartItemEntity) onToggleSelect;
  final void Function(CartItemEntity) onMoveToWishlist;
  final VoidCallback onMoveAll;

  const _PortraitBody({
    required this.state,
    required this.cubit,
    required this.metrics,
    required this.deselected,
    required this.selectedTotal,
    required this.selectedCount,
    required this.onToggleSelect,
    required this.onMoveToWishlist,
    required this.onMoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapXs, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CartTitleBlock(
            metrics: m,
            totalItems: state.totalItems,
            onMoveAll: onMoveAll,
          ),
          SizedBox(height: m.gapMd),
          const FreeDeliveryBanner(),
          SizedBox(height: m.gapMd),
          CartItemsCard(
            items: state.items,
            deselectedIds: deselected,
            pendingItemIds: state.pendingItemIds,
            onToggleSelect: onToggleSelect,
            onMoveToWishlist: onMoveToWishlist,
            onIncrease: cubit.increaseQuantity,
            onDecrease: cubit.decreaseQuantity,
            onDelete: (item) => cubit.removeItem(item.id),
          ),
          SizedBox(height: m.gapMd),
          const CartCouponCard(),
          SizedBox(height: m.gapMd),
          PriceDetailsCard(subtotal: selectedTotal, itemCount: selectedCount),
        ],
      ),
    );
  }
}

// ── Tablet landscape ──────────────────────────────────────────────────────
class _LandscapeBody extends StatelessWidget {
  final CartState state;
  final CartCubit cubit;
  final CartMetrics metrics;
  final Set<int> deselected;
  final double selectedTotal;
  final int selectedCount;
  final List<CartItemEntity> selectedItems;
  final void Function(CartItemEntity) onToggleSelect;
  final void Function(CartItemEntity) onMoveToWishlist;
  final VoidCallback onMoveAll;

  const _LandscapeBody({
    required this.state,
    required this.cubit,
    required this.metrics,
    required this.deselected,
    required this.selectedTotal,
    required this.selectedCount,
    required this.selectedItems,
    required this.onToggleSelect,
    required this.onMoveToWishlist,
    required this.onMoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CartTitleBlock(
                    metrics: m,
                    totalItems: state.totalItems,
                    onMoveAll: onMoveAll,
                  ),
                  SizedBox(height: m.gapMd),
                  const FreeDeliveryBanner(),
                  SizedBox(height: m.gapMd),
                  CartItemsCard(
                    items: state.items,
                    deselectedIds: deselected,
                    pendingItemIds: state.pendingItemIds,
                    onToggleSelect: onToggleSelect,
                    onMoveToWishlist: onMoveToWishlist,
                    onIncrease: cubit.increaseQuantity,
                    onDecrease: cubit.decreaseQuantity,
                    onDelete: (CartItemEntity item) {},
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: m.gapLg),

          SizedBox(
            width: m.railWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: m.gapSm, bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CartCouponCard(),
                  SizedBox(height: m.gapMd),
                  PriceDetailsCard(
                    subtotal: selectedTotal,
                    itemCount: selectedCount,
                  ),
                  SizedBox(height: m.gapMd),
                  CartPayButton(
                    items: selectedItems,
                    total: selectedTotal,
                    itemCount: selectedCount,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────
class CartEmptyView extends StatelessWidget {
  final CartMetrics metrics;

  const CartEmptyView({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final illustrationSize = m.emptyIllustration * 1.15;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: m.pageHPad, vertical: m.gapLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: illustrationSize,
              height: illustrationSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: illustrationSize,
                    height: illustrationSize,
                    decoration: BoxDecoration(
                      color: c.brandSoft,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: illustrationSize * 0.78,
                    height: illustrationSize * 0.78,
                    decoration: BoxDecoration(
                      color: c.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: c.textPrimary.withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: illustrationSize * 0.38,
                      color: c.brand,
                    ),
                  ),
                  Positioned(
                    top: illustrationSize * 0.06,
                    right: illustrationSize * 0.08,
                    child: Container(
                      width: illustrationSize * 0.16,
                      height: illustrationSize * 0.16,
                      decoration: BoxDecoration(
                        color: c.brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.background, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: illustrationSize * 0.08,
                        color: c.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: m.gapLg),

            Text(
              AppStrings.cartEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: m.emptyTitleSize * 1.1,
              ),
            ),

            SizedBox(height: m.gapSm * 0.7),

            Text(
              AppStrings.cartEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.emptySubSize,
                height: 1.5,
              ),
            ),

            SizedBox(height: m.gapLg * 1.2),

            SizedBox(
              width: m.isTablet ? 300 : double.infinity,
              height: m.payHeight,
              child: Material(
                color: c.brand,
                borderRadius: BorderRadius.circular(m.payHeight / 2),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                child: InkWell(
                  onTap: () => context.go(AppRoutes.home),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.storefront_rounded,
                        size: m.payFontSize + 4,
                        color: c.surface,
                      ),
                      SizedBox(width: m.gapSm * 0.6),
                      Text(
                        AppStrings.startShopping,
                        style: AppTextStyles.buttonText.copyWith(
                          color: c.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.payFontSize,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
