import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../data/models/categories_model.dart';

import '../cubit/categories_state.dart';
import 'curated_collection_card.dart';

class CuratedCollectionsList extends StatelessWidget {
  const CuratedCollectionsList({super.key, required this.collections});

  final List<CuratedCollectionModel> collections;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: collections.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => SizedBox(height: 1.8.h),
      itemBuilder: (_, index) {
        return CuratedCollectionCard(collection: collections[index]);
      },
    );
  }
}
