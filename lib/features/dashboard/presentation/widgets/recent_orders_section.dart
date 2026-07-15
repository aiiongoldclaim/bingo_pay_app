import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass/glass_card.dart';
import '../../../transactions/presentation/models/order_mock_data.dart';

const List<Color> _avatarPalette = [
  Color(0xFF1A73E8),
  Color(0xFF34A853),
  Color(0xFF7C4DFF),
  Color(0xFFB36B00),
  Color(0xFFEA4335),
];

Color _avatarColorFor(String name) => _avatarPalette[name.hashCode.abs() % _avatarPalette.length];

class RecentOrdersSection extends StatelessWidget {
  final List<Order> orders;

  /// Product image lookup, keyed by lowercase product title.
  final Map<String, String> productImages;
  final VoidCallback onSeeAllTap;

  const RecentOrdersSection({
    super.key,
    required this.orders,
    this.productImages = const {},
    required this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent orders', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: onSeeAllTap,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('See all'),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        for (final order in orders)
          _RecentOrderTile(
            order: order,
            imageUrl: order.items.isEmpty
                ? null
                : productImages[order.items.first.productName.toLowerCase()],
          ),
      ],
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final Order order;
  final String? imageUrl;

  const _RecentOrderTile({required this.order, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = switch (order.status) {
      OrderStatus.pending => (colors.warningTint, colors.warningFg),
      OrderStatus.confirmed => (colors.infoTint, colors.infoFg),
      OrderStatus.processing => (colors.infoTint, colors.infoFg),
      OrderStatus.shipped => (colors.purpleTint, colors.purpleFg),
      OrderStatus.delivered => (colors.successTint, colors.successFg),
    };
    final label = order.status.label;
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final productLine = firstItem == null
        ? 'No items'
        : '${firstItem.productName} × ${firstItem.quantity}'
            '${order.items.length > 1 ? '  +${order.items.length - 1} more' : ''}';
    final avatarName = firstItem?.productName ?? '?';
    final initial = avatarName.isNotEmpty ? avatarName[0].toUpperCase() : '?';

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm + 4),
      padding: const EdgeInsets.all(AppDimensions.md),
      radius: AppDimensions.radiusXl,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _avatarColorFor(avatarName),
            // foregroundImage falls back to the initial below if it fails to load.
            foregroundImage: imageUrl == null ? null : NetworkImage(imageUrl!),
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${order.orderId} · ${order.timeAgo}', style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  productLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.radiusCircular)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                ),
                Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
