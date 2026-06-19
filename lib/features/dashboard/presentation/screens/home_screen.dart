import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../product_details/data/models/product_details_model.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/app_horizontal_slider.dart';
import '../widgets/category_section.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/flashDealSection.dart';
import '../widgets/flash_deal_card.dart';
import '../widgets/home_bottom_nav.dart';
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
                        /// Blue Header Area
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: ThemeColors.blue,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 1.h),

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
                                      borderRadius: 12,
                                      backgroundColor: Colors.white,

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

                                  SizedBox(height: 15.h),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 33.h),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 2.h),

                                  /// Banner
                                  const PromoBanner(),

                                  SizedBox(height: 1.h),

                                  /// Categories
                                  CategorySection(categories: state.categories),

                                  /// Flash Deals
                                  FlashDealSection(products: state.recommended),

                                  RecommendedSection(
                                    products: state.recommended,
                                  ),

                                  // FlashDealCard(product: state.recommended,),
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
