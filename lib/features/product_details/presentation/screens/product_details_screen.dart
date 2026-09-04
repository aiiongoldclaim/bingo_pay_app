import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_benefits_strip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../payment/presentation/screens/payment_args.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../widgets/image_viewer_args.dart';
import '../widgets/product_color_section.dart';
import '../widgets/product_detail_widgets.dart';
import '../widgets/product_details_shimmer.dart';
import '../widgets/product_metrics.dart';
import '../widgets/product_rating_section.dart';
import '../widgets/product_variants_section.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Prevents a fast double-tap from pushing the Payment screen twice —
  // mirrors the isLoading guard Add to Cart already gets from CartCubit.
  bool _isBuyingNow = false;

  Future<void> _buyNow(BuildContext context, ProductDetailLoaded data) async {
    if (_isBuyingNow) return;

    final product = data.product;
    final variantUuid = product.variantUuid;

    if (variantUuid == null) {
      AppSnackbar.showError(context, 'This product is currently unavailable');
      return;
    }

    final rawPrice = product.price.replaceAll(RegExp(r'[$,]'), '').trim();
    final priceValue = double.tryParse(rawPrice) ?? 0.0;

    setState(() => _isBuyingNow = true);
    try {
      await context.push(
        AppRoutes.payment,
        extra: PaymentArgs(
          vendorEmail: product.vendorEmail,
          productName: product.productName,
          productPrice: priceValue,
          variantUuid: variantUuid,
          quantity: data.quantity,
          isCart: false,
        ),
      );
    } finally {
      if (mounted) setState(() => _isBuyingNow = false);
    }
  }

  Future<void> _addToCart(
      BuildContext context,
      ProductDetailLoaded data,
      bool isInCart,
      ) async {
    if (isInCart) {
      context.push(AppRoutes.cart);
      return;
    }

    final product = data.product;
    final variantUuid = product.variantUuid;

    if (variantUuid == null) {
      AppSnackbar.showError(context, 'This product is currently unavailable');
      return;
    }

    final cartCubit = context.read<CartCubit>();
    final colors = context.colors;

    final result = await cartCubit.addItem(
      variantUuid: variantUuid,
      quantity: data.quantity,
    );
    if (!context.mounted) return;

    if (!result.success) {
      AppSnackbar.showError(
        context,
        result.errorMessage ?? 'Something went wrong. Please try again.',
      );
      return;
    }

    AppSnackbar.showSuccessWithAction(
      context,
      '${product.productName} added to cart',
      actionLabel: 'GO TO CART',
      onAction: () => context.push(AppRoutes.cart),
      backgroundColor: colors.brand,
    );
  }

  void _openImageViewer(
      BuildContext context,
      List<String> images,
      int initialIndex,
      ) {
    if (images.isEmpty) return;

    context.push(
      AppRoutes.productImageViewer,
      extra: ImageViewerArgs(images: images, initialIndex: initialIndex),
    );
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
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

          final cartState = context.watch<CartCubit>();
          final isOutOfStock = product.availableStock <= 0;
          final isInCart = cartState.state.items.any(
                (item) => item.variant.uuid == product.variantUuid,
          );


          final gallery = ProductGallery(
            metrics: m,
            images: product.images,
            fallbackIcon: product.icon,
            badge: product.discount > 0 ? 'NEW' : null,
            onImageTap: (index) =>
                _openImageViewer(context, product.images, index),
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ProductInfoBlock(metrics: m, product: product),

              SizedBox(height: m.gapLg),

              ProductQuantitySelector(
                metrics: m,
                quantity: data.quantity,
                availableStock: product.availableStock,
                onIncrement: () =>
                    context.read<ProductDetailCubit>().incrementQuantity(),
                onDecrement: () =>
                    context.read<ProductDetailCubit>().decrementQuantity(),
              ),

              SizedBox(height: m.gapLg),

              ProductColorSection(
                colorOptions: product.colorOptions,
                selectedIndex: data.selectedColorIndex,
                onSelect: (index) =>
                    context.read<ProductDetailCubit>().selectColor(index),
              ),
              SizedBox(height: m.gapMd),


              ProductVariantsSection(
                metrics: m,
                variants: product.variants,
                productName: product.productName,
                selectedIndex: data.selectedVariantIndex,
                onSelect: (index) =>
                    context.read<ProductDetailCubit>().selectVariant(index),
              ),
              // SizedBox(height: m.gapLg),
              //
              //
              // ProductSectionCard(
              //   metrics: m,
              //   child: ProductActionRow(
              //     metrics: m,
              //     icon: Icons.location_on_outlined,
              //     title: 'Delivery & Return Details',
              //     subtitle: 'Enter delivery pincode',
              //     onTap: () {},
              //   ),
              // ),


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
              ),

              SizedBox(height: m.gapMd),

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

                /// BOTTOM BAR — add to cart + buy now
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) => AppBottomActionBar(
                    primaryLabel: isOutOfStock ? 'Out of Stock' : 'Buy Now',
                    primaryLoading: _isBuyingNow,
                    onPrimaryPressed: isOutOfStock || _isBuyingNow
                        ? null
                        : () => _buyNow(context, data),

                    secondaryLabel: isInCart ? 'Go to Cart' : 'Add to Cart',
                    secondaryIcon: Icons.shopping_bag_outlined,
                    secondaryLoading: cartState.isAddingItem,
                    onSecondaryPressed:
                    isOutOfStock ? null : () => _addToCart(context, data, isInCart),
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
