import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/theme_colors.dart';

const String kVaultSerif = 'CormorantGaramond';

class VaultGoldShader extends StatelessWidget {
  const VaultGoldShader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => ThemeColors.vaultGoldText.createShader(bounds),
      child: child,
    );
  }
}

class VaultDiamond extends StatelessWidget {
  const VaultDiamond({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return VaultGoldShader(
      child: Icon(
        Icons.diamond_outlined,
        size: size,
        color: ThemeColors.white,
      ),
    );
  }
}

class VaultWordmark extends StatelessWidget {
  const VaultWordmark({
    super.key,
    this.fontSize = 30,
    this.tagline,
    this.taglineColor,
    this.showDiamond = true,
  });

  final double fontSize;
  final String? tagline;
  final Color? taglineColor;
  final bool showDiamond;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDiamond) ...[
          VaultDiamond(size: fontSize * 0.95),
          SizedBox(height: fontSize * 0.12),
        ],
        FittedBox(
          fit: BoxFit.scaleDown,
          child: VaultGoldShader(
            child: Text(
              'TheVaults',
              style: TextStyle(
                fontFamily: kVaultSerif,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.05,
                color: ThemeColors.white,
              ),
            ),
          ),
        ),
        if (tagline != null) ...[
          SizedBox(height: fontSize * 0.28),
          Text(
            tagline!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: (fontSize * 0.2).clamp(9, 14),
              letterSpacing: 3.2,
              fontWeight: FontWeight.w500,
              color: taglineColor ?? ThemeColors.white,
            ),
          ),
        ],
      ],
    );
  }
}

enum VaultPillStyle { plum, gold, outlineGold }

class VaultPillButton extends StatelessWidget {
  const VaultPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = VaultPillStyle.plum,
    this.isLoading = false,
    this.height = 54,
    this.fontSize = 16,
    this.showArrow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final VaultPillStyle style;
  final bool isLoading;
  final double height;
  final double fontSize;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final Gradient? gradient = switch (style) {
      VaultPillStyle.plum => ThemeColors.vaultPlumButton,
      VaultPillStyle.gold => ThemeColors.vaultGoldButton,
      VaultPillStyle.outlineGold => null,
    };
    final Color fg = switch (style) {
      VaultPillStyle.plum => ThemeColors.vaultGoldLight,
      VaultPillStyle.gold => ThemeColors.vaultPlumDeep,
      VaultPillStyle.outlineGold => ThemeColors.vaultGoldLight,
    };
    final radius = BorderRadius.circular(12.sp);

    return Semantics(
      button: true,
      label: label,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          border: style == VaultPillStyle.outlineGold
              ? Border.all(color: ThemeColors.vaultGold, width: 1.2)
              : null,
          boxShadow: style == VaultPillStyle.outlineGold
              ? null
              : [
                  BoxShadow(
                    color: (style == VaultPillStyle.plum
                            ? ThemeColors.vaultPlumDeep
                            : ThemeColors.vaultGoldDeep)
                        .withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: radius,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: fontSize + 6,
                      height: fontSize + 6,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(fg),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ),
                        if (showArrow) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: fontSize + 4,
                            color: fg,
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class VaultIconBadge extends StatelessWidget {
  const VaultIconBadge({super.key, required this.icon, this.size = 120});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            ThemeColors.vaultGoldLight.withValues(alpha: 0.45),
            ThemeColors.vaultGoldLight.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Container(
        width: size * 0.66,
        height: size * 0.66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ThemeColors.vaultPlumButton,
          border: Border.all(color: ThemeColors.vaultGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.vaultPlumDeep.withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: VaultGoldShader(
          child: Icon(icon, size: size * 0.3, color: ThemeColors.white),
        ),
      ),
    );
  }
}

class VaultArtwork extends StatelessWidget {
  const VaultArtwork({
    super.key,
    required this.asset,
    required this.fallbackIcon,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  final String asset;
  final IconData fallbackIcon;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, _, _) => LayoutBuilder(
        builder: (context, c) {
          final side = c.biggest.shortestSide.isFinite
              ? c.biggest.shortestSide
              : 200.0;
          return Center(
            child: VaultIconBadge(
              icon: fallbackIcon,
              size: side.clamp(80, 260),
            ),
          );
        },
      ),
    );
  }
}
