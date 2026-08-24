import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intro/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_model.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/category_section.dart';
import '../widgets/home_banner_data.dart';
import '../widgets/home_header.dart';
import '../widgets/home_shimmer.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   late ScrollController _scrollController;
//   bool _introStarted = false;
//
//   IntroController get controller => Intro.of(context).controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _startIntroIfReady(HomeState state) async {
//     if (!_introStarted && state.status == HomeStatus.loaded) {
//       _introStarted = true;
//       final prefs = await SharedPreferences.getInstance();
//       final hasShownIntro = prefs.getBool('hasShownHomeIntro') ?? false;
//
//       if (!hasShownIntro) {
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted) {
//             controller.start(context);
//             prefs.setBool('hasShownHomeIntro', true);
//           }
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: const SystemUiOverlayStyle(
//         statusBarColor: ThemeColors.blue,
//         statusBarIconBrightness: Brightness.light,
//         statusBarBrightness: Brightness.dark,
//       ),
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundLight,
//
//         body: SafeArea(
//           top: false,
//           child: BlocBuilder<HomeCubit, HomeState>(
//             builder: (context, state) {
//               if (state.status == HomeStatus.loading) {
//                 return const HomeShimmer();
//               }
//
//               _startIntroIfReady(state);
//
//               return RefreshIndicator(
//                 onRefresh: () async {
//                   context.read<HomeCubit>().loadHome();
//                 },
//                 child: SingleChildScrollView(
//                   controller: _scrollController,
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ── Gradient header ───────────────────────────────
//                       Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           gradient: ThemeColors.primaryGradient,
//                         ),
//                         child: Column(
//                           children: [
//                             _buildStep1(HomeHeader(userName: state.userName)),
//
//                             _buildStep2(
//                               WalletCard(
//                                 bigoldBalance: state.formattedBigoldBalance,
//                               ),
//                             ),
//
//                             SizedBox(height: 2.h),
//
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 5.w),
//                               child: _buildStep3(
//                                 AppSearchBar(
//                                   hintText: 'Search products, brands...',
//                                   backgroundColor: ThemeColors.white,
//                                   prefixIcon: Icon(
//                                     Icons.search_sharp,
//                                     color: ThemeColors.blue,
//                                     size: 20.sp,
//                                   ),
//                                   suffixIcon: Icon(
//                                     Icons.mic_none_rounded,
//                                     color: ThemeColors.blue,
//                                     size: 20.sp,
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                             // Buffer so rounded white card overlaps gradient
//                             SizedBox(height: 5.h),
//                           ],
//                         ),
//                       ),
//
//                       // ── White content card (pulled up 24 px) ──────────
//                       Transform.translate(
//                         offset: const Offset(0, -24),
//                         child: Container(
//                           width: double.infinity,
//                           decoration: const BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.vertical(
//                               top: Radius.circular(AppSizes.radiusMd),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 2.h),
//
//                               if (state.flashDeals.isNotEmpty ||
//                                   state.recommended.isNotEmpty) ...[
//                                 PromoBanner(
//                                   title: 'Festive Gold Days',
//                                   heading: 'Up to 60% Off\non everything',
//                                   buttonText: 'Shop the sale',
//                                   onTap: () {},
//                                 ),
//                                 SizedBox(height: 1.h),
//                               ],
//
//                               _buildStep4(
//                                 CategorySection(categories: state.categories),
//                               ),
//
//                               SizedBox(height: 2.h),
//
//                               _buildStep5(
//                                 BlocProvider(
//                                   create: (_) =>
//                                       getIt<ServicesCubit>()..loadServices(),
//                                   child: const ServicesSection(),
//                                 ),
//                               ),
//
//                               if (state.flashDeals.isEmpty &&
//                                   state.recommended.isEmpty)
//                                 const _EmptyProductsState()
//                               else ...[
//                                 if (state.flashDeals.isNotEmpty)
//                                   _buildStep6(
//                                     FlashDealSection(
//                                       products: state.flashDeals,
//                                     ),
//                                   ),
//                                 if (state.recommended.isNotEmpty)
//                                   _buildStep7(
//                                     RecommendedSection(
//                                       products: state.recommended,
//                                     ),
//                                   ),
//                               ],
//
//                               SizedBox(height: 2.h),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStep1(Widget child) {
//     return IntroStepTarget(
//       step: 1,
//       controller: controller,
//       cardContents: const TextSpan(
//         text:
//             "Welcome to Bingo Pay! 👋\nDiscover amazing products and services in our marketplace.",
//       ),
//       child: child,
//     );
//   }
//
//   Widget _buildStep2(Widget child) {
//     return IntroStepTarget(
//       step: 2,
//       controller: controller,
//       cardContents: const TextSpan(
//         text:
//             "Your Wallet\n\nKeep track of your Bigold balance here for quick and easy payments.",
//       ),
//       child: child,
//     );
//   }
//
//   Widget _buildStep3(Widget child) {
//     return IntroStepTarget(
//       step: 3,
//       controller: controller,
//       cardContents: const TextSpan(
//         text:
//             "Search & Discover\n\nFind products and brands instantly using our search bar.",
//       ),
//       highlightDecoration: const IntroHighlightDecoration(
//         cursor: SystemMouseCursors.click,
//         radius: BorderRadius.all(Radius.circular(12)),
//         padding: EdgeInsets.all(8),
//       ),
//       child: child,
//     );
//   }
//
//   Widget _buildStep4(Widget child) {
//     return IntroStepTarget(
//       step: 4,
//       controller: controller,
//       cardContents: const TextSpan(
//         text:
//             "Browse Categories\n\nExplore products by category. Swipe to see more options.",
//       ),
//       onStepWillActivate: (fromStep) => _scrollToTarget(step: 4),
//       child: child,
//     );
//   }
//
//   Widget _buildStep5(Widget child) {
//     return IntroStepTarget(
//       step: 5,
//       controller: controller,
//       cardContents: const TextSpan(
//         text:
//             "Featured Services\n\nCheck out our partner services and exclusive offerings.",
//       ),
//       onStepWillActivate: (fromStep) => _scrollToTarget(step: 5),
//       child: child,
//     );
//   }
//
//   Widget _buildStep6(Widget child) {
//     return IntroStepTarget(
//       step: 6,
//       controller: controller,
//       cardContents: const TextSpan(
//         text:
//             "Flash Deals\n\nDon't miss out on our limited-time flash deals with huge discounts!",
//       ),
//       onStepWillActivate: (fromStep) => _scrollToTarget(step: 6),
//       child: child,
//     );
//   }
//
//   Widget _buildStep7(Widget child) {
//     return IntroStepTarget(
//       step: 7,
//       controller: controller,
//       cardContents: const TextSpan(
//         text:
//             "Recommended For You\n\nPersonalized recommendations based on your preferences.",
//       ),
//       onStepWillActivate: (fromStep) => _scrollToTarget(step: 7),
//       child: child,
//     );
//   }
//
//   void _scrollToTarget({required int step}) {
//     if (!_scrollController.hasClients) return;
//     Future.delayed(const Duration(milliseconds: 100), () {
//       final currentScroll = _scrollController.offset;
//       final maxScroll = _scrollController.position.maxScrollExtent;
//
//       late double targetScroll;
//       switch (step) {
//         case 4:
//           targetScroll = (currentScroll + 150).clamp(0.0, maxScroll);
//           break;
//         case 5:
//           targetScroll = (currentScroll + 250).clamp(0.0, maxScroll);
//           break;
//         case 6 || 7:
//           targetScroll = maxScroll;
//           break;
//         default:
//           targetScroll = currentScroll;
//       }
//
//       _scrollController
//           .animateTo(
//             targetScroll,
//             duration: const Duration(milliseconds: 400),
//             curve: Curves.easeInOut,
//           )
//           .then((_) {
//             controller.refresh();
//           });
//     });
//   }
// }
//
// class _EmptyProductsState extends StatelessWidget {
//   const _EmptyProductsState();
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 0.h),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Icon badge
//           Container(
//             width: 26.w,
//             height: 26.w,
//             decoration: const BoxDecoration(
//               color: Color(0xFFEEF2FF),
//               shape: BoxShape.circle,
//             ),
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Icon(
//                   Icons.storefront_outlined,
//                   size: 13.w,
//                   color: ThemeColors.blue,
//                 ),
//                 Positioned(
//                   bottom: 3.5.w,
//                   right: 3.5.w,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFFFA726),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.access_time_rounded,
//                       size: 3.5.w,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: 2.5.h),
//
//           Text(
//             'No Products Right Now',
//             style: TextStyle(
//               fontSize: 19.sp,
//               fontWeight: FontWeight.w700,
//               color: ThemeColors.black,
//               letterSpacing: -0.3,
//             ),
//           ),
//
//           SizedBox(height: 1.h),
//
//           Text(
//             "We're stocking up with amazing deals.\nCheck back soon for exclusive offers!",
//             style: TextStyle(
//               fontSize: 15.sp,
//               color: Colors.grey.shade500,
//               height: 1.6,
//             ),
//             textAlign: TextAlign.center,
//           ),
//
//           SizedBox(height: 2.h),
//
//           // Decorative tags row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _Tag(label: '🔥 Hot Deals', color: const Color(0xFFFFF3E0)),
//               SizedBox(width: 2.w),
//               _Tag(label: '✨ New Arrivals', color: const Color(0xFFF3E5F5)),
//               SizedBox(width: 2.w),
//               _Tag(label: '🎁 Offers', color: const Color(0xFFE8F5E9)),
//             ],
//           ),
//
//           SizedBox(height: 3.h),
//
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () => context.read<HomeCubit>().loadHome(),
//               icon: const Icon(Icons.refresh_rounded),
//               label: const Text('Refresh'),
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: ThemeColors.purple,
//                 side: const BorderSide(color: ThemeColors.purple, width: 1.5),
//                 padding: EdgeInsets.symmetric(vertical: 1.8.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 textStyle: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Tag extends StatelessWidget {
//   const _Tag({required this.label, required this.color});
//   final String label;
//   final Color color;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
//       ),
//     );
//   }
// }

import '../../../../core/theme/app_theme_colors.dart';
import '../../../categories/data/models/categories_model.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../widgets/benefits_strip.dart';
import '../widgets/book_services_section.dart';
import '../widgets/home_category_tabs.dart';
import '../widgets/home_metrics.dart';
import '../widgets/home_search_field.dart';
import '../widgets/product_rail.dart';
import '../widgets/promo_banner_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  bool _introStarted = false;

  int _selectedTabIndex = 0;

  IntroController get controller => Intro.of(context).controller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startIntroIfReady(HomeState state) {
    if (_introStarted || state.status != HomeStatus.loaded) {
      return;
    }

    _introStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      SharedPreferences.getInstance().then((prefs) {
        final hasShownIntro = prefs.getBool('hasShownHomeIntro') ?? false;

        if (hasShownIntro) {
          return;
        }

        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            if (!mounted) {
              return;
            }

            try {
              controller.start(context);
              prefs.setBool('hasShownHomeIntro', true);
            } catch (e) {
              debugPrint('Intro start error: $e');
              _introStarted = false;
            }
          },
        );
      });
    });
  }

  void _openCategory(CategoryModel cat) {
    context.push(
      AppRoutes.productListing.replaceFirst(
        ':categoryName',
        Uri.encodeComponent(cat.name),
      ),
      extra: cat.uuid,
    );
  }

  static const List<BenefitItemData> _benefits = [
    BenefitItemData(icon: Icons.verified_outlined, label: '100%\nOriginal'),
    BenefitItemData(icon: Icons.replay_rounded, label: 'Easy\nReturns'),
    BenefitItemData(
      icon: Icons.local_shipping_outlined,
      label: 'Fast\nDelivery',
    ),
    BenefitItemData(icon: Icons.shield_outlined, label: 'Secure\nPayment'),
  ];

  @override
  Widget build(BuildContext context) {
    final m = HomeMetrics.of(context);
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,

        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const HomeShimmer();
            }

            _startIntroIfReady(state);

            return RefreshIndicator(
              color: c.brand,
              backgroundColor: c.surface,
              onRefresh: () async {
                context.read<HomeCubit>().loadHome();
              },
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ── Header ──────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: m.pagePadding,
                          ),
                          child: _buildStep1(
                            BlocBuilder<CartCubit, CartState>(
                              buildWhen: (a, b) => a.totalItems != b.totalItems,
                              builder: (context, cartState) => HomeHeader(
                                metrics: m,
                                brandName: 'TheVaults',
                                cartCount: cartState.totalItems,
                                onMenuTap: () {
                                  context.push(AppRoutes.auctionScreen);
                                },
                                onWishlistTap: () =>
                                    context.push(AppRoutes.buyerWishlist),
                                onCartTap: () => context.push(AppRoutes.cart),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: m.pagePadding * 0.6),
                      ),

                      // ── Search ──────────────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: m.pagePadding,
                          ),
                          child: _buildStep3(
                            HomeSearchField(
                              metrics: m,
                              hintText: 'Search for products, brands and more',
                              onTap: () => context.push(AppRoutes.search),
                              onCameraTap: () {},
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(height: m.pagePadding * 0.6),
                      ),

                      // ── Category tabs ───────────────────────
                      if (state.categories.isNotEmpty)
                        SliverToBoxAdapter(
                          child: HomeCategoryTabs(
                            metrics: m,
                            labels: state.categories
                                .map((e) => e.name)
                                .toList(),
                            selectedIndex: _selectedTabIndex,
                            onSelected: (i) {
                              setState(() => _selectedTabIndex = i);
                              _openCategory(state.categories[i]);
                            },
                            onViewAll: () => context.push(AppRoutes.categories),
                          ),
                        ),

                      SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),

                      // ── Hero banner ─────────────────────────
                      SliverToBoxAdapter(
                        child: _buildStep2(
                          PromoBannerCarousel(
                            metrics: m,
                            banners: HomeBanners.defaults,
                            onBannerTap: (banner) {},
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: m.pagePadding,
                          ),
                          child: _buildStep4(
                            // CHANGED: step5 → step4
                            BlocProvider(
                              create: (_) =>
                                  getIt<ServicesCubit>()..loadServices(),
                              child: BlocBuilder<ServicesCubit, ServicesState>(
                                builder: (context, s) {
                                  if (s.services.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return BookServicesSection(
                                    metrics: m,
                                    title: 'Book Services',
                                    subtitle: 'Beauty, Home, Repairs & more',
                                    buttonText: 'Book Now',
                                    services: s.services,
                                    onBookNow: () =>
                                        context.push(AppRoutes.services),
                                    onServiceTap: (svc) => context.push(
                                      '/service-detail/${svc.uuid}',
                                    ),
                                    onViewAll: () =>
                                        context.push(AppRoutes.services),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(child: SizedBox(height: m.sectionGap)),

                      // ── Flash Deals / Recommended / Empty ────
                      if (state.flashDeals.isEmpty && state.recommended.isEmpty)
                        SliverToBoxAdapter(
                          child: _EmptyProductsState(metrics: m),
                        )
                      else ...[
                        if (state.flashDeals.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: _buildStep5(
                              ProductRail(
                                metrics: m,
                                title: 'Flash Deals',
                                actionText: 'View All',
                                products: state.flashDeals,
                                onActionTap: () =>
                                    context.push(AppRoutes.allProducts),
                                onProductTap: (p) {
                                  if (p.uuid == null) return;
                                  context.push(
                                    AppRoutes.productDetails,
                                    extra: p.uuid,
                                  );
                                },
                                onWishlistTap: _toggleWishlist,
                                onAddToCart: _addToCart,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(height: m.sectionGap),
                          ),
                        ],
                        if (state.recommended.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: _buildStep6(
                              ProductRail(
                                metrics: m,
                                title: 'Recommended For You',
                                actionText: 'View All',
                                products: state.recommended,
                                onActionTap: () =>
                                    context.push(AppRoutes.allProducts),
                                onProductTap: (p) {
                                  if (p.uuid == null) return;
                                  context.push(
                                    AppRoutes.productDetails,
                                    extra: p.uuid,
                                  );
                                },
                                onWishlistTap: _toggleWishlist,
                                onAddToCart: _addToCart,
                              ),
                            ),
                          ),
                          // SliverToBoxAdapter(
                          //   child: SizedBox(height: m.sectionGap),
                          // ),
                        ],
                      ],

                      // ── Benefits strip ──────────────────────
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: m.pagePadding,
                          ),
                          child: BenefitsStrip(metrics: m, benefits: _benefits),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: SizedBox(
                          height:
                              m.sectionGap +
                              MediaQuery.paddingOf(context).bottom,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─────────── Intro steps: ALL UNCHANGED ───────────
  Widget _buildStep1(Widget child) {
    return IntroStepTarget(
      step: 1,
      controller: controller,
      cardContents: const TextSpan(
        text:
            "Welcome to TheVaults! 👋\nDiscover amazing products and services in our marketplace.",
      ),
      child: child,
    );
  }

  Widget _buildStep2(Widget child) {
    return IntroStepTarget(
      step: 2,
      controller: controller,
      cardContents: const TextSpan(
        text:
            "Featured Campaign\n\nCheck out our latest seasonal collections and offers.",
      ),
      child: child,
    );
  }

  Widget _buildStep3(Widget child) {
    return IntroStepTarget(
      step: 3,
      controller: controller,
      cardContents: const TextSpan(
        text:
            "Search & Discover\n\nFind products and brands instantly using our search bar.",
      ),
      highlightDecoration: const IntroHighlightDecoration(
        cursor: SystemMouseCursors.click,
        radius: BorderRadius.all(Radius.circular(12)),
        padding: EdgeInsets.all(8),
      ),
      child: child,
    );
  }

  Widget _buildStep4(Widget child) {
    return IntroStepTarget(
      step: 4,
      controller: controller,
      cardContents: const TextSpan(
        text:
            "Book Services\n\nBeauty, home repairs, cleaning and more — book in a tap.",
      ),
      onStepWillActivate: (fromStep) => _scrollToTarget(step: 4),
      child: child,
    );
  }

  Widget _buildStep5(Widget child) {
    return IntroStepTarget(
      step: 5,
      controller: controller,
      cardContents: const TextSpan(
        text:
            "Flash Deals\n\nDon't miss out on our limited-time flash deals with huge discounts!",
      ),
      onStepWillActivate: (fromStep) => _scrollToTarget(step: 5),
      child: child,
    );
  }

  Widget _buildStep6(Widget child) {
    return IntroStepTarget(
      step: 6,
      controller: controller,
      cardContents: const TextSpan(
        text:
            "Recommended For You\n\nPersonalized recommendations based on your preferences.",
      ),
      onStepWillActivate: (fromStep) => _scrollToTarget(step: 6),
      child: child,
    );
  }

  void _scrollToTarget({required int step}) {
    if (!_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      final currentScroll = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;

      late double targetScroll;
      switch (step) {
        case 4:
          targetScroll = (currentScroll + 150).clamp(0.0, maxScroll);
          break;
        case 5:
          targetScroll = (currentScroll + 250).clamp(0.0, maxScroll);
          break;
        case 6:
          targetScroll = maxScroll;
          break;
        default:
          targetScroll = currentScroll;
      }

      _scrollController
          .animateTo(
            targetScroll,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          )
          .then((_) {
            controller.refresh();
          });
    });
  }

  // ─────────── Wishlist ───────────
  Future<void> _toggleWishlist(ProductModel product) async {
    if (product.uuid == null) return;

    final cubit = context.read<WishlistCubit>();
    final wasWishlisted = cubit.isWishlisted(product.uuid);

    await cubit.toggle(
      WishlistItem(
        id: product.uuid!,
        brand: product.brand,
        name: product.name,
        price: product.price,
        originalPrice: product.oldPrice.isNotEmpty ? product.oldPrice : null,
        discountPercent: product.discount > 0 ? product.discount : null,
        imageUrl: product.images.isNotEmpty ? product.images.first : null,
        rating: product.rating,
      ),
    );

    if (!mounted) return;
    if (!wasWishlisted) {
      AppSnackbar.showSuccess(
        context,
        'Product added to Wishlist successfully.',
      );
    }
  }

  // ─────────── Cart ───────────
  Future<void> _addToCart(ProductModel product) async {
    if (product.variantUuid == null) {
      AppSnackbar.showError(context, 'This product is currently unavailable.');
      return;
    }

    final cubit = context.read<CartCubit>();
    await cubit.addItem(variantUuid: product.variantUuid!);

    if (!mounted) return;
    final error = cubit.state.error;
    if (error != null) {
      AppSnackbar.showError(context, error);
    } else {
      AppSnackbar.showSuccess(context, 'Added to cart.');
    }
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({required this.metrics});
  final HomeMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.pagePadding * 1.5,
        vertical: metrics.sectionGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: metrics.categoryCircle * 1.6,
            height: metrics.categoryCircle * 1.6,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_outlined,
              size: metrics.categoryCircle * 0.72,
              color: c.brand,
            ),
          ),
          SizedBox(height: metrics.pagePadding),
          Text(
            'No Products Right Now',
            style: TextStyle(
              fontSize: metrics.sectionTitleSize * 1.1,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          SizedBox(height: metrics.pagePadding * 0.5),
          Text(
            "We're stocking up with amazing deals.\nCheck back soon for exclusive offers!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: metrics.heroBodySize,
              height: 1.55,
              color: c.textSecondary,
            ),
          ),
          SizedBox(height: metrics.sectionGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.brand,
                side: BorderSide(color: c.brand, width: 1.4),
                padding: EdgeInsets.symmetric(
                  vertical: metrics.pagePadding * 0.85,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: TextStyle(
                  fontSize: metrics.heroBodySize,
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
