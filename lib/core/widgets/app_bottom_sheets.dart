import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// METRICS
// ═══════════════════════════════════════════════════════════════════════════

class SheetMetrics {
  final bool isTablet;
  final bool isLandscape;

  final double maxWidth;
  final double hPad;
  final double vPad;
  final double radius;

  final double handleWidth;
  final double handleHeight;

  final double titleSize;
  final double bodySize;
  final double labelSize;
  final double captionSize;

  final double rowHeight;
  final double rowIconSize;
  final double rowIconGap;

  final double radioSize;
  final double chipHeight;
  final double chipHPad;
  final double swatchSize;

  final double btnHeight;
  final double btnFontSize;
  final double btnRadius;

  final double fieldHeight;
  final double fieldRadius;

  final double qtyBtnSize;
  final double qtyIconSize;
  final double qtyValueSize;

  final double infoArtSize;

  final double gapXs;
  final double gapSm;
  final double gapMd;
  final double gapLg;

  const SheetMetrics({
    required this.isTablet,
    required this.isLandscape,
    required this.maxWidth,
    required this.hPad,
    required this.vPad,
    required this.radius,
    required this.handleWidth,
    required this.handleHeight,
    required this.titleSize,
    required this.bodySize,
    required this.labelSize,
    required this.captionSize,
    required this.rowHeight,
    required this.rowIconSize,
    required this.rowIconGap,
    required this.radioSize,
    required this.chipHeight,
    required this.chipHPad,
    required this.swatchSize,
    required this.btnHeight,
    required this.btnFontSize,
    required this.btnRadius,
    required this.fieldHeight,
    required this.fieldRadius,
    required this.qtyBtnSize,
    required this.qtyIconSize,
    required this.qtyValueSize,
    required this.infoArtSize,
    required this.gapXs,
    required this.gapSm,
    required this.gapMd,
    required this.gapLg,
  });

  static SheetMetrics of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 540;
    final isLandscape = size.width > size.height;
    if (!isTablet) return SheetMetrics.phone();
    return isLandscape
        ? SheetMetrics.tabletLandscape()
        : SheetMetrics.tabletPortrait();
  }

  factory SheetMetrics.phone() => SheetMetrics(
    isTablet: false,
    isLandscape: false,
    maxWidth: double.infinity,
    hPad: 5.w,
    vPad: 2.h,
    radius: 22,
    handleWidth: 12.w,
    handleHeight: 4,
    titleSize: 16.sp,
    bodySize: 13.sp,
    labelSize: 13.sp,
    captionSize: 12.sp,
    rowHeight: 6.2.h,
    rowIconSize: 20.sp,
    rowIconGap: 4.w,
    radioSize: 6.w,
    chipHeight: 5.6.h,
    chipHPad: 5.w,
    swatchSize: 11.w,
    btnHeight: 6.4.h,
    btnFontSize: 14.sp,
    btnRadius: 12,
    fieldHeight: 6.2.h,
    fieldRadius: 10,
    qtyBtnSize: 13.w,
    qtyIconSize: 20.sp,
    qtyValueSize: 18.sp,
    infoArtSize: 24.w,
    gapXs: 0.5.h,
    gapSm: 1.h,
    gapMd: 1.8.h,
    gapLg: 2.6.h,
  );

  factory SheetMetrics.tabletPortrait() => const SheetMetrics(
    isTablet: true,
    isLandscape: false,
    maxWidth: 620,
    hPad: 28,
    vPad: 20,
    radius: 26,
    handleWidth: 56,
    handleHeight: 5,
    titleSize: 21,
    bodySize: 16,
    labelSize: 16,
    captionSize: 14,
    rowHeight: 58,
    rowIconSize: 26,
    rowIconGap: 18,
    radioSize: 26,
    chipHeight: 50,
    chipHPad: 24,
    swatchSize: 54,
    btnHeight: 56,
    btnFontSize: 17,
    btnRadius: 14,
    fieldHeight: 54,
    fieldRadius: 12,
    qtyBtnSize: 58,
    qtyIconSize: 26,
    qtyValueSize: 24,
    infoArtSize: 110,
    gapXs: 4,
    gapSm: 10,
    gapMd: 18,
    gapLg: 26,
  );

  factory SheetMetrics.tabletLandscape() => const SheetMetrics(
    isTablet: true,
    isLandscape: true,
    maxWidth: 680,
    hPad: 24,
    vPad: 16,
    radius: 26,
    handleWidth: 52,
    handleHeight: 5,
    titleSize: 20,
    bodySize: 15,
    labelSize: 15,
    captionSize: 13,
    rowHeight: 52,
    rowIconSize: 24,
    rowIconGap: 16,
    radioSize: 24,
    chipHeight: 46,
    chipHPad: 22,
    swatchSize: 48,
    btnHeight: 52,
    btnFontSize: 16,
    btnRadius: 14,
    fieldHeight: 50,
    fieldRadius: 12,
    qtyBtnSize: 52,
    qtyIconSize: 24,
    qtyValueSize: 22,
    infoArtSize: 96,
    gapXs: 3,
    gapSm: 8,
    gapMd: 14,
    gapLg: 20,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Actions Sheet ka ek row
class SheetAction {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SheetAction({
    required this.label,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  });
}

/// Sort / Payment jaise single-select options
class SheetOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const SheetOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

/// Filter Sheet ka ek row
class SheetFilterRow {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const SheetFilterRow({
    required this.label,
    this.value = 'All',
    this.onTap,
  });
}

/// Info Sheet ka bullet point
class SheetBullet {
  final String label;
  final IconData icon;

  const SheetBullet({required this.label, required this.icon});
}

// ═══════════════════════════════════════════════════════════════════════════
// SHELL — sab sheets isi ke andar render hote hain
// ═══════════════════════════════════════════════════════════════════════════

class AppSheetShell extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? footer;
  final bool scrollable;

  const AppSheetShell({
    super.key,
    this.title,
    required this.child,
    this.footer,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = SheetMetrics.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: m.gapSm),
        Center(
          child: Container(
            width: m.handleWidth,
            height: m.handleHeight,
            decoration: BoxDecoration(
              color: c.border,
              borderRadius: BorderRadius.circular(m.handleHeight),
            ),
          ),
        ),
        SizedBox(height: m.gapMd),
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: m.hPad),
            child: Text(
              title!,
              style: AppTextStyles.titleMedium.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.titleSize,
                height: 1.25,
              ),
            ),
          ),
          SizedBox(height: m.gapMd),
        ],
        Flexible(
          child: scrollable
              ? SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: m.hPad),
            child: child,
          )
              : Padding(
            padding: EdgeInsets.symmetric(horizontal: m.hPad),
            child: child,
          ),
        ),
        if (footer != null) ...[
          SizedBox(height: m.gapLg),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: m.hPad),
            child: footer!,
          ),
        ],
        SizedBox(height: m.vPad),
      ],
    );

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: m.maxWidth,
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Har sheet isi helper se open hota hai
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  final c = context.c;
  final m = SheetMetrics.of(context);

  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: c.surface,
    barrierColor: c.textPrimary.withValues(alpha: 0.45),
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(m.radius)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: builder(sheetContext),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED PIECES
// ═══════════════════════════════════════════════════════════════════════════

class AppSheetButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;

  const AppSheetButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = SheetMetrics.of(context);
    final enabled = onTap != null && !isLoading;

    return SizedBox(
      height: m.btnHeight,
      child: Material(
        color: isPrimary
            ? (enabled ? c.brand : c.border)
            : c.brandSoft,
        borderRadius: BorderRadius.circular(m.btnRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(m.btnRadius),
              border: isPrimary
                  ? null
                  : Border.all(color: c.brand.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
              width: m.btnFontSize + 4,
              height: m.btnFontSize + 4,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(
                  isPrimary ? c.surface : c.brand,
                ),
              ),
            )
                : Text(
              label,
              style: AppTextStyles.buttonText.copyWith(
                color: isPrimary
                    ? (enabled ? c.surface : c.textMuted)
                    : c.brand,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.btnFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;
  final SheetMetrics metrics;

  const _Radio({required this.selected, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      width: m.radioSize,
      height: m.radioSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? c.brand : c.border,
          width: selected ? m.radioSize * 0.16 : 1.5,
        ),
      ),
      child: selected
          ? Center(
        child: Container(
          width: m.radioSize * 0.36,
          height: m.radioSize * 0.36,
          decoration: BoxDecoration(
            color: c.brand,
            shape: BoxShape.circle,
          ),
        ),
      )
          : null,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. ACTIONS SHEET
// ═══════════════════════════════════════════════════════════════════════════

Future<void> showAppActionsSheet({
  required BuildContext context,
  String title = 'Choose an Action',
  required List<SheetAction> actions,
  String cancelLabel = 'Cancel',
}) {
  return showAppSheet<void>(
    context: context,
    builder: (sheetContext) {
      final c = sheetContext.c;
      final m = SheetMetrics.of(sheetContext);

      final normal = actions.where((a) => !a.isDestructive).toList();
      final destructive = actions.where((a) => a.isDestructive).toList();

      Widget row(SheetAction a) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: a.onTap == null
              ? null
              : () {
            Navigator.pop(sheetContext);
            a.onTap!();
          },
          child: SizedBox(
            height: m.rowHeight,
            child: Row(
              children: [
                Icon(
                  a.icon,
                  size: m.rowIconSize,
                  color: a.isDestructive ? c.statusWarning : c.textSecondary,
                ),
                SizedBox(width: m.rowIconGap),
                Expanded(
                  child: Text(
                    a.label,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: a.isDestructive ? c.statusWarning : c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: m.labelSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      return AppSheetShell(
        title: title,
        footer: AppSheetButton(
          label: cancelLabel,
          isPrimary: false,
          onTap: () => Navigator.pop(sheetContext),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ...normal.map(row),
            if (destructive.isNotEmpty) ...[
              Divider(height: m.gapMd * 2, thickness: 1, color: c.border),
              ...destructive.map(row),
            ],
          ],
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. SINGLE-SELECT SHEET (Sort By / Payment Methods)
// ═══════════════════════════════════════════════════════════════════════════

Future<T?> showAppSelectSheet<T>({
  required BuildContext context,
  required String title,
  required List<SheetOption<T>> options,
  T? selected,
  String confirmLabel = 'Apply',
  bool showDividers = false,
}) {
  return showAppSheet<T>(
    context: context,
    builder: (sheetContext) => _SelectSheetBody<T>(
      title: title,
      options: options,
      initial: selected,
      confirmLabel: confirmLabel,
      showDividers: showDividers,
    ),
  );
}

class _SelectSheetBody<T> extends StatefulWidget {
  final String title;
  final List<SheetOption<T>> options;
  final T? initial;
  final String confirmLabel;
  final bool showDividers;

  const _SelectSheetBody({
    required this.title,
    required this.options,
    required this.initial,
    required this.confirmLabel,
    required this.showDividers,
  });

  @override
  State<_SelectSheetBody<T>> createState() => _SelectSheetBodyState<T>();
}

class _SelectSheetBodyState<T> extends State<_SelectSheetBody<T>> {
  late T? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = SheetMetrics.of(context);

    return AppSheetShell(
      title: widget.title,
      footer: AppSheetButton(
        label: widget.confirmLabel,
        onTap: _selected == null
            ? null
            : () => Navigator.pop(context, _selected),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.options.length, (i) {
          final opt = widget.options[i];
          final isSelected = opt.value == _selected;
          final isLast = i == widget.options.length - 1;

          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selected = opt.value),
                  child: SizedBox(
                    height: opt.subtitle == null
                        ? m.rowHeight
                        : m.rowHeight * 1.25,
                    child: Row(
                      children: [
                        if (opt.icon != null) ...[
                          Icon(
                            opt.icon,
                            size: m.rowIconSize,
                            color: c.textSecondary,
                          ),
                          SizedBox(width: m.rowIconGap),
                        ] else ...[
                          _Radio(selected: isSelected, metrics: m),
                          SizedBox(width: m.rowIconGap),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                opt.label,
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: c.textPrimary,
                                  fontFamily: 'Inter',
                                  fontWeight: opt.subtitle == null
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  fontSize: m.labelSize,
                                  height: 1.3,
                                ),
                              ),
                              if (opt.subtitle != null) ...[
                                SizedBox(height: m.gapXs * 0.6),
                                Text(
                                  opt.subtitle!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: c.textSecondary,
                                    fontFamily: 'Inter',
                                    fontSize: m.captionSize,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (opt.icon != null) ...[
                          SizedBox(width: m.gapSm),
                          _Radio(selected: isSelected, metrics: m),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.showDividers && !isLast)
                Divider(height: 1, thickness: 1, color: c.border),
            ],
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. FILTER SHEET
// ═══════════════════════════════════════════════════════════════════════════

Future<void> showAppFilterSheet({
  required BuildContext context,
  String title = 'Filter',
  required List<SheetFilterRow> rows,
  VoidCallback? onClearAll,
  VoidCallback? onApply,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (sheetContext) {
      final c = sheetContext.c;
      final m = SheetMetrics.of(sheetContext);

      return AppSheetShell(
        title: title,
        footer: Row(
          children: [
            Expanded(
              child: AppSheetButton(
                label: 'Clear All',
                isPrimary: false,
                onTap: onClearAll == null
                    ? null
                    : () {
                  Navigator.pop(sheetContext);
                  onClearAll();
                },
              ),
            ),
            SizedBox(width: m.gapSm * 1.2),
            Expanded(
              child: AppSheetButton(
                label: 'Apply',
                onTap: onApply == null
                    ? null
                    : () {
                  Navigator.pop(sheetContext);
                  onApply();
                },
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(rows.length, (i) {
            final row = rows[i];
            final isLast = i == rows.length - 1;

            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: row.onTap,
                    child: SizedBox(
                      height: m.rowHeight,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              row.label,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: c.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: m.labelSize,
                              ),
                            ),
                          ),
                          Text(
                            row.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: c.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: m.bodySize,
                            ),
                          ),
                          SizedBox(width: m.gapXs * 1.4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: m.rowIconSize,
                            color: c.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, thickness: 1, color: c.border),
              ],
            );
          }),
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. CHIP SHEET (Select Size)
// ═══════════════════════════════════════════════════════════════════════════

Future<String?> showAppChipSheet({
  required BuildContext context,
  String title = 'Select Size',
  required List<String> chips,
  String? selected,
  Set<String> disabled = const {},
  String? linkLabel,
  IconData? linkIcon,
  VoidCallback? onLinkTap,
  String confirmLabel = 'Done',
}) {
  return showAppSheet<String>(
    context: context,
    builder: (sheetContext) => _ChipSheetBody(
      title: title,
      chips: chips,
      initial: selected,
      disabled: disabled,
      linkLabel: linkLabel,
      linkIcon: linkIcon,
      onLinkTap: onLinkTap,
      confirmLabel: confirmLabel,
    ),
  );
}

class _ChipSheetBody extends StatefulWidget {
  final String title;
  final List<String> chips;
  final String? initial;
  final Set<String> disabled;
  final String? linkLabel;
  final IconData? linkIcon;
  final VoidCallback? onLinkTap;
  final String confirmLabel;

  const _ChipSheetBody({
    required this.title,
    required this.chips,
    required this.initial,
    required this.disabled,
    required this.linkLabel,
    required this.linkIcon,
    required this.onLinkTap,
    required this.confirmLabel,
  });

  @override
  State<_ChipSheetBody> createState() => _ChipSheetBodyState();
}

class _ChipSheetBodyState extends State<_ChipSheetBody> {
  late String? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = SheetMetrics.of(context);

    return AppSheetShell(
      title: widget.title,
      footer: AppSheetButton(
        label: widget.confirmLabel,
        onTap: _selected == null
            ? null
            : () => Navigator.pop(context, _selected),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: m.gapSm,
            runSpacing: m.gapSm,
            children: widget.chips.map((chip) {
              final isSelected = chip == _selected;
              final isDisabled = widget.disabled.contains(chip);

              return Material(
                color: isSelected ? c.brand : c.surface,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: isDisabled
                      ? null
                      : () => setState(() => _selected = chip),
                  child: Container(
                    height: m.chipHeight,
                    padding: EdgeInsets.symmetric(horizontal: m.chipHPad),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? c.brand : c.border,
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      chip,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isDisabled
                            ? c.textMuted
                            : isSelected
                            ? c.surface
                            : c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.labelSize,
                        decoration: isDisabled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          if (widget.linkLabel != null) ...[
            SizedBox(height: m.gapMd),
            Center(
              child: InkWell(
                onTap: widget.onLinkTap,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.all(m.gapXs * 1.4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.linkIcon ?? Icons.straighten_rounded,
                        size: m.labelSize + 4,
                        color: c.brand,
                      ),
                      SizedBox(width: m.gapXs * 1.4),
                      Text(
                        widget.linkLabel!,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: c.brand,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: m.labelSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 5. COLOR SHEET
// ═══════════════════════════════════════════════════════════════════════════

Future<int?> showAppColorSheet({
  required BuildContext context,
  String title = 'Select Color',
  required List<Color> colors,
  int? selectedIndex,
  String confirmLabel = 'Done',
}) {
  return showAppSheet<int>(
    context: context,
    builder: (sheetContext) => _ColorSheetBody(
      title: title,
      colors: colors,
      initial: selectedIndex,
      confirmLabel: confirmLabel,
    ),
  );
}

class _ColorSheetBody extends StatefulWidget {
  final String title;
  final List<Color> colors;
  final int? initial;
  final String confirmLabel;

  const _ColorSheetBody({
    required this.title,
    required this.colors,
    required this.initial,
    required this.confirmLabel,
  });

  @override
  State<_ColorSheetBody> createState() => _ColorSheetBodyState();
}

class _ColorSheetBodyState extends State<_ColorSheetBody> {
  late int? _selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = SheetMetrics.of(context);

    return AppSheetShell(
      title: widget.title,
      footer: AppSheetButton(
        label: widget.confirmLabel,
        onTap: _selected == null
            ? null
            : () => Navigator.pop(context, _selected),
      ),
      child: Wrap(
        spacing: m.gapMd,
        runSpacing: m.gapMd,
        children: List.generate(widget.colors.length, (i) {
          final isSelected = i == _selected;

          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              width: m.swatchSize + (m.swatchSize * 0.22),
              height: m.swatchSize + (m.swatchSize * 0.22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? c.brand : Colors.transparent,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: m.swatchSize,
                height: m.swatchSize,
                decoration: BoxDecoration(
                  color: widget.colors[i],
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 1),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 6. QUANTITY SHEET
// ═══════════════════════════════════════════════════════════════════════════

Future<int?> showAppQuantitySheet({
  required BuildContext context,
  String title = 'Select Quantity',
  int initial = 1,
  int min = 1,
  required int max,
  String confirmLabel = 'Done',
}) {
  return showAppSheet<int>(
    context: context,
    builder: (sheetContext) => _QuantitySheetBody(
      title: title,
      initial: initial,
      min: min,
      max: max,
      confirmLabel: confirmLabel,
    ),
  );
}

class _QuantitySheetBody extends StatefulWidget {
  final String title;
  final int initial;
  final int min;
  final int max;
  final String confirmLabel;

  const _QuantitySheetBody({
    required this.title,
    required this.initial,
    required this.min,
    required this.max,
    required this.confirmLabel,
  });

  @override
  State<_QuantitySheetBody> createState() => _QuantitySheetBodyState();
}

class _QuantitySheetBodyState extends State<_QuantitySheetBody> {
  late int _qty = widget.initial.clamp(widget.min, widget.max);

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = SheetMetrics.of(context);

    Widget btn(IconData icon, VoidCallback? onTap) => Material(
      color: c.brandSoft,
      borderRadius: BorderRadius.circular(m.btnRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: m.qtyBtnSize,
          height: m.qtyBtnSize,
          child: Icon(
            icon,
            size: m.qtyIconSize,
            color: onTap == null ? c.textMuted : c.brand,
          ),
        ),
      ),
    );

    return AppSheetShell(
      title: widget.title,
      footer: AppSheetButton(
        label: widget.confirmLabel,
        onTap: () => Navigator.pop(context, _qty),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              btn(
                Icons.remove,
                _qty > widget.min ? () => setState(() => _qty--) : null,
              ),
              SizedBox(width: m.gapLg),
              SizedBox(
                width: m.qtyBtnSize,
                child: Text(
                  '$_qty',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.qtyValueSize,
                  ),
                ),
              ),
              SizedBox(width: m.gapLg),
              btn(
                Icons.add,
                _qty < widget.max ? () => setState(() => _qty++) : null,
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          Text(
            'Max available: ${widget.max}',
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontSize: m.captionSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 7. FORM SHEET (Add Address jaisa)
// ═══════════════════════════════════════════════════════════════════════════

class AppSheetField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? prefix;

  const AppSheetField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = SheetMetrics.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.captionSize,
          ),
        ),
        SizedBox(height: m.gapXs * 1.4),
        Row(
          children: [
            if (prefix != null) ...[
              prefix!,
              SizedBox(width: m.gapSm),
            ],
            Expanded(
              child: SizedBox(
                height: m.fieldHeight,
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: m.bodySize,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: c.textMuted,
                      fontFamily: 'Inter',
                      fontSize: m.bodySize,
                    ),
                    filled: true,
                    fillColor: c.surface,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: m.gapMd * 0.9,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(m.fieldRadius),
                      borderSide: BorderSide(color: c.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(m.fieldRadius),
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(m.fieldRadius),
                      borderSide: BorderSide(color: c.brand, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showAppFormSheet({
  required BuildContext context,
  required String title,
  required List<Widget> fields,
  required String confirmLabel,
  required VoidCallback onSubmit,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (sheetContext) {
      final m = SheetMetrics.of(sheetContext);

      return AppSheetShell(
        title: title,
        footer: AppSheetButton(
          label: confirmLabel,
          onTap: () {
            Navigator.pop(sheetContext);
            onSubmit();
          },
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              fields[i],
              if (i != fields.length - 1) SizedBox(height: m.gapMd),
            ],
          ],
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 8. INFO SHEET
// ═══════════════════════════════════════════════════════════════════════════

Future<void> showAppInfoSheet({
  required BuildContext context,
  required String title,
  required String message,
  IconData icon = Icons.lock_outline_rounded,
  List<SheetBullet> bullets = const [],
  String confirmLabel = 'Got It',
  VoidCallback? onConfirm,
}) {
  return showAppSheet<void>(
    context: context,
    builder: (sheetContext) {
      final c = sheetContext.c;
      final m = SheetMetrics.of(sheetContext);

      return AppSheetShell(
        footer: AppSheetButton(
          label: confirmLabel,
          onTap: () {
            Navigator.pop(sheetContext);
            onConfirm?.call();
          },
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: m.infoArtSize,
                height: m.infoArtSize,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: m.infoArtSize * 0.44,
                  color: c.brand,
                ),
              ),
            ),

            SizedBox(height: m.gapLg),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.titleSize + 1,
              ),
            ),

            SizedBox(height: m.gapSm),

            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: c.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.bodySize,
                height: 1.5,
              ),
            ),

            if (bullets.isNotEmpty) ...[
              SizedBox(height: m.gapLg),
              ...bullets.map(
                    (b) => Padding(
                  padding: EdgeInsets.only(bottom: m.gapMd * 0.8),
                  child: Row(
                    children: [
                      Icon(b.icon, size: m.rowIconSize, color: c.brand),
                      SizedBox(width: m.rowIconGap * 0.8),
                      Expanded(
                        child: Text(
                          b.label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: c.textSecondary,
                            fontFamily: 'Inter',
                            fontSize: m.bodySize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// 9. CONFIRM DIALOG (reusable, sheet family ke same styling me)
// ═══════════════════════════════════════════════════════════════════════════

Future<bool> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final c = dialogContext.c;
      final m = SheetMetrics.of(dialogContext);

      return Dialog(
        backgroundColor: c.surface,
        insetPadding: EdgeInsets.symmetric(horizontal: m.hPad, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(m.radius * 0.8),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.maxWidth),
          child: Padding(
            padding: EdgeInsets.all(m.hPad),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (icon != null) ...[
                  Center(
                    child: Container(
                      width: m.infoArtSize * 0.7,
                      height: m.infoArtSize * 0.7,
                      decoration: BoxDecoration(
                        color: isDestructive
                            ? c.statusWarningSoft
                            : c.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: m.infoArtSize * 0.32,
                        color: isDestructive ? c.statusWarning : c.brand,
                      ),
                    ),
                  ),
                  SizedBox(height: m.gapMd),
                ],

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                  ),
                ),

                SizedBox(height: m.gapSm),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.bodySize,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: m.gapLg),

                Row(
                  children: [
                    Expanded(
                      child: AppSheetButton(
                        label: cancelLabel,
                        isPrimary: false,
                        onTap: () => Navigator.pop(dialogContext, false),
                      ),
                    ),
                    SizedBox(width: m.gapSm * 1.2),
                    Expanded(
                      child: SizedBox(
                        height: m.btnHeight,
                        child: Material(
                          color: isDestructive ? c.statusWarning : c.brand,
                          borderRadius: BorderRadius.circular(m.btnRadius),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.pop(dialogContext, true),
                            child: Center(
                              child: Text(
                                confirmLabel,
                                style: AppTextStyles.buttonText.copyWith(
                                  color: c.surface,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: m.btnFontSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return result ?? false;
}