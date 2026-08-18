// import 'package:bingo_pay/core/theme/theme_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/services/product_share_service.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../../../../core/widgets/bottom_action_bar.dart';
// import '../../../cart/presentation/cubit/cart_cubit.dart';
// import '../../../cart/presentation/cubit/cart_state.dart';
// import '../../../payment/presentation/screens/payment_screen.dart';
// import '../../../wishlist/data/models/wishlist_model.dart';
// import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
// import '../cubit/product_details_cubit.dart';
// import '../cubit/product_details_state.dart';
// import '../widgets/product_color_section.dart';
// import '../widgets/product_highlights_section.dart';
// import '../widgets/product_image_section.dart';
// import '../widgets/product_info_section.dart';
// import '../widgets/product_details_shimmer.dart';
// import '../widgets/product_policies_section.dart';
// import '../widgets/product_rating_section.dart';
// import '../widgets/product_variants_section.dart';
//
// class ProductDetailScreen extends StatelessWidget {
//   const ProductDetailScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeColors.white,
//       body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
//         builder: (context, state) {
//           if (state is ProductDetailLoading) {
//             return const ProductDetailsShimmer();
//           }
//
//           if (state is ProductDetailError) {
//             return Center(child: Text(state.message));
//           }
//
//           final data = state as ProductDetailLoaded;
//           final product = state.product;
//           final wishlist = context.watch<WishlistCubit>();
//           final cartState = context.watch<CartCubit>();
//           final isOutOfStock = product.availableStock <= 0;
//           final isInCart = cartState.state.items.any(
//             (item) => item.variant.uuid == product.variantUuid,
//           );
//
//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       /// IMAGE
//                       ProductImageSection(
//                         icon: product.icon,
//                         images: product.images,
//                         isFavourite: wishlist.isWishlisted(product.uuid),
//                         onBack: () => Navigator.pop(context),
//                         onShare: () async {
//                           if (product.uuid != null) {
//                             await ProductShareService.shareProduct(
//                               productId: product.uuid!,
//                               productName: product.productName,
//                               productPrice: product.price,
//                             );
//                           }
//                         },
//                         onToggleFavourite: product.uuid == null
//                             ? () {}
//                             : () async {
//                           debugPrint('WISHLIST SAVE → variantUuid: ${product.variantUuid}');
//                                 final cubit = context.read<WishlistCubit>();
//                                 final wasWishlisted = cubit.isWishlisted(product.uuid);
//                                 await cubit.toggle(
//                                   WishlistItem(
//                                     id: product.uuid!,
//                                     variantUuid: product.variantUuid,// change here
//                                     brand: product.brand,
//                                     name: product.productName,
//                                     price: product.price,
//                                     originalPrice: product.oldPrice.isNotEmpty
//                                         ? product.oldPrice
//                                         : null,
//                                     discountPercent: product.discount > 0
//                                         ? product.discount
//                                         : null,
//                                     imageUrl: product.images.isNotEmpty
//                                         ? product.images.first
//                                         : null,
//                                     rating: product.rating,
//                                     reviewCount:
//                                         int.tryParse(product.reviewCount) ?? 0,
//                                   ),
//                                 );
//                                 if (!wasWishlisted && context.mounted) {
//                                   AppSnackbar.showSuccess(
//                                     context,
//                                     'Product added to Wishlist successfully.',
//                                   );
//                                 }
//                               },
//                       ),
//                       SizedBox(height: 1.h),
//
//                       /// PRODUCT INFO
//                       ProductInfoSection(
//                         product: product,
//                         quantity: data.quantity,
//                         onIncrementQuantity: () {
//                           if (data.quantity >= product.availableStock) {
//                             AppSnackbar.showWarning(
//                               context,
//                               'Should not more quantity than available stock',
//                             );
//                             return;
//                           }
//                           context
//                               .read<ProductDetailCubit>()
//                               .incrementQuantity();
//                         },
//                         onDecrementQuantity: () =>
//                             context.read<ProductDetailCubit>().decrementQuantity(),
//                       ),
//
//                       /// COLORS
//                       ProductColorSection(
//                         colorOptions: product.colorOptions,
//                         selectedIndex: data.selectedColorIndex,
//                         onSelect: (index) {
//                           context.read<ProductDetailCubit>().selectColor(index);
//                         },
//                       ),
//
//                       /// VARIANTS
//                       ProductVariantsSection(
//                         variants: product.variants,
//                         selectedIndex: data.selectedVariantIndex,
//                         onSelect: (index) {
//                           context.read<ProductDetailCubit>().selectVariant(index);
//                         },
//                       ),
//
//                       /// POLICIES
//                       ProductPoliciesSection(
//                         deliveryInfo: product.deliveryInfo,
//                       ),
//
//                       /// HIGHLIGHTS
//                       ProductHighlightsSection(highlights: product.highlights),
//
//                       /// RATINGS
//                       ProductRatingsSection(
//                         rating: product.rating,
//                         reviewCount: product.reviewCount,
//                         breakdown: product.ratingBreakdown,
//                         onSeeAll: () {
//                           context.read<ProductDetailCubit>().onSeeAllReviews();
//                         },
//                       ),
//
//                       const SizedBox(height: 16),
//                     ],
//                   ),
//                 ),
//               ),
//
//               /// BOTTOM BAR
//               BlocBuilder<CartCubit, CartState>(
//                 builder: (context, cartState) => AppBottomActionBar(
//                   price: product.price,
//                   secondaryLoading: cartState.isAddingItem,
//
//                   primaryLabel: isOutOfStock ? 'Out of Stock' : 'Buy Now',
//                   onPrimaryPressed: isOutOfStock
//                       ? null
//                       : () {
//                           final variantUuid = product.variantUuid;
//                           if (variantUuid == null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'This product is currently unavailable',
//                                 ),
//                                 duration: Duration(seconds: 2),
//                               ),
//                             );
//                             return;
//                           }
//                           final rawPrice = product.price
//                               .replaceAll(RegExp(r'[$,]'), '')
//                               .trim();
//                           final priceValue = double.tryParse(rawPrice) ?? 0.0;
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => PaymentScreen(
//                                 vendorEmail: product.vendorEmail,
//                                 productName: product.productName,
//                                 productPrice: priceValue,
//                                 variantUuid: variantUuid,
//                                 quantity: data.quantity,
//                                 isCart: false,
//                               ),
//                             ),
//                           );
//                         },
//                   secondaryTextColor: ThemeColors.black,
//                   secondaryIconColor: ThemeColors.black,
//                   secondaryLabel: isInCart ? 'Go to Cart' : 'Add Cart',
//                   secondaryIcon: Icons.shopping_bag_outlined,
//                   onSecondaryPressed: isOutOfStock
//                       ? null
//                       : () async {
//                           if (isInCart) {
//                             context.push(AppRoutes.cart);
//                             return;
//                           }
//
//                           final variantUuid = product.variantUuid;
//                           if (variantUuid == null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text(
//                                   'This product is currently unavailable',
//                                 ),
//                                 duration: Duration(seconds: 2),
//                               ),
//                             );
//                             return;
//                           }
//
//                           final cartCubit = context.read<CartCubit>();
//                           await cartCubit.addItem(
//                             variantUuid: variantUuid,
//                             quantity: data.quantity,
//                           );
//                           if (!context.mounted) return;
//
//                           final error = cartCubit.state.error;
//                           if (error != null) {
//                             AppSnackbar.showError(context, error);
//                             return;
//                           }
//
//                           AppSnackbar.showSuccessWithAction(
//                             context,
//                             '${product.productName} added to cart',
//                             actionLabel: 'GO TO CART',
//                             onAction: () => context.push(AppRoutes.cart),
//                             backgroundColor: ThemeColors.blue,
//                           );
//                         },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:bingo_pay/features/product_details/presentation/screens/product_image_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/product_share_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_benefits_strip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../payment/presentation/screens/payment_screen.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../widgets/product_bottom_bar.dart';
import '../widgets/product_detail_widgets.dart';
import '../widgets/product_details_shimmer.dart';
import '../widgets/product_metrics.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return const ProductDetailsShimmer();
          }

          if (state is ProductDetailError) {
            return _ErrorView(message: state.message);
          }

          final data = state as ProductDetailLoaded;
          final product = state.product;
          final m = ProductMetrics.of(context);

          final wishlist = context.watch<WishlistCubit>();
          final cartState = context.watch<CartCubit>();
          final isOutOfStock = product.availableStock <= 0;
          final isInCart = cartState.state.items.any(
                (item) => item.variant.uuid == product.variantUuid,
          );

          Future<void> toggleFavourite() async {
            if (product.uuid == null) return;
            final cubit = context.read<WishlistCubit>();
            final wasWishlisted = cubit.isWishlisted(product.uuid);
            await cubit.toggle(
              WishlistItem(
                id: product.uuid!,
                variantUuid: product.variantUuid,
                brand: product.brand,
                name: product.productName,
                price: product.price,
                originalPrice: product.oldPrice.isNotEmpty
                    ? product.oldPrice
                    : null,
                discountPercent: product.discount > 0 ? product.discount : null,
                imageUrl: product.images.isNotEmpty
                    ? product.images.first
                    : null,
                rating: product.rating,
                reviewCount: int.tryParse(product.reviewCount) ?? 0,
              ),
            );
            if (!wasWishlisted && context.mounted) {
              AppSnackbar.showSuccess(
                context,
                'Product added to Wishlist successfully.',
              );
            }
          }

          final gallery = ProductGallery(
            metrics: m,
            images: product.images,
            fallbackIcon: product.icon,
            badge: product.discount > 0 ? 'NEW' : null,
            onImageTap: (index) {
              if (product.images.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductImageViewerScreen(
                    images: product.images,
                    initialIndex: index,
                  ),
                ),
              );
            },
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ProductInfoBlock(metrics: m, product: product),

              SizedBox(height: m.gapLg),

              ProductSizeSelector(
                metrics: m,
                variants: product.variants,
                selectedIndex: data.selectedVariantIndex,
                onSelect: (index) =>
                    context.read<ProductDetailCubit>().selectVariant(index),
                onSizeGuide: () {},
              ),

              SizedBox(height: m.gapLg),

              ProductSectionCard(
                metrics: m,
                child: ProductActionRow(
                  metrics: m,
                  icon: Icons.location_on_outlined,
                  title: 'Delivery & Return Details',
                  subtitle: 'Enter delivery pincode',
                  onTap: () {},
                ),
              ),

              SizedBox(height: m.gapMd),

              ProductOffersCard(
                metrics: m,
                offers: const [
                  ProductOffer(
                    title: '10% Instant Discount on Bank Cards',
                    subtitle: 'Min. spend \$50 | T&C',
                  ),
                  ProductOffer(
                    title: 'Extra 5% off on Wallet',
                    subtitle: 'Max. discount \$10',
                  ),
                ],
                onViewAll: () {},
              ),

              SizedBox(height: m.gapMd),

              ProductHighlightsBlock(
                metrics: m,
                highlights: product.highlights,
              ),

              SizedBox(height: m.gapMd),

              ProductRatingsBlock(
                metrics: m,
                rating: product.rating,
                reviewCount: product.reviewCount,
                onSeeAll: () =>
                    context.read<ProductDetailCubit>().onSeeAllReviews(),
              ),

              SizedBox(height: m.gapMd),

              // Sabse neeche — reusable strip
              AppBenefitsStrip(
                items: AppBenefitsStrip.fromLabels(
                  deliveryLabel: product.deliveryInfo.deliveryLabel,
                  deliverySubtitle: product.deliveryInfo.deliverySubtitle,
                  returnLabel: product.deliveryInfo.returnLabel,
                  returnSubtitle: product.deliveryInfo.returnSubtitle,
                  warrantyLabel: product.deliveryInfo.warrantyLabel,
                  warrantySubtitle: product.deliveryInfo.warrantySubtitle,
                ),
              ),
            ],
          );

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                ProductTopBar(
                  metrics: m,
                  cartCount: cartState.state.totalItems,
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.home),
                  onWishlist: () => context.push(AppRoutes.buyerWishlist),
                  onCart: () => context.push(AppRoutes.cart),
                ),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                      child: m.isLandscape
                          ? Padding(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapSm,
                          m.pageHPad,
                          0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: m.galleryWidth,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  bottom: m.gapLg,
                                ),
                                child: gallery,
                              ),
                            ),
                            SizedBox(width: m.gapLg),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  bottom: m.gapLg,
                                ),
                                child: details,
                              ),
                            ),
                          ],
                        ),
                      )
                          : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapSm,
                          m.pageHPad,
                          m.gapLg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            gallery,
                            SizedBox(height: m.gapLg),
                            details,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                /// BOTTOM BAR — logic untouched
                // BlocBuilder<CartCubit, CartState>(
                //   builder: (context, cartState) => AppBottomActionBar(
                //     price: product.price,
                //     secondaryLoading: cartState.isAddingItem,
                //     primaryLabel: isOutOfStock ? 'Out of Stock' : 'Buy Now',
                //     onPrimaryPressed: isOutOfStock
                //         ? null
                //         : () {
                //       final variantUuid = product.variantUuid;
                //       if (variantUuid == null) {
                //         AppSnackbar.showError(
                //           context,
                //           'This product is currently unavailable',
                //         );
                //         return;
                //       }
                //       final rawPrice = product.price
                //           .replaceAll(RegExp(r'[$,]'), '')
                //           .trim();
                //       final priceValue =
                //           double.tryParse(rawPrice) ?? 0.0;
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (_) => PaymentScreen(
                //             vendorEmail: product.vendorEmail,
                //             productName: product.productName,
                //             productPrice: priceValue,
                //             variantUuid: variantUuid,
                //             quantity: data.quantity,
                //             isCart: false,
                //           ),
                //         ),
                //       );
                //     },
                //     secondaryTextColor: c.brand,
                //     secondaryIconColor: c.brand,
                //     secondaryLabel: isInCart ? 'Go to Cart' : 'Add Cart',
                //     secondaryIcon: Icons.shopping_bag_outlined,
                //     onSecondaryPressed: isOutOfStock
                //         ? null
                //         : () async {
                //       if (isInCart) {
                //         context.push(AppRoutes.cart);
                //         return;
                //       }
                //
                //       final variantUuid = product.variantUuid;
                //       if (variantUuid == null) {
                //         AppSnackbar.showError(
                //           context,
                //           'This product is currently unavailable',
                //         );
                //         return;
                //       }
                //
                //       final cartCubit = context.read<CartCubit>();
                //       await cartCubit.addItem(
                //         variantUuid: variantUuid,
                //         quantity: data.quantity,
                //       );
                //       if (!context.mounted) return;
                //
                //       final error = cartCubit.state.error;
                //       if (error != null) {
                //         AppSnackbar.showError(context, error);
                //         return;
                //       }
                //
                //       AppSnackbar.showSuccessWithAction(
                //         context,
                //         '${product.productName} added to cart',
                //         actionLabel: 'GO TO CART',
                //         onAction: () => context.push(AppRoutes.cart),
                //         backgroundColor: c.brand,
                //       );
                //     },
                //   ),
                // ),
                /// BOTTOM BAR — share + wishlist + add to bag
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) => ProductBottomBar(
                    metrics: m,
                    isWishlisted: wishlist.isWishlisted(product.uuid),
                    isOutOfStock: isOutOfStock,
                    isInCart: isInCart,
                    isAddingItem: cartState.isAddingItem,
                    onShare: () async {
                      if (product.uuid != null) {
                        await ProductShareService.shareProduct(
                          productId: product.uuid!,
                          productName: product.productName,
                          productPrice: product.price,
                        );
                      }
                    },
                    onWishlist: toggleFavourite,
                    onAddToBag: isOutOfStock
                        ? null
                        : () async {
                      if (isInCart) {
                        context.push(AppRoutes.cart);
                        return;
                      }

                      final variantUuid = product.variantUuid;
                      if (variantUuid == null) {
                        AppSnackbar.showError(
                          context,
                          'This product is currently unavailable',
                        );
                        return;
                      }

                      final cartCubit = context.read<CartCubit>();
                      await cartCubit.addItem(
                        variantUuid: variantUuid,
                        quantity: data.quantity,
                      );
                      if (!context.mounted) return;

                      final error = cartCubit.state.error;
                      if (error != null) {
                        AppSnackbar.showError(context, error);
                        return;
                      }

                      AppSnackbar.showSuccessWithAction(
                        context,
                        '${product.productName} added to cart',
                        actionLabel: 'GO TO CART',
                        onAction: () => context.push(AppRoutes.cart),
                        backgroundColor: c.brand,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = ProductMetrics.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.rowIconBox * 1.6,
              height: m.rowIconBox * 1.6,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.error_outline_rounded,
                size: m.rowIconBox * 0.7,
                color: c.brand,
              ),
            ),
            SizedBox(height: m.gapLg),
            Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.sectionTitleSize,
              ),
            ),
            SizedBox(height: m.gapSm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.rowSubSize,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}