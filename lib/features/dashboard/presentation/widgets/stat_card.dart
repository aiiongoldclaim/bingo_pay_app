import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass/glass_card.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Widget? trailing;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: AppDimensions.radiusXl,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 12),
      child: SizedBox(
        width: 136,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          if (trailing != null) ...[const SizedBox(height: 4), trailing!],
        ],
        ),
      ),
    );
  }
}