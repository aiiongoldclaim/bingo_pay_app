import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../payment/presentation/screens/payment_screen.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';

import '../widgets/product_bottom_bar.dart';
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
                        imageUrl: product.imageUrl,
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

              /// BOTTOM BAR
              ProductBottomBar(
                price: product.price,
                onAddToCart: () {
                  context.read<ProductDetailCubit>().onAddToCart();
                },
                onBuyNow: () {
                  // context.read<ProductDetailCubit>().onBuyNow();
                  Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PaymentScreen()),
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
