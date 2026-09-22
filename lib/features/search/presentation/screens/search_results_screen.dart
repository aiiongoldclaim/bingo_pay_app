import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_product_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/variant_resolver.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../home/data/models/product_model.dart';
import '../../../home/data/repositories/all_products_repo.dart';
import '../../../home/presentation/widgets/products_grid_shimmer.dart';
import '../../../home/presentation/widgets/products_metrics.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key, required this.query});

  final String query;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  static const int _fetchLimit = 100;

  List<ProductModel> _results = [];
  bool _isLoading = true;
  bool _hasError = false;
  final Set<String> _addingIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant SearchResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _load();
  }

  bool _matches(ProductModel p, String needle) =>
      p.name.toLowerCase().contains(needle) ||
      p.brand.toLowerCase().contains(needle);

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final products = await getIt<ProductRepository>().getAllProducts(
        page: 1,
        limit: _fetchLimit,
      );
      if (!mounted) return;
      final needle = widget.query.trim().toLowerCase();
      setState(() {
        _results = products.where((p) => _matches(p, needle)).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    final uuid = product.uuid;
    if (uuid == null || _addingIds.contains(uuid)) return;

    final cartCubit = context.read<CartCubit>();
    setState(() => _addingIds.add(uuid));

    try {
      final variantUuid = await VariantResolver.resolve(uuid);
      if (!mounted) return;

      if (variantUuid == null || variantUuid.isEmpty) {
        AppSnackbar.showError(context, AppStrings.productCurrentlyUnavailable);
        return;
      }

      final result = await cartCubit.addItem(
        variantUuid: variantUuid,
        quantity: 1,
      );
      if (!mounted) return;

      if (!result.success) {
        AppSnackbar.showError(
          context,
          result.errorMessage ?? AppStrings.genericAddItemError,
        );
        return;
      }

      AppSnackbar.showSuccessWithAction(
        context,
        AppStrings.itemAddedToCart(product.name),
        actionLabel: AppStrings.goToCart,
        onAction: () => context.push(AppRoutes.cart),
      );
    } finally {
      if (mounted) setState(() => _addingIds.remove(uuid));
    }
  }

  Future<void> _toggleWishlist(ProductModel product, bool isAdded) async {
    if (product.uuid == null) return;

    final cubit = context.read<WishlistCubit>();
    final buildContext = context;

    await cubit.toggle(
      WishlistItem(
        id: product.uuid!,
        brand: product.brand,
        name: product.name,
        price: product.price,
        originalPrice: product.oldPrice.isNotEmpty ? product.oldPrice : null,
        discountPercent: product.discount > 0 ? product.discount : null,
        imageUrl: product.images.isNotEmpty ? product.images.first : null,
        rating: product.rating,
      ),
      wasWishlisted: !isAdded,
    );

    if (isAdded && buildContext.mounted) {
      AppSnackbar.showSuccess(buildContext, AppStrings.wishlistAdded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = ProductsMetrics.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(title: widget.query,),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.maxContentWidth,
                        ),
                        child: ProductsGridShimmer(metrics: m),
                      ),
                    )
                  : _hasError
                  ? _MessageView(
                      metrics: m,
                      icon: Icons.wifi_off_rounded,
                      title: AppStrings.failedToLoadProducts,
                      subtitle: AppStrings.checkConnectionRetryLater,
                      actionLabel: AppStrings.retryUppercase,
                      onAction: _load,
                    )
                  : _results.isEmpty
                  ? _MessageView(
                      metrics: m,
                      icon: Icons.search_off_rounded,
                      title: AppStrings.noSearchResultsTitle,
                      subtitle: AppStrings.noSearchResultsSubtitle(
                        widget.query,
                      ),
                      actionLabel: AppStrings.browseAllProductsUppercase,
                      onAction: () =>
                          context.pushReplacement(AppRoutes.allProducts),
                    )
                  : RefreshIndicator(
                      color: colors.brand,
                      backgroundColor: colors.surface,
                      onRefresh: _load,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: m.maxContentWidth,
                          ),
                          child: _ResultsGrid(
                            metrics: m,
                            products: _results,
                            addingIds: _addingIds,
                            onAddToCart: _addToCart,
                            onGoToCart: () => context.push(AppRoutes.cart),
                            onToggleWishlist: _toggleWishlist,
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

// ── Grid ───────────────────────────────────────────────────────────────────
class _ResultsGrid extends StatelessWidget {
  final ProductsMetrics metrics;
  final List<ProductModel> products;
  final Set<String> addingIds;
  final void Function(ProductModel) onAddToCart;
  final VoidCallback onGoToCart;
  final void Function(ProductModel, bool) onToggleWishlist;

  const _ResultsGrid({
    required this.metrics,
    required this.products,
    required this.addingIds,
    required this.onAddToCart,
    required this.onGoToCart,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    final cartItems = context.watch<CartCubit>().state.items;
    final wishlist = context.watch<WishlistCubit>();

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapMd, m.pageHPad, m.gapLg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: m.crossAxisCount,
        crossAxisSpacing: m.gridSpacing,
        mainAxisSpacing: m.gridSpacing,
        childAspectRatio: m.cardAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final uuid = product.uuid;

        final isInCart =
            uuid != null && cartItems.any((i) => i.product.uuid == uuid);

        return AppProductCard(
          brand: product.brand,
          productName: product.name,
          price: product.price,
          oldPrice: product.oldPrice.isNotEmpty ? product.oldPrice : null,
          discountPercent: product.discount > 0 ? product.discount : null,
          imageUrl: product.images.isNotEmpty ? product.images.first : '',
          rating: product.rating,
          isOutOfStock: product.stock == 0,
          isFavourite: wishlist.isWishlisted(uuid),
          isInCart: isInCart,
          isAddingToCart: uuid != null && addingIds.contains(uuid),
          onFavouriteChanged: uuid == null
              ? null
              : (isAdded) => onToggleWishlist(product, isAdded),
          onAddToCart: uuid == null
              ? null
              : () => isInCart ? onGoToCart() : onAddToCart(product),
          onTap: uuid == null
              ? null
              : () => context.push(AppRoutes.productDetails, extra: uuid),
        );
      },
    );
  }
}

// ── Error / empty ──────────────────────────────────────────────────────────
class _MessageView extends StatelessWidget {
  final ProductsMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageView({
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
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
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: m.emptyIllustration * 0.42,
                color: colors.brand,
              ),
            ),
            SizedBox(height: m.gapLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.emptyTitleSize,
              ),
            ),
            SizedBox(height: m.gapSm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.emptySubSize,
                height: 1.45,
              ),
            ),
            SizedBox(height: m.gapLg),
            SizedBox(
              width: m.isTablet ? 240 : null,
              height: m.btnHeight,
              child: Material(
                color: colors.brand,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onAction,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
                    child: Center(
                      child: Text(
                        actionLabel,
                        style: AppTextStyles.buttonText.copyWith(
                          color: colors.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.btnFontSize,
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
