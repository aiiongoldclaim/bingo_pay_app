import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../models/vault_section.dart';
import 'home_metrics.dart';

/// Premium three-section top experience nav — TheVaults / Vaults Luxe /
/// Ultra Luxe — rendered as three individually-bordered, top-rounded panels
/// (AJIO-style connected navigation tabs) rather than pill-shaped buttons or
/// plain text, sitting on top of (not blended into) the lavender header
/// gradient behind them.
class VaultExperienceSelector extends StatelessWidget {
  const VaultExperienceSelector({
    super.key,
    required this.metrics,
    required this.selectedSection,
    this.onSectionChanged,
  });

  final HomeMetrics metrics;
  final VaultSection selectedSection;
  final ValueChanged<VaultSection>? onSectionChanged;

  static const _sections = VaultSection.values;
  static const _animationDuration = Duration(milliseconds: 250);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    // Scales with the device class HomeMetrics already resolves to
    // (headerHeight itself is tuned per phone/tablet), clamped to a
    // shorter range than before so the panels read as compact tabs.
    final tabAreaHeight = (metrics.headerHeight * 1.05).clamp(52.0, 60.0);
    final tabGap = metrics.pagePadding * 0.35;

    return SizedBox(
      height: tabAreaHeight,
      child: Row(
        children: [
          for (final section in _sections) ...[
            Expanded(
              child: _ExperienceTab(
                metrics: metrics,
                section: section,
                isSelected: section == selectedSection,
                onTap: () => onSectionChanged?.call(section),
              ),
            ),
            if (section != _sections.last) SizedBox(width: tabGap),
          ],
        ],
      ),
    );
  }
}

class _ExperienceTab extends StatelessWidget {
  const _ExperienceTab({
    required this.metrics,
    required this.section,
    required this.isSelected,
    required this.onTap,
  });

  final HomeMetrics metrics;
  final VaultSection section;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Same top-rounded, near-flat-bottom "panel" shape for every tab —
    // selected vs unselected is communicated by fill/border/shadow, not by
    // a different silhouette. Top radius is intentionally modest now (not
    // the earlier 22-24) so the tabs read as gently rounded, not pill-like.
    final topRadius = metrics.heroRadius.clamp(14.0, 16.0);
    const bottomRadius = 3.0;
    final borderColor = isSelected
        ? ThemeColors.vaultSelectorPrimary
        : ThemeColors.vaultTabUnselectedBorder;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: VaultExperienceSelector._animationDuration,
        curve: VaultExperienceSelector._animationCurve,
        decoration: BoxDecoration(
          // Left anchor matches the header's own top (status-bar) colour so
          // every tab reads as "cut from" the same surface; it then washes
          // out towards white left-to-right, stronger for unselected tabs
          // so they recede, lighter for the selected one so it still pops.
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isSelected
                ? const [
                    ThemeColors.vaultHeaderGradientTop,
                    ThemeColors.vaultSelectorLavender,
                  ]
                : const [
                    ThemeColors.vaultHeaderGradientTop,
                    ThemeColors.white,
                  ],
          ),
          // No bottom edge — only top + sides — so each tab stays visually
          // attached to whatever sits beneath it instead of being boxed in.
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
            left: BorderSide(color: borderColor, width: 1),
            right: BorderSide(color: borderColor, width: 1),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topRadius),
            topRight: Radius.circular(topRadius),
            bottomLeft: const Radius.circular(bottomRadius),
            bottomRight: const Radius.circular(bottomRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.vaultSelectorPrimary.withValues(
                alpha: isSelected ? 0.28 : 0.06,
              ),
              blurRadius: isSelected ? 12 : 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding * 0.3),
        child: _TabLabel(
          text: section.label,
          metrics: metrics,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.text,
    required this.metrics,
    required this.isSelected,
  });

  final String text;
  final HomeMetrics metrics;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        style: TextStyle(
          fontFamily: AppTextStyles.fontBody,
          fontSize: metrics.tabFontSize * 0.88,
          letterSpacing: 0.1,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          // The selected tab's own gradient now washes from the light
          // status-bar colour into lavender, so white text would go
          // illegible on its left half — dark purple stays readable across
          // the whole gradient instead.
          color: ThemeColors.vaultSelectorPrimary,
        ),
        child: Text(text, maxLines: 1),
      ),
    );
  }
}
