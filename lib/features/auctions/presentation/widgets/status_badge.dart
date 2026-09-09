import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = _getStatusColor(colors);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _getStatusColor(AppThemeColors colors) {
    switch (status) {
      case 'LIVE':
        return colors.statusSuccess;

      case 'ENDING_SOON':
        return colors.statusWarning;

      case 'STARTING_SOON':
        return colors.statusInfo;

      case 'CLOSED':
        return colors.textMuted;

      default:
        return colors.textMuted;
    }
  }
}