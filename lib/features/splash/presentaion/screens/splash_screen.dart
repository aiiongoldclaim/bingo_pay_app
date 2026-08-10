import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../../core/theme/theme_colors.dart';
import '../widgets/splash_background..dart';
import '../widgets/splash_logo.dart';
import '../widgets/splash_metrics.dart';
import '../widgets/splash_progress_bar.dart';
import '../widgets/splash_service_icons.dart';

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
      duration: const Duration(milliseconds: 2200),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove(); // Flutter splash paint ho chuka
      _controller.forward();
    });

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeColors.ink : ThemeColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final m = SplashMetrics.of(context, constraints);

          return Stack(
            fit: StackFit.expand,
            children: [
              SplashBackground(metrics: m, isDark: isDark),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: m.hPadding),
                      child: m.isLandscape && m.isTablet
                          ? _LandscapeContent(
                              metrics: m,
                              isDark: isDark,
                              fade: _fade,
                              scale: _scale,
                            )
                          : _PortraitContent(
                              metrics: m,
                              isDark: isDark,
                              fade: _fade,
                              scale: _scale,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PortraitContent extends StatelessWidget {
  const _PortraitContent({
    required this.metrics,
    required this.isDark,
    required this.fade,
    required this.scale,
  });

  final SplashMetrics metrics;
  final bool isDark;
  final Animation<double> fade;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: SplashLogo(metrics: metrics, isDark: isDark),
          ),
        ),
        const Spacer(flex: 2),
        FadeTransition(
          opacity: fade,
          child: SplashServiceIcons(metrics: metrics, isDark: isDark),
        ),
        SizedBox(height: metrics.gapXl),
        SplashProgressBar(metrics: metrics, isDark: isDark),
        SizedBox(height: metrics.bottomGap),
      ],
    );
  }
}

class _LandscapeContent extends StatelessWidget {
  const _LandscapeContent({
    required this.metrics,
    required this.isDark,
    required this.fade,
    required this.scale,
  });

  final SplashMetrics metrics;
  final bool isDark;
  final Animation<double> fade;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: SplashLogo(metrics: metrics, isDark: isDark),
            ),
          ),
        ),
        SizedBox(width: metrics.gapXl),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: fade,
                child: SplashServiceIcons(metrics: metrics, isDark: isDark),
              ),
              SizedBox(height: metrics.gapXl),
              SplashProgressBar(metrics: metrics, isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }
}
