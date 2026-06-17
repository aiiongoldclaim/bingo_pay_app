import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';

class BuyerShellScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const BuyerShellScreen({
    super.key,
    required this.child,
    required this.location,
  });

  int get _selectedIndex {
    if (location.startsWith(AppRoutes.buyerDashboard)) {
      return 3;
    }
    if (location.startsWith(AppRoutes.buyerCart) ||
        location.startsWith(AppRoutes.buyerCheckout)) {
      return 2;
    }
    if (location.startsWith(AppRoutes.buyerCatalog) ||
        location.startsWith(AppRoutes.buyerSearch) ||
        location.startsWith('/buyer/categories') ||
        location.startsWith('/buyer/products')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go(AppRoutes.buyerHome);
          } else if (index == 1) {
            context.go(AppRoutes.buyerCatalog);
          } else if (index == 2) {
            context.go(AppRoutes.buyerCart);
          } else if (index == 3) {
            context.go(AppRoutes.buyerDashboard);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag_rounded),
            label: 'Cart',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
