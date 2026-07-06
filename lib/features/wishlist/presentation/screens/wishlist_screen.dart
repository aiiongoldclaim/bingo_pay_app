import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';
import '../widgets/wishlist_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Wishlist'),
      ),
      body: BlocBuilder<WishlistCubit, WishlistState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const _EmptyWishlist();
          }

          return GridView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: state.items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.56,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
            ),
            itemBuilder: (context, index) {
              final item = state.items[index];
              return WishlistCard(
                item: item,
                onTap: () => context.push(
                  AppRoutes.productDetails,
                  extra: item.id,
                ),
                onRemove: () => context.read<WishlistCubit>().remove(item.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 48.sp,
              color: ThemeColors.inkDim,
            ),
            SizedBox(height: 2.h),
            Text(
              'Your wishlist is empty',
              style: AppTextStyles.titleMedium.copyWith(
                color: ThemeColors.inkMid,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Tap the heart icon on any product to save it here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
