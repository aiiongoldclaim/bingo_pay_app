import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_search_bar.dart';
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
            top: false,
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
                        // ── Gradient header ───────────────────────────────
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: ThemeColors.primaryGradient,
                          ),
                          child: Column(
                            children: [
                              HomeHeader(userName: state.userName),

                              WalletCard(
                                bigoldBalance: state.formattedBigoldBalance,
                              ),

                              SizedBox(height: 2.h),

                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
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

                              // Buffer so rounded white card overlaps gradient
                              SizedBox(height: 3.h),
                            ],
                          ),
                        ),

                        // ── White content card (pulled up 24 px) ──────────
                        Transform.translate(
                          offset: const Offset(0, -24),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 2.h),

                                PromoBanner(
                                  title: 'Festive Gold Days',
                                  heading: 'Up to 60% Off\non everything',
                                  buttonText: 'Shop the sale',
                                  onTap: () {},
                                ),

                                SizedBox(height: 1.h),

                                CategorySection(categories: state.categories),

                                if (state.flashDeals.isNotEmpty)
                                  FlashDealSection(products: state.flashDeals),

                                if (state.recommended.isNotEmpty)
                                  RecommendedSection(products: state.recommended),

                                SizedBox(height: 2.h),
                              ],
                            ),
                          ),
                        ),
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
