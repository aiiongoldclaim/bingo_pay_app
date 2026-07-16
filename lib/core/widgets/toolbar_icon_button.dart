import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_glass.dart';
import 'glass/glass_border.dart';

/// Square bordered icon button used in list toolbars (filter, view toggle…).
/// Shows a small primary-colored dot when [showDot] is true.
class ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool showDot;
  final VoidCallback onTap;

  const ToolbarIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.glass.fill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              border: GlassBorder(context.glass),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 22, color: context.colors.textPrimary),
                if (showDot)
                  Positioned(
                    right: 9,
                    top: 9,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
