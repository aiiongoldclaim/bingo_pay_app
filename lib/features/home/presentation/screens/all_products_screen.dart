// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import 'package:dio/dio.dart';
//
// import '../../../../core/api/api_client.dart';
// import '../../../../core/config/app_config.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/services/product_cache_service.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../../../../core/widgets/product_card.dart';
// import '../../../wishlist/data/models/wishlist_model.dart';
// import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
// import '../../data/models/product_model.dart';
//
// class AllProductsScreen extends StatefulWidget {
//   const AllProductsScreen({super.key});
//
//   @override
//   State<AllProductsScreen> createState() => _AllProductsScreenState();
// }
//
// class _AllProductsScreenState extends State<AllProductsScreen> {
//   late Future<List<ProductModel>> _productsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _productsFuture = _fetchAllProducts();
//   }
//
//   Future<List<ProductModel>> _fetchAllProducts() async {
//     final client = getIt<ApiClient>();
//     final cacheService = getIt<ProductCacheService>();
//
//     try {
//       final response = await client.dio.get(
//         '${AppConfig.apiBaseUrl}/api/v1/products',
//         queryParameters: {'page': 1, 'limit': 100},
//       );
//       final raw = response.data as Map<String, dynamic>;
//       final dataMap = raw['data'] as Map<String, dynamic>;
//       final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
//       final products = dataList
//           .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
//           .toList();
//
//       // Cache on success
//       await cacheService.cacheHomeProducts(products);
//       debugPrint('✓ Loaded and cached ${products.length} products from API');
//       return products;
//     } catch (e) {
//       debugPrint('✗ Failed to fetch products: $e');
//
//       // Handle throttling gracefully
//       final isDioError = e is DioException;
//       final isThrottled = isDioError && e.response?.statusCode == 429;
//
//       if (isThrottled) {
//         debugPrint('⚠ API throttled (429), attempting to load from cache...');
//       }
//
//       // Try cache as fallback
//       final cachedProducts = await cacheService.getHomeProductsCache();
//       if (cachedProducts != null && cachedProducts.isNotEmpty) {
//         debugPrint(
//           '✓ Loaded ${cachedProducts.length} products from cache (API ${isThrottled ? 'throttled' : 'failed'})',
//         );
//         return cachedProducts;
//       }
//
//       debugPrint('✗ No cached products available, rethrowing error');
//       rethrow;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeColors.background,
//       appBar: const CustomAppBar(title: 'All Products'),
//       body: FutureBuilder<List<ProductModel>>(
//         future: _productsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline,
//                     size: 15.w,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     'Failed to load products',
//                     style: TextStyle(fontSize: 16.sp),
//                   ),
//                   SizedBox(height: 2.h),
//                   ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         _productsFuture = _fetchAllProducts();
//                       });
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final products = snapshot.data ?? [];
//
//           if (products.isEmpty) {
//             return Center(
//               child: Text(
//                 'No products available',
//                 style: TextStyle(fontSize: 16.sp),
//               ),
//             );
//           }
//
//           return GridView.builder(
//             padding: EdgeInsets.all(4.w),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 3.w,
//               mainAxisSpacing: 1.h,
//               childAspectRatio: 0.65,
//             ),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               final product = products[index];
//               final wishlist = context.watch<WishlistCubit>();
//
//               return ProductCard(
//                 brand: product.brand,
//                 productName: product.name,
//                 price: product.price,
//                 imageUrl:
//                     product.images.isNotEmpty ? product.images.first : '',
//                 rating: product.rating,
//                 initialFavourite: wishlist.isWishlisted(product.uuid),
//                 onFavouriteChanged: product.uuid == null
//                     ? null
//                     : (isAdded) async {
//                         final cubit = context.read<WishlistCubit>();
//                         final buildContext = context;
//                         await cubit.toggle(
//                           WishlistItem(
//                             id: product.uuid!,
//                             brand: product.brand,
//                             name: product.name,
//                             price: product.price,
//                             originalPrice: product.oldPrice.isNotEmpty
//                                 ? product.oldPrice
//                                 : null,
//                             discountPercent: product.discount > 0
//                                 ? product.discount
//                                 : null,
//                             imageUrl: product.images.isNotEmpty
//                                 ? product.images.first
//                                 : null,
//                             rating: product.rating,
//                           ),
//                         );
//                         if (isAdded && buildContext.mounted) {
//                           AppSnackbar.showSuccess(
//                             buildContext,
//                             'Product added to Wishlist successfully.',
//                           );
//                         }
//                       },
//                 onTap: product.uuid != null
//                     ? () => context.push(
//                           AppRoutes.productDetails,
//                           extra: product.uuid,
//                         )
//                     : null,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_product_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/variant_resolver.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/all_products_repo.dart';
import '../widgets/products_grid_shimmer.dart';
import '../widgets/products_metrics.dart';


class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {

  static const int _pageSize = 20;

  final List<ProductModel> _products = [];
  final ScrollController _scrollController = ScrollController();

  int _currentPage = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool _hasMore = true;


  final Set<String> _addingIds = {};

  @override
  void initState() {
    super.initState();
    // _productsFuture = getIt<ProductRepository>().getAllProducts();
    // _productsFuture = _fetchAllProducts();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final products = await getIt<ProductRepository>()
          .getAllProducts(page: 1, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(products);
        _currentPage = 1;
        _hasMore = products.length == _pageSize;
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

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    setState(() => _isLoadingMore = true);
    try {
      final nextPage = _currentPage + 1;
      final products = await getIt<ProductRepository>()
          .getAllProducts(page: nextPage, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        _products.addAll(products);
        _currentPage = nextPage;
        _hasMore = products.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (_) {
      // Leave existing products as-is; the user can keep scrolling to retry.
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }


  void _retry() {
    // setState(() {
    //   _productsFuture = getIt<ProductRepository>().getAllProducts();
    //   _productsFuture = _fetchAllProducts();
    // });
    _loadInitial();
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

      AppSnackbar.showSuccessWithAction(
        context,
        '${product.name} added to cart',
        actionLabel: 'GO TO CART',
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
    );

    if (isAdded && buildContext.mounted) {
      AppSnackbar.showSuccess(
        buildContext,
        'Product added to Wishlist successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = ProductsMetrics.of(context);

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ProductsTopBar(
              metrics: m,
              count: _isLoading ? null : _products.length,
            ),

            Expanded(
              child: _isLoading
                  ? Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                  child: ProductsGridShimmer(metrics: m),
                ),
              )
                  : _hasError && _products.isEmpty
                  ? _MessageView(
                metrics: m,
                icon: Icons.wifi_off_rounded,
                title: 'Failed to load products',
                subtitle:
                'Check your internet connection and try again later.',
                actionLabel: 'RETRY',
                onAction: _retry,
              )
                  : _products.isEmpty
                  ? _MessageView(
                metrics: m,
                icon: Icons.inventory_2_outlined,
                title: 'No products available',
                subtitle: 'New Products coming soon.',
                actionLabel: 'REFRESH',
                onAction: _retry,
              )
                  : Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: m.maxContentWidth,
                  ),
                  child: _ProductsGrid(
                    metrics: m,
                    products: _products,
                    addingIds: _addingIds,
                    scrollController: _scrollController,
                    hasMore: _hasMore,
                    isLoadingMore: _isLoadingMore,
                    onAddToCart: _addToCart,
                    onGoToCart: () => context.push(AppRoutes.cart),
                    onToggleWishlist: _toggleWishlist,
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
class _ProductsGrid extends StatelessWidget {
  final ProductsMetrics metrics;
  final List<ProductModel> products;
  final Set<String> addingIds;
  final ScrollController scrollController;
  final bool hasMore;
  final bool isLoadingMore;
  final void Function(ProductModel) onAddToCart;
  final VoidCallback onGoToCart;
  final void Function(ProductModel, bool) onToggleWishlist;

  const _ProductsGrid({
    required this.metrics,
    required this.products,
    required this.addingIds,
    required this.scrollController,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onAddToCart,
    required this.onGoToCart,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    final cartItems = context.watch<CartCubit>().state.items;
    final wishlist = context.watch<WishlistCubit>();

    final showLoader = hasMore && isLoadingMore;

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapMd,
        m.pageHPad,
        m.gapLg,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: m.crossAxisCount,
        crossAxisSpacing: m.gridSpacing,
        mainAxisSpacing: m.gridSpacing,
        childAspectRatio: m.cardAspectRatio,
      ),
      itemCount: products.length + (showLoader ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= products.length) {
          return const Center(child: CircularProgressIndicator());
        }

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

// ── Top bar ────────────────────────────────────────────────────────────────
class _ProductsTopBar extends StatelessWidget {
  final ProductsMetrics metrics;
  final int? count;

  const _ProductsTopBar({required this.metrics, required this.count});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.5,
        m.pageHPad * 0.6,
        m.pageVPad * 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.home),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: c.textPrimary,
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'All Products',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                    height: 1.2,
                  ),
                ),
                if (count != null) ...[
                  SizedBox(height: m.gapXs * 0.6),
                  Text(
                    '$count product${count == 1 ? '' : 's'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.subtitleSize,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            onPressed: () => context.push(AppRoutes.search),
            splashRadius: m.topIconSize * 1.2,
            icon: Icon(
              Icons.search_rounded,
              size: m.topIconSize,
              color: c.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.buyerWishlist),
            splashRadius: m.topIconSize * 1.2,
            icon: Icon(
              Icons.favorite_border_rounded,
              size: m.topIconSize,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
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
                icon,
                size: m.emptyIllustration * 0.42,
                color: c.brand,
              ),
            ),

            SizedBox(height: m.gapLg),

            Text(
              title,
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
              subtitle,
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
              width: m.isTablet ? 240 : null,
              height: m.btnHeight,
              child: Material(
                color: c.brand,
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
                          color: c.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.btnFontSize,
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
