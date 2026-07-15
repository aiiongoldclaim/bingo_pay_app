import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../product_details/data/models/product_details_model.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_model.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key, required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: [
              Text(
                "Recommended for you",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.black,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 1.h),

        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final product = products[index];
              final wishlist = context.watch<WishlistCubit>();

              return ProductCard(
                brand: product.brand,
                productName: product.name,
                price: product.price,
                imageUrl: product.images.isNotEmpty ? product.images.first : '',
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
                            discountPercent:
                                product.discount > 0 ? product.discount : null,
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
          ),
        ),
      ],
    );
  }
}
