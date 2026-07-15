import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_container.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_categories_model.dart';
import '../product_categories_cubit/product_categories_cubit.dart';
import '../product_categories_cubit/product_categories_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/listing_product_card.dart';
import '../widgets/listing_results_bar.dart';

String _formatListingPrice(double value) {
  final s = value.truncate().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final fromEnd = s.length - i;
    buf.write(s[i]);
    final rem = fromEnd - 1;
    if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
  }
  return buf.toString();
}

WishlistItem _toWishlistItem(ListingProductModel product) => WishlistItem(
      id: product.uuid!,
      brand: product.brand,
      name: product.name,
      price:
          product.price > 0 ? '\$${_formatListingPrice(product.price)}' : 'N/A',
      originalPrice: product.originalPrice != null && product.originalPrice! > 0
          ? '\$${_formatListingPrice(product.originalPrice!)}'
          : null,
      discountPercent: product.discountPercent,
      imageUrl: product.imageUrl,
      rating: (product.rating ?? 0).toStringAsFixed(1),
      reviewCount: product.ratingCount ?? 0,
      badge: product.badge,
    );

class ProductListingScreen extends StatelessWidget {
  final String categoryName;
  final String categoryUuid;

  const ProductListingScreen({
    super.key,
    required this.categoryName,
    required this.categoryUuid,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProductListingCubit()..loadCategory(categoryName, categoryUuid),
      child: _ProductListingView(categoryName: categoryName),
    );
  }
}

class _ProductListingView extends StatelessWidget {
  final String categoryName;
  const _ProductListingView({required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListingCubit, ProductListingState>(
      builder: (context, state) {
        final cubit = context.read<ProductListingCubit>();

        return Scaffold(
          backgroundColor: ThemeColors.background,
          appBar: CustomAppBar(
            title: categoryName,
            actionIcon1: Icons.search,
            onAction1: () {
              context.push(AppRoutes.search);
            },
            // actionIcon2: Icons.delete,
            // onAction2: () {},
          ),

          body: Column(
            children: [
              // // ── Sticky filter  ────────────────────
              if (state is ProductListingLoaded) ...[
                ListingFilterBar(
                  selectedSort: state.selectedSort,
                  selectedPriceFilter: state.selectedPriceFilter,
                  selectedRatingFilter: state.selectedRatingFilter,
                  onFilterTap: () {},
                  onSortTap: cubit.applySort,
                  onPriceFilter: cubit.applyPriceFilter,
                  onRatingFilter: cubit.applyRatingFilter,
                ),
              ],

              // ── Body ─────────────────────────────────────────────────────
              Expanded(
                child: switch (state) {
                  ProductListingLoading() => const Center(
                    child: CircularProgressIndicator(color: ThemeColors.blue),
                  ),

                  ProductListingError(
                    :final message,
                    :final isRateLimited,
                    :final retryAfterSeconds,
                  ) =>
                    _ErrorState(
                      message: message,
                      isRateLimited: isRateLimited,
                      retryAfterSeconds: retryAfterSeconds,
                      onRetry: cubit.retryLoadCategory,
                    ),

                  ProductListingLoaded() => CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: ListingResultsBar(
                          count: state.filteredProducts.length,
                          // viewMode: state.viewMode,
                          viewMode: ViewMode.grid,
                          // onToggleView: cubit.toggleViewMode,
                          // onToggleView: cubit.toggleViewMode,
                          onToggleView: () {},
                        ),
                      ),

                      if (state.filteredProducts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyProductsState(
                            hasActiveFilters: state.selectedPriceFilter != null ||
                                state.selectedRatingFilter != null,
                            onClearFilters: cubit.clearFilters,
                          ),
                        )
                      else if (state.viewMode == ViewMode.grid)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 3.w,
                                  mainAxisSpacing: 2.h,
                                  childAspectRatio: 0.62,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = state.filteredProducts[index];
                              final wishlist = context.watch<WishlistCubit>();

                              return ListingProductCard(
                                product: product.copyWith(
                                  isFavourite:
                                      wishlist.isWishlisted(product.uuid),
                                ),

                                onTap: product.uuid != null
                                    ? () => context.push(
                                          AppRoutes.productDetails,
                                          extra: product.uuid,
                                        )
                                    : null,
                                onFavouriteTap: product.uuid == null
                                    ? null
                                    : () async {
                                        final cubit = context.read<WishlistCubit>();
                                        final buildContext = context;
                                        final wasWishlisted = cubit.isWishlisted(product.uuid);
                                        await cubit.toggle(_toWishlistItem(product));
                                        if (!wasWishlisted && buildContext.mounted) {
                                          AppSnackbar.showSuccess(
                                            buildContext,
                                            'Product added to Wishlist successfully.',
                                          );
                                        }
                                      },
                              );
                            }, childCount: state.filteredProducts.length),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = state.filteredProducts[index];
                              final wishlist = context.watch<WishlistCubit>();

                              return Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: SizedBox(
                                  height: 18.h,
                                  child: ListingProductCard(
                                    product: product.copyWith(
                                      isFavourite:
                                          wishlist.isWishlisted(product.uuid),
                                    ),
                                    onTap: product.uuid != null
                                    ? () => context.push(
                                          AppRoutes.productDetails,
                                          extra: product.uuid,
                                        )
                                    : null,
                                    onFavouriteTap: product.uuid == null
                                        ? null
                                        : () async {
                                            final cubit = context.read<WishlistCubit>();
                                            final buildContext = context;
                                            final wasWishlisted = cubit.isWishlisted(product.uuid);
                                            await cubit.toggle(_toWishlistItem(product));
                                            if (!wasWishlisted && buildContext.mounted) {
                                              AppSnackbar.showSuccess(
                                                buildContext,
                                                'Product added to Wishlist successfully.',
                                              );
                                            }
                                          },
                                  ),
                                ),
                              );
                            }, childCount: state.filteredProducts.length),
                          ),
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: 3.h)),
                    ],
                  ),

                  _ => const SizedBox.shrink(),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorState extends StatefulWidget {
  final String message;
  final bool isRateLimited;
  final int? retryAfterSeconds;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.isRateLimited,
    required this.retryAfterSeconds,
    required this.onRetry,
  });

  @override
  State<_ErrorState> createState() => _ErrorStateState();
}

class _ErrorStateState extends State<_ErrorState>
    with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.retryAfterSeconds ?? 0;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isRateLimited && _remainingSeconds > 0) {
      _startCountdown();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _remainingSeconds--;
      });
      return _remainingSeconds > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isRateLimited = widget.isRateLimited;
    final primaryColor = isRateLimited ? const Color(0xFFD32F2F) : ThemeColors.blue;
    final lightColor = isRateLimited ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);
    final accentColor =
        isRateLimited ? const Color(0xFFFF6F00) : const Color(0xFF1976D2);

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [lightColor, lightColor.withOpacity(0.5)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isRateLimited
                          ? Icons.speed_outlined
                          : Icons.error_outline_rounded,
                      size: 14.w,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.5.h),
              Text(
                isRateLimited ? 'High Demand! 🚀' : 'Oops!',
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.8.h),
              Text(
                isRateLimited
                    ? 'Everyone\'s Shopping Right Now'
                    : 'Something Went Wrong',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.5.h),
              Container(
                decoration: BoxDecoration(
                  color: lightColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
                child: Column(
                  children: [
                    Text(
                      isRateLimited
                          ? 'Our servers are buzzing with shoppers! We\'re working at full capacity to keep everything running smoothly.'
                          : widget.message,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF424242),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isRateLimited && _remainingSeconds > 0) ...[
                      SizedBox(height: 1.5.h),
                      Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.2.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hourglass_bottom,
                              size: 16,
                              color: primaryColor,
                            ),
                            SizedBox(width: 1.5.w),
                            Text(
                              'Retry in $_remainingSeconds sec',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 3.5.h),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _remainingSeconds == 0
                        ? [primaryColor, accentColor]
                        : [primaryColor.withOpacity(0.6), accentColor.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _remainingSeconds == 0
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _remainingSeconds == 0 ? widget.onRetry : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _remainingSeconds > 0
                                ? Icons.schedule
                                : Icons.refresh_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            _remainingSeconds > 0
                                ? 'Waiting for you...'
                                : 'Try Again',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                isRateLimited
                    ? 'Your cart and wishlist are safe 💙'
                    : 'We\'re here to help. Try again shortly.',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({
    required this.hasActiveFilters,
    this.onClearFilters,
  });

  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: const BoxDecoration(
                color: ThemeColors.blueSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActiveFilters
                    ? Icons.filter_alt_off_outlined
                    : Icons.inventory_2_outlined,
                size: 32,
                color: ThemeColors.blue,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              hasActiveFilters ? 'No matching products' : 'No products yet',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              hasActiveFilters
                  ? 'Try adjusting or clearing your filters to see more results.'
                  : 'This category is currently empty. Check back later for new arrivals.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (hasActiveFilters && onClearFilters != null) ...[
              SizedBox(height: 2.5.h),
              OutlinedButton(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeColors.blue,
                  side: const BorderSide(color: ThemeColors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                ),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
