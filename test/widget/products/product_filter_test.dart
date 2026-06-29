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
          'title': 'Leather wallet — brown',
          'slug': 'leather-wallet-brown',
          'status': 'PUBLISHED',
          'isPublished': true,
          'category': {'name': 'Accessories'},
        },
        {
          'title': "Men's cotton t-shirt — navy",
          'slug': 'mens-cotton-tshirt-navy',
          'status': 'DRAFT',
          'isPublished': false,
          'category': {'name': 'Apparel'},
        },
      ],
    );
    getIt.registerSingleton<ProductRemoteDataSource>(dataSource);
  });

  tearDown(() => getIt.reset());

  testWidgets('tapping "Draft" chip filters the product list', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProductsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Leather wallet — brown'), findsOneWidget);
    expect(find.text("Men's cotton t-shirt — navy"), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Draft'));
    await tester.pumpAndSettle();

    expect(find.text('Leather wallet — brown'), findsNothing);
    expect(find.text("Men's cotton t-shirt — navy"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
