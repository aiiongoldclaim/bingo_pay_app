import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../models/vault_section.dart';
import 'home_metrics.dart';

/// AJIO-style brand-level segmented selector shown in the dashboard's top
/// app bar in place of the plain brand title: TheVaults / Vaults Luxe /
/// Ultra Luxe.
class VaultSectionSelector extends StatelessWidget {
  const VaultSectionSelector({
    super.key,
    required this.metrics,
    required this.selected,
    this.onChanged,
  });

  final HomeMetrics metrics;
  final VaultSection selected;
  final ValueChanged<VaultSection>? onChanged;

  static const _sections = VaultSection.values;
  static const _animationDuration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _sections.indexOf(selected);
    final pillHeight = metrics.headerHeight * 0.76;

    return Container(
      height: pillHeight,
      padding: EdgeInsets.all(metrics.pagePadding * 0.06),
      decoration: BoxDecoration(
        color: ThemeColors.vaultSelectorVeryLightLavender,
        borderRadius: BorderRadius.circular(pillHeight),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / _sections.length;

          return Stack(
            children: [
              AnimatedAlign(
                duration: _animationDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  -1 + (2 * selectedIndex / (_sections.length - 1)),
                  0,
                ),
                child: Container(
                  width: segmentWidth,
                  decoration: BoxDecoration(
                    color: ThemeColors.vaultSelectorPrimary,
                    borderRadius: BorderRadius.circular(pillHeight),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final section in _sections)
                    Expanded(
                      child: _SegmentLabel(
                        section: section,
                        metrics: metrics,
                        isSelected: section == selected,
                        onTap: () => onChanged?.call(section),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  const _SegmentLabel({
    required this.section,
    required this.metrics,
    required this.isSelected,
    required this.onTap,
  });

  final VaultSection section;
  final HomeMetrics metrics;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding * 0.15),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              style: TextStyle(
                fontFamily: AppTextStyles.fontBody,
                fontSize: metrics.tabFontSize * 0.86,
                letterSpacing: 0.1,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? ThemeColors.white
                    : ThemeColors.vaultSelectorSecondaryText,
              ),
              child: Text(section.label, maxLines: 1),
            ),
          ),
        ),
      ),
    );
  }
}
