import 'package:bingo_pay/features/health/presentation/cubit/health_cubit.dart';
import 'package:bingo_pay/features/health/presentation/cubit/health_state.dart';
import 'package:bingo_pay/features/health/presentation/widgets/server_down_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class MockHealthCubit extends MockCubit<HealthState> implements HealthCubit {}

const _message =
    'We’re unable to connect to our server right now. '
    'Please try again in a moment.';

void main() {
  testWidgets('server-down screen tells the user something went wrong', (
    tester,
  ) async {
    final cubit = MockHealthCubit();
    // The message the cubit emits when the server can't be reached.
    when(() => cubit.state).thenReturn(const HealthDown(_message));

    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => MaterialApp(
          home: BlocProvider<HealthCubit>.value(
            value: cubit,
            child: const ServerDownScreen(),
          ),
        ),
      ),
    );

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(find.text(_message), findsOneWidget);
    expect(find.text('Service Unavailable'), findsNothing);
  });
}
