// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
//
// class RecentSearchesSection extends StatelessWidget {
//   const RecentSearchesSection({
//     super.key,
//     required this.recents,
//     required this.onTap,
//     required this.onClear,
//   });
//
//   final List<String> recents;
//   final ValueChanged<String> onTap;
//   final VoidCallback onClear;
//
//   @override
//   Widget build(BuildContext context) {
//     if (recents.isEmpty) return const SizedBox.shrink();
//
//     // Split into rows of up to 3
//     final rows = <List<String>>[];
//     for (var i = 0; i < recents.length; i += 3) {
//       rows.add(recents.sublist(i, (i + 3).clamp(0, recents.length)));
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'RECENT',
//                 style: AppTextStyles.labelLarge.copyWith(
//                   letterSpacing: 1.2,
//                   fontSize: 15.sp,
//                   color: ThemeColors.inkMid,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: onClear,
//                 child: Text(
//                   'Clear',
//                   style: AppTextStyles.labelLarge.copyWith(
//                     color: ThemeColors.blue,
//                     fontSize: 15.sp,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // Chip rows
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: rows
//                 .map(
//                   (row) => Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Wrap(
//                       spacing: 8,
//                       children: row
//                           .map(
//                             (term) => _RecentChip(
//                               term: term,
//                               onTap: () => onTap(term),
//                             ),
//                           )
//                           .toList(),
//                     ),
//                   ),
//                 )
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _RecentChip extends StatelessWidget {
//   const _RecentChip({required this.term, required this.onTap});
//   final String term;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//         decoration: BoxDecoration(
//           color: ThemeColors.surface,
//           borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//           border: Border.all(color: ThemeColors.line),
//         ),
//         child: Text(term, style: AppTextStyles.bodyMedium),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/matrics/search_metrics.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'search_section_header.dart';

class RecentSearchesSection extends StatelessWidget {
  const RecentSearchesSection({
    super.key,
    required this.metrics,
    required this.recents,
    required this.onTap,
    required this.onClear,
    this.onRemove,
  });

  final SearchMetrics metrics;
  final List<String> recents;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (recents.isEmpty) return const SizedBox.shrink();
    final c = context.c;
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchSectionHeader(
          metrics: m,
          title: 'Recent Searches',
          actionText: 'Clear All',
          showChevron: false,
          onActionTap: onClear,
        ),
        SizedBox(height: m.pagePadding * 0.3),
        ...recents.map(
          (query) => _RecentRow(
            metrics: m,
            query: query,
            onTap: () => onTap(query),
            onRemove: onRemove == null ? null : () => onRemove!(query),
            borderColor: c.border,
          ),
        ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.metrics,
    required this.query,
    required this.onTap,
    required this.borderColor,
    this.onRemove,
  });

  final SearchMetrics metrics;
  final String query;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: m.recentRowHeight,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: borderColor)),
        ),
        child: Row(
          children: [
            Container(
              width: m.recentIconBadge,
              height: m.recentIconBadge,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: m.recentIconSize,
                color: c.brand,
              ),
            ),
            SizedBox(width: m.pagePadding * 0.8),
            Expanded(
              child: Text(
                query,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: m.recentFontSize,
                  color: c.textPrimary,
                ),
              ),
            ),
            if (onRemove != null)
              InkResponse(
                onTap: onRemove,
                radius: m.recentIconSize * 1.6,
                child: Padding(
                  padding: EdgeInsets.all(m.pagePadding * 0.4),
                  child: Icon(
                    Icons.close_rounded,
                    size: m.recentIconSize * 1.1,
                    color: c.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
