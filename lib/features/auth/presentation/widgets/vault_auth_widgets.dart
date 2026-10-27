import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/vault_brand.dart';
import 'auth_metrics.dart';

TextStyle vaultFieldTextStyle(AuthMetrics m, {bool isDark = false}) =>
    TextStyle(
      fontFamily: 'Inter',
      fontSize: m.linkText + 1,
      color: isDark ? ThemeColors.white : ThemeColors.vaultInk,
    );

InputDecoration vaultFieldDecoration(
  AuthMetrics m, {
  required String hint,
  IconData? icon,
  Widget? prefix,
  Widget? suffix,
  bool isDark = false,
}) {
  final borderColor =
      isDark ? ThemeColors.vaultDarkBorder : ThemeColors.vaultLoginFieldBorder;
  final iconColor = isDark ? ThemeColors.vaultGoldLight : ThemeColors.vaultInk;

  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.sp),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      fontSize: m.linkText + 1,
      color: isDark ? ThemeColors.vaultDarkBody : ThemeColors.vaultBody,
    ),
    filled: true,
    fillColor:
        isDark ? ThemeColors.vaultDarkSurface : ThemeColors.vaultLoginFieldFill,
    contentPadding: EdgeInsets.symmetric(
      horizontal: m.pagePadH,
      vertical: m.buttonHeight * 0.22,
    ),
    prefixIcon: prefix ??
        (icon == null
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  left: m.pagePadH,
                  right: m.pagePadH * 0.7,
                ),
                child: Icon(icon, size: 22, color: iconColor),
              )),
    isDense: true,
    prefixIconConstraints: const BoxConstraints(minWidth: 0),
    suffixIconConstraints: const BoxConstraints(minWidth: 0),
    suffixIcon: suffix == null
        ? null
        : Padding(
            padding: EdgeInsets.only(right: m.pagePadH * 0.4),
            child: IconButtonTheme(
              data: IconButtonThemeData(
                style: IconButton.styleFrom(
                  foregroundColor: iconColor,
                  iconSize: 22,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              child: IconTheme(
                data: IconThemeData(color: iconColor, size: 22),
                child: suffix,
              ),
            ),
          ),
    border: border(borderColor),
    enabledBorder: border(borderColor),
    focusedBorder: border(ThemeColors.vaultGold, 1.5),
    errorBorder: border(ThemeColors.red),
    focusedErrorBorder: border(ThemeColors.red, 1.5),
    errorStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: m.footerText,
      color: ThemeColors.red,
    ),
  );
}

class VaultAuthScaffold extends StatelessWidget {
  const VaultAuthScaffold({
    super.key,
    required this.builder,
    this.onBack,
  });

  final VoidCallback? onBack;
  final Widget Function(BuildContext context, AuthMetrics m) builder;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: c.isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: c.isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: c.vaultAuthBackground,
      ),
      child: ColoredBox(
        color: c.vaultAuthBackground,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final m = AuthMetrics.of(constraints);
              return Column(
                children: [
                  if (onBack != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: m.pagePadH * 0.4),
                        child: IconButton(
                          onPressed: onBack,
                          tooltip: 'Back',
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: c.vaultAuthTitle,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        m.pagePadH * 1.2,
                        onBack != null ? 0 : m.pagePadV,
                        m.pagePadH * 1.2,
                        m.blockGap,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: builder(context, m),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class VaultAuthHeader extends StatelessWidget {
  const VaultAuthHeader({
    super.key,
    required this.m,
    required this.title,
    this.subtitle,
    this.subtitleBold,
    this.illustration,
    this.illustrationAboveTitle = false,
  });

  final AuthMetrics m;
  final String title;
  final String? subtitle;

  final String? subtitleBold;
  final Widget? illustration;
  final bool illustrationAboveTitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final titleText = Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: kVaultSerif,
        fontSize: m.heroTitle * 1.05,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: c.vaultAuthTitle,
      ),
    );

    final subtitleText = subtitle == null
        ? null
        : Text.rich(
            TextSpan(
              text: subtitle,
              children: [
                if (subtitleBold != null)
                  TextSpan(
                    text: '\n$subtitleBold',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: c.vaultAuthTitle,
                    ),
                  ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: m.linkText,
              height: 1.5,
              color: c.vaultAuthBody,
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VaultWordmark(fontSize: m.brandTitle * 1.05),
        SizedBox(height: m.blockGap),
        if (illustration != null && illustrationAboveTitle) ...[
          illustration!,
          SizedBox(height: m.fieldGap),
        ],
        titleText,
        if (subtitleText != null) ...[
          SizedBox(height: m.fieldGap * 0.5),
          subtitleText,
        ],
        if (illustration != null && !illustrationAboveTitle) ...[
          SizedBox(height: m.blockGap),
          illustration!,
        ],
      ],
    );
  }
}

class VaultFooterLink extends StatelessWidget {
  const VaultFooterLink({
    super.key,
    required this.prefix,
    required this.action,
    required this.onTap,
    this.fontSize = 14,
  });

  final String prefix;
  final String action;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            prefix,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fontSize,
              color: c.vaultAuthBody,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                action,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: c.vaultAuthLink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VaultCornerArt extends StatelessWidget {
  const VaultCornerArt({super.key, required this.asset, required this.corner});

  final String asset;
  final Alignment corner;

  static Shader _fade(Rect bounds, Alignment from, Alignment to, double keep) {
    return LinearGradient(
      begin: from,
      end: to,
      colors: [
        ThemeColors.black,
        ThemeColors.black,
        ThemeColors.black.withValues(alpha: 0),
      ],
      stops: [0.0, keep, 1.0],
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context) {
    final vFrom = Alignment(0, corner.y);
    final hFrom = Alignment(corner.x, 0);

    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (b) => _fade(b, hFrom, Alignment(-corner.x, 0), 0.7),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (b) => _fade(b, vFrom, Alignment(0, -corner.y), 0.72),
          child: Image.asset(
            asset,
            fit: BoxFit.fitWidth,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class VaultGradientButton extends StatelessWidget {
  const VaultGradientButton({
    super.key,
    required this.label,
    required this.height,
    required this.fontSize,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final double height;
  final double fontSize;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.sp);

    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: ThemeColors.vaultLoginButton,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: ThemeColors.vaultPlumDeep.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: radius,
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: fontSize + 6,
                    height: fontSize + 6,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(ThemeColors.white),
                    ),
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.white,
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: fontSize + 6,
                        color: ThemeColors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class VaultOutlineGoldButton extends StatelessWidget {
  const VaultOutlineGoldButton({
    super.key,
    required this.label,
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.sp);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: ThemeColors.vaultLoginFieldBorder),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: ThemeColors.vaultGoldDeep,
            ),
          ),
        ),
      ),
    );
  }
}

