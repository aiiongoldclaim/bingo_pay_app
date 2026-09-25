import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/vault_section.dart';
import '../models/vault_theme_colors.dart';
import 'home_metrics.dart';

class VaultExperienceSelector extends StatelessWidget {
  const VaultExperienceSelector({
    super.key,
    required this.metrics,
    required this.selectedSection,
    required this.activeTheme,
    this.onSectionChanged,
  });

  final HomeMetrics metrics;
  final VaultSection selectedSection;
  final VaultThemeColors activeTheme;
  final ValueChanged<VaultSection>? onSectionChanged;

  static const _sections = VaultSection.values;
  static const _animationDuration = Duration(milliseconds: 350);
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
                activeTheme: activeTheme,
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
    required this.activeTheme,
    required this.onTap,
  });

  final HomeMetrics metrics;
  final VaultSection section;
  final bool isSelected;
  final VaultThemeColors activeTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {

    final topRadius = metrics.heroRadius.clamp(14.0, 16.0);
    const bottomLeftRadius = 3.0;
    final bottomRightRadius = topRadius * 0.6;
    final borderColor = isSelected
        ? activeTheme.primary
        : activeTheme.tabUnselectedBorder;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: VaultExperienceSelector._animationDuration,
        curve: VaultExperienceSelector._animationCurve,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: isSelected
                ? [
                    activeTheme.headerGradientTop,
                    activeTheme.selectedTabBackground,
                  ]
                : [
                    activeTheme.headerGradientTop,
                    activeTheme.unselectedTabBackground,
                  ],
          ),

          border: isSelected
              ? Border(
                  top: BorderSide(color: borderColor, width: 1),
                  left: BorderSide(color: borderColor, width: 1),
                  right: BorderSide(color: borderColor, width: 1),
                )
              : Border(
                  top: BorderSide(color: borderColor, width: 1),
                  left: BorderSide(color: borderColor, width: 1),
                ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(topRadius),
            topRight: Radius.circular(topRadius),
            bottomLeft: const Radius.circular(bottomLeftRadius),
            bottomRight: Radius.circular(bottomRightRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: activeTheme.primary.withValues(
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
          activeTheme: activeTheme,
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
    required this.activeTheme,
  });

  final String text;
  final HomeMetrics metrics;
  final bool isSelected;
  final VaultThemeColors activeTheme;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
        style: TextStyle(
          fontFamily: AppTextStyles.fontBody,
          fontSize: metrics.tabFontSize * 0.88,
          letterSpacing: 0.1,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? activeTheme.selectedTabText : activeTheme.text,
        ),
        child: Text(text, maxLines: 1),
      ),
    );
  }
}
