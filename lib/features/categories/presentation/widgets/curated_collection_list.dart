// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../data/models/categories_model.dart';
//
// import '../cubit/categories_state.dart';
// import 'curated_collection_card.dart';
//
// class CuratedCollectionsList extends StatelessWidget {
//   const CuratedCollectionsList({super.key, required this.collections});
//
//   final List<CuratedCollectionModel> collections;
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       itemCount: collections.length,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       separatorBuilder: (_, __) => SizedBox(height: 1.8.h),
//       itemBuilder: (_, index) {
//         return CuratedCollectionCard(collection: collections[index]);
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../data/models/categories_model.dart';
import 'categories_metrics.dart';
import 'curated_collection_card.dart';

class CuratedCollectionsList extends StatelessWidget {
  const CuratedCollectionsList({
    super.key,
    required this.metrics,
    required this.collections,
    this.imageResolver,
    this.onCollectionTap,
  });

  final CategoriesMetrics metrics;
  final List<CuratedCollectionModel> collections;
  final String? Function(CuratedCollectionModel c)? imageResolver;
  final ValueChanged<CuratedCollectionModel>? onCollectionTap;

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) return const SizedBox.shrink();
    final m = metrics;

    return SizedBox(
      height: m.collectionHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
        itemCount: collections.length,
        separatorBuilder: (_, __) => SizedBox(width: m.gridGap),
        itemBuilder: (_, i) => CuratedCollectionCard(
          metrics: m,
          collection: collections[i],
          imageUrl: imageResolver?.call(collections[i]),
          onTap: () => onCollectionTap?.call(collections[i]),
        ),
      ),
    );
  }
}
