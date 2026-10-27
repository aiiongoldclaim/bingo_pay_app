import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/image_constants.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../widgets/splash_metrics.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: ThemeColors.vaultPlumNight,
      ),
      child: Scaffold(
        backgroundColor: ThemeColors.vaultPlumNight,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final m = SplashMetrics.of(context, constraints);

            return Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: ThemeColors.vaultNightBg),
                ),

                Positioned.fill(
                  child: FadeTransition(
                    opacity: _fade,
                    child: VaultArtwork(
                      asset: AppImages.vaultSplashHero,
                      fallbackIcon: Icons.diamond_outlined,
                      fit: BoxFit.cover,
                      alignment: m.isLandscape
                          ? const Alignment(0, -0.15)
                          : Alignment.topCenter,
                    ),
                  ),
                ),

                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ThemeColors.vaultPlumDeep.withValues(alpha: 0.55),
                        ThemeColors.vaultPlumDeep.withValues(alpha: 0.0),
                        ThemeColors.vaultPlumNight.withValues(alpha: 0.0),
                        ThemeColors.vaultPlumNight.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      m.hPadding,
                      m.gapXl,
                      m.hPadding,
                      m.bottomGap,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: FadeTransition(
                            opacity: _fade,
                            child: ScaleTransition(
                              scale: _scale,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ShiningDiamond(
                                    size: m.wordmarkSize * 1.05 * 0.95,
                                  ),
                                  SizedBox(
                                    height: m.wordmarkSize * 1.05 * 0.12,
                                  ),
                                  VaultWordmark(
                                    fontSize: m.wordmarkSize * 1.05,
                                    showDiamond: false,
                                    tagline: 'LUXURY LIVES WITH YOU',
                                    taglineColor: ThemeColors.vaultCreamDeep,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        FadeTransition(
                          opacity: _fade,
                          child: Text(
                            'Curated\nFashion, Beauty\n& Lifestyle',
                            style: TextStyle(
                              fontFamily: kVaultSerif,
                              fontSize: m.wordmarkSize * 0.62,
                              fontWeight: FontWeight.w500,
                              height: 1.15,
                              color: ThemeColors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: m.gapXl),
                        Center(child: _SplashProgress(progress: _controller)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SplashProgress extends StatelessWidget {
  const _SplashProgress({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    const width = 120.0;

    return SizedBox(
      width: width,
      height: 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Container(color: ThemeColors.white.withValues(alpha: 0.18)),
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) => Container(
                width: width * progress.value,
                decoration: const BoxDecoration(
                  gradient: ThemeColors.vaultGoldText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiningDiamond extends StatefulWidget {
  const _ShiningDiamond({required this.size});

  final double size;

  @override
  State<_ShiningDiamond> createState() => _ShiningDiamondState();
}

class _ShiningDiamondState extends State<_ShiningDiamond>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return AnimatedBuilder(
      animation: _shine,
      builder: (context, _) {
        final t = _shine.value;

        final p = -0.3 + (t / 0.55) * 1.6;
        final a = (p - 0.14).clamp(0.0, 1.0);
        final b = p.clamp(0.0, 1.0);
        final c = (p + 0.14).clamp(0.0, 1.0);

        final glow = 0.22 + 0.18 * (0.5 + 0.5 * math.sin(t * 2 * math.pi));
        final twinkle = t > 0.4 && t < 0.75
            ? math.sin(math.pi * (t - 0.4) / 0.35)
            : 0.0;

        return SizedBox(
          width: size * 1.7,
          height: size * 1.3,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size * 1.6,
                height: size * 1.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ThemeColors.vaultGoldLight.withValues(alpha: glow),
                      ThemeColors.vaultGoldLight.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [
                    ThemeColors.vaultGoldLight,
                    ThemeColors.vaultGold,
                    ThemeColors.white,
                    ThemeColors.vaultGold,
                    ThemeColors.vaultGoldDeep,
                  ],
                  stops: [0.0, a, b, c, 1.0],
                ).createShader(bounds),
                child: Icon(
                  Icons.diamond_outlined,
                  size: size,
                  color: ThemeColors.white,
                ),
              ),
              Positioned(
                top: size * 0.05,
                right: size * 0.22,
                child: Opacity(
                  opacity: twinkle,
                  child: Transform.scale(
                    scale: 0.6 + 0.4 * twinkle,
                    child: Icon(
                      Icons.auto_awesome,
                      size: size * 0.32,
                      color: ThemeColors.vaultGoldLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
