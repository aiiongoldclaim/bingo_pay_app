import 'package:bingo_pay/features/product_details/presentation/widgets/product_detail_widgets.dart';
import 'package:bingo_pay/features/product_details/presentation/widgets/product_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

void main() {
  testWidgets(
    'tapping a thumbnail in the rail should open the full-screen image '
    'viewer at that thumbnail\'s index',
    (tester) async {
      final images = List.generate(3, (i) => 'https://cdn.example.com/img$i.jpg');
      final openedIndexes = <int>[];

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ProductGallery(
                  metrics: ProductMetrics.of(context),
                  images: images,
                  fallbackIcon: Icons.shopping_bag_outlined,
                  onImageTap: (index) => openedIndexes.add(index),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // GestureDetector order in the tree: [0] wraps the hero image,
      // [1]/[2]/[3] wrap rail thumbnails 0/1/2 respectively. Tap the
      // GestureDetector for thumbnail index 1.
      final gestureDetectors = find.byType(GestureDetector);
      expect(gestureDetectors, findsNWidgets(4));
      await tester.tap(gestureDetectors.at(2));
      await tester.pumpAndSettle();

      expect(
        openedIndexes,
        [1],
        reason: "tapping the thumbnail for image index 1 must call "
            "onImageTap(1) to open the full-screen viewer at that image — "
            "currently the thumbnail only updates which image the hero "
            "preview shows (setState(() => _index = i)) and never calls "
            "onImageTap at all",
      );
    },
  );
}
