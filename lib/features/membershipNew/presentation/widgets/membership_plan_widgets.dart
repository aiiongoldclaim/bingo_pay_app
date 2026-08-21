import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import '../../../../core/constants/image_constants.dart';
import '../../data/models/membership_plan_model.dart';
import 'benifits_tile.dart';
import 'landing_widgets.dart';
import 'membership_metrices.dart';



class MembershipPlansHero extends StatelessWidget {
  const MembershipPlansHero({
    super.key,
    required this.metrics,
    this.artworkAsset = AppImages.membershipCard,
  });

  final MembershipMetrics metrics;
  final String artworkAsset;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return ClipRRect(
      borderRadius: BorderRadius.circular(m.radiusLg),
      child: Image.asset(
        artworkAsset,
        width: double.infinity,
        // fitWidth -> poori image dikhegi, text crop nahi hoga
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => Container(
          height: m.heroHeight,
          decoration: BoxDecoration(
            gradient: c.isDark
                ? ThemeColors.heroBannerDark
                : ThemeColors.primaryGradient1,
            borderRadius: BorderRadius.circular(m.radiusLg),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3D RING CAROUSEL — ek time pe ek card, scroll pe agla
// ---------------------------------------------------------------------------

class MembershipPlanRingCarousel extends StatefulWidget {
  const MembershipPlanRingCarousel({
    super.key,
    required this.plans,
    required this.selectedUuid,
    required this.metrics,
    required this.onPlanChanged,
  });

  final List<MembershipPlanOption> plans;
  final String? selectedUuid;
  final MembershipMetrics metrics;

  /// Center me jo card aaya, wahi selected ho jaata hai
  final ValueChanged<String> onPlanChanged;

  @override
  State<MembershipPlanRingCarousel> createState() =>
      _MembershipPlanRingCarouselState();
}

class _MembershipPlanRingCarouselState
    extends State<MembershipPlanRingCarousel> {
  late final PageController _controller;
  late int _current;

  /// Aas-paas ke cards ka rotation (radians)
  static const double _maxRotation = 0.42;

  /// Aas-paas ke cards kitne chhote
  static const double _minScale = 0.82;

  @override
  void initState() {
    super.initState();
    _current = _indexOf(widget.selectedUuid);
    _controller = PageController(
      initialPage: _current,
      viewportFraction: _viewportFraction,
    );
  }

  double get _viewportFraction {
    final m = widget.metrics;
    if (m.isTabletLandscape) return 0.36;
    if (m.isTablet) return 0.52;
    return 0.74;
  }

  int _indexOf(String? uuid) {
    if (uuid == null) return 0;
    final i = widget.plans.indexWhere((p) => p.uuid == uuid);
    return i < 0 ? 0 : i;
  }

  @override
  void didUpdateWidget(covariant MembershipPlanRingCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bahar se selection badla (jaise tap se) to page bhi wahin le jao
    final target = _indexOf(widget.selectedUuid);
    if (target != _current && _controller.hasClients) {
      _current = target;
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.metrics;
    final height = _cardHeight(m, widget.plans);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.plans.length,
            clipBehavior: Clip.none,
            onPageChanged: (i) {
              setState(() => _current = i);
              widget.onPlanChanged(widget.plans[i].uuid);
            },
            itemBuilder: (context, index) {
              final plan = widget.plans[index];

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // page value abhi available na ho to initialPage use karo
                  double page = _current.toDouble();
                  if (_controller.hasClients &&
                      _controller.position.haveDimensions) {
                    page = _controller.page ?? page;
                  }

                  final delta = (index - page).clamp(-1.5, 1.5);
                  final absDelta = delta.abs();

                  final rotation = delta * _maxRotation;
                  final scale = 1 - (absDelta * (1 - _minScale));
                  final opacity = (1 - absDelta * 0.45).clamp(0.35, 1.0);

                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.0014) // perspective
                    ..rotateY(rotation)
                    ..scale(scale, scale);

                  return Transform(
                    alignment: delta > 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    transform: transform,
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: m.tileGap * 0.5,
                    vertical: m.tileGap * 0.4,
                  ),
                  child: MembershipPlanTierCard(
                    plan: plan,
                    selected: widget.selectedUuid == plan.uuid,
                    metrics: m,
                    onTap: () => _goTo(index),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: m.rowGap * 0.8),
        _Dots(
          count: widget.plans.length,
          current: _current,
          metrics: m,
          onTap: _goTo,
        ),
      ],
    );
  }

  void _goTo(int index) {
    if (!_controller.hasClients) return;
    widget.onPlanChanged(widget.plans[index].uuid);   // ← add
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  /// Card ki height sabse zyada features wale plan se
  double _cardHeight(MembershipMetrics m, List<MembershipPlanOption> plans) {
    var maxFeatures = 0;
    for (final p in plans) {
      maxFeatures = math.max(maxFeatures, p.features.length);
    }

    final base =
        m.cardPad * 1.9 + // padding
            m.captionSize * 2.4 + // ribbon
            m.sectionTitleSize * 1.5 + // name
            m.captionSize * 2.8 + // description
            m.iconCircle + // icon
            m.rowGap * 4.2 + // gaps
            m.priceSize * 1.25 + // price
            m.captionSize * 1.6 + // period
            m.buttonHeight * 0.95; // button

    final featureBlock =
        maxFeatures * (m.labelSize * 1.55 + m.rowGap * 0.5);

    return base + featureBlock;
  }
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.current,
    required this.metrics,
    required this.onTap,
  });

  final int count;
  final int current;
  final MembershipMetrics metrics;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final dot = m.captionSize * 0.62;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.symmetric(horizontal: dot * 0.45),
              width: i == current ? dot * 3.2 : dot,
              height: dot,
              decoration: BoxDecoration(
                color: i == current ? c.brand : c.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PLAN TIER CARD
// ---------------------------------------------------------------------------

class MembershipPlanTierCard extends StatelessWidget {
  const MembershipPlanTierCard({
    super.key,
    required this.plan,
    required this.selected,
    required this.metrics,
    required this.onTap,
  });

  final MembershipPlanOption plan;
  final bool selected;
  final MembershipMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final version = plan.version;
    final ribbon = plan.isHighlighted;
    final pad = m.cardPad * 0.85;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.radiusMd),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.radiusMd),
          border: Border.all(
            color: selected || ribbon ? c.brand : c.border,
            width: selected ? 1.8 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: c.brand.withValues(alpha: 0.18),
              blurRadius: m.cardPad,
              offset: Offset(0, m.cardPad * 0.35),
            ),
          ]
              : null,
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ribbon)
                Container(
                  width: double.infinity,
                  color: c.brand,
                  padding: EdgeInsets.symmetric(vertical: pad * 0.36),
                  child: Text(
                    plan.highlight!.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: m.captionSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: ThemeColors.white,
                    ),
                  ),
                ),

              Padding(
                padding: EdgeInsets.all(pad),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      plan.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.sectionTitleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: c.textPrimary,
                      ),
                    ),
                    if (plan.hasDescription) ...[
                      SizedBox(height: m.rowGap * 0.3),
                      Text(
                        plan.description,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: m.captionSize,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                          color: c.textSecondary,
                        ),
                      ),
                    ],

                    SizedBox(height: m.rowGap * 0.9),
                    MembershipIconCircle(icon: _planIcon(plan), metrics: m),
                    SizedBox(height: m.rowGap * 0.6),

                    Container(
                      width: m.iconCircle * 0.34,
                      height: 2,
                      decoration: BoxDecoration(
                        color: c.brand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    SizedBox(height: m.rowGap * 0.75),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        version?.priceLabel ?? '--',
                        style: TextStyle(
                          fontSize: m.priceSize,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: c.brand,
                        ),
                      ),
                    ),
                    SizedBox(height: m.rowGap * 0.15),
                    Text(
                      version?.periodLabel ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: m.captionSize,
                        fontWeight: FontWeight.w500,
                        color: c.textSecondary,
                      ),
                    ),

                    if (version?.hasTrial ?? false) ...[
                      SizedBox(height: m.rowGap * 0.45),
                      MembershipTag(
                        label: '${version!.trialDays}-day trial',
                        metrics: m,
                        background: c.statusSuccessSoft,
                        foreground: c.statusSuccess,
                      ),
                    ],

                    SizedBox(height: m.rowGap * 0.9),

                    for (final f in plan.features)
                      Padding(
                        padding: EdgeInsets.only(bottom: m.rowGap * 0.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              f.isIncluded
                                  ? Icons.check_rounded
                                  : Icons.cancel_outlined,
                              size: m.smallIcon,
                              color: f.isIncluded ? c.brand : c.textMuted,
                            ),
                            SizedBox(width: pad * 0.45),
                            Expanded(
                              child: Text(
                                f.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: m.labelSize,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                  color: f.isIncluded
                                      ? c.textPrimary
                                      : c.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: m.rowGap * 0.5),

                    SizedBox(
                      width: double.infinity,
                      height: m.buttonHeight * 0.82,
                      child: selected
                          ? ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: c.brand,
                          foregroundColor: ThemeColors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              m.radiusSm,
                            ),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Selected',
                            style: TextStyle(
                              fontSize: m.labelSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                          : OutlinedButton(
                        onPressed: onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.brand,
                          side: BorderSide(color: c.brand),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              m.radiusSm,
                            ),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Select Plan',
                            style: TextStyle(
                              fontSize: m.labelSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

  IconData _planIcon(MembershipPlanOption plan) {
    if (plan.isHighlighted) return Icons.stars_outlined;
    return switch (plan.rank) {
      <= 1 => Icons.workspace_premium_outlined,
      <= 5 => Icons.person_outline_rounded,
      _ => Icons.card_membership_outlined,
    };
  }
}

// ---------------------------------------------------------------------------
// COMPARE PLAN FEATURES
// ---------------------------------------------------------------------------

class MembershipCompareTable extends StatelessWidget {
  const MembershipCompareTable({
    super.key,
    required this.plans,
    required this.featureKeys,
    required this.featureNameFor,
    required this.metrics,
    this.highlightPlanUuid,
  });

  final List<MembershipPlanOption> plans;
  final List<String> featureKeys;
  final String Function(String key) featureNameFor;
  final MembershipMetrics metrics;
  final String? highlightPlanUuid;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    if (plans.isEmpty || featureKeys.isEmpty) return const SizedBox.shrink();

    final needsScroll = plans.length > 3;
    final minWidth = m.iconCircle * 3.2 + plans.length * m.iconCircle * 1.7;

    final table = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Container(
            color: c.surfaceAlt,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.all(m.cardPad * 0.65),
                    child: Text(
                      'Features',
                      style: TextStyle(
                        fontSize: m.labelSize,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ),
                for (final plan in plans)
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: plan.uuid == highlightPlanUuid
                          ? c.brandSoft.withValues(alpha: 0.55)
                          : null,
                      padding: EdgeInsets.all(m.cardPad * 0.65),
                      child: Text(
                        plan.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: m.captionSize,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          for (final key in featureKeys) ...[
            Divider(height: 1, color: c.border),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.all(m.cardPad * 0.55),
                      child: Row(
                        children: [
                          MembershipIconCircle(
                            icon: membershipEntitlementIcon(key),
                            metrics: m,
                            size: m.iconCircle * 0.55,
                          ),
                          SizedBox(width: m.cardPad * 0.4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  featureNameFor(key),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: m.labelSize,
                                    fontWeight: FontWeight.w700,
                                    height: 1.25,
                                    color: c.textPrimary,
                                  ),
                                ),
                                if (_subtitleFor(key) != null) ...[
                                  SizedBox(height: m.rowGap * 0.12),
                                  Text(
                                    _subtitleFor(key)!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: m.captionSize * 0.92,
                                      fontWeight: FontWeight.w400,
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (final plan in plans)
                    Expanded(
                      flex: 3,
                      child: Container(
                        color: plan.uuid == highlightPlanUuid
                            ? c.brandSoft.withValues(alpha: 0.3)
                            : null,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(m.cardPad * 0.3),
                        child: _cell(context, plan, key),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    if (!needsScroll) return table;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: table,
      ),
    );
  }

  String? _subtitleFor(String key) {
    String? best;
    for (final plan in plans) {
      for (final f in plan.features) {
        if (f.key == key && f.isIncluded && f.numericValue != null) {
          best = f.valueLabel;
        }
      }
    }
    return best;
  }

  Widget _cell(BuildContext context, MembershipPlanOption plan, String key) {
    final c = context.c;
    final m = metrics;

    MembershipPlanFeature? feature;
    for (final f in plan.features) {
      if (f.key == key) {
        feature = f;
        break;
      }
    }

    if (feature == null || !feature.isIncluded) {
      return Icon(
        Icons.close_rounded,
        size: m.smallIcon * 1.1,
        color: c.textMuted,
      );
    }

    if (feature.numericValue != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          feature.valueLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: m.captionSize,
            fontWeight: FontWeight.w700,
            color: c.brand,
          ),
        ),
      );
    }

    return Icon(Icons.check_rounded, size: m.smallIcon * 1.1, color: c.brand);
  }
}