import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import 'auth_metrics.dart';
import 'auth_terms_text.dart';

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

  /// Portrait: brand → image → title, sab center mein (stacked).
  final bool centeredHero;

  /// [centeredHero] mein image ki minimum height (lambe forms ke liye badhao).
  final double centeredImageMinHeight;

  /// Default dashboard image ki jagah custom image asset (optional).
  final String? heroImageAsset;

  /// Image ki jagah custom widget (e.g. icon illustration); [heroImageAsset]
  /// se priority zyada.
  final Widget? heroIllustration;

  /// [centeredHero] mein image ke upar/neeche ka gap (default: fieldGap * 0.6).
  final double? centeredImageGap;

  /// [centeredHero] mein brand upar fixed, baaki content neeche center.
  final bool centeredBrandOnTop;

  final String? topActionLabel;
  final VoidCallback? onTopAction;

  final List<AuthFeature> features;
  final Widget Function(BuildContext context, AuthMetrics m) formBuilder;

  const AuthResponsiveLayout({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.formBuilder,
    this.centeredHero = false,
    this.centeredImageMinHeight = 56,
    this.heroImageAsset,
    this.heroIllustration,
    this.centeredImageGap,
    this.centeredBrandOnTop = false,
    this.brandFirst = 'The',
    this.brandSecond = 'Vaults',
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
    final tabletPortrait = m.isTablet;

    if (centeredHero) return _buildCenteredPortrait(context, m);

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
              SizedBox(height: tabletPortrait ? m.blockGap * 0.5 : m.blockGap),

              /// Text left + illustration right
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: tabletPortrait ? 5 : 7,
                    child: _HeroText(m: m, title: title, subtitle: subtitle),
                  ),
                  SizedBox(width: m.fieldGap),
                  Expanded(
                    flex: tabletPortrait ? 6 : 4,
                    child: _HeroImage(
                      asset: heroImageAsset,
                      maxWidth: m.heroImageMax,
                      maxHeight: m.heroImageMaxH,
                    ),
                  ),
                ],
              ),

              SizedBox(height: tabletPortrait ? m.blockGap : m.sectionGap),

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

  Widget _buildCenteredPortrait(BuildContext context, AuthMetrics m) {
    return _CenteredPortrait(
      m: m,
      imageMinHeight: centeredImageMinHeight,
      imageGap: centeredImageGap,
      brandOnTop: centeredBrandOnTop,
      header: _StylishBrand(
        m: m,
        brandFirst: brandFirst,
        brandSecond: brandSecond,
        tagline: brandTagline,
      ),
      image:
          heroIllustration ??
          _HeroImage(
            asset: heroImageAsset,
            maxWidth: m.heroImageMax * 1.6,
            maxHeight: m.heroImageMaxH * 1.2,
          ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeroText(m: m, title: title, subtitle: subtitle, center: true),
          SizedBox(height: m.blockGap),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: m.formMaxWidth),
              child: formBuilder(context, m),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscape(BuildContext context, AuthMetrics m) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: m.pagePadH,
          vertical: m.pagePadV,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ── LEFT : brand → image → features (row) ──
            if (!keyboardOpen) ...[
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Brand — top pe fixed
                    _BrandRow(
                      m: m,
                      brandFirst: brandFirst,
                      brandSecond: brandSecond,
                      tagline: brandTagline,
                      actionLabel: null,
                      onAction: null,
                    ),

                    /// Image —
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: m.blockGap * 0.6,
                        ),
                        child:
                            heroIllustration ??
                            _HeroImage(
                              asset: heroImageAsset,
                              maxWidth: m.heroImageMax * 0.80,
                            ),
                      ),
                    ),

                    /// Features — horizontal row, 3 across
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (int i = 0; i < features.length; i++) ...[
                          if (i > 0) SizedBox(width: m.fieldGap * 0.6),
                          Expanded(
                            child: _FeatureTile(
                              m: m,
                              feature: features[i],
                              vertical: true,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              /// ── CENTER : divider ──
              _PaneDivider(m: m),
            ],

            /// ── RIGHT : hero text → form → terms ──
            Expanded(
              flex: keyboardOpen ? 10 : 5,
              child: _AutoScrollPane(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!keyboardOpen) ...[
                      _HeroText(
                        m: m,
                        title: title,
                        subtitle: subtitle,
                        center: true,
                      ),
                      SizedBox(height: m.blockGap * 0.8),
                    ],
                    formBuilder(context, m),
                    SizedBox(height: m.blockGap * 0.6),
                    AuthTermsText(m: m, onTapTerms: () {}, onTapPrivacy: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ek screen mein fit hota hai (image bachi jagah le leti hai), scroll tabhi
/// jab keyboard khulne pe content viewport se bada ho jaye.
class _CenteredPortrait extends StatefulWidget {
  final AuthMetrics m;
  final Widget header;
  final Widget image;
  final Widget body;
  final double imageMinHeight;
  final double? imageGap;
  final bool brandOnTop;

  const _CenteredPortrait({
    required this.m,
    required this.imageMinHeight,
    this.imageGap,
    this.brandOnTop = false,
    required this.header,
    required this.image,
    required this.body,
  });

  @override
  State<_CenteredPortrait> createState() => _CenteredPortraitState();
}

class _CenteredPortraitState extends State<_CenteredPortrait> {
  double _width = -1;
  double _fullHeight = 0;

  List<Widget> _imageAndBody(AuthMetrics m) => [
    // Image apne size jitni jagah leti hai; jagah kam ho to
    // [imageMinHeight] tak shrink hoti hai.
    Flexible(
      child: _MinIntrinsicHeight(
        height: widget.imageMinHeight,
        child: widget.image,
      ),
    ),
    SizedBox(height: widget.imageGap ?? m.fieldGap * 0.6),
    widget.body,
  ];

  @override
  Widget build(BuildContext context) {
    final m = widget.m;

    return LayoutBuilder(
      builder: (context, c) {
        // Keyboard viewport chhota karta hai — keyboard-free height yaad rakho
        // taaki content ka size keyboard khulne pe na badle.
        if (c.maxWidth != _width || c.maxHeight > _fullHeight) {
          _width = c.maxWidth;
          _fullHeight = c.maxHeight;
        }
        final minHeight = (_fullHeight - m.pagePadV * 2).clamp(
          0.0,
          double.infinity,
        );

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: m.pagePadH,
            vertical: m.pagePadV,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: m.contentMaxWidth,
                minHeight: minHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.header,
                    SizedBox(height: widget.imageGap ?? m.fieldGap * 0.6),
                    if (widget.brandOnTop)
                      // Brand upar fixed; baaki content neeche bachi jagah
                      // mein thoda upar ki taraf center. (Spacers nahi —
                      // IntrinsicHeight flex children ki height badha deta.)
                      Expanded(
                        child: Align(
                          alignment: const Alignment(0, -0.3),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _imageAndBody(m),
                          ),
                        ),
                      )
                    else
                      ..._imageAndBody(m),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// IntrinsicHeight ko child ki jagah fixed [height] batata hai, taaki image
/// apne natural size se page ko scroll na karwaye. Actual layout normal hai.
class _MinIntrinsicHeight extends SingleChildRenderObjectWidget {
  final double height;

  const _MinIntrinsicHeight({required this.height, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMinIntrinsicHeight(height);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMinIntrinsicHeight renderObject,
  ) {
    renderObject.height = height;
  }
}

class _RenderMinIntrinsicHeight extends RenderProxyBox {
  _RenderMinIntrinsicHeight(this._height);

  double _height;
  set height(double value) {
    if (value == _height) return;
    _height = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicHeight(double width) => _height;

  @override
  double computeMaxIntrinsicHeight(double width) => _height;
}

class _FitPane extends StatelessWidget {
  final Widget child;
  final Alignment alignment;

  const _FitPane({required this.child}) : alignment = Alignment.center;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            // child ko unbounded height — tabhi FittedBox theek se shrink karega
            child: SizedBox(width: c.maxWidth, child: child),
          ),
        );
      },
    );
  }
}

class _AutoScrollPane extends StatelessWidget {
  final Widget child;
  const _AutoScrollPane({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

class _PaneDivider extends StatelessWidget {
  final AuthMetrics m;
  const _PaneDivider({required this.m});

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).dividerColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.paneGap),
      child: SizedBox(
        width: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                line.withValues(alpha: 0),
                line.withValues(alpha: 0.55),
                line.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
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
            gradient: ThemeColors.bottomSection,
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
                  fontFamily: 'Inter',
                  fontSize: m.brandTitle,
                  fontWeight: FontWeight.w800,
                  color: isDark ? ThemeColors.white : ThemeColors.ink,
                ),
                children: [
                  TextSpan(
                    text: brandSecond,
                    style: TextStyle(color: ThemeColors.primaryPurple),
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
        if (actionLabel != null && m.isTablet)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: m.linkText,
                color: isDark
                    ? ThemeColors.primaryPurple
                    : ThemeColors.deepPurple,
              ),
            ),
          ),
      ],
    );
  }
}

/// Bada, centered "TheVaults" wordmark — "Vaults" gradient mein.
class _StylishBrand extends StatelessWidget {
  final AuthMetrics m;
  final String brandFirst;
  final String brandSecond;
  final String tagline;

  const _StylishBrand({
    required this.m,
    required this.brandFirst,
    required this.brandSecond,
    required this.tagline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = TextStyle(
      fontFamily: 'Inter',
      fontSize: m.brandTitle * 1.6,
      height: 1.1,
      letterSpacing: -0.5,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                brandFirst,
                style: base.copyWith(
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  color: isDark ? ThemeColors.white : ThemeColors.ink,
                ),
              ),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) =>
                    ThemeColors.bottomSection.createShader(bounds),
                child: Text(
                  brandSecond,
                  style: base.copyWith(
                    fontWeight: FontWeight.w900,
                    color: ThemeColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: m.brandTagline * 0.6),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelSmall.copyWith(
            fontSize: m.brandTagline * 1.1,
            letterSpacing: 3,
            color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
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
  final bool center; // ← ADD

  const _HeroText({
    required this.m,
    required this.title,
    required this.subtitle,
    this.center = false, // ← ADD
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          center // ← CHANGED
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: center ? TextAlign.center : TextAlign.start, // ← ADD
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: m.heroTitle,
            height: 1.1,
            color: isDark ? ThemeColors.white : ThemeColors.ink,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          SizedBox(height: m.fieldGap * 0.5),
          Text(
            subtitle,
            textAlign: center ? TextAlign.center : TextAlign.start, // ← ADD
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: m.heroBody,
              color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final double maxWidth;
  final double maxHeight;

  /// Custom asset; null ho to theme ke hisaab se dashboard image.
  final String? asset;

  const _HeroImage({
    required this.maxWidth,
    this.maxHeight = double.infinity,
    this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.center,
      // Height image jitni (loose constraints mein extra khaali jagah nahi).
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Image.asset(
          asset ??
              (isDark ? AppImages.dashboardDark : AppImages.dashboardLight),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final AuthMetrics m;
  final AuthFeature feature;

  final bool vertical;

  const _FeatureTile({
    required this.m,
    required this.feature,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final iconBox = Container(
      width: m.featureIconBox,
      height: m.featureIconBox,
      decoration: BoxDecoration(
        color: isDark
            ? ThemeColors.primaryPurple.withValues(alpha: 0.18)
            : ThemeColors.blueSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(
        feature.icon,
        size: m.featureIconBox * 0.5,
        color: ThemeColors.deepPurple,
      ),
    );

    final texts = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          feature.title,
          textAlign: vertical ? TextAlign.center : TextAlign.start,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: m.featureTitle,
            fontWeight: FontWeight.w700,
            color: isDark ? ThemeColors.white : ThemeColors.ink,
          ),
        ),
        SizedBox(height: m.featureBody * 0.2),
        Text(
          feature.subtitle.replaceAll('\n', ' '),
          textAlign: vertical ? TextAlign.center : TextAlign.start,
          maxLines: vertical ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: m.featureBody,
            color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
          ),
        ),
      ],
    );

    /// Vertical: icon upar, text neeche (3 tiles ek row mein)
    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconBox,
          SizedBox(height: m.fieldGap * 0.5),
          texts,
        ],
      );
    }

    /// Horizontal: icon left, text right (portrait / default)
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        iconBox,
        SizedBox(width: m.fieldGap * 0.7),
        Expanded(child: texts),
      ],
    );
  }
}

/// Auth screens ke neeche halki lavender wave (Stack mein content ke peeche);
/// keyboard khulne pe fade out.
class AuthBottomWave extends StatelessWidget {
  const AuthBottomWave({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardOpen = View.of(context).viewInsets.bottom > 0;

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: keyboardOpen ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: CustomPaint(
          painter: _AuthWavePainter(
            back: isDark
                ? ThemeColors.mediumPurple.withValues(alpha: 0.10)
                : ThemeColors.lavenderMist.withValues(alpha: 0.6),
            front: isDark
                ? ThemeColors.mediumPurple.withValues(alpha: 0.18)
                : ThemeColors.lavenderMist,
          ),
        ),
      ),
    );
  }
}

class _AuthWavePainter extends CustomPainter {
  final Color back;
  final Color front;

  const _AuthWavePainter({required this.back, required this.front});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final backPath = Path()
      ..moveTo(0, h * 0.35)
      ..cubicTo(w * 0.30, h * 0.05, w * 0.60, h * 0.65, w, h * 0.25)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final frontPath = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.35, h * 0.40, w * 0.65, h * 0.95, w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas
      ..drawPath(backPath, Paint()..color = back)
      ..drawPath(frontPath, Paint()..color = front);
  }

  @override
  bool shouldRepaint(_AuthWavePainter old) =>
      old.back != back || old.front != front;
}
