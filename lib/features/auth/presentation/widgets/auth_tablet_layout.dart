import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import 'auth_metrics.dart';

class AuthFeature {
  final IconData icon;
  final String title;
  final String subtitle;
  const AuthFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class AuthResponsiveLayout extends StatelessWidget {
  final String brandFirst;
  final String brandSecond;
  final String brandTagline;

  final String title;
  final String subtitle;

  final String? topActionLabel;
  final VoidCallback? onTopAction;

  final List<AuthFeature> features;
  final Widget Function(BuildContext context, AuthMetrics m) formBuilder;

  const AuthResponsiveLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.formBuilder,
    this.brandFirst = 'The',
    this.brandSecond = 'Vault',
    this.brandTagline = 'YOUR EVERYDAY STORE',
    this.topActionLabel,
    this.onTopAction,
    this.features = const [
      AuthFeature(
        icon: Icons.grid_view_rounded,
        title: 'Wide Range',
        subtitle: 'Explore millions of products\nacross categories.',
      ),
      AuthFeature(
        icon: Icons.verified_user_rounded,
        title: 'Safe & Secure',
        subtitle: 'Your data and payments\nare always protected.',
      ),
      AuthFeature(
        icon: Icons.local_shipping_rounded,
        title: 'Fast Delivery',
        subtitle: 'Get your orders quickly\nat your doorstep.',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final m = AuthMetrics.of(constraints);
          return (m.isTablet && m.isLandscape)
              ? _buildLandscape(context, m)
              : _buildPortrait(context, m);
        },
      ),
    );
  }

  // ---------------- PHONE + TABLET PORTRAIT ----------------
  Widget _buildPortrait(BuildContext context, AuthMetrics m) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: m.pagePadH,
        vertical: m.pagePadV,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrandRow(
                m: m,
                brandFirst: brandFirst,
                brandSecond: brandSecond,
                tagline: brandTagline,
                actionLabel: topActionLabel,
                onAction: onTopAction,
              ),
              SizedBox(height: m.blockGap),

              /// Text left + illustration right
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: _HeroText(m: m, title: title, subtitle: subtitle),
                  ),
                  SizedBox(width: m.fieldGap),
                  Expanded(
                    flex: 4,
                    child: _HeroImage(maxWidth: m.heroImageMax),
                  ),
                ],
              ),

              SizedBox(height: m.sectionGap),

              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: m.formMaxWidth),
                child: formBuilder(context, m),
              ),
              SizedBox(height: m.blockGap),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- TABLET LANDSCAPE (2-pane) ----------------
  Widget _buildLandscape(BuildContext context, AuthMetrics m) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.pagePadH,
        vertical: m.pagePadV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BrandRow(
            m: m,
            brandFirst: brandFirst,
            brandSecond: brandSecond,
            tagline: brandTagline,
            actionLabel: topActionLabel,
            onAction: onTopAction,
          ),
          SizedBox(height: m.blockGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// LEFT : heading + features
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroText(m: m, title: title, subtitle: subtitle),
                        SizedBox(height: m.blockGap),
                        ...features.map(
                          (f) => Padding(
                            padding: EdgeInsets.only(bottom: m.fieldGap),
                            child: _FeatureTile(m: m, feature: f),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: m.paneGap),

                /// CENTER : illustration
                Expanded(flex: 5, child: _HeroImage(maxWidth: m.heroImageMax)),
                SizedBox(width: m.paneGap),

                /// RIGHT : form
                SizedBox(
                  width: m.formMaxWidth,
                  child: SingleChildScrollView(child: formBuilder(context, m)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= SUB WIDGETS =================

class _BrandRow extends StatelessWidget {
  final AuthMetrics m;
  final String brandFirst;
  final String brandSecond;
  final String tagline;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _BrandRow({
    required this.m,
    required this.brandFirst,
    required this.brandSecond,
    required this.tagline,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: m.logoBox,
          height: m.logoBox,
          decoration: BoxDecoration(
            gradient: ThemeColors.buttonBackGroundColor,
            borderRadius: BorderRadius.circular(m.logoBox * 0.28),
          ),
          child: Icon(
            Icons.shopping_bag_rounded,
            color: ThemeColors.white,
            size: m.logoBox * 0.55,
          ),
        ),
        SizedBox(width: m.logoBox * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: brandFirst,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: m.brandTitle,
                  fontWeight: FontWeight.w800,
                  color: isDark ? ThemeColors.white : ThemeColors.ink,
                ),
                children: [
                  TextSpan(
                    text: brandSecond,
                    style: TextStyle(color: ThemeColors.purple),
                  ),
                ],
              ),
            ),
            SizedBox(height: m.brandTagline * 0.25),
            Text(
              tagline,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: m.brandTagline,
                letterSpacing: 1.2,
                color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: m.linkText,
                color: ThemeColors.blue,
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroText extends StatelessWidget {
  final AuthMetrics m;
  final String title;
  final String subtitle;

  const _HeroText({
    required this.m,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: m.heroTitle,
            height: 1.1,
            color: isDark ? ThemeColors.white : ThemeColors.ink,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.5),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: m.heroBody,
            color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final double maxWidth;
  const _HeroImage({required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            isDark ? 'assets/images/Image_8.png' : 'assets/images/Image_7.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final AuthMetrics m;
  final AuthFeature feature;

  const _FeatureTile({required this.m, required this.feature});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: m.featureIconBox,
          height: m.featureIconBox,
          decoration: BoxDecoration(
            color: isDark
                ? ThemeColors.purple.withValues(alpha: 0.18)
                : ThemeColors.blueSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            feature.icon,
            size: m.featureIconBox * 0.5,
            color: ThemeColors.blue,
          ),
        ),
        SizedBox(width: m.fieldGap * 0.7),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: m.featureTitle,
                  fontWeight: FontWeight.w700,
                  color: isDark ? ThemeColors.white : ThemeColors.ink,
                ),
              ),
              SizedBox(height: m.featureBody * 0.2),
              Text(
                feature.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: m.featureBody,
                  color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
