import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/product_cache_service.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_model.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchAllProducts();
  }

  Future<List<ProductModel>> _fetchAllProducts() async {
    final client = getIt<ApiClient>();
    final cacheService = getIt<ProductCacheService>();

    try {
      final response = await client.dio.get(
        '${AppConfig.categoriesApiBaseUrl}/api/v1/products',
        queryParameters: {'page': 1, 'limit': 100},
      );
      final raw = response.data as Map<String, dynamic>;
      final dataMap = raw['data'] as Map<String, dynamic>;
      final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
      final products = dataList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Cache on success
      await cacheService.cacheHomeProducts(products);
      debugPrint('✓ Loaded and cached ${products.length} products from API');
      return products;
    } catch (e) {
      debugPrint('✗ Failed to fetch products: $e');

      // Handle throttling gracefully
      final isDioError = e is DioException;
      final isThrottled = isDioError && e.response?.statusCode == 429;

      if (isThrottled) {
        debugPrint('⚠ API throttled (429), attempting to load from cache...');
      }

      // Try cache as fallback
      final cachedProducts = await cacheService.getHomeProductsCache();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        debugPrint(
          '✓ Loaded ${cachedProducts.length} products from cache (API ${isThrottled ? 'throttled' : 'failed'})',
        );
        return cachedProducts;
      }

      debugPrint('✗ No cached products available, rethrowing error');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: const CustomAppBar(title: 'All Products'),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 15.w,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Failed to load products',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _productsFuture = _fetchAllProducts();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Text(
                'No products available',
                style: TextStyle(fontSize: 16.sp),
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(4.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 1.h,
              childAspectRatio: 0.65,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final wishlist = context.watch<WishlistCubit>();

              return ProductCard(
                brand: product.brand,
                productName: product.name,
                price: product.price,
                imageUrl:
                    product.images.isNotEmpty ? product.images.first : '',
                rating: product.rating,
                initialFavourite: wishlist.isWishlisted(product.uuid),
                onFavouriteChanged: product.uuid == null
                    ? null
                    : (isAdded) async {
                        final cubit = context.read<WishlistCubit>();
                        final buildContext = context;
                        await cubit.toggle(
                          WishlistItem(
                            id: product.uuid!,
                            brand: product.brand,
                            name: product.name,
                            price: product.price,
                            originalPrice: product.oldPrice.isNotEmpty
                                ? product.oldPrice
                                : null,
                            discountPercent: product.discount > 0
                                ? product.discount
                                : null,
                            imageUrl: product.images.isNotEmpty
                                ? product.images.first
                                : null,
                            rating: product.rating,
                          ),
                        );
                        if (isAdded && buildContext.mounted) {
                          AppSnackbar.showSuccess(
                            buildContext,
                            'Product added to Wishlist successfully.',
                          );
                        }
                      },
                onTap: product.uuid != null
                    ? () => context.push(
                          AppRoutes.productDetails,
                          extra: product.uuid,
                        )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
