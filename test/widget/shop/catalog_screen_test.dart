import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_bloc.dart';
import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_event.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../unit/shop/fakes/fake_shop_remote_datasource.dart';

Widget buildSubject(ShopBloc bloc) {
  return BlocProvider<ShopBloc>.value(
    value: bloc,
    child: const MaterialApp(
      home: Scaffold(
        body: CatalogScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('shows products and empty state when searching', (tester) async {
    final bloc = ShopBloc(remoteDataSource: FakeShopRemoteDataSource())
      ..add(const ShopStarted());

    await tester.pumpWidget(buildSubject(bloc));
    await tester.pumpAndSettle();

    expect(find.text('Catalog'), findsOneWidget);
    expect(find.text('Pulse ANC Headphones'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'zzzz');
    await tester.pump();

    expect(find.text('No products match your filters'), findsOneWidget);
  });
}
