import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class LeaveWithoutPasswordDialog extends StatelessWidget {
  const LeaveWithoutPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final m = _LeaveDialogMetrics.get();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? Color.alphaBlend(
            ThemeColors.white.withValues(alpha: 0.06),
            ThemeColors.ink,
          )
        : ThemeColors.white;
    final titleColor = isDark ? ThemeColors.white : ThemeColors.ink;
    final bodyColor = isDark ? ThemeColors.inkDim : ThemeColors.inkMid;
    final accent = isDark ? ThemeColors.primaryPurple : ThemeColors.deepPurple;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: m.insetH, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.maxWidth),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(m.padH, m.padTop, m.padH, m.padH),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(m.radius),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.28 : 0.16),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? ThemeColors.black.withValues(alpha: 0.55)
                      : ThemeColors.blueDeep.withValues(alpha: 0.22),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------- badge + close ----------
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _ShieldBadge(m: m, accent: accent, isDark: isDark),
                  ],
                ),
                SizedBox(height: m.gapLg),

                // ---------- title ----------
                Text(
                  'Leave Without Setting\nYour Password?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: m.titleFont,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: titleColor,
                  ),
                ),
                SizedBox(height: m.gapMd),

                // ---------- body ----------
                Text(
                  "You haven't set a password yet. If you go back now, you "
                  "won't be able to sign in or access your account until you "
                  'complete the password setup process.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: m.bodyFont,
                    height: 1.5,
                    color: bodyColor,
                  ),
                ),
                SizedBox(height: m.gapLg),

                // ---------- actions ----------
                Row(
                  children: [
                    Expanded(
                      child: _OutlinedAction(
                        m: m,
                        accent: accent,
                        label: 'Go Back',
                        caption: 'Stay and set password',
                        captionColor: bodyColor,
                        onTap: () => Navigator.of(context).pop(false),
                      ),
                    ),
                    SizedBox(width: m.gapMd),
                    Expanded(
                      child: _FilledAction(
                        m: m,
                        label: 'Leave Anyway',
                        caption: 'Yes, take me back',
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge({
    required this.m,
    required this.accent,
    required this.isDark,
  });

  final _LeaveDialogMetrics m;
  final Color accent;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: m.badgeRing,
      height: m.badgeRing,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.4),
        color: isDark
            ? accent.withValues(alpha: 0.06)
            : accent.withValues(alpha: 0.04),
      ),
      alignment: Alignment.center,
      child: Container(
        width: m.badgeRing * 0.62,
        height: m.badgeRing * 0.62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ThemeColors.bottomSection,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.shield_outlined,
          size: m.badgeRing * 0.34,
          color: ThemeColors.white,
        ),
      ),
    );
  }
}

class _OutlinedAction extends StatelessWidget {
  const _OutlinedAction({
    required this.m,
    required this.accent,
    required this.label,
    required this.caption,
    required this.captionColor,
    required this.onTap,
  });

  final _LeaveDialogMetrics m;
  final Color accent;
  final String label;
  final String caption;
  final Color captionColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.radius * 0.6),
      child: Container(
        height: m.actionHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(m.radius * 0.6),
          border: Border.all(color: accent, width: 1.4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.buttonText.copyWith(
                fontSize: m.actionFont,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
            SizedBox(height: m.gapSm * 0.35),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: m.captionFont,
                color: captionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilledAction extends StatelessWidget {
  const _FilledAction({
    required this.m,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final _LeaveDialogMetrics m;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.radius * 0.6),
      child: Container(
        height: m.actionHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(m.radius * 0.6),
          gradient: ThemeColors.bottomSection,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.buttonText.copyWith(
                fontSize: m.actionFont,
                fontWeight: FontWeight.w700,
                color: ThemeColors.white,
              ),
            ),
            SizedBox(height: m.gapSm * 0.35),
            Text(
              caption,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: m.captionFont,
                color: ThemeColors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveDialogMetrics {
  const _LeaveDialogMetrics({
    required this.maxWidth,
    required this.insetH,
    required this.padH,
    required this.padTop,
    required this.radius,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
    required this.titleFont,
    required this.bodyFont,
    required this.noteFont,
    required this.actionFont,
    required this.captionFont,
    required this.actionHeight,
    required this.badgeRing,
    required this.closeIcon,
    required this.notePad,
    required this.noteIconBox,
  });

  final double maxWidth;
  final double insetH;
  final double padH;
  final double padTop;
  final double radius;
  final double gapSm;
  final double gapMd;
  final double gapLg;
  final double titleFont;
  final double bodyFont;
  final double noteFont;
  final double actionFont;
  final double captionFont;
  final double actionHeight;
  final double badgeRing;
  final double closeIcon;
  final double notePad;
  final double noteIconBox;

  factory _LeaveDialogMetrics.get() {
    if (ResponsiveUtils.isTabletLandscape) {
      return const _LeaveDialogMetrics(
        maxWidth: 540,
        insetH: 48,
        padH: 32,
        padTop: 26,
        radius: 26,
        gapSm: 10,
        gapMd: 14,
        gapLg: 24,
        titleFont: 26,
        bodyFont: 16,
        noteFont: 15,
        actionFont: 17,
        captionFont: 13,
        actionHeight: 66,
        badgeRing: 104,
        closeIcon: 20,
        notePad: 16,
        noteIconBox: 34,
      );
    }

    if (ResponsiveUtils.isTabletPortrait) {
      return const _LeaveDialogMetrics(
        maxWidth: 580,
        insetH: 56,
        padH: 34,
        padTop: 28,
        radius: 28,
        gapSm: 11,
        gapMd: 16,
        gapLg: 26,
        titleFont: 28,
        bodyFont: 17,
        noteFont: 16,
        actionFont: 18,
        captionFont: 14,
        actionHeight: 70,
        badgeRing: 116,
        closeIcon: 21,
        notePad: 18,
        noteIconBox: 36,
      );
    }

    // phone
    return const _LeaveDialogMetrics(
      maxWidth: 440,
      insetH: 20,
      padH: 22,
      padTop: 20,
      radius: 24,
      gapSm: 9,
      gapMd: 12,
      gapLg: 20,
      titleFont: 22,
      bodyFont: 14,
      noteFont: 13,
      actionFont: 15,
      captionFont: 11,
      actionHeight: 62,
      badgeRing: 92,
      closeIcon: 18,
      notePad: 14,
      noteIconBox: 30,
    );
  }
}
