import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../payment/presentation/screens/payment_screen.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../widgets/product_color_section.dart';
import '../widgets/product_highlights_section.dart';
import '../widgets/product_image_section.dart';
import '../widgets/product_info_section.dart';
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductDetailError) {
            return Center(child: Text(state.message));
          }

          final data = state as ProductDetailLoaded;
          final product = state.product;

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
                        isFavourite: data.isFavourite,
                        onBack: () => Navigator.pop(context),
                        onShare: () {},
                        onToggleFavourite: () {
                          context.read<ProductDetailCubit>().toggleFavourite();
                        },
                      ),
                      SizedBox(height: 1.h),

                      /// PRODUCT INFO
                      ProductInfoSection(product: product),

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

              /// QUANTITY SELECTOR
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.black,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D4E),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => context
                                .read<ProductDetailCubit>()
                                .decrementQuantity(),
                            icon: const Icon(Icons.remove, color: Colors.white),
                          ),
                          Text(
                            '${data.quantity}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () => context
                                .read<ProductDetailCubit>()
                                .incrementQuantity(),
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// BOTTOM BAR
              AppBottomActionBar(
                price: product.price,

                primaryLabel: 'Buy Now',
                onPrimaryPressed: () {
                  final variantUuid = product.variantUuid;
                  if (variantUuid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This product is currently unavailable'),
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
                secondaryLabel: 'Add Cart',
                secondaryIcon: Icons.shopping_bag_outlined,
                onSecondaryPressed: () {
                  final variantUuid = product.variantUuid;
                  if (variantUuid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('This product is currently unavailable'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  context.read<CartCubit>().addItem(
                    variantUuid: variantUuid,
                    quantity: data.quantity,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.productName} added to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
