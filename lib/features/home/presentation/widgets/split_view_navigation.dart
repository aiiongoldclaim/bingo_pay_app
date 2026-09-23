import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../services/presentation/cubit/services_state.dart';
import '../../../orders/cubit/orders_cubit.dart';
import '../../../orders/cubit/orders_state.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../auctions/presentation/cubit/auction_cubit.dart';
import '../../../auctions/presentation/cubit/auction_state.dart';
import '../../../auctions/presentation/screens/auction_detail_screen.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import 'home_metrics.dart';

enum NavigationSection {
  services('Services', Icons.miscellaneous_services_outlined),
  auctions('Auctions', Icons.local_activity_outlined),
  products('Products', Icons.shopping_bag_outlined),
  categories('Categories', Icons.category_outlined),
  orders('Orders', Icons.receipt_outlined),
  wallet('Wallet', Icons.account_balance_wallet_outlined),
  help('Help & Support', Icons.help_outline);

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

  @override
  void initState() {
    super.initState();
    _servicesCubit = getIt<ServicesCubit>()..loadServices();
    _auctionCubit = getIt<AuctionCubit>()..getAuctions();
  }

  @override
  void dispose() {
    _servicesCubit.close();
    _auctionCubit.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final metrics = HomeMetrics.of(context);

    return Row(
      children: [
        _buildLeftSidebar(colors, metrics),
        Expanded(
          child: _buildRightContent(colors, metrics),
        ),
      ],
    );
  }

  Widget _buildLeftSidebar(AppThemeColors colors, HomeMetrics metrics) {
    return Container(
      width: 95,
      color: colors.surface,
      child: Column(
        children: [
          SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: NavigationSection.values.length,
              separatorBuilder: (_, _) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final section = NavigationSection.values[index];
                final isSelected = _selectedSection == section;
                return _buildNavItem(
                  section: section,
                  isSelected: isSelected,
                  colors: colors,
                  onTap: () => setState(() => _selectedSection = section),
                );
              },
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required NavigationSection section,
    required bool isSelected,
    required AppThemeColors colors,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? colors.brand.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: colors.brand.withValues(alpha: 0.3), width: 1) : null,
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  section.icon,
                  size: 22,
                  color: isSelected ? colors.brand : colors.textSecondary,
                ),
                SizedBox(height: 5),
                Text(
                  section.label.split(' ')[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
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
            _buildOrdersContent(colors, metrics),
            _buildWalletContent(colors, metrics),
            _buildHelpContent(colors, metrics),
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
                padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Book amazing services', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: state.services.isEmpty
                    ? Center(child: Text('No services', style: TextStyle(color: colors.textSecondary)))
                    : GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                        ),
                        itemCount: state.services.length,
                        itemBuilder: (context, index) {
                          final service = state.services[index];
                          return _buildServiceCard(
                            title: service.title,
                            imageUrl: service.imageUrl,
                            colors: colors,
                            onTap: () {
                              if (service.uuid.isNotEmpty) {
                                context.push(AppRoutes.serviceDetailPath(service.uuid));
                              }
                            },
                          );
                        },
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
                padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Auctions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Bid on exclusive items', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(AppRoutes.auctionScreen),
                        icon: Icon(Icons.view_list_outlined),
                        label: Text('View All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.brand,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.myBids),
                        icon: Icon(Icons.history_outlined),
                        label: Text('My Bids'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colors.brand),
                          foregroundColor: colors.brand,
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: _buildAuctionContent(state, colors, context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuctionContent(AuctionState state, AppThemeColors colors, BuildContext context) {
    if (state is AuctionLoading || state is AuctionInitial) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(colors.brand)),
            SizedBox(height: 16),
            Text('Loading auctions...', style: TextStyle(color: colors.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }

    if (state is AuctionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: 16),
            Text('Failed to load auctions', style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(state.message, style: TextStyle(color: colors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _auctionCubit.getAuctions(),
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brand,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (state is AuctionLoaded) {
      final allAuctions = [...state.liveAuctions, ...state.endingSoonAuctions, ...state.upcomingAuctions];
      if (allAuctions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_activity_outlined, size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
              SizedBox(height: 16),
              Text('No auctions available', style: TextStyle(color: colors.textSecondary, fontSize: 14)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.auctionScreen),
                icon: Icon(Icons.view_list_outlined),
                label: Text('View All Auctions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.brand,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        separatorBuilder: (_, _) => SizedBox(height: 12),
        itemCount: allAuctions.length,
        itemBuilder: (context, index) {
          final auction = allAuctions[index];
          return _buildAuctionCardFromEntity(auction, colors, context);
        },
      );
    }

    return Center(
      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(colors.brand)),
    );
  }

  Widget _buildAuctionCardFromEntity(dynamic auction, AppThemeColors colors, BuildContext context) {
    final price = auction.currentBid ?? auction.startingPrice;
    final priceLabel = auction.currentBid != null ? 'Current Bid' : 'Starting Price';
    final isLive = auction.status.toUpperCase() == 'LIVE';
    final category = auction.category?.name.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openAuctionDetails(context, auction.uuid),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border.withValues(alpha: 0.5), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image thumbnail with LIVE badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 75,
                      height: 75,
                      child: auction.images != null && auction.images!.isNotEmpty
                          ? Image.network(
                              auction.images!.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _placeholderImage(colors),
                            )
                          : _placeholderImage(colors),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and bid count
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            auction.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${auction.bidCount} ${auction.bidCount == 1 ? 'bid' : 'bids'}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    // Category
                    if (category.isNotEmpty)
                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),

                    SizedBox(height: 8),

                    // Price section
                    Text(
                      priceLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹$price',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colors.brand,
                      ),
                    ),

                    SizedBox(height: 6),

                    // Time remaining
                    if (auction.secondsRemaining != null && auction.secondsRemaining! > 0)
                      Row(
                        children: [
                          Text(
                            'Closes in',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            _formatSecondsRemaining(auction.secondsRemaining!),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.brand,
                            ),
                          ),
                        ],
                      )
                    else if (auction.status.toUpperCase() == 'STARTING_SOON' && auction.secondsUntilStart != null)
                      Row(
                        children: [
                          Text(
                            'Starts in',
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            _formatSecondsRemaining(auction.secondsUntilStart!),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.brand,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              SizedBox(width: 8),

              // Chevron icon
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.brand,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
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


  String _formatSecondsRemaining(int seconds) {
    if (seconds <= 0) return '0s';

    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }


  Widget _buildProductsContent(AppThemeColors colors, HomeMetrics metrics) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final products = [...state.flashDeals, ...state.recommended].take(6).toList();
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Discover our collection', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? Center(child: Text('No products', style: TextStyle(color: colors.textSecondary)))
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return _buildProductCard(
                          title: p.name,
                          imageUrl: p.images.isNotEmpty ? p.images.first : null,
                          price: p.price.toString(),
                          colors: colors,
                          onTap: () {
                            if (p.uuid != null) context.push(AppRoutes.productDetails, extra: p.uuid);
                          },
                        );
                      },
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
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Browse by category', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: state.categories.isEmpty
                  ? Center(child: Text('No categories', style: TextStyle(color: colors.textSecondary)))
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return _buildCategoryCard(title: category.name, colors: colors, onTap: () {});
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersContent(AppThemeColors colors, HomeMetrics metrics) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Orders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Track and manage all your orders', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: _buildOrdersView(state, colors, context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrdersView(OrdersState state, AppThemeColors colors, BuildContext context) {
    if (state is OrdersLoading || state is OrdersInitial) {
      return Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(colors.brand)),
      );
    }

    if (state is OrdersError) {
      return Center(
        child: Text('Error: ${state.message}', style: TextStyle(color: colors.textSecondary)),
      );
    }

    if (state is OrdersLoaded) {
      if (state.all.isEmpty) {
        return Center(
          child: Text('No orders found', style: TextStyle(color: colors.textSecondary)),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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

  Widget _buildRealOrderCard(OrderModel order, AppThemeColors colors, BuildContext context) {
    final statusColor = order.orderStatus == 'Delivered' || order.orderStatus == 'DELIVERED'
        ? Colors.green
        : order.orderStatus == 'Pending' || order.orderStatus == 'PENDING'
            ? Colors.orange
            : Colors.blue;

    final placedAtStr = _formatDateTime(order.placedAt);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.orderDetail, extra: order),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1),
        ),
        padding: EdgeInsets.all(12),
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
                      Text('Order ID ${order.id}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                      SizedBox(height: 2),
                      Text(placedAtStr, style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(order.orderStatus, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: statusColor)),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text('Total: ₹${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.brand)),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: Colors.orange),
                  SizedBox(width: 6),
                  Text('Payment ${order.paymentStatus}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.orange)),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.orderDetail, extra: order),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.brand),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text('View Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.brand)),
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

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildWalletContent(AppThemeColors colors, HomeMetrics metrics) {
    return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wallet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  SizedBox(height: 4),
                  Text('Manage your balance', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.brand, colors.brand.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Available Balance', style: TextStyle(fontSize: 14, color: Colors.white70)),
                        SizedBox(height: 8),
                        Text('₹ 5,240.50', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Recent Transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  SizedBox(height: 12),
                  _buildTransactionCard('Service Booking', '-₹250', colors),
                  SizedBox(height: 8),
                  _buildTransactionCard('Refund Received', '+₹500', colors),
                  SizedBox(height: 8),
                  _buildTransactionCard('Product Purchase', '-₹1,200', colors),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildHelpContent(AppThemeColors colors, HomeMetrics metrics) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              SizedBox(height: 4),
              Text('Find answers and support', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            children: [
              _buildHelpCard('How to place an order?', Icons.shopping_cart_outlined, colors),
              SizedBox(height: 12),
              _buildHelpCard('Track your shipment', Icons.local_shipping_outlined, colors),
              SizedBox(height: 12),
              _buildHelpCard('Return & Refund Policy', Icons.assignment_return_outlined, colors),
              SizedBox(height: 12),
              _buildHelpCard('Contact Support', Icons.support_agent_outlined, colors),
              SizedBox(height: 12),
              _buildHelpCard('FAQs', Icons.help_outline, colors),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({required String title, required AppThemeColors colors, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 32, color: colors.brand),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }


  Widget _buildTransactionCard(String title, String amount, AppThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textPrimary)),
          Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: amount.startsWith('-') ? Colors.red : Colors.green)),
        ],
      ),
    );
  }

  Widget _buildHelpCard(String title, IconData icon, AppThemeColors colors) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: colors.brand),
          SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
          ),
          Icon(Icons.arrow_forward_ios_outlined, size: 16, color: colors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildServiceCard({required String title, required String? imageUrl, required AppThemeColors colors, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: colors.textPrimary.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.08), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.image, color: colors.brand, size: 30)))
                  : Center(child: Icon(Icons.miscellaneous_services_outlined, color: colors.brand, size: 30)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 11, color: Colors.amber),
                      SizedBox(width: 2),
                      Text('4.5', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    ],
                  ),
                  SizedBox(height: 3),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('From ₹299', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colors.brand)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard({required String title, required String? imageUrl, required String price, required AppThemeColors colors, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: colors.textPrimary.withValues(alpha: 0.1), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.08), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(borderRadius: BorderRadius.vertical(top: Radius.circular(12)), child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.shopping_bag, color: colors.brand, size: 30)))
                  : Center(child: Icon(Icons.shopping_bag_outlined, color: colors.brand, size: 30)),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 11, color: Colors.amber),
                      SizedBox(width: 2),
                      Text('4.3', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    ],
                  ),
                  SizedBox(height: 3),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.brand.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text('₹$price', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors.brand)),
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
