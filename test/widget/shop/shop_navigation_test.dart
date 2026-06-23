import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_bloc.dart';
import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_event.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/buyer_home_screen.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/buyer_shell_screen.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/cart_screen.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/catalog_screen.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

GoRouter buildRouter(ShopBloc bloc) {
  return GoRouter(
    initialLocation: AppRoutes.buyerHome,
    routes: [
      ShellRoute(
        builder: (context, state, child) => BlocProvider<ShopBloc>.value(
          value: bloc,
          child: BuyerShellScreen(child: child, location: state.uri.path),
        ),
        routes: [
          GoRoute(
            path: AppRoutes.buyerHome,
            builder: (_, __) => const BuyerHomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.buyerCatalog,
            builder: (_, __) => const CatalogScreen(),
          ),
          // GoRoute(
          //   path: AppRoutes.buyerProductDetail,
          //   builder: (context, state) => ProductDetailScreen(
          //     productId: state.pathParameters['id'] ?? '',
          //   ),
          // ),
          GoRoute(
            path: AppRoutes.buyerCart,
            builder: (_, __) => const CartScreen(),
          ),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('supports the main buyer shopping flow', (tester) async {
    final bloc = ShopBloc()..add(const ShopStarted());

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: buildRouter(bloc)),
    );
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Shop now'), findsOneWidget);

    await tester.tap(find.text('Shop now'));
    await tester.pumpAndSettle();
    expect(find.byType(CatalogScreen), findsOneWidget);

    await tester.ensureVisible(find.text('Pulse ANC Headphones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pulse ANC Headphones'));
    await tester.pumpAndSettle();
    // expect(find.byType(ProductDetailScreen), findsOneWidget);

    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsOneWidget);
    expect(find.text('Order summary'), findsOneWidget);
  });
}
