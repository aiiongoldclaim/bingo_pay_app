// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../cubit/wishlist_cubit.dart';
// import '../cubit/wishlist_state.dart';
// import '../widgets/wishlist_card.dart';
//
// class WishlistScreen extends StatelessWidget {
//   const WishlistScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeColors.background,
//       appBar: AppBar(
//         backgroundColor: ThemeColors.background,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         title: const Text('Wishlist'),
//       ),
//       body: BlocBuilder<WishlistCubit, WishlistState>(
//         builder: (context, state) {
//           if (state.items.isEmpty) {
//             return const _EmptyWishlist();
//           }
//
//           return GridView.builder(
//             padding: EdgeInsets.all(4.w),
//             itemCount: state.items.length,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.56,
//               crossAxisSpacing: 3.w,
//               mainAxisSpacing: 2.h,
//             ),
//             itemBuilder: (context, index) {
//               final item = state.items[index];
//               return WishlistCard(
//                 item: item,
//                 onTap: () => context.push(
//                   AppRoutes.productDetails,
//                   extra: item.id,
//                 ),
//                 onRemove: () => context.read<WishlistCubit>().remove(item.id),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// class _EmptyWishlist extends StatelessWidget {
//   const _EmptyWishlist();
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 10.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               Icons.favorite_border_rounded,
//               size: 48.sp,
//               color: ThemeColors.inkDim,
//             ),
//             SizedBox(height: 2.h),
//             Text(
//               'Your wishlist is empty',
//               style: AppTextStyles.titleMedium.copyWith(
//                 color: ThemeColors.inkMid,
//               ),
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               'Tap the heart icon on any product to save it here.',
//               textAlign: TextAlign.center,
//               style: AppTextStyles.bodyMedium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/image_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../product_details/data/models/product_details_model.dart';
import '../../data/models/wishlist_model.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';
import '../widgets/promo_banner.dart';
import '../widgets/wishlist_card.dart';
import '../widgets/wishlist_metrics.dart';
import '../widgets/wishlist_variant.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final Set<String> _pendingIds = {};

  void _openProduct(BuildContext context, WishlistItem item) {
    context.push(AppRoutes.productDetails, extra: item.id);
  }

  Future<void> _moveToBag(BuildContext context, WishlistItem item) async {
    if (_pendingIds.contains(item.id)) return;

    final cartCubit = context.read<CartCubit>();
    final wishlistCubit = context.read<WishlistCubit>();
    final repository = getIt<WishlistRepository>();

    setState(() => _pendingIds.add(item.id));

    try {
      var variantUuid = item.variantUuid;

      if (variantUuid == null || variantUuid.isEmpty) {
        ProductDetailModel? product;
        try {
          product = await repository.getProductDetail(item.id);
        } catch (_) {
          product = null;
        }

        if (!mounted) return;

        if (product == null) {
          AppSnackbar.showError(
            context,
            'This product is currently unavailable',
          );
          return;
        }

        final inStockVariants = product.variants
            .where((v) => v.availableStock > 0 && v.uuid.isNotEmpty)
            .toList();

        // More than one purchasable option — don't guess which one the
        // user wants, send them to the product page to pick explicitly,
        // same as the normal PDP add-to-cart flow requires.
        if (inStockVariants.length > 1) {
          AppSnackbar.showError(
            context,
            'This item has multiple options in stock — pick one on the product page to add it to your bag.',
          );
          _openProduct(context, item);
          return;
        }

        final chosen = inStockVariants.isNotEmpty
            ? inStockVariants.first
            : (product.variants.isNotEmpty ? product.variants.first : null);
        variantUuid = chosen?.uuid;
      }

      if (!mounted) return;

      if (variantUuid == null || variantUuid.isEmpty) {
        AppSnackbar.showError(
          context,
          'This product is currently unavailable',
        );
        return;
      }

      final result =
          await cartCubit.addItem(variantUuid: variantUuid, quantity: 1);
      if (!mounted) return;

      if (!result.success) {
        AppSnackbar.showError(
          context,
          result.errorMessage ?? 'Something went wrong. Please try again.',
        );
        return;
      }

      await wishlistCubit.remove(item.id);
      if (!mounted) return;

      AppSnackbar.showSuccess(context, '${item.name} moved to bag');
    } finally {
      if (mounted) setState(() => _pendingIds.remove(item.id));
    }
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final c = context.c;
    final cubit = context.read<WishlistCubit>();
    final items = List<WishlistItem>.from(cubit.state.items);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(
          'Clear wishlist?',
          style: AppTextStyles.titleMedium.copyWith(color: c.textPrimary),
        ),
        content: Text(
          'All saved items will be removed.',
          style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Clear', style: TextStyle(color: c.statusWarning)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    for (final item in items) {
      await cubit.remove(item.id);
    }
  }

  void _showItemSheet(BuildContext context, WishlistItem item) {
    final colors = context.c;
    final m = WishlistMetrics.of(context);
    final cubit = context.read<WishlistCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(m.cardRadius + 4),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: m.gapSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: m.gapMd),
            ListTile(
              leading: Icon(Icons.open_in_new_rounded, color: colors.textSecondary),
              title: Text(
                'View Product',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: m.nameSize,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                _openProduct(context, item);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.favorite_border_rounded,
                color: colors.statusWarning,
              ),
              title: Text(
                'Remove from Wishlist',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: m.nameSize,
                ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                cubit.remove(item.id);
              },
            ),
            SizedBox(height: m.gapSm),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        final colors = context.colors;
        final metrics = WishlistMetrics.of(context);
        final items = state.items;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: CustomAppBar(
            title: 'Wishlist',
            actionIcon1: Icons.search_rounded,
            onAction1: () => context.push(AppRoutes.search),
            actionIcon2: items.isEmpty ? null : Icons.delete_outline_rounded,
            onAction2: items.isEmpty ? null : () => _confirmClearAll(context),
          ),
          body: SafeArea(
            bottom: false,
            child: items.isEmpty
                ? WishlistEmptyView(metrics: metrics)
                : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: metrics.maxContentWidth,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        metrics.pageHPad,
                        metrics.gapMd,
                        metrics.pageHPad,
                        metrics.gapMd,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: metrics.crossAxisCount,
                          childAspectRatio: metrics.cardAspectRatio,
                          crossAxisSpacing: metrics.gridSpacing,
                          mainAxisSpacing: metrics.gridSpacing,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final item = items[index];
                            return WishlistCard(
                              item: item,
                              metrics: metrics,
                              isPending: _pendingIds.contains(item.id),
                              onTap: () => _openProduct(context, item),
                              onRemove: () => context
                                  .read<WishlistCubit>()
                                  .remove(item.id),
                              onMoveToBag: () => _moveToBag(context, item),
                              onMore: () => _showItemSheet(context, item),
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        metrics.pageHPad,
                        0,
                        metrics.pageHPad,
                        metrics.gapLg,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: AppPromoBanner(
                          title: 'Good things\nare waiting!',
                          subtitle:
                          'Add more items you love\nto your wishlist.',
                          buttonLabel: 'Explore Now',
                          imagePath: AppImages.wishlistImg,
                          fallbackIcon: Icons.shopping_bag_rounded,
                          onPressed: () => context.go(AppRoutes.home),
                          padding: metrics.promoPad,
                          radius: metrics.promoRadius,
                          titleSize: metrics.promoTitleSize,
                          subtitleSize: metrics.promoSubSize,
                          buttonHeight: metrics.promoBtnHeight,
                          buttonFontSize: metrics.promoBtnFontSize,
                          artSize: metrics.promoArtSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────
class WishlistEmptyView extends StatelessWidget {
  final WishlistMetrics metrics;

  const WishlistEmptyView({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: metrics.pageHPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // SizedBox(
            //   width: metrics.emptyIllustration,
            //   height: metrics.emptyIllustration,
            //   child: Lottie.asset(
            //     'assets/animations/empty_wishlist.json',
            //     fit: BoxFit.contain,
            //     repeat: true,
            //   ),
            // ),
            Container(
              width: metrics.emptyIllustration,
              height: metrics.emptyIllustration,
              decoration: BoxDecoration(
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.favorite_border_rounded,
                size: metrics.emptyIllustration * 0.42,
                color: colors.brand,
              ),
            ),

            SizedBox(height: metrics.gapLg),

            Text(
              'Your wishlist is empty',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: metrics.emptyTitleSize,
              ),
            ),

            SizedBox(height: metrics.gapSm),

            Text(
              'Tap the heart icon on any product\nto save it here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: metrics.emptySubSize,
                height: 1.45,
              ),
            ),

            SizedBox(height: metrics.gapLg),

            SizedBox(
              width: metrics.isTablet ? 260 : null,
              height: metrics.promoBtnHeight,
              child: Material(
                color: colors.brand,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go(AppRoutes.home),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: metrics.promoPad,
                    ),
                    child: Center(
                      child: Text(
                        'EXPLORE NOW',
                        style: AppTextStyles.buttonText.copyWith(
                          color: colors.onBrand,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: metrics.promoBtnFontSize,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
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