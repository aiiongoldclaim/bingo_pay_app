import 'package:bingo_pay/features/categories/domain/entities/category_entity.dart';
import 'package:bingo_pay/features/categories/presentation/widgets/categories_grid.dart';
import 'package:bingo_pay/features/categories/presentation/widgets/categories_metrics.dart';
import 'package:bingo_pay/features/categories/presentation/widgets/categories_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _message({required bool isError, VoidCallback? onRetry}) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => CategoriesStateMessage(
        metrics: CategoriesMetrics.of(context),
        isError: isError,
        onRetry: onRetry ?? () {},
      ),
    ),
  ),
);

Widget _grid(List<CategoryEntity> categories) => MaterialApp(
  home: Scaffold(
    body: Builder(
      builder: (context) => CustomScrollView(
        slivers: [
          CategoriesSliverGrid(
            metrics: CategoriesMetrics.of(context),
            categories: categories,
          ),
        ],
      ),
    ),
  ),
);

List<CategoryEntity> _categories(int count) => List.generate(
  count,
  (i) => CategoryEntity(
    id: '$i',
    uuid: 'uuid-$i',
    name: 'Category number $i with a long name',
    slug: 'category-$i',
  ),
);

void main() {
  testWidgets(
    'an empty categories list shows a "No categories available" message '
    'instead of rendering nothing',
    (tester) async {
      await tester.pumpWidget(_message(isError: false));

      expect(find.text('No categories available'), findsOneWidget);
    },
  );

  testWidgets('a failed load shows the server-down message with a '
      'working Try Again button', (tester) async {
    var retries = 0;
    await tester.pumpWidget(_message(isError: true, onRetry: () => retries++));

    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text(
        'We’re unable to connect to our server right now. '
        'Please try again in a moment.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Try Again'));
    expect(retries, 1);
  });

  testWidgets('every category from the API is reachable — no row cap', (
    tester,
  ) async {
    await tester.pumpWidget(_grid(_categories(30)));

    expect(find.text('Category number 0 with a long name'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Category number 29 with a long name'),
      300,
    );
    expect(find.text('Category number 29 with a long name'), findsOneWidget);
  });

  testWidgets('sub-categories messages name sub-categories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => CategoriesStateMessage(
              metrics: CategoriesMetrics.of(context),
              isError: false,
              noun: 'sub-categories',
              onRetry: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('No sub-categories available'), findsOneWidget);
  });

  for (final width in [320.0, 412.0, 820.0, 1280.0]) {
    testWidgets('sub-categories shimmer lays out at ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) =>
                  SubCategoriesShimmer(metrics: CategoriesMetrics.of(context)),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [320.0, 412.0, 820.0, 1280.0]) {
    testWidgets('no overflow at ${width.toInt()}px wide with 2x text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(_grid(_categories(12)));

      expect(tester.takeException(), isNull);
    });
  }
}
