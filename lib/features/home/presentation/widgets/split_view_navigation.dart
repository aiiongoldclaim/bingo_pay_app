import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/price_formatter.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../../../services/presentation/widgets/all_services_shimmer.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/widgets/orders_shimmer.dart';
import '../../../orders/presentation/widgets/orders_metrics.dart';
import '../../../auctions/presentation/cubit/auction_cubit.dart';
import '../../../auctions/presentation/cubit/auction_state.dart';
import '../../../auctions/presentation/screens/auction_detail_screen.dart';
import '../../../auctions/presentation/screens/my_bids_screen.dart';
import '../../../auctions/presentation/widgets/auction_list_shimmer.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/cubit/categories_state.dart';
import '../../../categories/presentation/widgets/categories_metrics.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import 'home_metrics.dart';
import 'products_grid_shimmer.dart';
import 'products_metrics.dart';
import '../../../categories/data/models/categories_model.dart';

enum NavigationSection {
  services('Services', Icons.miscellaneous_services_outlined),
  auctions('Auctions', Icons.local_activity_outlined),
  products('Products', Icons.shopping_cart_outlined),
  categories('Categories', Icons.category_outlined),
  brands('Brands', Icons.storefront_outlined),
  orders('Orders', Icons.receipt_outlined);

  final String label;
  final IconData icon;

  const NavigationSection(this.label, this.icon);
}

class SplitViewNavigation extends StatefulWidget {
  const SplitViewNavigation({super.key});

  @override
  State<SplitViewNavigation> createState() => _SplitViewNavigationState();
}

class _SplitViewNavigationState extends State<SplitViewNavigation> {
  NavigationSection _selectedSection = NavigationSection.services;
  late final ServicesCubit _servicesCubit;
  late final AuctionCubit _auctionCubit;
  late final CategoriesCubit _categoriesCubit;

  @override
  void initState() {
    super.initState();
    _servicesCubit = getIt<ServicesCubit>()..loadServices();
    // Auctions are fetched when the Auctions tab is opened (see _onSectionTap).
    _auctionCubit = getIt<AuctionCubit>();
    _categoriesCubit = getIt<CategoriesCubit>()..loadData();
  }

  @override
  void dispose() {
    _servicesCubit.close();
    _auctionCubit.close();
    _categoriesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final metrics = HomeMetrics.of(context);

    return Row(
      children: [
        _buildLeftSidebar(colors, metrics),
        Expanded(child: _buildRightContent(colors, metrics)),
      ],
    );
  }

  Widget _buildLeftSidebar(AppThemeColors colors, HomeMetrics metrics) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final sidebarWidth = (screenWidth * 0.24).clamp(76.0, 110.0);

    return Container(
      width: sidebarWidth,
      color: colors.surface,
      child: Column(
        children: [
          SizedBox(height: 1.42.h),
          Expanded(
            child: ListView.separated(
              itemCount: NavigationSection.values.length,
              separatorBuilder: (_, _) => SizedBox(height: 0.95.h),
              itemBuilder: (context, index) {
                final section = NavigationSection.values[index];
                final isSelected = _selectedSection == section;
                return _buildNavItem(
                  section: section,
                  isSelected: isSelected,
                  colors: colors,
                  onTap: () => _onSectionTap(section),
                );
              },
            ),
          ),
          SizedBox(height: 1.42.h),
        ],
      ),
    );
  }

  void _onSectionTap(NavigationSection section) {
    setState(() => _selectedSection = section);

    if (section == NavigationSection.auctions &&
        _auctionCubit.state is! AuctionLoading) {
      _auctionCubit.getAuctions();
    }
  }

  Widget _buildNavItem({
    required NavigationSection section,
    required bool isSelected,
    required AppThemeColors colors,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.54.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.brand.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(
                      color: colors.brand.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            padding: EdgeInsets.symmetric(vertical: 1.19.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  section.icon,
                  size: 26,
                  color: isSelected ? colors.brand : colors.textSecondary,
                ),
                SizedBox(height: 0.59.h),
                Text(
                  section.label.split(' ')[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? colors.brand : colors.textSecondary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Wraps [child] so it's always scrollable — even when it's shorter than
  /// the viewport — so pull-to-refresh keeps working on empty/error states.
  Widget _scrollableCenter(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(child: child),
          ),
        ],
      ),
    );
  }

  Widget _buildRightContent(AppThemeColors colors, HomeMetrics metrics) {
    return Container(
      color: colors.background,
      child: SafeArea(
        left: false,
        bottom: false,
        child: IndexedStack(
          index: _selectedSection.index,
          children: [
            _buildServicesContent(colors, metrics),
            _buildAuctionsContent(colors, metrics),
            _buildProductsContent(colors, metrics),
            _buildCategoriesContent(colors, metrics),
            _buildBrandsContent(colors, metrics),
            _buildOrdersContent(colors, metrics),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesContent(AppThemeColors colors, HomeMetrics metrics) {
    return BlocProvider.value(
      value: _servicesCubit,
      child: BlocBuilder<ServicesCubit, ServicesState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4.1.w, 2.84.h, 4.1.w, 2.37.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.47.h),
                    Text(
                      'Book amazing services',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    state.status == ServicesStatus.initial ||
                        state.status == ServicesStatus.loading
                    ? const AllServicesShimmer()
                    : RefreshIndicator(
                        onRefresh: () => _servicesCubit.loadServices(),
                        color: colors.brand,
                        child: state.status == ServicesStatus.error
                            ? _scrollableCenter(
                                Text(
                                  state.errorMessage ??
                                      'Unable to load services',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              )
                            : state.services.isEmpty
                            ? _scrollableCenter(
                                Text(
                                  'No services',
                                  style: TextStyle(color: colors.textSecondary),
                                ),
                              )
                            : GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  4.1.w,
                                  0,
                                  4.1.w,
                                  10.h,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 43.59.w,
                                      mainAxisExtent: 23.7.h,
                                      mainAxisSpacing: 1.9.h,
                                      crossAxisSpacing: 4.1.w,
                                    ),
                                itemCount: state.services.length,
                                itemBuilder: (context, index) {
                                  final service = state.services[index];
                                  return _buildServiceCard(
                                    title: service.title,
                                    imageUrl: service.imageUrl,
                                    displayPrice: service.displayPrice,
                                    averageRating: service.averageRating,
                                    totalReviews: service.totalReviews,
                                    colors: colors,
                                    onTap: () {
                                      if (service.uuid.isNotEmpty) {
                                        context.push(
                                          AppRoutes.serviceDetailPath(
                                            service.uuid,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuctionsContent(AppThemeColors colors, HomeMetrics metrics) {
    return BlocProvider.value(
      value: _auctionCubit,
      child: BlocBuilder<AuctionCubit, AuctionState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4.1.w, 2.84.h, 4.1.w, 1.9.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auctions',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.47.h),
                    Text(
                      'Bid on exclusive items',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _auctionCubit.getAuctions(),
                  color: colors.brand,
                  child: _buildAuctionContent(state, colors, context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuctionContent(
    AuctionState state,
    AppThemeColors colors,
    BuildContext context,
  ) {
    if (state is AuctionLoading || state is AuctionInitial) {
      return const AuctionListShimmer();
    }

    if (state is AuctionError) {
      return _scrollableCenter(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 58,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 1.9.h),
            Text(
              'Failed to load auctions',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.95.h),
            Text(
              state.message,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.37.h),
            ElevatedButton.icon(
              onPressed: () => _auctionCubit.getAuctions(),
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brand,
                foregroundColor: colors.onBrand,
              ),
            ),
          ],
        ),
      );
    }

    if (state is AuctionLoaded) {
      final hasAuctions =
          state.liveAuctions.isNotEmpty ||
          state.endingSoonAuctions.isNotEmpty ||
          state.upcomingAuctions.isNotEmpty;

      if (!hasAuctions) {
        return _scrollableCenter(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_activity_outlined,
                size: 58,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: 1.9.h),
              Text(
                'No auctions available',
                style: TextStyle(color: colors.textSecondary, fontSize: 17),
              ),
            ],
          ),
        );
      }

      final heroAuction = state.liveAuctions.isNotEmpty
          ? _getHeroAuction(state.liveAuctions)
          : null;

      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.1.w, vertical: 0),
        children: [
          // Hero auction card
          if (heroAuction != null) ...[
            SizedBox(height: 1.42.h),
            _buildHeroAuctionCard(heroAuction, colors, context),
            SizedBox(height: 1.9.h),

            // Action buttons - stacked vertically for narrow split view
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.brand,
                            colors.brand.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            _openAuctionDetails(context, heroAuction.uuid),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 1.3.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.gavel_rounded,
                                color: colors.onBrand,
                                size: 18,
                              ),
                              SizedBox(width: 1.54.w),
                              Text(
                                'PLACE A BID',
                                style: TextStyle(
                                  color: colors.onBrand,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              SizedBox(width: 1.03.w),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: colors.onBrand,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.19.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _openMyBids(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.brand,
                      side: BorderSide(color: colors.brand, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.3.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, size: 16),
                        SizedBox(width: 1.54.w),
                        Text(
                          'MY BIDS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(width: 1.03.w),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.84.h),
          ],

          // Live Auctions section
          if (state.liveAuctions.isNotEmpty) ...[
            _buildAuctionSectionHeader(
              'Live Auctions',
              'Bidding open now',
              colors,
            ),
            SizedBox(height: 1.h),
            ...state.liveAuctions
                .take(3)
                .map(
                  (auction) => Padding(
                    padding: EdgeInsets.only(bottom: 1.2.h),
                    child: _buildAuctionCardFromEntity(
                      auction,
                      colors,
                      context,
                    ),
                  ),
                ),
            SizedBox(height: 10.h),
          ],

          // Ending Soon section
          if (state.endingSoonAuctions.isNotEmpty) ...[
            _buildAuctionSectionHeader(
              'Ending Soon',
              'Don\'t miss these auctions',
              colors,
            ),
            SizedBox(height: 1.42.h),
            ...state.endingSoonAuctions
                .take(3)
                .map(
                  (auction) => Padding(
                    padding: EdgeInsets.only(bottom: 1.42.h),
                    child: _buildAuctionCardFromEntity(
                      auction,
                      colors,
                      context,
                    ),
                  ),
                ),
            SizedBox(height: 2.37.h),
          ],

          // Upcoming section
          if (state.upcomingAuctions.isNotEmpty) ...[
            _buildAuctionSectionHeader('Upcoming', 'Get ready to bid', colors),
            SizedBox(height: 1.42.h),
            ...state.upcomingAuctions
                .take(3)
                .map(
                  (auction) => Padding(
                    padding: EdgeInsets.only(bottom: 1.42.h),
                    child: _buildAuctionCardFromEntity(
                      auction,
                      colors,
                      context,
                    ),
                  ),
                ),
            SizedBox(height: 2.37.h),
          ],
        ],
      );
    }

    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(colors.brand),
      ),
    );
  }

  Widget _buildAuctionSectionHeader(
    String title,
    String subtitle,
    AppThemeColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 0.24.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroAuctionCard(
    dynamic auction,
    AppThemeColors colors,
    BuildContext context,
  ) {
    final price = auction.currentBid ?? auction.startingPrice;
    final imageUrl = auction.images != null && auction.images!.isNotEmpty
        ? auction.images!.first
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAuctionDetails(context, auction.uuid),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 18.96.h,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _placeholderImage(colors),
                          )
                        : _placeholderImage(colors),
                  ),
                  Positioned(
                    left: 3.08.w,
                    top: 1.42.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.56.w,
                        vertical: 0.59.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 2.05.w,
                            height: 2.05.w,
                            decoration: BoxDecoration(
                              color: ThemeColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.54.w),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(3.59.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            auction.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.05.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.05.w,
                            vertical: 0.47.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.brand.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${auction.bidCount} bids',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.brand,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.95.h),
                    Text(
                      'Current Bid',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${_formatPrice(price)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.brand,
                      ),
                    ),
                    SizedBox(height: 0.95.h),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 16,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: 1.54.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Closes in',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (auction.secondsRemaining != null &&
                                  auction.secondsRemaining! > 0)
                                Text(
                                  _formatSecondsRemaining(
                                    auction.secondsRemaining!,
                                  ),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: colors.brand,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  dynamic _getHeroAuction(List<dynamic> liveAuctions) {
    if (liveAuctions.isEmpty) return null;

    final sorted = List.from(liveAuctions);
    sorted.sort((a, b) {
      final aTime = a.secondsRemaining ?? 999999999;
      final bTime = b.secondsRemaining ?? 999999999;
      return aTime.compareTo(bTime);
    });

    return sorted.first;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    if (price is num) return formatExactAmount(price);
    if (price is String) {
      try {
        return formatExactAmount(double.parse(price));
      } catch (e) {
        return price;
      }
    }
    return '0';
  }

  Widget _buildAuctionCardFromEntity(
    dynamic auction,
    AppThemeColors colors,
    BuildContext context,
  ) {
    final price = auction.currentBid ?? auction.startingPrice;
    final priceLabel = auction.currentBid != null
        ? 'CURRENT BID'
        : 'STARTING PRICE';

    final isLive = auction.status.toUpperCase() == 'LIVE';
    final category = auction.category?.name.trim() ?? '';

    final hasImage = auction.images != null && auction.images!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAuctionDetails(context, auction.uuid),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // PRODUCT IMAGE
              // ============================================================
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.35,
                    child: hasImage
                        ? Image.network(
                            auction.images!.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return _placeholderImage(colors);
                            },
                          )
                        : _placeholderImage(colors),
                  ),

                  // Slight image gradient
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors.scrim.withValues(alpha: 0.10),
                              Colors.transparent,
                              colors.scrim.withValues(alpha: 0.15),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ========================================================
                  // LIVE BADGE
                  // ========================================================
                  if (isLive)
                    Positioned(
                      top: 2.0.h,
                      left: 4.1.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.6.w,
                          vertical: 1.05.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 2.05.w,
                              height: 2.05.w,
                              decoration: const BoxDecoration(
                                color: ThemeColors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 1.8.w),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // ============================================================
              // DETAILS SECTION
              // ============================================================
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(4.2.w, 2.0.h, 4.2.w, 2.2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------------------------------------------------------
                    // BID COUNT + CATEGORY
                    // ------------------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.8.w,
                            vertical: 0.9.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.brand.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gavel_rounded,
                                color: colors.brand,
                                size: 17,
                              ),
                              SizedBox(width: 1.4.w),
                              Text(
                                '${auction.bidCount}',
                                style: TextStyle(
                                  color: colors.brand,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (category.isNotEmpty) ...[
                          SizedBox(width: 2.3.w),
                          Expanded(
                            child: Text(
                              category.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: colors.brand,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 0.8.h),

                    // ------------------------------------------------------
                    // TITLE
                    // ------------------------------------------------------
                    Text(
                      auction.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 23,
                        height: 1.22,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),

                    SizedBox(height: 1.8.h),

                    // ------------------------------------------------------
                    // PRICE + ARROW
                    // ------------------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                priceLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: colors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 0.25.h),
                              Text(
                                '\$${_formatPrice(price)}',
                                style: TextStyle(
                                  fontSize: 29,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: colors.brand,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 3.w),

                        // Arrow button
                        Container(
                          width: 12.w,
                          height: 12.w,
                          constraints: const BoxConstraints(
                            minWidth: 46,
                            minHeight: 46,
                            maxWidth: 58,
                            maxHeight: 58,
                          ),
                          decoration: BoxDecoration(
                            color: colors.brand.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: colors.brand,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.8.h),

                    // ------------------------------------------------------
                    // COUNTDOWN
                    // ------------------------------------------------------
                    _buildAuctionTimer(auction: auction, colors: colors),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionTimer({
    required dynamic auction,
    required AppThemeColors colors,
  }) {
    final status = auction.status.toUpperCase();

    String label;
    String time;
    IconData icon;

    if (auction.secondsRemaining != null && auction.secondsRemaining! > 0) {
      label = 'Closes in';
      time = _formatSecondsRemaining(auction.secondsRemaining!);
      icon = Icons.access_time_rounded;
    } else if (status == 'STARTING_SOON' && auction.secondsUntilStart != null) {
      label = 'Starts in';
      time = _formatSecondsRemaining(auction.secondsUntilStart!);
      icon = Icons.access_time_rounded;
    } else {
      label = status;
      time = '';
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.8.w, vertical: 1.55.h),
      decoration: BoxDecoration(
        color: colors.brand.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          // Clock
          Container(
            width: 10.w,
            height: 10.w,
            constraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 38,
              maxWidth: 48,
              maxHeight: 48,
            ),
            decoration: BoxDecoration(
              color: colors.brand.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colors.brand, size: 23),
          ),

          SizedBox(width: 3.w),

          // Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),

          // Time
          if (time.isNotEmpty)
            Flexible(
              child: Text(
                time,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: colors.brand,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _placeholderImage(AppThemeColors colors) {
    return Container(
      color: colors.surface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 30,
          color: colors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  void _openAuctionDetails(BuildContext context, String auctionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AuctionDetailScreen(auctionId: auctionId),
      ),
    );
  }

  void _openMyBids(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyBidsScreen()),
    );
  }

  String _formatSecondsRemaining(int seconds) {
    if (seconds <= 0) return '0s';

    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (days >= 30) {
      final months = days ~/ 30;
      final remainingDays = days % 30;
      final remainingHours = hours;
      return '${months}mo ${remainingDays}d ${remainingHours}h';
    } else if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  Widget _buildProductsContent(AppThemeColors colors, HomeMetrics metrics) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final products = [
          ...state.flashDeals,
          ...state.recommended,
        ].take(6).toList();
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.1.w, 2.84.h, 4.1.w, 2.37.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.47.h),
                  Text(
                    'Discover our collection',
                    style: TextStyle(fontSize: 16, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  state.status == HomeStatus.initial ||
                      state.status == HomeStatus.loading
                  ? ProductsGridShimmer(metrics: ProductsMetrics.of(context))
                  : RefreshIndicator(
                      onRefresh: () => context.read<HomeCubit>().loadHome(),
                      color: colors.brand,
                      child: products.isEmpty
                          ? _scrollableCenter(
                              Text(
                                'No products',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                4.1.w,
                                0,
                                4.1.w,
                                10.h,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 43.59.w,
                                    mainAxisExtent: 23.7.h,
                                    mainAxisSpacing: 1.9.h,
                                    crossAxisSpacing: 4.1.w,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final p = products[index];
                                return _buildProductCard(
                                  title: p.name,
                                  imageUrl: p.images.isNotEmpty
                                      ? p.images.first
                                      : null,
                                  price: p.price.toString(),
                                  colors: colors,
                                  onTap: () {
                                    if (p.uuid != null) {
                                      context.push(
                                        AppRoutes.productDetails,
                                        extra: p.uuid,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesContent(AppThemeColors colors, HomeMetrics metrics) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.1.w, 2.84.h, 4.1.w, 2.37.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.47.h),
                  Text(
                    'Browse by category',
                    style: TextStyle(fontSize: 16, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  state.status == HomeStatus.initial ||
                      state.status == HomeStatus.loading
                  ? const _CategoryGridShimmer()
                  : RefreshIndicator(
                      onRefresh: () => context.read<HomeCubit>().loadHome(),
                      color: colors.brand,
                      child: state.categories.isEmpty
                          ? _scrollableCenter(
                              Text(
                                'No categories',
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            )
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                3.59.w,
                                1.42.h,
                                3.59.w,
                                10.h,
                              ),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 46.15.w,
                                    mainAxisExtent: 18.96.h,
                                    mainAxisSpacing: 1.9.h,
                                    crossAxisSpacing: 3.59.w,
                                  ),
                              itemCount: state.categories.length,
                              itemBuilder: (context, index) {
                                final category = state.categories[index];
                                return _buildPremiumCategoryCard(
                                  category: category,
                                  colors: colors,
                                  onTap: () {
                                    if (category.uuid.isEmpty) return;
                                    context.push(
                                      AppRoutes.subCategoriesPath(
                                        category.uuid,
                                      ),
                                      extra: category.name,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandsContent(AppThemeColors colors, HomeMetrics metrics) {
    final m = CategoriesMetrics.of(context);

    return BlocProvider.value(
      value: _categoriesCubit,
      child: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4.1.w, 2.84.h, 4.1.w, 1.9.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Brands',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.47.h),
                    Text(
                      'Discover top brands',
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _categoriesCubit.loadData(),
                  color: colors.brand,
                  child: _buildBrandsView(state, colors, m, context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrandsView(
    CategoriesState state,
    AppThemeColors colors,
    CategoriesMetrics metrics,
    BuildContext context,
  ) {
    if (state.isBrandsLoading) {
      return AppShimmer(
        backgroundColor: colors.background,
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 3.59.w, vertical: 1.42.h),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 30.77.w,
            mainAxisExtent: 15.4.h,
            mainAxisSpacing: 1.9.h,
            crossAxisSpacing: 3.08.w,
          ),
          itemCount: 6,
          itemBuilder: (_, _) =>
              ShimmerBox(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (state.brandsError != null) {
      return _scrollableCenter(
        Padding(
          padding: EdgeInsets.all(metrics.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 58,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              SizedBox(height: 1.9.h),
              Text(
                'Failed to load brands',
                style: TextStyle(color: colors.textSecondary, fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state.brands.isEmpty) {
      return _scrollableCenter(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 58,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: 1.9.h),
            Text(
              'No brands available',
              style: TextStyle(color: colors.textSecondary, fontSize: 17),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 3.59.w, vertical: 1.42.h),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 30.77.w,
        mainAxisExtent: 15.4.h,
        mainAxisSpacing: 1.9.h,
        crossAxisSpacing: 3.08.w,
      ),
      itemCount: state.brands.length,
      itemBuilder: (context, index) {
        final brand = state.brands[index];
        return _buildBrandGridItem(
          brand: brand,
          colors: colors,
          onTap: () {
            if (brand.uuid.isEmpty) return;
            context.push(
              AppRoutes.brandListingPath(brand.name),
              extra: brand.uuid,
            );
          },
        );
      },
    );
  }

  Widget _buildBrandGridItem({
    required dynamic brand,
    required AppThemeColors colors,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(4.1.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border, width: 0.8),
              ),
              child: Text(
                brand.name.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: colors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: 0.95.h),
            Flexible(
              child: Text(
                brand.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersContent(AppThemeColors colors, HomeMetrics metrics) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4.1.w, 2.84.h, 4.1.w, 2.37.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.47.h),
                  Text(
                    'Track and manage all your orders',
                    style: TextStyle(fontSize: 16, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<OrdersCubit>().loadOrders(),
                color: colors.brand,
                child: _buildOrdersView(state, colors, context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersView(
    OrdersState state,
    AppThemeColors colors,
    BuildContext context,
  ) {
    if (state is OrdersLoading || state is OrdersInitial) {
      return OrdersShimmer(metrics: OrdersMetrics.of(context));
    }

    if (state is OrdersError) {
      return _scrollableCenter(
        Text(
          'Error: ${state.message}',
          style: TextStyle(color: colors.textSecondary),
        ),
      );
    }

    if (state is OrdersLoaded) {
      if (state.all.isEmpty) {
        return _scrollableCenter(
          Text(
            'No orders found',
            style: TextStyle(color: colors.textSecondary),
          ),
        );
      }

      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 10.h),
        separatorBuilder: (_, _) => SizedBox(height: 12),
        itemCount: state.all.length,
        itemBuilder: (context, index) {
          final order = state.all[index];
          return _buildRealOrderCard(order, colors, context);
        },
      );
    }

    return Center(
      child: Text('Loading...', style: TextStyle(color: colors.textSecondary)),
    );
  }

  Widget _buildRealOrderCard(
    OrderModel order,
    AppThemeColors colors,
    BuildContext context,
  ) {
    final statusColor =
        order.orderStatus == 'Delivered' || order.orderStatus == 'DELIVERED'
        ? ThemeColors.green
        : order.orderStatus == 'Pending' || order.orderStatus == 'PENDING'
        ? ThemeColors.orange
        : ThemeColors.blue;

    final placedAtStr = _formatDateTime(order.placedAt);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.orderDetail, extra: order),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1),
        ),
        padding: EdgeInsets.all(3.08.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID ${order.id}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 0.24.h),
                      Text(
                        placedAtStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.05.w,
                    vertical: 0.36.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.orderStatus,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.19.h),
            Text(
              'Total: ${order.formattedTotal}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.brand,
              ),
            ),
            SizedBox(height: 1.19.h),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.05.w,
                vertical: 0.71.h,
              ),
              decoration: BoxDecoration(
                color: ThemeColors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 17,
                    color: ThemeColors.orange,
                  ),
                  SizedBox(width: 1.54.w),
                  Text(
                    'Payment ${order.paymentStatus}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.orange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.19.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    context.push(AppRoutes.orderDetail, extra: order),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.brand),
                  padding: EdgeInsets.symmetric(vertical: 0.95.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.brand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPremiumCategoryCard({
    required CategoryModel category,
    required AppThemeColors colors,
    required VoidCallback onTap,
  }) {
    final hasImage = category.image != null && category.image!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: colors.surface,
            border: Border.all(color: colors.border, width: 0.9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular icon/image container - fixed size
              SizedBox(
                width: 19.49.w,
                height: 19.49.w,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: hasImage
                      ? ClipOval(
                          child: Image.network(
                            category.image!,
                            width: 16.41.w,
                            height: 16.41.w,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              category.icon,
                              size: 38,
                              color: colors.brand,
                            ),
                          ),
                        )
                      : Icon(category.icon, size: 38, color: colors.brand),
                ),
              ),
              SizedBox(height: 1.42.h),
              // Category name with fixed height
              SizedBox(
                height: 5.21.h,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.54.w),
                    child: Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String? imageUrl,
    required String displayPrice,
    required double averageRating,
    required int totalReviews,
    required AppThemeColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Icon(Icons.image, color: colors.brand, size: 36),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.miscellaneous_services_outlined,
                          color: colors.brand,
                          size: 36,
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(2.05.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.24.h),
                    if (totalReviews > 0)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: ThemeColors.amber,
                          ),
                          SizedBox(width: 0.51.w),
                          Text(
                            averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 0.36.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 1.28.w,
                        vertical: 0.24.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brand.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        displayPrice,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.brand,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String? imageUrl,
    required String price,
    required AppThemeColors colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.textPrimary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.shopping_bag,
                            color: colors.brand,
                            size: 36,
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: colors.brand,
                          size: 36,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.05.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.24.h),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: ThemeColors.amber,
                      ),
                      SizedBox(width: 0.51.w),
                      Text(
                        '4.3',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.36.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.28.w,
                      vertical: 0.24.h,
                    ),
                    decoration: BoxDecoration(
                      color: colors.brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.brand,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGridShimmer extends StatelessWidget {
  const _CategoryGridShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppShimmer(
      backgroundColor: colors.background,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(3.59.w, 1.42.h, 3.59.w, 10.h),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 46.15.w,
          mainAxisExtent: 18.96.h,
          mainAxisSpacing: 1.9.h,
          crossAxisSpacing: 3.59.w,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShimmerBox(
              width: 19.49.w,
              height: 19.49.w,
              borderRadius: BorderRadius.circular(19.49.w),
            ),
            SizedBox(height: 1.42.h),
            ShimmerBox(width: 16.w, height: 13),
          ],
        ),
      ),
    );
  }
}
