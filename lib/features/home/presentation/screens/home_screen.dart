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

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon badge
          Container(
            width: 26.w,
            height: 26.w,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 13.w,
                  color: ThemeColors.blue,
                ),
                Positioned(
                  bottom: 3.5.w,
                  right: 3.5.w,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFA726),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.access_time_rounded, size: 3.5.w, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.5.h),

          Text(
            'No Products Right Now',
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.w700,
              color: ThemeColors.black,
              letterSpacing: -0.3,
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            "We're stocking up with amazing deals.\nCheck back soon for exclusive offers!",
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.grey.shade500,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Decorative tags row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Tag(label: '🔥 Hot Deals', color: const Color(0xFFFFF3E0)),
              SizedBox(width: 2.w),
              _Tag(label: '✨ New Arrivals', color: const Color(0xFFF3E5F5)),
              SizedBox(width: 2.w),
              _Tag(label: '🎁 Offers', color: const Color(0xFFE8F5E9)),
            ],
          ),

          SizedBox(height: 3.h),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeColors.blue,
                side: const BorderSide(color: ThemeColors.blue, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit()..loadHome(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: ThemeColors.blue,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
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
                              SizedBox(height: 5.h),
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

                                if (state.flashDeals.isNotEmpty || state.recommended.isNotEmpty) ...[
                                  PromoBanner(
                                    title: 'Festive Gold Days',
                                    heading: 'Up to 60% Off\non everything',
                                    buttonText: 'Shop the sale',
                                    onTap: () {},
                                  ),
                                  SizedBox(height: 1.h),
                                ],

                                CategorySection(categories: state.categories),

                                if (state.flashDeals.isEmpty && state.recommended.isEmpty)
                                  const _EmptyProductsState()
                                else ...[
                                  if (state.flashDeals.isNotEmpty)
                                    FlashDealSection(products: state.flashDeals),
                                  if (state.recommended.isNotEmpty)
                                    RecommendedSection(products: state.recommended),
                                ],

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
