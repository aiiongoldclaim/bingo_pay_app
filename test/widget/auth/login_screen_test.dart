import 'package:bloc_test/bloc_test.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_event.dart';
import 'package:bingo_pay/features/auth/presentation/bloc/auth_state.dart';
import 'package:bingo_pay/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

Widget buildSubject(AuthBloc bloc) {
  return BlocProvider<AuthBloc>.value(
    value: bloc,
    child: MaterialApp.router(
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const LoginScreen())],
      ),
    ),
  );
}

void main() {
  late MockAuthBloc bloc;

  setUp(() {
    bloc = MockAuthBloc();
    when(() => bloc.state).thenReturn(const AuthInitial());
  });

  tearDown(() => bloc.close());

  testWidgets('renders email and password fields', (tester) async {
    await tester.pumpWidget(buildSubject(bloc));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('shows loading indicator when AuthLoading', (tester) async {
    when(() => bloc.state).thenReturn(const AuthLoading());
    await tester.pumpWidget(buildSubject(bloc));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('dispatches VendorLoginRequested on valid submit', (tester) async {
    await tester.pumpWidget(buildSubject(bloc));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'owner13@acme.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.text('Sign In'));
    await tester.pump();
    verify(() => bloc.add(const VendorLoginRequested(
          identifier: 'owner13@acme.com',
          password: 'password123',
        ))).called(1);
  });
}
