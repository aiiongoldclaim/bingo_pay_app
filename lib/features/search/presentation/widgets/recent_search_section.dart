import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class RecentSearchesSection extends StatelessWidget {
  const RecentSearchesSection({
    super.key,
    required this.recents,
    required this.onTap,
    required this.onClear,
  });

  final List<String> recents;
  final ValueChanged<String> onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (recents.isEmpty) return const SizedBox.shrink();

    // Split into rows of up to 3
    final rows = <List<String>>[];
    for (var i = 0; i < recents.length; i += 3) {
      rows.add(recents.sublist(i, (i + 3).clamp(0, recents.length)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT',
                style: AppTextStyles.labelSmall.copyWith(
                  letterSpacing: 1.2,
                  color: ThemeColors.inkDim,
                ),
              ),
              GestureDetector(
                onTap: onClear,
                child: Text(
                  'Clear',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: ThemeColors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Chip rows
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rows
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      children: row
                          .map(
                            (term) => _RecentChip(
                              term: term,
                              onTap: () => onTap(term),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({required this.term, required this.onTap});
  final String term;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
          border: Border.all(color: ThemeColors.line),
        ),
        child: Text(term, style: AppTextStyles.bodyMedium),
      ),
    );
  }
}
