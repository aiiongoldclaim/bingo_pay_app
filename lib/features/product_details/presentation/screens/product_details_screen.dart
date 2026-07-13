import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../payment/presentation/screens/payment_screen.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../widgets/product_color_section.dart';
import '../widgets/product_highlights_section.dart';
import '../widgets/product_image_section.dart';
import '../widgets/product_info_section.dart';
import '../widgets/product_details_shimmer.dart';
import '../widgets/product_policies_section.dart';
import '../widgets/product_rating_section.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.white,
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return const ProductDetailsShimmer();
          }

          if (state is ProductDetailError) {
            return Center(child: Text(state.message));
          }

          final data = state as ProductDetailLoaded;
          final product = state.product;
          final wishlist = context.watch<WishlistCubit>();
          final cartState = context.watch<CartCubit>();
          final isOutOfStock = product.availableStock <= 0;
          final isInCart = cartState.state.items.any(
            (item) => item.variant.uuid == product.variantUuid,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// IMAGE
                      ProductImageSection(
                        icon: product.icon,
                        images: product.images,
                        isFavourite: wishlist.isWishlisted(product.uuid),
                        onBack: () => Navigator.pop(context),
                        onShare: () {},
                        onToggleFavourite: product.uuid == null
                            ? () {}
                            : () => context.read<WishlistCubit>().toggle(
                                WishlistItem(
                                  id: product.uuid!,
                                  brand: product.brand,
                                  name: product.productName,
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
                                  reviewCount:
                                      int.tryParse(product.reviewCount) ?? 0,
                                ),
                              ),
                      ),
                      SizedBox(height: 1.h),

                      /// PRODUCT INFO
                      ProductInfoSection(
                        product: product,
                        quantity: data.quantity,
                        onIncrementQuantity: () {
                          if (data.quantity >= product.availableStock) {
                            AppSnackbar.showWarning(
                              context,
                              'Should not more quantity than available stock',
                            );
                            return;
                          }
                          context
                              .read<ProductDetailCubit>()
                              .incrementQuantity();
                        },
                        onDecrementQuantity: () =>
                            context.read<ProductDetailCubit>().decrementQuantity(),
                      ),

                      /// COLORS
                      ProductColorSection(
                        colorOptions: product.colorOptions,
                        selectedIndex: data.selectedColorIndex,
                        onSelect: (index) {
                          context.read<ProductDetailCubit>().selectColor(index);
                        },
                      ),

                      /// POLICIES
                      ProductPoliciesSection(
                        deliveryInfo: product.deliveryInfo,
                      ),

                      /// HIGHLIGHTS
                      ProductHighlightsSection(highlights: product.highlights),

                      /// RATINGS
                      ProductRatingsSection(
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        breakdown: product.ratingBreakdown,
                        onSeeAll: () {
                          context.read<ProductDetailCubit>().onSeeAllReviews();
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              /// BOTTOM BAR
              BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) => AppBottomActionBar(
                  price: product.price,
                  secondaryLoading: cartState.isAddingItem,

                  primaryLabel: isOutOfStock ? 'Out of Stock' : 'Buy Now',
                  onPrimaryPressed: isOutOfStock
                      ? null
                      : () {
                          final variantUuid = product.variantUuid;
                          if (variantUuid == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'This product is currently unavailable',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          final rawPrice = product.price
                              .replaceAll(RegExp(r'[$,]'), '')
                              .trim();
                          final priceValue = double.tryParse(rawPrice) ?? 0.0;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentScreen(
                                vendorEmail: product.vendorEmail,
                                productName: product.productName,
                                productPrice: priceValue,
                                variantUuid: variantUuid,
                                quantity: data.quantity,
                                isCart: false,
                              ),
                            ),
                          );
                        },
                  secondaryTextColor: ThemeColors.black,
                  secondaryIconColor: ThemeColors.black,
                  secondaryLabel: isInCart ? 'Go to Cart' : 'Add Cart',
                  secondaryIcon: Icons.shopping_bag_outlined,
                  onSecondaryPressed: isOutOfStock
                      ? null
                      : () async {
                          if (isInCart) {
                            context.push(AppRoutes.cart);
                            return;
                          }

                          final variantUuid = product.variantUuid;
                          if (variantUuid == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'This product is currently unavailable',
                                ),
                                duration: Duration(seconds: 2),
                              ),
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
                            backgroundColor: ThemeColors.blue,
                          );
                        },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
