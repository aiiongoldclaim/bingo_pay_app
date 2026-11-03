import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/orders/data/datasource/orders_remote_datasource.dart';
import 'package:bingo_pay/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:bingo_pay/features/orders/presentation/screens/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class _MockRemote extends Mock implements OrdersRemoteDataSource {}

void main() {
  setUp(() {
    final remote = _MockRemote();
    when(() => remote.getOrders()).thenAnswer((_) async => []);
    getIt.registerFactory<OrdersCubit>(() => OrdersCubit(remote));
  });
  tearDown(() => getIt.reset());

  Future<GoRouter> pumpAt(WidgetTester tester, {required bool pushed}) async {
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (_, _) => const Text('home')),
        GoRoute(path: AppRoutes.profile, builder: (_, _) => const Text('profile')),
        GoRoute(path: AppRoutes.orders, builder: (_, _) => const OrdersScreen()),
      ],
    );
    await tester.pumpWidget(
      Sizer(builder: (_, _, _) => MaterialApp.router(routerConfig: router)),
    );
    if (pushed) {
      router.go(AppRoutes.profile);
      await tester.pumpAndSettle();
      router.push(AppRoutes.orders);
    } else {
      router.go(AppRoutes.orders); // e.g. "View my orders" after paying
    }
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('opened with go(), back goes home instead of doing nothing', (
    tester,
  ) async {
    await pumpAt(tester, pushed: false);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('opened with push(), back returns to where it came from', (
    tester,
  ) async {
    await pumpAt(tester, pushed: true);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('profile'), findsOneWidget);
  });

  testWidgets('the system back button goes home too', (tester) async {
    await pumpAt(tester, pushed: false);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });
}
