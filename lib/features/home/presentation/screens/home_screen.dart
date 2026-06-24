import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../data/models/product_model.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/category_section.dart';
import '../widgets/flashDealSection.dart';
import '../widgets/home_header.dart';
import '../widgets/promo_banner.dart';
import '../widgets/recommended_section.dart';
import '../widgets/wallet_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..loadHome(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: ThemeColors.blue, // same as header
          statusBarIconBrightness: Brightness.light, // Android
          statusBarBrightness: Brightness.dark, // iOS
        ),
        child: Scaffold(
          backgroundColor: AppColors.backgroundLight,

          body: SafeArea(
            // top: false,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state.status == HomeStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeCubit>().loadHome();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: ThemeColors.primaryGradient,
                              ),
                              child: Column(
                                children: [
                                  HomeHeader(userName: state.userName),

                                  WalletCard(
                                    amount: state.walletAmount,
                                    goldWeight: state.goldWeight,
                                  ),

                                  SizedBox(height: 2.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                    ),
                                    child: AppSearchBar(
                                      hintText: 'Search products, brands...',
                                      backgroundColor: ThemeColors.white,
                                      prefixIcon: Icon(
                                        Icons.search_sharp,
                                        color: ThemeColors.blue,
                                        size: 20.sp,
                                      ),

                                      suffixIcon: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.mic_none_rounded,
                                          color: ThemeColors.blue,
                                          size: 20.sp,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 10.h),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 33.h),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(AppSizes.radiusMd),
                                  topRight: Radius.circular(AppSizes.radiusMd),
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 2.h),

                                  /// Banner
                                  PromoBanner(
                                    title: 'Festive Gold Days',
                                    heading: 'Up to 60% Off\non everything',
                                    buttonText: 'Shop the sale',
                                    onTap: () {},
                                  ),

                                  SizedBox(height: 1.h),

                                  /// Categories
                                  CategorySection(categories: state.categories),

                                  /// Flash Deals
                                  FlashDealSection(
                                    products: ProductModel.flashDeals(),
                                  ),

                                  RecommendedSection(
                                    products: ProductModel.recommended(),
                                  ),

                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
