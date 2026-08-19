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

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../data/models/wishlist_model.dart';
import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';
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

    setState(() => _pendingIds.add(item.id));

    try {
      var variantUuid = item.variantUuid;
      if (variantUuid == null || variantUuid.isEmpty) {
        variantUuid = await WishlistVariantResolver.resolve(item.id);
      }

      if (!mounted) return;

      if (variantUuid == null || variantUuid.isEmpty) {
        AppSnackbar.showError(
          context,
          'This product is currently unavailable',
        );
        return;
      }

      await cartCubit.addItem(variantUuid: variantUuid, quantity: 1);
      if (!mounted) return;

      final error = cartCubit.state.error;
      if (error != null) {
        AppSnackbar.showError(context, error);
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
    final c = context.c;
    final m = WishlistMetrics.of(context);
    final cubit = context.read<WishlistCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
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
                color: c.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: m.gapMd),
            ListTile(
              leading: Icon(Icons.open_in_new_rounded, color: c.textSecondary),
              title: Text(
                'View Product',
                style: AppTextStyles.labelLarge.copyWith(
                  color: c.textPrimary,
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
                color: c.statusWarning,
              ),
              title: Text(
                'Remove from Wishlist',
                style: AppTextStyles.labelLarge.copyWith(
                  color: c.textPrimary,
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
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<WishlistCubit, WishlistState>(
          builder: (context, state) {
            final m = WishlistMetrics.of(context);
            final items = state.items;

            return Column(
              children: [
                _WishlistTopBar(
                  metrics: m,
                  count: items.length,
                  onClearAll: items.isEmpty
                      ? null
                      : () => _confirmClearAll(context),
                ),

                Expanded(
                  child: items.isEmpty
                      ? WishlistEmptyView(metrics: m)
                      : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: m.maxContentWidth,
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              m.pageHPad,
                              m.gapMd,
                              m.pageHPad,
                              m.gapMd,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: m.crossAxisCount,
                                childAspectRatio: m.cardAspectRatio,
                                crossAxisSpacing: m.gridSpacing,
                                mainAxisSpacing: m.gridSpacing,
                              ),
                              delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                  ) {
                                final item = items[index];
                                return WishlistCard(
                                  item: item,
                                  metrics: m,
                                  isPending: _pendingIds.contains(item.id),
                                  onTap: () => _openProduct(context, item),
                                  onRemove: () => context
                                      .read<WishlistCubit>()
                                      .remove(item.id),
                                  onMoveToBag: () => _moveToBag(context, item),
                                  onMore: () => _showItemSheet(context, item),
                                );
                              }, childCount: items.length),
                            ),
                          ),

                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              m.pageHPad,
                              0,
                              m.pageHPad,
                              m.gapLg,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _PromoBanner(metrics: m),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Top bar: title + count + search/delete ────────────────────────────────
class _WishlistTopBar extends StatelessWidget {
  final WishlistMetrics metrics;
  final int count;
  final VoidCallback? onClearAll;

  const _WishlistTopBar({
    required this.metrics,
    required this.count,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.pageVPad,
        m.pageHPad * 0.5,
        m.pageVPad * 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: m.gapXs),
            child: IconButton(
              onPressed: () => context.pop(),
              splashRadius: m.topIconSize * 1.2,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: m.topIconSize,
                color: c.textPrimary,
              ),
            ),
          ),
          SizedBox(width: m.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [


                Text(
                  'Wishlist',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  '$count Item${count == 1 ? '' : 's'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.subtitleSize,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => context.push(AppRoutes.search),
            splashRadius: m.topIconSize * 1.2,
            icon: Icon(
              Icons.search_rounded,
              size: m.topIconSize + 2,
              color: c.textPrimary,
            ),
          ),
          IconButton(
            onPressed: onClearAll,
            splashRadius: m.topIconSize * 1.2,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: m.topIconSize,
              color: onClearAll == null ? c.textMuted : c.brand,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Promo banner ──────────────────────────────────────────────────────────
class _PromoBanner extends StatelessWidget {
  final WishlistMetrics metrics;

  const _PromoBanner({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.promoPad),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.promoRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Good things\nare waiting!',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.bold,
                    fontSize: m.promoTitleSize,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: m.gapSm),
                Text(
                  'Add more items you love\nto your wishlist.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.promoSubSize,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: m.gapMd),
                SizedBox(
                  height: m.promoBtnHeight,
                  child: Material(
                    color: c.brand,
                    borderRadius: BorderRadius.circular(10),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.go(AppRoutes.home),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: m.promoPad * 0.8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore Now',
                              style: AppTextStyles.buttonText.copyWith(
                                color: c.surface,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: m.promoBtnFontSize,
                              ),
                            ),
                            SizedBox(width: m.gapSm),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: m.promoBtnFontSize + 4,
                              color: c.surface,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: m.gapSm),

          // Illustration placeholder — SVG asset mile to swap kar denge
          SizedBox(
            width: m.promoArtSize,
            height: m.promoArtSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: m.promoArtSize * 0.72,
                  height: m.promoArtSize * 0.72,
                  decoration: BoxDecoration(
                    color: c.brand,
                    borderRadius: BorderRadius.circular(m.promoRadius * 0.6),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.favorite,
                    size: m.promoArtSize * 0.3,
                    color: c.surface,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: m.promoArtSize * 0.06,
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    size: m.promoArtSize * 0.26,
                    color: c.brand,
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: m.promoArtSize * 0.08,
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    size: m.promoArtSize * 0.2,
                    color: c.brand.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────
class WishlistEmptyView extends StatelessWidget {
  final WishlistMetrics metrics;

  const WishlistEmptyView({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.emptyIllustration,
              height: m.emptyIllustration,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.favorite_border_rounded,
                size: m.emptyIllustration * 0.42,
                color: c.brand,
              ),
            ),

            SizedBox(height: m.gapLg),

            Text(
              'Your wishlist is empty',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.emptyTitleSize,
              ),
            ),

            SizedBox(height: m.gapSm),

            Text(
              'Tap the heart icon on any product\nto save it here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.emptySubSize,
                height: 1.45,
              ),
            ),

            SizedBox(height: m.gapLg),

            SizedBox(
              width: m.isTablet ? 260 : null,
              height: m.promoBtnHeight,
              child: Material(
                color: c.brand,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go(AppRoutes.home),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: m.promoPad),
                    child: Center(
                      child: Text(
                        'EXPLORE NOW',
                        style: AppTextStyles.buttonText.copyWith(
                          color: c.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.promoBtnFontSize,
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