import 'package:bingo_pay/features/search/presentation/widgets/search_section_header.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/matrics/search_metrics.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';

class SuggestionsList extends StatelessWidget {
  const SuggestionsList({
    super.key,
    required this.query,
    required this.suggestions,
    required this.onTap,
  });

  final String query;
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(4.w),
        child: Text('No suggestions found', style: AppTextStyles.bodyMedium),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) =>
            Divider(color: ThemeColors.line, height: 1),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];

          return ListTile(
            leading: const Icon(Icons.search, color: ThemeColors.inkMid),
            title: Text(suggestion, style: AppTextStyles.bodyLarge),
            trailing: const Icon(
              Icons.north_west,
              size: 18,
              color: ThemeColors.inkDim,
            ),
            onTap: () => onTap(suggestion),
          );
        },
      ),
    );
  }
}

class SuggestedChipsSection extends StatelessWidget {
  const SuggestedChipsSection({
    super.key,
    required this.metrics,
    required this.suggestions,
    this.onTap,
    this.title = 'Suggested For You',
  });

  final SearchMetrics metrics;
  final List<String> suggestions;
  final ValueChanged<String>? onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchSectionHeader(metrics: m, title: title),
        SizedBox(height: m.pagePadding * 0.7),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
          child: Wrap(
            spacing: m.chipGap,
            runSpacing: m.chipGap,
            children: suggestions
                .map(
                  (s) => _SuggestionChip(
                    metrics: m,
                    label: s,
                    onTap: () => onTap?.call(s),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.metrics,
    required this.label,
    this.onTap,
  });

  final SearchMetrics metrics;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.chipHeight),
      child: Container(
        height: m.chipHeight,
        padding: EdgeInsets.symmetric(horizontal: m.pagePadding * 0.8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.chipHeight),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: m.chipIconSize, color: c.brand),
            SizedBox(width: m.pagePadding * 0.45),
            Text(
              label,
              style: TextStyle(
                fontSize: m.chipFontSize,
                fontWeight: FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
