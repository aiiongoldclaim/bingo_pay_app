import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/products/data/datasources/product_remote_datasource.dart';
import 'package:bingo_pay/features/products/data/models/category_model.dart';
import 'package:bingo_pay/features/products/presentation/screens/add_product_screen.dart';
import 'package:bingo_pay/features/products/presentation/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockProductRemoteDataSource dataSource;

  Widget buildApp() {
    final router = GoRouter(
      initialLocation: AppRoutes.vendorProducts,
      routes: [
        GoRoute(
          path: AppRoutes.vendorProducts,
          builder: (_, _) => const ProductsScreen(),
          routes: [
            GoRoute(path: 'create', builder: (_, _) => const AddProductScreen()),
          ],
        ),
      ],
    );
    return MaterialApp.router(routerConfig: router);
  }

  setUp(() {
    dataSource = MockProductRemoteDataSource();
    when(() => dataSource.getProducts()).thenAnswer((_) async => []);
    when(() => dataSource.addProduct(any())).thenAnswer((_) async {});
    when(() => dataSource.getCategories()).thenAnswer(
      (_) async => const [
        CategoryModel(id: '1', uuid: 'uuid-1', name: 'Electronics', slug: 'electronics'),
        CategoryModel(id: '2', uuid: 'uuid-2', name: 'Apparel', slug: 'apparel'),
      ],
    );
    getIt.registerSingleton<ProductRemoteDataSource>(dataSource);
  });

  tearDown(() => getIt.reset());

  testWidgets('FAB on Products screen navigates to Add Product wizard', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget);
  });

  testWidgets('Next is blocked until required Info fields are valid, then SKU is auto-suggested on Stock step',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Info step: Next blocked with empty required fields.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Info'), findsOneWidget); // still on step 1

    await tester.enterText(find.widgetWithText(TextFormField, "e.g. Men's Cotton T-Shirt"), 'Cotton T-Shirt');
    await tester.tap(find.text('Tap to select category'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apparel').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.textContaining('MRP (max retail price)'), findsOneWidget); // now on Pricing step

    // Pricing step: fill MRP + selling price, check live discount text, then GST slab required.
    await tester.enterText(find.widgetWithText(TextFormField, '999'), '1000');
    await tester.enterText(find.widgetWithText(TextFormField, '699'), '700');
    await tester.pumpAndSettle();
    expect(find.text('30% discount applied'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    expect(find.text('GST slab is required'), findsOneWidget);

    await tester.tap(find.text('12%').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('12%').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();

    // Now on Stock step — SKU should be auto-suggested from the product name.
    expect(find.text('Barcode / EAN'), findsOneWidget);
    final skuField = tester.widget<TextFormField>(find.byType(TextFormField).first);
    expect(skuField.controller!.text, isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Products screen renders products returned by the API', (tester) async {
    when(() => dataSource.getProducts()).thenAnswer(
      (_) async => [
        {
          'title': 'Brand New Gadget',
          'slug': 'brand-new-gadget',
          'status': 'PUBLISHED',
          'isPublished': true,
          'category': {'name': 'Electronics'},
        },
      ],
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Brand New Gadget'), findsOneWidget);
  });
}
