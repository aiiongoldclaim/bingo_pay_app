import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../setting/features/widgets/settings_metrics.dart';

/// Steps of the vendor application, in order.
const List<String> vendorApplicationSteps = [
  'Business Info',
  'Branding',
  'Identity',
  'Bank Account',
  'Review',
];

/// Text sizes for the step tabs, step headings and field labels — scaled
/// with sizer on phones, fixed values on tablets (portrait / landscape).
class _VendorTextSizes {
  final double tab;
  final double headerTitle;
  final double headerSubtitle;
  final double fieldLabel;

  const _VendorTextSizes._(
    this.tab,
    this.headerTitle,
    this.headerSubtitle,
    this.fieldLabel,
  );

  factory _VendorTextSizes.of(SettingsMetrics m) {
    if (!m.isTablet) return _VendorTextSizes._(15.sp, 19.sp, 14.5.sp, 16.sp);
    return m.isLandscape
        ? const _VendorTextSizes._(17, 24, 16, 18)
        : const _VendorTextSizes._(18, 25, 17, 19);
  }
}

// ── White card wrapper for a group of fields ───────────────────────────────
class VendorSectionCard extends StatelessWidget {
  final SettingsMetrics metrics;
  final Widget child;

  const VendorSectionCard({
    super.key,
    required this.metrics,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(metrics.tileHPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        border: Border.all(color: colors.border),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

// ── Step tabs (scrollable, tab-bar style) ──────────────────────────────────
class VendorStepTabs extends StatefulWidget {
  final SettingsMetrics metrics;
  final int currentIndex;
  final ValueChanged<int> onStepTap;

  const VendorStepTabs({
    super.key,
    required this.metrics,
    required this.currentIndex,
    required this.onStepTap,
  });

  @override
  State<VendorStepTabs> createState() => _VendorStepTabsState();
}

class _VendorStepTabsState extends State<VendorStepTabs> {
  late final List<GlobalKey> _keys =
      List.generate(vendorApplicationSteps.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant VendorStepTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _keys[widget.currentIndex].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.5,
            duration: const Duration(milliseconds: 250),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = widget.metrics;
    final sizes = _VendorTextSizes.of(m);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: m.pageHPad * 0.6),
        child: Row(
          children: List.generate(vendorApplicationSteps.length, (index) {
            final isActive = index == widget.currentIndex;

            return InkWell(
              key: _keys[index],
              onTap: () => widget.onStepTap(index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: m.tileHPad * 0.75,
                  vertical: m.gapSm * 1.4,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? colors.brand : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  vendorApplicationSteps[index],
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isActive ? colors.brand : colors.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: sizes.tab,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Step header (title + helper text above each form) ──────────────────────
class VendorStepHeader extends StatelessWidget {
  final SettingsMetrics metrics;
  final String title;
  final String subtitle;

  const VendorStepHeader({
    super.key,
    required this.metrics,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final sizes = _VendorTextSizes.of(m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.start,
          style: AppTextStyles.titleMedium.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: sizes.headerTitle,
            height: 1.25,
          ),
        ),
        SizedBox(height: m.gapSm * 0.8),
        Text(
          subtitle,
          textAlign: TextAlign.start,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: sizes.headerSubtitle,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

// ── Placeholder for steps whose form isn't built yet ───────────────────────
class VendorStepPlaceholder extends StatelessWidget {
  final SettingsMetrics metrics;
  final String stepName;

  const VendorStepPlaceholder({
    super.key,
    required this.metrics,
    required this.stepName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: m.gapLg * 2),
      child: Column(
        children: [
          Icon(
            Icons.construction_rounded,
            size: m.emptyIllustration * 0.35,
            color: colors.textMuted,
          ),
          SizedBox(height: m.gapMd),
          Text(
            '$stepName form coming soon',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: m.emptyTitleSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upload box (placeholder / preview with change + remove) ────────────────
class VendorImageUploadBox extends StatelessWidget {
  final SettingsMetrics metrics;
  final String? imagePath;
  final IconData placeholderIcon;
  final String placeholderText;
  final bool hasError;

  /// How the picked image fills the box — use [BoxFit.contain] for logos so
  /// nothing gets cropped.
  final BoxFit fit;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const VendorImageUploadBox({
    super.key,
    required this.metrics,
    required this.imagePath,
    required this.placeholderIcon,
    required this.placeholderText,
    required this.onPick,
    required this.onRemove,
    this.hasError = false,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final radius = BorderRadius.circular(m.cardRadius);

    return Material(
      color: imagePath == null ? colors.brandSoft : colors.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPick,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: hasError
                  ? colors.error
                  : colors.brand.withValues(alpha: 0.35),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: imagePath == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      placeholderIcon,
                      size: m.iconSize * 1.3,
                      color: colors.brand,
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      placeholderText,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colors.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.tileSubSize - 1,
                      ),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(imagePath!), fit: fit),
                    Positioned(
                      top: m.gapXs,
                      right: m.gapXs,
                      child: Row(
                        children: [
                          _OverlayIconButton(
                            metrics: m,
                            icon: Icons.edit_outlined,
                            onTap: onPick,
                          ),
                          SizedBox(width: m.gapXs),
                          _OverlayIconButton(
                            metrics: m,
                            icon: Icons.close_rounded,
                            onTap: onRemove,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final SettingsMetrics metrics;
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayIconButton({
    required this.metrics,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = metrics.iconSize * 1.35;

    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.6, color: Colors.white),
        ),
      ),
    );
  }
}

class VendorFieldLabel extends StatelessWidget {
  final SettingsMetrics metrics;
  final String label;
  final bool isRequired;

  const VendorFieldLabel({
    super.key,
    required this.metrics,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final style = AppTextStyles.labelLarge.copyWith(
      color: colors.textPrimary,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: _VendorTextSizes.of(metrics).fieldLabel,
    );

    return Text.rich(
      TextSpan(
        text: label,
        style: style,
        children: [
          if (isRequired)
            TextSpan(text: ' *', style: style.copyWith(color: colors.error)),
        ],
      ),
    );
  }
}

class VendorFieldHint extends StatelessWidget {
  final SettingsMetrics metrics;
  final String text;

  const VendorFieldHint({super.key, required this.metrics, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: context.c.textMuted,
        fontFamily: 'Inter',
        fontSize: metrics.tileSubSize - 2,
      ),
    );
  }
}

class VendorErrorText extends StatelessWidget {
  final SettingsMetrics metrics;
  final String text;

  const VendorErrorText({super.key, required this.metrics, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: context.c.error,
        fontFamily: 'Inter',
        fontSize: metrics.tileSubSize - 2,
      ),
    );
  }
}
