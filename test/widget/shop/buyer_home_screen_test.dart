import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_bloc.dart';
import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_event.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/buyer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildSubject(ShopBloc bloc) {
  return BlocProvider<ShopBloc>.value(
    value: bloc,
    child: const MaterialApp(
      home: Scaffold(
        body: BuyerHomeScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the main storefront sections', (tester) async {
    final bloc = ShopBloc()..add(const ShopStarted());

    await tester.pumpWidget(buildSubject(bloc));
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Good morning, shopper'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });
}
