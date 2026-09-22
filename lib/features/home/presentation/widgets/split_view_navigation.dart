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

class _SplitViewNavigationState extends State<SplitViewNavigation> with TickerProviderStateMixin {
  NavigationSection _selectedSection = NavigationSection.services;
  late final ServicesCubit _servicesCubit;
  String _auctionTab = 'active';
  late AnimationController _timerController;
  late DateTime _auctionStartTime;

  @override
  void initState() {
    super.initState();
    _servicesCubit = getIt<ServicesCubit>()..loadServices();
    _auctionStartTime = DateTime.now();
    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _timerController.dispose();
    _servicesCubit.close();
    super.dispose();
  }

  String _getTimeRemaining(int secondsLeft) {
    int remaining = secondsLeft - DateTime.now().difference(_auctionStartTime).inSeconds;
    if (remaining < 0) remaining = 0;

    final hours = remaining ~/ 3600;
    final minutes = (remaining % 3600) ~/ 60;
    final seconds = remaining % 60;

    return '${hours}h ${minutes}m ${seconds}s';
  }

  String _getTimeUntilStart(int secondsUntilStart) {
    int remaining = secondsUntilStart - DateTime.now().difference(_auctionStartTime).inSeconds;
    if (remaining < 0) remaining = 0;

    final days = remaining ~/ 86400;
    final hours = (remaining % 86400) ~/ 3600;

    if (days > 0) {
      return '${days}d ${hours}h';
    }
    return '${hours}h';
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
    final activeAuctions = [
      {'name': 'Bauble Cluster Anti Tarnish Ring', 'category': 'Beauty & Personal Care', 'price': '300', 'bids': '0', 'secondsLeft': 9930, 'status': 'ending-soon'},
      {'name': 'Z-zone Gold Ball Crystal Set', 'category': 'Beauty Wellness', 'price': '200', 'bids': '2', 'secondsLeft': 19815, 'status': 'active'},
      {'name': 'Premium Gold Necklace Set', 'category': 'Jewelry', 'price': '450', 'bids': '5', 'secondsLeft': 4545, 'status': 'ending-soon'},
      {'name': 'Vintage Watch Collection', 'category': 'Accessories', 'price': '180', 'bids': '1', 'secondsLeft': 28820, 'status': 'active'},
    ];

    final upcomingAuctions = [
      {'name': 'Designer Handbag Premium', 'category': 'Fashion', 'price': '2500', 'secondsUntilStart': 183600, 'status': 'upcoming'},
      {'name': 'Antique Vase Ceramic', 'category': 'Collectibles', 'price': '850', 'secondsUntilStart': 129600, 'status': 'upcoming'},
      {'name': 'Luxury Watch Timepiece', 'category': 'Electronics', 'price': '5000', 'secondsUntilStart': 272400, 'status': 'upcoming'},
      {'name': 'Rare Book Collection', 'category': 'Books', 'price': '400', 'secondsUntilStart': 288000, 'status': 'upcoming'},
    ];

    final currentAuctions = _auctionTab == 'active' ? activeAuctions : upcomingAuctions;

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
              _buildTabButton('Active (${activeAuctions.length})', 'active', colors),
              SizedBox(width: 12),
              _buildTabButton('Upcoming (${upcomingAuctions.length})', 'upcoming', colors),
            ],
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            separatorBuilder: (_, _) => SizedBox(height: 12),
            itemCount: currentAuctions.length,
            itemBuilder: (context, index) {
              final auction = currentAuctions[index];
              if (_auctionTab == 'active') {
                return AnimatedBuilder(
                  animation: _timerController,
                  builder: (context, child) {
                    return _buildLiveAuctionCard(
                      name: auction['name'].toString(),
                      category: auction['category'].toString(),
                      price: auction['price'].toString(),
                      bids: auction['bids'].toString(),
                      secondsLeft: auction['secondsLeft'] as int,
                      status: auction['status'].toString(),
                      colors: colors,
                    );
                  },
                );
              } else {
                return AnimatedBuilder(
                  animation: _timerController,
                  builder: (context, child) {
                    return _buildUpcomingAuctionCard(
                      name: auction['name'].toString(),
                      category: auction['category'].toString(),
                      price: auction['price'].toString(),
                      secondsUntilStart: auction['secondsUntilStart'] as int,
                      colors: colors,
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, String tabValue, AppThemeColors colors) {
    final isActive = _auctionTab == tabValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _auctionTab = tabValue),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? colors.brand.withValues(alpha: 0.1) : Colors.transparent,
            border: Border(bottom: BorderSide(color: isActive ? colors.brand : Colors.transparent, width: 2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? colors.brand : colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveAuctionCard({
    required String name,
    required String category,
    required String price,
    required String bids,
    required int secondsLeft,
    required String status,
    required AppThemeColors colors,
  }) {
    final timeLeft = _getTimeRemaining(secondsLeft);
    final isEndingSoon = status == 'ending-soon';
    return Container(
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.shopping_bag_outlined, color: colors.brand),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(category, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isEndingSoon ? Colors.red.withValues(alpha: 0.15) : colors.brand.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isEndingSoon ? 'ENDING SOON' : 'LIVE',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isEndingSoon ? Colors.red : colors.brand),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Starting Price', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                  Text('₹$price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brand)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Bids', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                  Text(bids, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Ending in', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                  Text(
                    timeLeft,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isEndingSoon ? Colors.red : colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAuctionCard({
    required String name,
    required String category,
    required String price,
    required int secondsUntilStart,
    required AppThemeColors colors,
  }) {
    final startsIn = _getTimeUntilStart(secondsUntilStart);
    return Container(
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: colors.brand.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.hourglass_empty_outlined, color: colors.brand),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(category, style: TextStyle(fontSize: 11, color: colors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('UPCOMING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: colors.brand)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Starting Price', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                  Text('₹$price', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.brand)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Starts in', style: TextStyle(fontSize: 10, color: colors.textSecondary)),
                  Text(startsIn, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
