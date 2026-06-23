import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
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
