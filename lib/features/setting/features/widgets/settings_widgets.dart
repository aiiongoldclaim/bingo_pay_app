import 'package:bingo_pay/features/setting/features/widgets/settings_metrics.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';


// ── Top bar (back + title + subtitle + optional action) ────────────────────
class SettingsTopBar extends StatelessWidget {
  final SettingsMetrics metrics;
  final String title;
  final String? subtitle;
  final Widget? action;
  final VoidCallback onBack;

  const SettingsTopBar({
    super.key,
    required this.metrics,
    required this.title,
    this.subtitle,
    this.action,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.5,
        m.pageHPad,
        m.pageVPad * 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onBack,
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: c.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                    height: 1.2,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: m.gapXs * 0.6),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.subtitleSize,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ── Section heading ────────────────────────────────────────────────────────
class SettingsSectionHeading extends StatelessWidget {
  final SettingsMetrics metrics;
  final String label;

  const SettingsSectionHeading({
    super.key,
    required this.metrics,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: AppTextStyles.titleMedium.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.sectionHeadingSize,
          ),
        ),
      ),
    );
  }
}

// ── Grouped card ───────────────────────────────────────────────────────────
class SettingsCard extends StatelessWidget {
  final SettingsMetrics metrics;
  final List<Widget> children;

  const SettingsCard({
    super.key,
    required this.metrics,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: m.pageHPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        boxShadow: c.isDark
            ? null
            : [
          BoxShadow(
            color: c.textPrimary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: m.tileHPad + m.iconBox + m.tileHPad * 0.8,
                endIndent: m.tileHPad,
                color: c.border,
              ),
          ],
        ],
      ),
    );
  }
}

// ── Tile: navigation / toggle / value ──────────────────────────────────────
class SettingsTile extends StatelessWidget {
  final SettingsMetrics metrics;
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingValue;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.metrics,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingValue,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final accent = isDestructive ? c.statusWarning : c.brand;
    final isSwitch = switchValue != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSwitch
            ? () => onSwitchChanged?.call(!switchValue!)
            : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m.tileHPad,
            vertical: m.tileVPad,
          ),
          child: Row(
            children: [
              Container(
                width: m.iconBox,
                height: m.iconBox,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? c.statusWarningSoft
                      : c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: m.iconSize, color: accent),
              ),

              SizedBox(width: m.tileHPad * 0.8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDestructive ? c.statusWarning : c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.tileTitleSize,
                        height: 1.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: m.gapXs * 0.7),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: m.tileSubSize,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: m.gapSm),

              if (isSwitch)
                Switch(
                  value: switchValue!,
                  onChanged: onSwitchChanged,
                  activeColor: c.surface,
                  activeTrackColor: c.brand,
                  inactiveThumbColor: c.surface,
                  inactiveTrackColor: c.border,
                )
              else ...[
                if (trailingValue != null) ...[
                  Text(
                    trailingValue!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.tileSubSize,
                    ),
                  ),
                  SizedBox(width: m.gapXs * 1.4),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  size: m.chevronSize + 6,
                  color: c.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────
class SettingsEmptyView extends StatelessWidget {
  final SettingsMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SettingsEmptyView({
    super.key,
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.emptyIllustration,
              height: m.emptyIllustration,
              decoration: BoxDecoration(
                color: c.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: m.emptyIllustration * 0.42,
                color: c.brand,
              ),
            ),

            SizedBox(height: m.gapLg),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.emptyTitleSize,
              ),
            ),

            SizedBox(height: m.gapSm),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.emptySubSize,
                height: 1.45,
              ),
            ),

            if (actionLabel != null) ...[
              SizedBox(height: m.gapLg),
              SizedBox(
                width: m.isTablet ? 260 : null,
                height: m.btnHeight,
                child: Material(
                  color: c.brand,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onAction,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
                      child: Center(
                        child: Text(
                          actionLabel!,
                          style: AppTextStyles.buttonText.copyWith(
                            color: c.surface,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.btnFontSize,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}