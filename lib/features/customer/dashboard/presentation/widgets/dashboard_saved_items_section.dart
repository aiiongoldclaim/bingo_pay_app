import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../cubit/buyer_dashboard_state.dart';

/// Section displaying saved items / wishlist.
/// 
/// Shows a preview of saved items with:
/// - Item titles
/// - Horizontal scrollable list
/// - "View all" action
class DashboardSavedItemsSection extends StatelessWidget {
  final List<SavedItem> savedItems;
  final VoidCallback onViewAll;

  const DashboardSavedItemsSection({
    super.key,
    required this.savedItems,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (savedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Saved Items',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: onViewAll,
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: savedItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
            itemBuilder: (context, index) {
              final item = savedItems[index];
              return _SavedItemCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _SavedItemCard extends StatelessWidget {
  final SavedItem item;

  const _SavedItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to product detail
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View ${item.title}')),
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          color: AppColors.backgroundLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
