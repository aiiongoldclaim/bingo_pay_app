import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/features/products/data/datasources/product_remote_datasource.dart';
import 'package:bingo_pay/features/products/presentation/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockProductRemoteDataSource dataSource;

  setUp(() {
    dataSource = MockProductRemoteDataSource();
    when(() => dataSource.getProducts()).thenAnswer(
      (_) async => [
        {
          'product_name': 'Leather wallet — brown',
          'sku': 'ACC-2210',
          'sub_category': 'Accessories',
          'stock_quantity': 0,
          'low_stock_threshold': 5,
        },
        {
          'product_name': "Men's cotton t-shirt — navy",
          'sku': 'TSH-1042',
          'sub_category': 'Apparel',
          'selling_price': 999,
          'stock_quantity': 20,
          'low_stock_threshold': 5,
        },
      ],
    );
    getIt.registerSingleton<ProductRemoteDataSource>(dataSource);
  });

  tearDown(() => getIt.reset());

  testWidgets('tapping "Out of stock" chip filters the product list', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Leather wallet — brown'), findsOneWidget);
    expect(find.text("Men's cotton t-shirt — navy"), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Out of stock'));
    await tester.pumpAndSettle();

    expect(find.text('Leather wallet — brown'), findsOneWidget);
    expect(find.text("Men's cotton t-shirt — navy"), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
