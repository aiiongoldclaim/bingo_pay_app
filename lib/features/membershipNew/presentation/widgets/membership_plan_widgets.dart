// import 'dart:math' as math;
//
// import 'package:flutter/material.dart';
// import 'package:bingo_pay/core/theme/app_theme_colors.dart';
// import 'package:bingo_pay/core/theme/theme_colors.dart';
//
// import '../../../../core/constants/image_constants.dart';
// import '../../data/models/membership_plan_model.dart';
// import 'benifits_tile.dart';
// import 'landing_widgets.dart';
// import 'membership_metrices.dart';
//
//
//
// class MembershipPlansHero extends StatelessWidget {
//   const MembershipPlansHero({
//     super.key,
//     required this.metrics,
//     this.artworkAsset = AppImages.membershipCard,
//   });
//
//   final MembershipMetrics metrics;
//   final String artworkAsset;
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = metrics;
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(m.radiusLg),
//       child: Image.asset(
//         artworkAsset,
//         width: double.infinity,
//         fit: BoxFit.fitWidth,
//         errorBuilder: (_, __, ___) => Container(
//           height: m.heroHeight,
//           decoration: BoxDecoration(
//             gradient: colors.isDark
//                 ? ThemeColors.heroBannerDark
//                 : ThemeColors.primaryGradient1,
//             borderRadius: BorderRadius.circular(m.radiusLg),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ---------------------------------------------------------------------------
// // 3D RING CAROUSEL — ek time pe ek card, scroll pe agla
// // ---------------------------------------------------------------------------
//
// class MembershipPlanRingCarousel extends StatefulWidget {
//   const MembershipPlanRingCarousel({
//     super.key,
//     required this.plans,
//     required this.selectedUuid,
//     required this.metrics,
//     required this.onPlanChanged,
//   });
//
//   final List<MembershipPlanOption> plans;
//   final String? selectedUuid;
//   final MembershipMetrics metrics;
//
//   final ValueChanged<String> onPlanChanged;
//
//   @override
//   State<MembershipPlanRingCarousel> createState() =>
//       _MembershipPlanRingCarouselState();
// }
//
// class _MembershipPlanRingCarouselState
//     extends State<MembershipPlanRingCarousel> {
//   late final PageController _controller;
//   late int _current;
//
//   static const double _maxRotation = 0.42;
//   static const double _minScale = 0.82;
//
//   @override
//   void initState() {
//     super.initState();
//     _current = _indexOf(widget.selectedUuid);
//     _controller = PageController(
//       initialPage: _current,
//       viewportFraction: _viewportFraction,
//     );
//   }
//
//   double get _viewportFraction {
//     final m = widget.metrics;
//     if (m.isTabletLandscape) return 0.36;
//     if (m.isTablet) return 0.52;
//     return 0.74;
//   }
//
//   int _indexOf(String? uuid) {
//     if (uuid == null) return 0;
//     final i = widget.plans.indexWhere((p) => p.uuid == uuid);
//     return i < 0 ? 0 : i;
//   }
//
//   @override
//   void didUpdateWidget(covariant MembershipPlanRingCarousel oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     final target = _indexOf(widget.selectedUuid);
//     if (target != _current && _controller.hasClients) {
//       _current = target;
//       _controller.animateToPage(
//         target,
//         duration: const Duration(milliseconds: 320),
//         curve: Curves.easeOutCubic,
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final m = widget.metrics;
//     final height = _cardHeight(m, widget.plans);
//
//     return Column(
//       children: [
//         SizedBox(
//           height: height,
//           child: PageView.builder(
//             controller: _controller,
//             itemCount: widget.plans.length,
//             clipBehavior: Clip.none,
//             onPageChanged: (i) {
//               setState(() => _current = i);
//               widget.onPlanChanged(widget.plans[i].uuid);
//             },
//             itemBuilder: (context, index) {
//               final plan = widget.plans[index];
//
//               return AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   double page = _current.toDouble();
//                   if (_controller.hasClients &&
//                       _controller.position.haveDimensions) {
//                     page = _controller.page ?? page;
//                   }
//
//                   final delta = (index - page).clamp(-1.5, 1.5);
//                   final absDelta = delta.abs();
//
//                   final rotation = delta * _maxRotation;
//                   final scale = 1 - (absDelta * (1 - _minScale));
//                   final opacity = (1 - absDelta * 0.45).clamp(0.35, 1.0);
//
//                   final transform = Matrix4.identity()
//                     ..setEntry(3, 2, 0.0014) // perspective
//                     ..rotateY(rotation)
//                     ..scale(scale, scale);
//
//                   return Transform(
//                     alignment: delta > 0
//                         ? Alignment.centerLeft
//                         : Alignment.centerRight,
//                     transform: transform,
//                     child: Opacity(opacity: opacity, child: child),
//                   );
//                 },
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: m.tileGap * 0.5,
//                     vertical: m.tileGap * 0.4,
//                   ),
//                   child: MembershipPlanTierCard(
//                     plan: plan,
//                     selected: widget.selectedUuid == plan.uuid,
//                     metrics: m,
//                     onTap: () => _goTo(index),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//
//         SizedBox(height: m.rowGap * 0.8),
//         _Dots(
//           count: widget.plans.length,
//           current: _current,
//           metrics: m,
//           onTap: _goTo,
//         ),
//       ],
//     );
//   }
//
//   void _goTo(int index) {
//     if (!_controller.hasClients) return;
//     widget.onPlanChanged(widget.plans[index].uuid);   // ← add
//     _controller.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 320),
//       curve: Curves.easeOutCubic,
//     );
//   }
//
//
//   double _cardHeight(MembershipMetrics m, List<MembershipPlanOption> plans) {
//     var maxFeatures = 0;
//     for (final p in plans) {
//       maxFeatures = math.max(maxFeatures, p.features.length);
//     }
//
//     final base =
//         m.cardPad * 1.9 + // padding
//             m.captionSize * 2.4 + // ribbon
//             m.sectionTitleSize * 1.5 + // name
//             m.captionSize * 2.8 + // description
//             m.iconCircle + // icon
//             m.rowGap * 4.2 + // gaps
//             m.priceSize * 1.25 + // price
//             m.captionSize * 1.6 + // period
//             m.buttonHeight * 0.95; // button
//
//     final featureBlock =
//         maxFeatures * (m.labelSize * 1.55 + m.rowGap * 0.5);
//
//     return base + featureBlock;
//   }
// }
//
// class _Dots extends StatelessWidget {
//   const _Dots({
//     required this.count,
//     required this.current,
//     required this.metrics,
//     required this.onTap,
//   });
//
//   final int count;
//   final int current;
//   final MembershipMetrics metrics;
//   final ValueChanged<int> onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = metrics;
//     final dot = m.captionSize * 0.62;
//
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         for (var i = 0; i < count; i++)
//           GestureDetector(
//             onTap: () => onTap(i),
//             behavior: HitTestBehavior.opaque,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               margin: EdgeInsets.symmetric(horizontal: dot * 0.45),
//               width: i == current ? dot * 3.2 : dot,
//               height: dot,
//               decoration: BoxDecoration(
//                 color: i == current ? colors.brand : colors.border,
//                 borderRadius: BorderRadius.circular(99),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
//
// // ---------------------------------------------------------------------------
// // PLAN TIER CARD
// // ---------------------------------------------------------------------------
//
// class MembershipPlanTierCard extends StatelessWidget {
//   const MembershipPlanTierCard({
//     super.key,
//     required this.plan,
//     required this.selected,
//     required this.metrics,
//     required this.onTap,
//   });
//
//   final MembershipPlanOption plan;
//   final bool selected;
//   final MembershipMetrics metrics;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = metrics;
//     final version = plan.version;
//     final ribbon = plan.isHighlighted;
//     final pad = m.cardPad * 0.85;
//
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(m.radiusMd),
//       child: Container(
//         clipBehavior: Clip.antiAlias,
//         decoration: BoxDecoration(
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(m.radiusMd),
//           border: Border.all(
//             color: selected || ribbon ? colors.brand : colors.border,
//             width: selected ? 1.8 : 1,
//           ),
//           boxShadow: selected
//               ? [
//             BoxShadow(
//               color: colors.brand.withValues(alpha: 0.18),
//               blurRadius: m.cardPad,
//               offset: Offset(0, m.cardPad * 0.35),
//             ),
//           ]
//               : null,
//         ),
//         child: SingleChildScrollView(
//           physics: const NeverScrollableScrollPhysics(),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (ribbon)
//                 Container(
//                   width: double.infinity,
//                   color: colors.brand,
//                   padding: EdgeInsets.symmetric(vertical: pad * 0.36),
//                   child: Text(
//                     plan.highlight!.toUpperCase(),
//                     textAlign: TextAlign.center,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: m.captionSize,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.5,
//                       color: ThemeColors.white,
//                     ),
//                   ),
//                 ),
//
//               Padding(
//                 padding: EdgeInsets.all(pad),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       plan.name,
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: m.sectionTitleSize,
//                         fontWeight: FontWeight.w700,
//                         height: 1.2,
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                     if (plan.hasDescription) ...[
//                       SizedBox(height: m.rowGap * 0.3),
//                       Text(
//                         plan.description,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: m.captionSize,
//                           fontWeight: FontWeight.w400,
//                           height: 1.35,
//                           color: colors.textSecondary,
//                         ),
//                       ),
//                     ],
//
//                     SizedBox(height: m.rowGap * 0.9),
//                     MembershipIconCircle(icon: _planIcon(plan), metrics: m),
//                     SizedBox(height: m.rowGap * 0.6),
//
//                     Container(
//                       width: m.iconCircle * 0.34,
//                       height: 2,
//                       decoration: BoxDecoration(
//                         color: colors.brand,
//                         borderRadius: BorderRadius.circular(2),
//                       ),
//                     ),
//
//                     SizedBox(height: m.rowGap * 0.75),
//                     FittedBox(
//                       fit: BoxFit.scaleDown,
//                       child: Text(
//                         version?.priceLabel ?? '--',
//                         style: TextStyle(
//                           fontSize: m.priceSize,
//                           fontWeight: FontWeight.w700,
//                           height: 1.1,
//                           color: colors.brand,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: m.rowGap * 0.15),
//                     Text(
//                       version?.periodLabel ?? '',
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: m.captionSize,
//                         fontWeight: FontWeight.w500,
//                         color: colors.textSecondary,
//                       ),
//                     ),
//
//                     if (version?.hasTrial ?? false) ...[
//                       SizedBox(height: m.rowGap * 0.45),
//                       MembershipTag(
//                         label: '${version!.trialDays}-day trial',
//                         metrics: m,
//                         background: colors.statusSuccessSoft,
//                         foreground: colors.statusSuccess,
//                       ),
//                     ],
//
//                     SizedBox(height: m.rowGap * 0.9),
//
//                     for (final f in plan.features)
//                       Padding(
//                         padding: EdgeInsets.only(bottom: m.rowGap * 0.5),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Icon(
//                               f.isIncluded
//                                   ? Icons.check_rounded
//                                   : Icons.cancel_outlined,
//                               size: m.smallIcon,
//                               color: f.isIncluded ? colors.brand : colors.textMuted,
//                             ),
//                             SizedBox(width: pad * 0.45),
//                             Expanded(
//                               child: Text(
//                                 f.name,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontSize: m.labelSize,
//                                   fontWeight: FontWeight.w500,
//                                   height: 1.3,
//                                   color: f.isIncluded
//                                       ? colors.textPrimary
//                                       : colors.textMuted,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                     SizedBox(height: m.rowGap * 0.5),
//
//                     SizedBox(
//                       width: double.infinity,
//                       height: m.buttonHeight * 0.82,
//                       child: selected
//                           ? ElevatedButton(
//                         onPressed: onTap,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: colors.brand,
//                           foregroundColor: ThemeColors.white,
//                           elevation: 0,
//                           padding: EdgeInsets.zero,
//                           minimumSize: Size.zero,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                               m.radiusSm,
//                             ),
//                           ),
//                         ),
//                         child: FittedBox(
//                           fit: BoxFit.scaleDown,
//                           child: Text(
//                             'Selected',
//                             style: TextStyle(
//                               fontSize: m.labelSize,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       )
//                           : OutlinedButton(
//                         onPressed: onTap,
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: colors.brand,
//                           side: BorderSide(color: colors.brand),
//                           padding: EdgeInsets.zero,
//                           minimumSize: Size.zero,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(
//                               m.radiusSm,
//                             ),
//                           ),
//                         ),
//                         child: FittedBox(
//                           fit: BoxFit.scaleDown,
//                           child: Text(
//                             'Select Plan',
//                             style: TextStyle(
//                               fontSize: m.labelSize,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   IconData _planIcon(MembershipPlanOption plan) {
//     if (plan.isHighlighted) return Icons.stars_outlined;
//     return switch (plan.rank) {
//       <= 1 => Icons.workspace_premium_outlined,
//       <= 5 => Icons.person_outline_rounded,
//       _ => Icons.card_membership_outlined,
//     };
//   }
// }
//
// // ---------------------------------------------------------------------------
// // COMPARE PLAN FEATURES
// // ---------------------------------------------------------------------------
//
// class MembershipCompareTable extends StatelessWidget {
//   const MembershipCompareTable({
//     super.key,
//     required this.plans,
//     required this.featureKeys,
//     required this.featureNameFor,
//     required this.metrics,
//     this.highlightPlanUuid,
//   });
//
//   final List<MembershipPlanOption> plans;
//   final List<String> featureKeys;
//   final String Function(String key) featureNameFor;
//   final MembershipMetrics metrics;
//   final String? highlightPlanUuid;
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = context.c;
//     final m = metrics;
//
//     if (plans.isEmpty || featureKeys.isEmpty) return const SizedBox.shrink();
//
//     final needsScroll = plans.length > 3;
//
//     // fixed widths instead of flex, since this can sit inside a horizontal scroll
//     final featureColWidth = m.iconCircle * 3.2;
//     final planColWidth = m.iconCircle * 1.7;
//     final minWidth = featureColWidth + plans.length * planColWidth;
//
//     final table = Container(
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.circular(m.radiusMd),
//         border: Border.all(color: colors.border),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             color: colors.surfaceAlt,
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: featureColWidth,
//                   child: Padding(
//                     padding: EdgeInsets.all(m.cardPad * 0.65),
//                     child: Text(
//                       'Features',
//                       style: TextStyle(
//                         fontSize: m.labelSize,
//                         fontWeight: FontWeight.w700,
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                   ),
//                 ),
//                 for (final plan in plans)
//                   SizedBox(
//                     width: planColWidth,
//                     child: Container(
//                       color: plan.uuid == highlightPlanUuid
//                           ? colors.brandSoft.withValues(alpha: 0.55)
//                           : null,
//                       padding: EdgeInsets.all(m.cardPad * 0.65),
//                       child: Text(
//                         plan.name,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: m.captionSize,
//                           fontWeight: FontWeight.w700,
//                           color: colors.textPrimary,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//           for (final key in featureKeys) ...[
//             Divider(height: 1, color: colors.border),
//             IntrinsicHeight(
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   SizedBox(
//                     width: featureColWidth,
//                     child: Padding(
//                       padding: EdgeInsets.all(m.cardPad * 0.55),
//                       child: Row(
//                         children: [
//                           MembershipIconCircle(
//                             icon: membershipEntitlementIcon(key),
//                             metrics: m,
//                             size: m.iconCircle * 0.55,
//                           ),
//                           SizedBox(width: m.cardPad * 0.4),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   featureNameFor(key),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     fontSize: m.labelSize,
//                                     fontWeight: FontWeight.w700,
//                                     height: 1.25,
//                                     color: colors.textPrimary,
//                                   ),
//                                 ),
//                                 if (_subtitleFor(key) != null) ...[
//                                   SizedBox(height: m.rowGap * 0.12),
//                                   Text(
//                                     _subtitleFor(key)!,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       fontSize: m.captionSize * 0.92,
//                                       fontWeight: FontWeight.w400,
//                                       color: colors.textSecondary,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   for (final plan in plans)
//                     SizedBox(
//                       width: planColWidth,
//                       child: Container(
//                         color: plan.uuid == highlightPlanUuid
//                             ? colors.brandSoft.withValues(alpha: 0.3)
//                             : null,
//                         alignment: Alignment.center,
//                         padding: EdgeInsets.all(m.cardPad * 0.3),
//                         child: _cell(context, plan, key),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//
//     if (!needsScroll) return table;
//
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(minWidth: minWidth),
//         child: table,
//       ),
//     );
//   }
//
//   String? _subtitleFor(String key) {
//     String? best;
//     for (final plan in plans) {
//       for (final f in plan.features) {
//         if (f.key == key && f.isIncluded && f.numericValue != null) {
//           best = f.valueLabel;
//         }
//       }
//     }
//     return best;
//   }
//
//   Widget _cell(BuildContext context, MembershipPlanOption plan, String key) {
//     final colors = context.c;
//     final m = metrics;
//
//     MembershipPlanFeature? feature;
//     for (final f in plan.features) {
//       if (f.key == key) {
//         feature = f;
//         break;
//       }
//     }
//
//     if (feature == null || !feature.isIncluded) {
//       return Icon(
//         Icons.close_rounded,
//         size: m.smallIcon * 1.1,
//         color: colors.textMuted,
//       );
//     }
//
//     if (feature.numericValue != null) {
//       return FittedBox(
//         fit: BoxFit.scaleDown,
//         child: Text(
//           feature.valueLabel,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: m.captionSize,
//             fontWeight: FontWeight.w700,
//             color: colors.brand,
//           ),
//         ),
//       );
//     }
//
//     return Icon(Icons.check_rounded, size: m.smallIcon * 1.1, color: colors.brand);
//   }
// }
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
    final colors = context.c;
    final m = metrics;

    // image ki height thodi choti — pehle width-driven aspect ratio thi,
    // ab explicit shorter height + cover fit taaki crop clean lage.
    final heroHeight = m.heroHeight * 0.78;

    return ClipRRect(
      borderRadius: BorderRadius.circular(m.radiusLg),
      child: Image.asset(
        artworkAsset,
        width: double.infinity,
        height: heroHeight,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: heroHeight,
          decoration: BoxDecoration(
            gradient: colors.isDark
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
// PLAN CARDS — vertical stack of large premium horizontal cards, one per
// tier (TheVaults / Vaults Luxe / Ultra Luxe), each visually distinct by its
// position in the (existing, dynamic) plans list.
// ---------------------------------------------------------------------------

class MembershipPlanCardsColumn extends StatelessWidget {
  const MembershipPlanCardsColumn({
    super.key,
    required this.plans,
    required this.selectedUuid,
    required this.metrics,
    required this.onPlanChanged,
  });

  final List<MembershipPlanOption> plans;
  final String? selectedUuid;
  final MembershipMetrics metrics;
  final ValueChanged<String> onPlanChanged;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Column(
      children: [
        for (var i = 0; i < plans.length; i++) ...[
          if (i > 0) SizedBox(height: m.rowGap * 1.1),
          MembershipPlanTierCard(
            plan: plans[i],
            tierStyle: MembershipTierStyle.forIndex(i),
            selected: selectedUuid == plans[i].uuid,
            metrics: m,
            onTap: () => onPlanChanged(plans[i].uuid),
          ),
        ],
      ],
    );
  }
}

/// Purely presentational per-tier palette — picked by position in the
/// existing dynamic plans list, never by hardcoded plan name/id.
class MembershipTierStyle {
  const MembershipTierStyle({
    required this.background,
    required this.border,
    required this.accent,
    required this.titleColor,
    required this.subtitleColor,
    required this.dividerColor,
    required this.isDark,
  });

  final Color background;
  final Color border;
  final Color accent;
  final Color titleColor;
  final Color subtitleColor;
  final Color dividerColor;
  final bool isDark;

  factory MembershipTierStyle.forIndex(int index) {
    switch (index) {
      case 0: // TheVaults — purple / lavender
        return const MembershipTierStyle(
          background: ThemeColors.membershipEssentialBg,
          border: ThemeColors.membershipEssentialBorder,
          accent: ThemeColors.membershipPrimaryPurple,
          titleColor: ThemeColors.membershipTextDark,
          subtitleColor: ThemeColors.membershipTextSecondary,
          dividerColor: ThemeColors.membershipLightLavender,
          isDark: false,
        );
      case 1: // Vaults Luxe — champagne / gold
        return const MembershipTierStyle(
          background: ThemeColors.membershipLuxeBg,
          border: ThemeColors.membershipLuxeBorder,
          accent: ThemeColors.membershipLuxeAccent,
          titleColor: ThemeColors.membershipLuxeText,
          subtitleColor: ThemeColors.membershipLuxeText,
          dividerColor: ThemeColors.membershipLuxeBorder,
          isDark: false,
        );
      default: // Ultra Luxe — darkest, most premium
        return const MembershipTierStyle(
          background: ThemeColors.membershipUltraBg,
          border: ThemeColors.membershipUltraAccent,
          accent: ThemeColors.membershipUltraAccent,
          titleColor: ThemeColors.white,
          subtitleColor: Color(0xB3FFFFFF),
          dividerColor: Color(0x33F3CE6B),
          isDark: true,
        );
    }
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
    MembershipTierStyle? tierStyle,
  }) : _tierStyle = tierStyle;

  final MembershipPlanOption plan;
  final bool selected;
  final MembershipMetrics metrics;
  final VoidCallback onTap;
  final MembershipTierStyle? _tierStyle;

  static const int _maxVisibleFeatures = 6;
  static const Duration _animDuration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    final version = plan.version;
    final style = _tierStyle ?? MembershipTierStyle.forIndex(0);
    final pad = m.cardPad * 0.9;

    final totalFeatures = plan.features.length;
    final visibleFeatures = totalFeatures > _maxVisibleFeatures
        ? plan.features.sublist(0, _maxVisibleFeatures)
        : plan.features;
    final remainingFeatures = totalFeatures - visibleFeatures.length;

    final subtitleColor = style.isDark
        ? style.subtitleColor
        : style.subtitleColor.withValues(alpha: 0.85);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: _animDuration,
            curve: Curves.easeInOut,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(m.radiusMd),
              border: Border.all(
                color: style.border,
                width: selected ? 2.0 : 1.2,
              ),
              boxShadow: selected
                  ? [
                BoxShadow(
                  color: style.accent.withValues(alpha: style.isDark ? 0.35 : 0.22),
                  blurRadius: m.cardPad,
                  offset: Offset(0, m.cardPad * 0.3),
                ),
              ]
                  : null,
            ),
            child: Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── header: icon, name, selection indicator ──────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MembershipIconCircle(
                        icon: _planIcon(plan),
                        metrics: m,
                        size: m.iconCircle * 0.62,
                        background: style.accent.withValues(alpha: style.isDark ? 0.18 : 0.12),
                        foreground: style.accent,
                      ),
                      SizedBox(width: m.cardPad * 0.6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              plan.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: m.sectionTitleSize * 1.12,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                color: style.titleColor,
                              ),
                            ),
                            if (plan.hasDescription) ...[
                              SizedBox(height: m.rowGap * 0.2),
                              Text(
                                plan.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: m.captionSize * 1.15,
                                  fontWeight: FontWeight.w400,
                                  height: 1.3,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: m.cardPad * 0.4),
                      AnimatedSwitcher(
                        duration: _animDuration,
                        child: Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          key: ValueKey(selected),
                          size: m.radioSize,
                          color: selected ? style.accent : style.border,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: m.rowGap * 0.85),

                  // ── price ─────────────────────────────────────────────
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          version?.priceLabel ?? '--',
                          style: TextStyle(
                            fontSize: m.priceSize * 1.1,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: style.accent,
                          ),
                        ),
                        SizedBox(width: m.rowGap * 0.25),
                        Text(
                          version?.periodLabel ?? '',
                          style: TextStyle(
                            fontSize: m.captionSize * 1.15,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (version?.hasTrial ?? false) ...[
                    SizedBox(height: m.rowGap * 0.5),
                    MembershipTag(
                      label: '${version!.trialDays}-day trial',
                      metrics: m,
                      background: style.accent.withValues(alpha: 0.14),
                      foreground: style.accent,
                    ),
                  ],

                  SizedBox(height: m.rowGap),
                  Divider(height: 1, thickness: 1, color: style.dividerColor),
                  SizedBox(height: m.rowGap),

                  // ── benefits: compact icon + text, 2 columns ─────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 2;
                      final spacing = m.cardPad * 0.6;
                      final itemWidth =
                          (constraints.maxWidth - spacing * (columns - 1)) /
                              columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: m.rowGap * 0.55,
                        children: [
                          for (final f in visibleFeatures)
                            SizedBox(
                              width: itemWidth,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    membershipEntitlementIcon(f.key),
                                    size: m.smallIcon * 0.8,
                                    color: f.isIncluded
                                        ? style.accent
                                        : subtitleColor.withValues(alpha: 0.5),
                                  ),
                                  SizedBox(width: m.cardPad * 0.35),
                                  Flexible(
                                    child: Text(
                                      f.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: m.labelSize * 1.15,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3,
                                        color: f.isIncluded
                                            ? style.titleColor
                                            : subtitleColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  if (remainingFeatures > 0) ...[
                    SizedBox(height: m.rowGap * 0.4),
                    Text(
                      '+$remainingFeatures more',
                      style: TextStyle(
                        fontSize: m.labelSize * 1.15,
                        fontWeight: FontWeight.w700,
                        color: style.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── "Most Popular" corner ribbon — existing highlight data only ──
          if (plan.isHighlighted)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: m.cardPad * 0.6,
                  vertical: m.rowGap * 0.25,
                ),
                decoration: BoxDecoration(
                  color: style.accent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(m.radiusMd),
                    bottomLeft: Radius.circular(m.radiusMd),
                  ),
                ),
                child: Text(
                  plan.highlight!.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: m.captionSize * 0.95,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: style.isDark ? ThemeColors.membershipUltraBg : ThemeColors.white,
                  ),
                ),
              ),
            ),
        ],
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
    final colors = context.c;
    final m = metrics;

    if (plans.isEmpty || featureKeys.isEmpty) return const SizedBox.shrink();

    final featureColWidth = m.iconCircle * 3.2;
    final planColWidth = m.iconCircle * 1.7;

    // Header aur har feature row ke liye fixed heights, taaki left (fixed)
    // column aur right (scrollable) columns hamesha row-by-row align rahein.
    final headerHeight = m.cardPad * 1.3 + m.captionSize * 1.15 * 2.6;
    final rowHeight = m.cardPad * 1.1 + m.labelSize * 1.25 * 2.6;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.radiusMd),
        border: Border.all(color: ThemeColors.membershipLightLavender),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Fixed "Features" column — kabhi scroll nahi hoga ----
          SizedBox(
            width: featureColWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: headerHeight,
                  color: ThemeColors.membershipVeryLightLavender,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(m.cardPad * 0.65),
                  child: Text(
                    'Features',
                    style: TextStyle(
                      fontSize: m.labelSize * 1.35,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.membershipTextDark,
                    ),
                  ),
                ),
                for (final key in featureKeys) ...[
                  Divider(height: 1, color: ThemeColors.membershipLightLavender),
                  Container(
                    height: rowHeight,
                    padding: EdgeInsets.all(m.cardPad * 0.55),
                    child: Row(
                      children: [
                        MembershipIconCircle(
                          icon: membershipEntitlementIcon(key),
                          metrics: m,
                          size: m.iconCircle * 0.55,
                          background: ThemeColors.membershipPrimaryPurple.withValues(alpha: 0.12),
                          foreground: ThemeColors.membershipPrimaryPurple,
                        ),
                        SizedBox(width: m.cardPad * 0.4),
                        Expanded(
                          child: Text(
                            featureNameFor(key),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: m.labelSize * 1.25,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                              color: ThemeColors.membershipTextDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ---- Scrollable plan columns (Vault Club / Test Plan / ...) ----
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final plan in plans)
                          Container(
                            width: planColWidth,
                            color: ThemeColors.membershipVeryLightLavender,
                            child: Container(
                              color: plan.uuid == highlightPlanUuid
                                  ? ThemeColors.membershipLightLavender.withValues(alpha: 0.7)
                                  : null,
                              padding: EdgeInsets.all(m.cardPad * 0.65),
                              alignment: Alignment.center,
                              child: Text(
                                plan.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: m.captionSize * 1.15,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.membershipTextDark,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (final key in featureKeys) ...[
                    Divider(height: 1, color: ThemeColors.membershipLightLavender),
                    SizedBox(
                      height: rowHeight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final plan in plans)
                            Container(
                              width: planColWidth,
                              color: plan.uuid == highlightPlanUuid
                                  ? ThemeColors.membershipLightLavender.withValues(alpha: 0.4)
                                  : null,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(m.cardPad * 0.3),
                              child: _cell(context, plan, key),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, MembershipPlanOption plan, String key) {
    final colors = context.c;
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
        color: colors.textMuted,
      );
    }

    if (feature.numericValue != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          feature.valueLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: m.captionSize * 1.15,
            fontWeight: FontWeight.w700,
            color: ThemeColors.membershipPrimaryPurple,
          ),
        ),
      );
    }

    return Icon(
      Icons.check_rounded,
      size: m.smallIcon * 1.1,
      color: ThemeColors.membershipPrimaryPurple,
    );
  }
}