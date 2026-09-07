import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_benefits_strip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../payment/presentation/screens/payment_args.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_details_model.dart';
import '../cubit/product_details_cubit.dart';
import '../cubit/product_details_state.dart';
import '../widgets/image_viewer_args.dart';
import '../widgets/product_color_section.dart';
import '../widgets/product_detail_widgets.dart';
import '../widgets/product_details_shimmer.dart';
import '../widgets/product_metrics.dart';
import '../widgets/product_rating_section.dart';
import '../widgets/product_variants_section.dart';

WishlistItem _toWishlistItem(ProductDetailModel product, String uuid) =>
    WishlistItem(
      id: uuid,
      brand: product.brand,
      name: product.productName,
      price: product.price,
      originalPrice: product.oldPrice.isNotEmpty ? product.oldPrice : null,
      discountPercent: product.discount > 0 ? product.discount : null,
      imageUrl: product.images.isNotEmpty ? product.images.first : null,
      rating: product.rating,
    );

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  bool _isBuyingNow = false;
  bool _isAddingToCart = false;

  Future<void> _buyNow(BuildContext context, ProductDetailLoaded data) async {
    if (_isBuyingNow) return;

    final product = data.product;
    final variantUuid = product.variantUuid;

    if (variantUuid == null) {
      AppSnackbar.showError(context, AppStrings.productCurrentlyUnavailable);
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

    if (_isAddingToCart) return;

    final product = data.product;
    final variantUuid = product.variantUuid;

    if (variantUuid == null) {
      AppSnackbar.showError(context, AppStrings.productCurrentlyUnavailable);
      return;
    }

    final cartCubit = context.read<CartCubit>();
    final colors = context.colors;

    setState(() => _isAddingToCart = true);
    final result = await cartCubit.addItem(
      variantUuid: variantUuid,
      quantity: data.quantity,
    );
    if (mounted) setState(() => _isAddingToCart = false);
    if (!context.mounted) return;

    if (!result.success) {
      AppSnackbar.showError(
        context,
        result.errorMessage ?? AppStrings.genericAddItemError,
      );
      return;
    }

    AppSnackbar.showSuccessWithAction(
      context,
      AppStrings.itemAddedToCart(product.productName),
      actionLabel: AppStrings.goToCart,
      onAction: () => context.push(AppRoutes.cart),
      backgroundColor: colors.brand,
    );
  }

  Future<void> _toggleWishlist(
      BuildContext context,
      ProductDetailModel product,
      bool wasWishlisted,
      ) async {
    final uuid = product.uuid;
    if (uuid == null) return;

    final wishlistCubit = context.read<WishlistCubit>();
    await wishlistCubit.toggle(
      _toWishlistItem(product, uuid),
      wasWishlisted: wasWishlisted,
    );

    if (!wasWishlisted && context.mounted) {
      AppSnackbar.showSuccess(context, AppStrings.addedToWishlist);
    }
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
          final wishlistCubit = context.watch<WishlistCubit>();
          final isOutOfStock = product.availableStock <= 0;
          final isInCart = cartState.state.items.any(
                (item) => item.variant.uuid == product.variantUuid,
          );
          final isWishlisted = wishlistCubit.isWishlisted(product.uuid);


          final gallery = ProductGallery(
            metrics: m,
            images: product.images,
            fallbackIcon: product.icon,
            badge: product.discount > 0 ? AppStrings.newBadge : null,
            onImageTap: (index) =>
                _openImageViewer(context, product.images, index),
          );

          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ProductInfoBlock(metrics: m, product: product),

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
                    title: AppStrings.offer1Title,
                    subtitle: AppStrings.offer1Subtitle,
                  ),
                  ProductOffer(
                    title: AppStrings.offer2Title,
                    subtitle: AppStrings.offer2Subtitle,
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

              if (product.benefits.isNotEmpty) ...[
                SizedBox(height: m.gapMd),
                AppBenefitsStrip(
                  items: [
                    for (final b in product.benefits)
                      BenefitItem(
                        icon: b.icon,
                        title: b.label,
                        subtitle: b.subtitle,
                      ),
                  ],
                ),
              ],
            ],
          );

          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                ProductTopBar(
                  metrics: m,
                  cartCount: cartState.state.totalItems,
                  isWishlisted: isWishlisted,
                  onBack: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.home),
                  onWishlist: () => _toggleWishlist(context, product, isWishlisted),
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
                    primaryLabel: isOutOfStock
                        ? AppStrings.outOfStockTitleCase
                        : AppStrings.buyNow,
                    primaryLoading: _isBuyingNow,
                    onPrimaryPressed: isOutOfStock || _isBuyingNow
                        ? null
                        : () => _buyNow(context, data),

                    secondaryLabel: isInCart
                        ? AppStrings.goToCartTitleCase
                        : AppStrings.addToCartLabel,
                    secondaryIcon: Icons.shopping_bag_outlined,
                    secondaryLoading: cartState.isAddingItem || _isAddingToCart,
                    onSecondaryPressed: isOutOfStock || _isAddingToCart
                        ? null
                        : () => _addToCart(context, data, isInCart),
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
              AppStrings.somethingWentWrongLower,
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
