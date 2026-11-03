import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../orders/data/models/order_model.dart' show formatDateTime;
import '../../data/models/review_models.dart';

/// Five stars; tappable when [onChanged] is given.
class ReviewStars extends StatelessWidget {
  final int value;
  final double size;
  final ValueChanged<int>? onChanged;

  const ReviewStars({
    super.key,
    required this.value,
    this.size = 16,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          onChanged == null
              ? Icon(
                  i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: size,
                  color: i <= value ? c.brand : c.textMuted,
                )
              : IconButton(
                  tooltip: '$i star${i == 1 ? '' : 's'}',
                  onPressed: () => onChanged!(i),
                  iconSize: size,
                  icon: Icon(
                    i <= value
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i <= value ? c.brand : c.textMuted,
                  ),
                ),
      ],
    );
  }
}

class ReviewStatusChip extends StatelessWidget {
  final String status;

  const ReviewStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final color = switch (status) {
      'APPROVED' => c.statusSuccess,
      'PENDING' => c.statusWarning,
      'REJECTED' => c.error,
      _ => c.textMuted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        reviewStatusLabels[status] ?? status,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ReviewPhotoStrip extends StatelessWidget {
  final List<String> urls;
  final double size;

  /// Shows a remove button on each photo when given.
  final ValueChanged<String>? onRemove;

  const ReviewPhotoStrip({
    super.key,
    required this.urls,
    this.size = 64,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final url in urls)
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: size,
                    height: size,
                    color: c.surfaceAlt,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: c.textMuted,
                    ),
                  ),
                ),
              ),
              if (onRemove != null)
                Positioned(
                  right: -8,
                  top: -8,
                  child: IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    iconSize: 14,
                    tooltip: 'Remove photo',
                    onPressed: () => onRemove!(url),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// One review as a shopper reads it (product page, My Reviews).
class ReviewTile extends StatelessWidget {
  final Review review;

  /// My Reviews: what was reviewed, its status and actions.
  final bool showSubject;
  final List<Widget> actions;

  const ReviewTile({
    super.key,
    required this.review,
    this.showSubject = false,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final r = review;
    final muted = AppTextStyles.bodySmall.copyWith(color: c.textSecondary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSubject)
          Text(
            r.subject,
            style: AppTextStyles.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        Row(
          children: [
            ReviewStars(value: r.rating),
            const SizedBox(width: 8),
            if (r.status != null) ReviewStatusChip(status: r.status!),
          ],
        ),
        if ((r.title ?? '').isNotEmpty)
          Text(
            r.title!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        if ((r.comment ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              r.comment!,
              style: AppTextStyles.bodyMedium.copyWith(color: c.textPrimary),
            ),
          ),
        if (r.images.isNotEmpty) ...[
          const SizedBox(height: 8),
          ReviewPhotoStrip(urls: r.images),
        ],
        if ((r.moderationNote ?? '').isNotEmpty)
          Text(r.moderationNote!, style: muted.copyWith(color: c.error)),
        const SizedBox(height: 4),
        Text(
          [
            if (!showSubject && r.reviewer.isNotEmpty) r.reviewer,
            if (r.verifiedPurchase) 'Verified purchase',
            if (r.createdAt != null) formatDateTime(r.createdAt!),
          ].join(' · '),
          style: muted,
        ),
        if (actions.isNotEmpty) Row(children: actions),
      ],
    );
  }
}
