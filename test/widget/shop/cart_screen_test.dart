import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_bloc.dart';
import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_event.dart';
import 'package:bingo_pay/features/customer/shop/presentation/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildSubject(ShopBloc bloc) {
  return BlocProvider<ShopBloc>.value(
    value: bloc,
    child: const MaterialApp(
      home: Scaffold(
        body: CartScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('renders the empty cart state', (tester) async {
    final bloc = ShopBloc()..add(const ShopStarted());

    await tester.pumpWidget(buildSubject(bloc));
    await tester.pump();

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('Start shopping'), findsOneWidget);
  });
}
