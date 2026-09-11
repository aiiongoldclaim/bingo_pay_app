import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intro/intro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../data/models/product_model.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/home_banner_data.dart';
import '../widgets/home_header.dart';
import '../widgets/home_shimmer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../services/presentation/cubit/services_state.dart';

import '../widgets/book_services_section.dart';
import '../widgets/home_category_tabs.dart';
import '../widgets/home_metrics.dart';
import '../widgets/home_search_field.dart';
import '../widgets/home_wallet_chip.dart';
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

  final Set<String> _addingIds = {};

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
        Future.delayed(const Duration(milliseconds: 500), () {
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
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = HomeMetrics.of(context);
    final colors = context.c;

    return BlocProvider(
      create: (_) => getIt<ServicesCubit>()..loadServices(),

      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          bottom: false,

          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading) {
                return const HomeShimmer();
              }

              if (state.status == HomeStatus.error) {
                return _HomeErrorState(metrics: m, message: state.errorMessage);
              }

              _startIntroIfReady(state);

              return RefreshIndicator(
                color: colors.brand,
                backgroundColor: colors.surface,
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
                                buildWhen: (a, b) =>
                                    a.totalItems != b.totalItems,
                                builder: (context, cartState) => HomeHeader(
                                  metrics: m,
                                  brandName: AppStrings.appBrandName,
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

                        // ── Search + wallet ─────────────────────
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: m.pagePadding,
                            ),
                            child: _buildStep3(
                              Row(
                                children: [
                                  Expanded(
                                    child: HomeSearchField(
                                      metrics: m,
                                      hintText: AppStrings.searchHint,
                                      onTap: () =>
                                          context.push(AppRoutes.search),
                                    ),
                                  ),
                                  SizedBox(width: m.pagePadding * 0.5),
                                  HomeWalletChip(
                                    metrics: m,
                                    balanceLabel: state.compactBigoldBalance,
                                    onTap: () => context.push(AppRoutes.wallet),
                                  ),
                                ],
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
                              labels: [
                                AppStrings.allTab,
                                ...state.categories.map((e) => e.name),
                              ],
                              selectedIndex: _selectedTabIndex,
                              onSelected: (i) {
                                if (i == 0) {
                                  setState(() => _selectedTabIndex = 0);
                                  return;
                                }

                                final category = state.categories[i - 1];

                                context.push(
                                  AppRoutes.productListingPath(category.name),
                                  extra: category.uuid,
                                );
                              },
                            ),
                          ),

                        SliverToBoxAdapter(
                          child: SizedBox(height: m.sectionGap),
                        ),

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

                        SliverToBoxAdapter(
                          child: SizedBox(height: m.sectionGap),
                        ),

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: m.pagePadding,
                            ),
                            child: _buildStep4(
                              BlocBuilder<ServicesCubit, ServicesState>(
                                buildWhen: (previous, current) =>
                                    previous.services != current.services,
                                builder: (context, servicesState) {
                                  return BookServicesSection(
                                    metrics: m,
                                    title: AppStrings.bookService,
                                    subtitle: AppStrings.bookServiceSubtitle,
                                    buttonText: AppStrings.bookNow,
                                    services: servicesState.services,
                                    onViewAll: () =>
                                        context.push(AppRoutes.services),
                                    onServiceTap: (service) {
                                      if (service.uuid.isEmpty) return;
                                      context.push(
                                        AppRoutes.serviceDetailPath(
                                          service.uuid,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: SizedBox(height: m.sectionGap),
                        ),

                        // ── Flash Deals / Recommended / Empty ────
                        if (state.flashDeals.isEmpty &&
                            state.recommended.isEmpty)
                          SliverToBoxAdapter(
                            child: _EmptyProductsState(metrics: m),
                          )
                        else ...[
                          if (state.flashDeals.isNotEmpty) ...[
                            SliverToBoxAdapter(
                              child: _buildStep5(
                                ProductRail(
                                  metrics: m,
                                  title: AppStrings.todaysDeals,
                                  actionText: AppStrings.viewAll,
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
                                  addingIds: _addingIds,
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
                                  title: AppStrings.recommendedForYou,
                                  actionText: AppStrings.viewAll,
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
                                  addingIds: _addingIds,
                                ),
                              ),
                            ),
                          ],
                        ],
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
      ),
    );
  }

  // ─────────── Intro steps: ALL UNCHANGED ───────────
  Widget _buildStep1(Widget child) {
    return IntroStepTarget(
      step: 1,
      controller: controller,
      cardContents: const TextSpan(text: AppStrings.introStep1),
      child: child,
    );
  }

  Widget _buildStep2(Widget child) {
    return IntroStepTarget(
      step: 2,
      controller: controller,
      cardContents: const TextSpan(text: AppStrings.introStep2),
      child: child,
    );
  }

  Widget _buildStep3(Widget child) {
    return IntroStepTarget(
      step: 3,
      controller: controller,
      cardContents: const TextSpan(text: AppStrings.introStep3),
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
      cardContents: const TextSpan(text: AppStrings.introStep4),
      onStepWillActivate: (fromStep) => _scrollToTarget(step: 4),
      child: child,
    );
  }

  Widget _buildStep5(Widget child) {
    return IntroStepTarget(
      step: 5,
      controller: controller,
      cardContents: const TextSpan(text: AppStrings.introStep5),
      onStepWillActivate: (fromStep) => _scrollToTarget(step: 5),
      child: child,
    );
  }

  Widget _buildStep6(Widget child) {
    return IntroStepTarget(
      step: 6,
      controller: controller,
      cardContents: const TextSpan(text: AppStrings.introStep6),
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
      wasWishlisted: wasWishlisted,
    );

    if (!mounted) return;
    if (!wasWishlisted) {
      AppSnackbar.showSuccess(context, AppStrings.wishlistAdded);
    }
  }

  // ─────────── Cart ───────────
  Future<void> _addToCart(ProductModel product) async {
    final uuid = product.uuid;
    if (uuid == null || _addingIds.contains(uuid)) return;

    if (product.variantUuid == null) {
      AppSnackbar.showError(context, AppStrings.productUnavailableError);
      return;
    }

    final cubit = context.read<CartCubit>();

    setState(() => _addingIds.add(uuid));

    try {
      final result = await cubit.addItem(variantUuid: product.variantUuid!);

      if (!mounted) return;
      if (!result.success) {
        AppSnackbar.showError(
          context,
          result.errorMessage ?? AppStrings.genericAddItemError,
        );
      } else {
        AppSnackbar.showSuccess(context, AppStrings.addedToCart);
      }
    } finally {
      if (mounted) setState(() => _addingIds.remove(uuid));
    }
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({required this.metrics});
  final HomeMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

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
              color: colors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.storefront_outlined,
              size: metrics.categoryCircle * 0.72,
              color: colors.brand,
            ),
          ),
          SizedBox(height: metrics.pagePadding),
          Text(
            AppStrings.noProductsRightNow,
            style: TextStyle(
              fontSize: metrics.sectionTitleSize * 1.1,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: metrics.pagePadding * 0.5),
          Text(
            AppStrings.noProductsRightNowSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: metrics.heroBodySize,
              height: 1.55,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: metrics.sectionGap),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.refresh),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.brand,
                side: BorderSide(color: colors.brand, width: 1.4),
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

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.metrics, this.message});
  final HomeMetrics metrics;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: metrics.categoryCircle * 1.6,
              height: metrics.categoryCircle * 1.6,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: metrics.categoryCircle * 0.72,
                color: colors.brand,
              ),
            ),
            SizedBox(height: metrics.pagePadding),
            Text(
              AppStrings.errorSubtitle,
              style: TextStyle(
                fontSize: metrics.sectionTitleSize * 1.1,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: metrics.pagePadding * 0.5),
            Text(
              message ?? AppStrings.checkConnectionRetry,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: metrics.heroBodySize,
                height: 1.55,
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: metrics.sectionGap),
            AppButton(
              label: AppStrings.retry,
              onPressed: () => context.read<HomeCubit>().loadHome(),
              prefixIcon: Icons.refresh_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
