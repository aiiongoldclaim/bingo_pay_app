import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../dashboard/presentation/widgets/home_bottom_nav.dart';

class BuyerShellScreen extends StatelessWidget {
  final Widget child;
  final String location;

  const BuyerShellScreen({
    super.key,
    required this.child,
    required this.location,
  });
  int get _selectedIndex {
    if (location.startsWith(AppRoutes.home)) {
      return 0;
    }

    if (location.startsWith(AppRoutes.categories)) {
      return 1;
    }

    if (location.startsWith(AppRoutes.cart)) {
      return 3;
    }

    if (location.startsWith(AppRoutes.account)) {
      return 4;
    }

    return 0;
  }

  // int get _selectedIndex {
  //   if (location.startsWith(AppRoutes.home)) {
  //     return 0;
  //   }
  //
  //   if (location.startsWith(AppRoutes.buyerCatalog) ||
  //       location.startsWith(AppRoutes.buyerSearch) ||
  //       location.startsWith('/buyer/categories') ||
  //       location.startsWith('/buyer/products')) {
  //     return 1;
  //   }
  //
  //   if (location.startsWith(AppRoutes.buyerCart) ||
  //       location.startsWith(AppRoutes.buyerCheckout)) {
  //     return 3;
  //   }
  //
  //   if (location.startsWith(AppRoutes.buyerProfile) ||
  //       location.startsWith(AppRoutes.buyerSettings)) {
  //     return 4;
  //   }
  //
  //   return 0;
  // }

  @override
  Widget build(BuildContext context) {
    final hideBottomNav = location.startsWith('/buyer/products');

    return Scaffold(
      body: child,
      bottomNavigationBar: hideBottomNav
          ? null
          : HomeBottomNav(
              currentIndex: _selectedIndex,
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go(AppRoutes.home);
                    break;

                  case 1:
                    context.go(AppRoutes.categories);
                    break;

                  case 2:
                    context.push(AppRoutes.scanner);
                    break;

                  case 3:
                    context.go(AppRoutes.cart);
                    break;

                  case 4:
                    context.go(AppRoutes.account);
                    break;
                }
              },
            ),
    );
  }
}
