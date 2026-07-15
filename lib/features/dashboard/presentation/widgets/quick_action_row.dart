import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/glass/glass_card.dart';

class QuickAction {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  const QuickAction({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });
}

class QuickActionRow extends StatelessWidget {
  final List<QuickAction> actions;

  const QuickActionRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDimensions.sm),
          Expanded(child: _QuickActionCard(action: actions[i])),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: AppDimensions.radiusXl,
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
      onTap: action.onTap,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: action.iconBackground, shape: BoxShape.circle),
              child: Icon(action.icon, color: action.iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
    );
  }
}
