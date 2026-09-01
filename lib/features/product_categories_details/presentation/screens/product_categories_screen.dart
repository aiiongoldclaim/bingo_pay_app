// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../../core/theme/theme_colors.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../../../../core/widgets/custom_app_bar.dart';
// import '../../../../core/widgets/custom_container.dart';
// import '../../../wishlist/data/models/wishlist_model.dart';
// import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
// import '../../data/models/product_categories_model.dart';
// import '../product_categories_cubit/product_categories_cubit.dart';
// import '../product_categories_cubit/product_categories_state.dart';
// import '../widgets/filter_bar.dart';
// import '../widgets/listing_product_card.dart';
// import '../widgets/listing_results_bar.dart';
//
// String _formatListingPrice(double value) {
//   final s = value.truncate().toString();
//   final buf = StringBuffer();
//   for (int i = 0; i < s.length; i++) {
//     final fromEnd = s.length - i;
//     buf.write(s[i]);
//     final rem = fromEnd - 1;
//     if (rem == 3 || (rem > 3 && (rem - 3) % 2 == 0)) buf.write(',');
//   }
//   return buf.toString();
// }
//
// WishlistItem _toWishlistItem(ListingProductModel product) => WishlistItem(
//       id: product.uuid!,
//       brand: product.brand,
//       name: product.name,
//       price:
//           product.price > 0 ? '\$${_formatListingPrice(product.price)}' : 'N/A',
//       originalPrice: product.originalPrice != null && product.originalPrice! > 0
//           ? '\$${_formatListingPrice(product.originalPrice!)}'
//           : null,
//       discountPercent: product.discountPercent,
//       imageUrl: product.imageUrl,
//       rating: (product.rating ?? 0).toStringAsFixed(1),
//       reviewCount: product.ratingCount ?? 0,
//       badge: product.badge,
//     );
//
// class ProductListingScreen extends StatelessWidget {
//   final String categoryName;
//   final String categoryUuid;
//
//   const ProductListingScreen({
//     super.key,
//     required this.categoryName,
//     required this.categoryUuid,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) =>
//           ProductListingCubit()..loadCategory(categoryName, categoryUuid),
//       child: _ProductListingView(categoryName: categoryName),
//     );
//   }
// }
//
// class _ProductListingView extends StatelessWidget {
//   final String categoryName;
//   const _ProductListingView({required this.categoryName});
//
//   @override
//   Widget build(BuildContext context) {
//
//     return BlocBuilder<ProductListingCubit, ProductListingState>(
//       builder: (context, state) {
//         final cubit = context.read<ProductListingCubit>();
//
//
//         return Scaffold(
//           backgroundColor: ThemeColors.background,
//           appBar: CustomAppBar(
//             title: categoryName,
//             actionIcon1: Icons.search,
//             onAction1: () {
//               context.push(AppRoutes.search);
//             },
//             actionIcon2: Icons.delete,
//             onAction2: () {},
//           ),
//
//           body: Column(
//             children: [
//               // ── Cached Data Indicator ────────────────────────
//               // if (state is ProductListingLoaded && state.isCachedData) ...[
//               //   Container(
//               //     width: double.infinity,
//               //     padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//               //     decoration: BoxDecoration(
//               //       color: const Color(0xFFFFF3E0),
//               //       border: Border(
//               //         bottom: BorderSide(
//               //           color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
//               //           width: 1,
//               //         ),
//               //       ),
//               //     ),
//               //     child: Row(
//               //       children: [
//               //         const Icon(
//               //           Icons.cloud_off_outlined,
//               //           size: 18,
//               //           color: Color(0xFFF57C00),
//               //         ),
//               //         SizedBox(width: 2.w),
//               //         Expanded(
//               //           child: Column(
//               //             crossAxisAlignment: CrossAxisAlignment.start,
//               //             children: [
//               //               Text(
//               //                 'Showing Cached Data',
//               //                 style: AppTextStyles.labelMedium.copyWith(
//               //                   color: const Color(0xFFF57C00),
//               //                   fontWeight: FontWeight.w600,
//               //                 ),
//               //               ),
//               //               Text(
//               //                 'Last updated ${state.cachedTimeAgo ?? 'recently'}',
//               //                 style: AppTextStyles.bodySmall.copyWith(
//               //                   color: const Color(0xFFE65100).withValues(alpha: 0.7),
//               //                 ),
//               //               ),
//               //             ],
//               //           ),
//               //         ),
//               //         SizedBox(width: 1.w),
//               //         Icon(
//               //           Icons.info_outline,
//               //           size: 16,
//               //           color: const Color(0xFFF57C00).withValues(alpha: 0.6),
//               //         ),
//               //       ],
//               //     ),
//               //   ),
//               // ],
//
//               // // ── Sticky filter  ────────────────────
//               if (state is ProductListingLoaded) ...[
//                 ListingFilterBar(
//                   selectedSort: state.selectedSort,
//                   selectedPriceFilter: state.selectedPriceFilter,
//                   selectedRatingFilter: state.selectedRatingFilter,
//                   onFilterTap: () {},
//                   onSortTap: cubit.applySort,
//                   onPriceFilter: cubit.applyPriceFilter,
//                   onRatingFilter: cubit.applyRatingFilter,
//                 ),
//               ],
//
//               // ── Body ─────────────────────────────────────────────────────
//               Expanded(
//                 child: switch (state) {
//                   ProductListingLoading() => const Center(
//                     child: CircularProgressIndicator(color: ThemeColors.primaryPurple),
//                   ),
//
//                   ProductListingError(
//                     :final message,
//                     :final isRateLimited,
//                     :final retryAfterSeconds,
//                   ) =>
//                     _ErrorState(
//                       message: message,
//                       isRateLimited: isRateLimited,
//                       retryAfterSeconds: retryAfterSeconds,
//                       onRetry: cubit.retryLoadCategory,
//                     ),
//
//                   ProductListingLoaded() => CustomScrollView(
//                     slivers: [
//                       SliverToBoxAdapter(
//                         child: ListingResultsBar(
//                           count: state.filteredProducts.length,
//                           viewMode: state.viewMode,
//                           onToggleView: cubit.toggleViewMode,
//                         ),
//                       ),
//
//                       if (state.filteredProducts.isEmpty)
//                         SliverFillRemaining(
//                           hasScrollBody: false,
//                           child: _EmptyProductsState(
//                             hasActiveFilters: state.selectedPriceFilter != null ||
//                                 state.selectedRatingFilter != null,
//                             onClearFilters: cubit.clearFilters,
//                           ),
//                         )
//                       else if (state.viewMode == ViewMode.grid)
//                         SliverPadding(
//                           padding: EdgeInsets.symmetric(horizontal: 4.w),
//                           sliver: SliverGrid(
//                             gridDelegate:
//                                 SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   crossAxisSpacing: 3.w,
//                                   mainAxisSpacing: 2.h,
//                                   childAspectRatio: 0.62,
//                                 ),
//                             delegate: SliverChildBuilderDelegate((
//                               context,
//                               index,
//                             ) {
//                               final product = state.filteredProducts[index];
//                               final wishlist = context.watch<WishlistCubit>();
//
//                               return ListingProductCard(
//                                 product: product.copyWith(
//                                   isFavourite:
//                                       wishlist.isWishlisted(product.uuid),
//                                 ),
//
//                                 onTap: product.uuid != null
//                                     ? () => context.push(
//                                           AppRoutes.productDetails,
//                                           extra: product.uuid,
//                                         )
//                                     : null,
//                                 onFavouriteTap: product.uuid == null
//                                     ? null
//                                     : () async {
//                                         final cubit = context.read<WishlistCubit>();
//                                         final buildContext = context;
//                                         final wasWishlisted = cubit.isWishlisted(product.uuid);
//                                         await cubit.toggle(_toWishlistItem(product));
//                                         if (!wasWishlisted && buildContext.mounted) {
//                                           AppSnackbar.showSuccess(
//                                             buildContext,
//                                             'Product added to Wishlist successfully.',
//                                           );
//                                         }
//                                       },
//                               );
//                             }, childCount: state.filteredProducts.length),
//                           ),
//                         )
//                       else
//                         SliverPadding(
//                           padding: EdgeInsets.symmetric(horizontal: 4.w),
//                           sliver: SliverList(
//                             delegate: SliverChildBuilderDelegate((
//                               context,
//                               index,
//                             ) {
//                               final product = state.filteredProducts[index];
//                               final wishlist = context.watch<WishlistCubit>();
//
//                               return Padding(
//                                 padding: EdgeInsets.only(bottom: 2.h),
//                                 child: SizedBox(
//                                   height: 18.h,
//                                   child: ListingProductCard(
//                                     product: product.copyWith(
//                                       isFavourite:
//                                           wishlist.isWishlisted(product.uuid),
//                                     ),
//                                     onTap: product.uuid != null
//                                     ? () => context.push(
//                                           AppRoutes.productDetails,
//                                           extra: product.uuid,
//                                         )
//                                     : null,
//                                     onFavouriteTap: product.uuid == null
//                                         ? null
//                                         : () async {
//                                             final cubit = context.read<WishlistCubit>();
//                                             final buildContext = context;
//                                             final wasWishlisted = cubit.isWishlisted(product.uuid);
//                                             await cubit.toggle(_toWishlistItem(product));
//                                             if (!wasWishlisted && buildContext.mounted) {
//                                               AppSnackbar.showSuccess(
//                                                 buildContext,
//                                                 'Product added to Wishlist successfully.',
//                                               );
//                                             }
//                                           },
//                                   ),
//                                 ),
//                               );
//                             }, childCount: state.filteredProducts.length),
//                           ),
//                         ),
//
//                       SliverToBoxAdapter(child: SizedBox(height: 3.h)),
//                     ],
//                   ),
//
//                   _ => const SizedBox.shrink(),
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _ErrorState extends StatefulWidget {
//   final String message;
//   final bool isRateLimited;
//   final int? retryAfterSeconds;
//   final VoidCallback onRetry;
//
//   const _ErrorState({
//     required this.message,
//     required this.isRateLimited,
//     required this.retryAfterSeconds,
//     required this.onRetry,
//   });
//
//   @override
//   State<_ErrorState> createState() => _ErrorStateState();
// }
//
// class _ErrorStateState extends State<_ErrorState>
//     with SingleTickerProviderStateMixin {
//   late int _remainingSeconds;
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _remainingSeconds = widget.retryAfterSeconds ?? 0;
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();
//
//     _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     if (widget.isRateLimited && _remainingSeconds > 0) {
//       _startCountdown();
//     }
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }
//
//   void _startCountdown() {
//     Future.doWhile(() async {
//       await Future.delayed(const Duration(seconds: 1));
//       if (!mounted) return false;
//       setState(() {
//         _remainingSeconds--;
//       });
//       return _remainingSeconds > 0;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isRateLimited = widget.isRateLimited;
//     final primaryColor = isRateLimited ? const Color(0xFFD32F2F) : ThemeColors.primaryPurple;
//     final lightColor = isRateLimited ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);
//     final accentColor =
//         isRateLimited ? const Color(0xFFFF6F00) : const Color(0xFF1976D2);
//
//     return SingleChildScrollView(
//       child: Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               ScaleTransition(
//                 scale: _pulseAnimation,
//                 child: Container(
//                   width: 28.w,
//                   height: 28.w,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [lightColor, lightColor.withOpacity(0.5)],
//                     ),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: primaryColor.withOpacity(0.15),
//                         blurRadius: 20,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Icon(
//                       isRateLimited
//                           ? Icons.speed_outlined
//                           : Icons.error_outline_rounded,
//                       size: 14.w,
//                       color: primaryColor,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 3.5.h),
//               Text(
//                 isRateLimited ? 'High Demand! 🚀' : 'Oops!',
//                 style: AppTextStyles.titleMedium.copyWith(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.w700,
//                   color: const Color(0xFF1A1A1A),
//                   letterSpacing: -0.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 0.8.h),
//               Text(
//                 isRateLimited
//                     ? 'Everyone\'s Shopping Right Now'
//                     : 'Something Went Wrong',
//                 style: TextStyle(
//                   fontSize: 15.sp,
//                   fontWeight: FontWeight.w500,
//                   color: accentColor,
//                   letterSpacing: 0.3,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 2.5.h),
//               Container(
//                 decoration: BoxDecoration(
//                   color: lightColor.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(
//                     color: primaryColor.withOpacity(0.1),
//                     width: 1.5,
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: primaryColor.withOpacity(0.05),
//                       blurRadius: 10,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
//                 child: Column(
//                   children: [
//                     Text(
//                       isRateLimited
//                           ? 'Our servers are buzzing with shoppers! We\'re working at full capacity to keep everything running smoothly.'
//                           : widget.message,
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: const Color(0xFF424242),
//                         height: 1.6,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (isRateLimited && _remainingSeconds > 0) ...[
//                       SizedBox(height: 1.5.h),
//                       Container(
//                         decoration: BoxDecoration(
//                           color: primaryColor.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 3.w,
//                           vertical: 1.2.h,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.hourglass_bottom,
//                               size: 16,
//                               color: primaryColor,
//                             ),
//                             SizedBox(width: 1.5.w),
//                             Text(
//                               'Retry in $_remainingSeconds sec',
//                               style: TextStyle(
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w600,
//                                 color: primaryColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//               SizedBox(height: 3.5.h),
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: _remainingSeconds == 0
//                         ? [primaryColor, accentColor]
//                         : [primaryColor.withOpacity(0.6), accentColor.withOpacity(0.6)],
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: _remainingSeconds == 0
//                       ? [
//                           BoxShadow(
//                             color: primaryColor.withOpacity(0.3),
//                             blurRadius: 15,
//                             spreadRadius: 0,
//                             offset: const Offset(0, 4),
//                           ),
//                         ]
//                       : [],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: _remainingSeconds == 0 ? widget.onRetry : null,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 5.w,
//                         vertical: 1.8.h,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _remainingSeconds > 0
//                                 ? Icons.schedule
//                                 : Icons.refresh_rounded,
//                             color: Colors.white,
//                             size: 18,
//                           ),
//                           SizedBox(width: 2.w),
//                           Text(
//                             _remainingSeconds > 0
//                                 ? 'Waiting for you...'
//                                 : 'Try Again',
//                             style: TextStyle(
//                               fontSize: 15.sp,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 2.h),
//               Text(
//                 isRateLimited
//                     ? 'Your cart and wishlist are safe 💙'
//                     : 'We\'re here to help. Try again shortly.',
//                 style: TextStyle(
//                   fontSize: 13.5.sp,
//                   fontWeight: FontWeight.w400,
//                   color: const Color(0xFF757575),
//                   height: 1.5,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _EmptyProductsState extends StatelessWidget {
//   const _EmptyProductsState({
//     required this.hasActiveFilters,
//     this.onClearFilters,
//   });
//
//   final bool hasActiveFilters;
//   final VoidCallback? onClearFilters;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(5.w),
//               decoration: const BoxDecoration(
//                 color: ThemeColors.blueSoft,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 hasActiveFilters
//                     ? Icons.filter_alt_off_outlined
//                     : Icons.inventory_2_outlined,
//                 size: 32,
//                 color: ThemeColors.primaryPurple,
//               ),
//             ),
//             SizedBox(height: 2.h),
//             Text(
//               hasActiveFilters ? 'No matching products' : 'No products yet',
//               style: AppTextStyles.titleMedium,
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               hasActiveFilters
//                   ? 'Try adjusting or clearing your filters to see more results.'
//                   : 'This category is currently empty. Check back later for new arrivals.',
//               style: AppTextStyles.bodyMedium,
//               textAlign: TextAlign.center,
//             ),
//             if (hasActiveFilters && onClearFilters != null) ...[
//               SizedBox(height: 2.5.h),
//               OutlinedButton(
//                 onPressed: onClearFilters,
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: ThemeColors.primaryPurple,
//                   side: const BorderSide(color: ThemeColors.primaryPurple),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
//                 ),
//                 child: const Text('Clear filters'),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/price_formatter.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_categories_model.dart';
import '../product_categories_cubit/product_categories_cubit.dart';
import '../product_categories_cubit/product_categories_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/listing_product_card.dart';
import '../widgets/listing_results_bar.dart';
import '../widgets/listing_shimmer.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

// String _formatListingPrice(double value) {
//   final digits = value.truncate().toString();
//   final buffer = StringBuffer();
//   for (int index = 0; index < digits.length; index++) {
//     final fromEnd = digits.length - index;
//     buffer.write(digits[index]);
//     final remaining = fromEnd - 1;
//     if (remaining == 3 || (remaining > 3 && (remaining - 3) % 2 == 0)) {
//       buffer.write(',');
//     }
//   }
//   return buffer.toString();
// }

WishlistItem _toWishlistItem(ListingProductModel product) => WishlistItem(
  id: product.uuid!,
  brand: product.brand,
  name: product.name,
  price:
  product.price > 0 ? '\$${formatPrice(product.price)}' : 'N/A',
  originalPrice: product.originalPrice != null && product.originalPrice! > 0
      ? '\$${formatPrice(product.originalPrice!)}'
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
    final colors = context.colors;

    return BlocBuilder<ProductListingCubit, ProductListingState>(
      builder: (context, state) {
        final cubit = context.read<ProductListingCubit>();

        return Scaffold(
          backgroundColor: colors.background,
          appBar: CustomAppBar(
            title: categoryName,
            actionIcon1: Icons.search,
            onAction1: () => context.push(AppRoutes.search),
          ),
          body: Column(
            children: [
              if (state is ProductListingLoaded)
                ListingFilterBar(
                  selectedSort: state.selectedSort,
                  selectedPriceFilter: state.selectedPriceFilter,
                  selectedRatingFilter: state.selectedRatingFilter,
                  onFilterTap: () {},
                  onSortTap: cubit.applySort,
                  onPriceFilter: cubit.applyPriceFilter,
                  onRatingFilter: cubit.applyRatingFilter,
                ),
              Expanded(child: _buildBody(context, state, cubit)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      ProductListingState state,
      ProductListingCubit cubit,
      ) {
    return switch (state) {
      // ProductListingLoading() => Center(
      //   child: CircularProgressIndicator(color: context.colors.brand),
      // ),
      ProductListingLoading() => const ListingShimmer(),
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
      ProductListingLoaded() => _LoadedView(state: state, cubit: cubit),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── Loaded ─────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  final ProductListingLoaded state;
  final ProductListingCubit cubit;

  const _LoadedView({required this.state, required this.cubit});

  bool get _hasActiveFilters =>
      state.selectedPriceFilter != null || state.selectedRatingFilter != null;

  @override
  Widget build(BuildContext context) {
    final products = state.filteredProducts;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: ListingResultsBar(
            count: products.length,
            viewMode: state.viewMode,
            onToggleView: cubit.toggleViewMode,
          ),
        ),

        if (products.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyProductsState(
              hasActiveFilters: _hasActiveFilters,
              onClearFilters: cubit.clearFilters,
            ),
          )
        else if (state.viewMode == ViewMode.grid)
          _ProductsSliverGrid(products: products)
        else
          _ProductsSliverList(products: products),

        SliverToBoxAdapter(child: SizedBox(height: 3.h)),
      ],
    );
  }
}

class _ProductsSliverGrid extends StatelessWidget {
  final List<ListingProductModel> products;

  const _ProductsSliverGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 0.62,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => _ListingCard(product: products[index]),
          childCount: products.length,
        ),
      ),
    );
  }
}

class _ProductsSliverList extends StatelessWidget {
  final List<ListingProductModel> products;

  const _ProductsSliverList({required this.products});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: SizedBox(
              height: 18.h,
              child: _ListingCard(product: products[index]),
            ),
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingProductModel product;

  const _ListingCard({required this.product});

  Future<void> _toggleWishlist(BuildContext context) async {
    final wishlistCubit = context.read<WishlistCubit>();
    final wasWishlisted = wishlistCubit.isWishlisted(product.uuid);

    await wishlistCubit.toggle(_toWishlistItem(product));

    if (!wasWishlisted && context.mounted) {
      AppSnackbar.showSuccess(context, AppStrings.wishlistAdded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistCubit>();
    final uuid = product.uuid;

    return ListingProductCard(
      product: product.copyWith(isFavourite: wishlist.isWishlisted(uuid)),
      onTap: uuid == null
          ? null
          : () => context.push(AppRoutes.productDetails, extra: uuid),
      onFavouriteTap: uuid == null ? null : () => _toggleWishlist(context),
    );
  }
}

// ── Error ──────────────────────────────────────────────────────────────────

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
      setState(() => _remainingSeconds--);
      return _remainingSeconds > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRateLimited = widget.isRateLimited;

    final accentColor = isRateLimited ? colors.statusWarning : colors.error;
    final softColor = accentColor.withValues(alpha: 0.12);
    final canRetry = _remainingSeconds == 0;

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingIcon(
                animation: _pulseAnimation,
                icon: isRateLimited
                    ? Icons.speed_outlined
                    : Icons.error_outline_rounded,
                accentColor: accentColor,
                softColor: softColor,
              ),

              SizedBox(height: 3.5.h),

              Text(
                isRateLimited
                    ? AppStrings.rateLimitedTitle
                    : AppStrings.errorTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              SizedBox(height: 0.8.h),

              Text(
                isRateLimited
                    ? AppStrings.rateLimitedSubtitle
                    : AppStrings.errorSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: accentColor,
                  letterSpacing: 0.3,
                ),
              ),

              SizedBox(height: 2.5.h),

              _MessageCard(
                message: isRateLimited
                    ? AppStrings.rateLimitedBody
                    : widget.message,
                accentColor: accentColor,
                softColor: softColor,
                remainingSeconds: isRateLimited ? _remainingSeconds : 0,
              ),

              SizedBox(height: 3.5.h),

              _RetryButton(
                canRetry: canRetry,
                onRetry: widget.onRetry,
              ),

              SizedBox(height: 2.h),

              Text(
                isRateLimited
                    ? AppStrings.rateLimitedFooter
                    : AppStrings.errorFooter,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: colors.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatelessWidget {
  final Animation<double> animation;
  final IconData icon;
  final Color accentColor;
  final Color softColor;

  const _PulsingIcon({
    required this.animation,
    required this.icon,
    required this.accentColor,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: animation,
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [softColor, softColor.withValues(alpha: 0.5)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 14.w, color: accentColor),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final Color accentColor;
  final Color softColor;
  final int remainingSeconds;

  const _MessageCard({
    required this.message,
    required this.accentColor,
    required this.softColor,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: softColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
          if (remainingSeconds > 0) ...[
            SizedBox(height: 1.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hourglass_bottom,
                    size: 16.sp,
                    color: accentColor,
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    AppStrings.retryInSeconds(remainingSeconds),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final bool canRetry;
  final VoidCallback onRetry;

  const _RetryButton({required this.canRetry, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = canRetry ? colors.brand : colors.brand.withValues(alpha: 0.5);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: canRetry ? onRetry : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canRetry ? Icons.refresh_rounded : Icons.schedule,
                  color: colors.onBrand,
                  size: 16.sp,
                ),
                SizedBox(width: 2.w),
                Text(
                  canRetry ? AppStrings.retryNow : AppStrings.retryWaiting,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: colors.onBrand,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty ──────────────────────────────────────────────────────────────────

class _EmptyProductsState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback? onClearFilters;

  const _EmptyProductsState({
    required this.hasActiveFilters,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasActiveFilters
                    ? Icons.filter_alt_off_outlined
                    : Icons.inventory_2_outlined,
                size: 28.sp,
                color: colors.brand,
              ),
            ),

            SizedBox(height: 2.h),

            Text(
              hasActiveFilters
                  ? AppStrings.emptyFilteredTitle
                  : AppStrings.emptyTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              hasActiveFilters
                  ? AppStrings.emptyFilteredBody
                  : AppStrings.emptyBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),

            if (hasActiveFilters && onClearFilters != null) ...[
              SizedBox(height: 2.5.h),
              OutlinedButton(
                onPressed: onClearFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.brand,
                  side: BorderSide(color: colors.brand),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding:
                  EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.2.h),
                ),
                child: const Text(AppStrings.clearFilters),
              ),
            ],
          ],
        ),
      ),
    );
  }
}