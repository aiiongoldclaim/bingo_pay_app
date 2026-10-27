import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../../data/model/on_boarding_feature.dart';
import 'onboarding_metrics.dart';

class VaultOnboardingTone {
  const VaultOnboardingTone(this.dark);

  final bool dark;

  Color get title => dark ? ThemeColors.white : ThemeColors.vaultInk;
  Color get body => dark ? ThemeColors.vaultDarkBody : ThemeColors.vaultBody;
  Color get dotIdle => dark
      ? ThemeColors.white.withValues(alpha: 0.28)
      : ThemeColors.vaultDotIdle;
  LinearGradient get background =>
      dark ? ThemeColors.vaultNightBg : ThemeColors.vaultCreamBg;
}

class VaultOnboardingPage extends StatelessWidget {
  const VaultOnboardingPage({
    super.key,
    required this.content,
    required this.metrics,
    required this.topInset,
    required this.bottomInset,
  });

  final OnBoardingContent content;
  final OnboardingMetrics metrics;
  final double topInset;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final tone = VaultOnboardingTone(content.darkPage);

    final hPad = metrics.isRow ? metrics.hPad : 0.0;
    final bottom =
        metrics.isRow || content.perks.isNotEmpty || content.darkPage
        ? bottomInset
        : 0.0;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: tone.background),
      child: Padding(
        padding: EdgeInsets.fromLTRB(hPad, topInset, hPad, bottom),
        child: metrics.isRow ? _landscape(tone) : _portrait(tone),
      ),
    );
  }

  Widget _portrait(VaultOnboardingTone tone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.hPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content.showBrand) ...[
                Center(child: VaultWordmark(fontSize: metrics.title * 0.9)),
                SizedBox(height: metrics.gapImage),
              ],
              _Copy(content: content, metrics: metrics, tone: tone),
            ],
          ),
        ),
        SizedBox(height: metrics.gapImage),
        Expanded(child: _artworkArea(tone)),
        if (content.perks.isNotEmpty) ...[
          SizedBox(height: metrics.gapImage),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: metrics.hPad),
            child: _PerkRow(perks: content.perks, metrics: metrics, tone: tone),
          ),
        ],
      ],
    );
  }

  Widget _landscape(VaultOnboardingTone tone) {
    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.showBrand) ...[
          VaultWordmark(fontSize: metrics.title * 0.8),
          SizedBox(height: metrics.gapTitle),
        ],
        _Copy(content: content, metrics: metrics, tone: tone),
        if (content.perks.isNotEmpty) ...[
          SizedBox(height: metrics.gapImage),
          _PerkRow(perks: content.perks, metrics: metrics, tone: tone),
        ],
      ],
    );

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: content.perks.isEmpty
              ? SingleChildScrollView(child: copy)
              : LayoutBuilder(
                  builder: (context, c) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: c.maxWidth, child: copy),
                  ),
                ),
        ),
        SizedBox(width: metrics.gapImage),
        Expanded(flex: 5, child: _artworkArea(tone)),
      ],
    );
  }

  Widget _artworkArea(VaultOnboardingTone tone) {
    if (metrics.isRow) {
      return VaultArtwork(
        asset: content.image,
        fallbackIcon: content.fallbackIcon,
        alignment: Alignment.bottomCenter,
      );
    }

    if (content.perks.isEmpty) {
      return LayoutBuilder(
        builder: (context, c) {
          final h = c.maxHeight + metrics.gapImage * 4;
          return OverflowBox(
            maxHeight: h,
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: c.maxWidth,
              height: h,
              child: _FadeBottom(
                child: VaultArtwork(
                  asset: content.image,
                  fallbackIcon: content.fallbackIcon,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final halo = c.biggest.shortestSide * 1.05;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: halo,
              height: halo,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ThemeColors.vaultGoldLight.withValues(alpha: 0.42),
                    ThemeColors.vaultGoldLight.withValues(alpha: 0.12),
                    ThemeColors.vaultGoldLight.withValues(alpha: 0),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Container(
              width: halo * 0.78,
              height: halo * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeColors.vaultGold.withValues(alpha: 0.35),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: metrics.hPad * 1.5),
              child: VaultArtwork(
                asset: content.image,
                fallbackIcon: content.fallbackIcon,
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PerkRow extends StatelessWidget {
  const _PerkRow({
    required this.perks,
    required this.metrics,
    required this.tone,
  });

  final List<OnBoardingPerk> perks;
  final OnboardingMetrics metrics;
  final VaultOnboardingTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: metrics.gapTitle * 1.4,
        horizontal: metrics.gapTitle * 0.4,
      ),
      decoration: BoxDecoration(
        color: ThemeColors.white.withValues(alpha: tone.dark ? 0.06 : 0.75),
        borderRadius: BorderRadius.circular(metrics.subtitle * 1.4),
        border: Border.all(
          color: ThemeColors.vaultGold.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.vaultPlumDeep.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final perk in perks)
            Expanded(
              child: _PerkChip(perk: perk, metrics: metrics, tone: tone),
            ),
        ],
      ),
    );
  }
}

class _Copy extends StatelessWidget {
  const _Copy({
    required this.content,
    required this.metrics,
    required this.tone,
  });

  final OnBoardingContent content;
  final OnboardingMetrics metrics;
  final VaultOnboardingTone tone;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontFamily: kVaultSerif,
      fontSize: metrics.title * 1.3,
      fontWeight: FontWeight.w600,
      height: 1.08,
      color: tone.title,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.showMark) ...[
          const _TitleMark(),
          SizedBox(height: metrics.gapTitle),
        ],
        Text(content.title, style: titleStyle),
        if (content.titleHighlight.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: content.titleHighlight,
                  style: TextStyle(
                    color: tone.dark
                        ? ThemeColors.vaultGoldLight
                        : ThemeColors.vaultGold,
                  ),
                ),
                TextSpan(text: content.titleSuffix),
              ],
            ),
            style: titleStyle.copyWith(
              fontSize: content.showBrand
                  ? titleStyle.fontSize! * 1.35
                  : titleStyle.fontSize,
            ),
          ),
        SizedBox(height: metrics.gapTitle),
        Text(
          content.subTitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: metrics.subtitle,
            height: 1.5,
            color: tone.body,
          ),
        ),
      ],
    );
  }
}

class _PerkChip extends StatelessWidget {
  const _PerkChip({
    required this.perk,
    required this.metrics,
    required this.tone,
  });

  final OnBoardingPerk perk;
  final OnboardingMetrics metrics;
  final VaultOnboardingTone tone;

  @override
  Widget build(BuildContext context) {
    final box = metrics.subtitle * 2.9;
    final lines = perk.label.split('\n');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: box,
          height: box,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ThemeColors.vaultPlumButton,
            border: Border.all(color: ThemeColors.vaultGold, width: 1.2),
          ),
          child: VaultGoldShader(
            child: Icon(perk.icon, size: box * 0.46, color: ThemeColors.white),
          ),
        ),
        SizedBox(height: metrics.gapTitle * 0.8),
        Text.rich(
          TextSpan(
            text: lines.first,
            style: TextStyle(fontWeight: FontWeight.w600, color: tone.title),
            children: [
              if (lines.length > 1)
                TextSpan(
                  text: '\n${lines.skip(1).join(' ')}',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: tone.body,
                  ),
                ),
            ],
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: metrics.subtitle * 0.8,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _FadeBottom extends StatelessWidget {
  const _FadeBottom({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ThemeColors.black,
          ThemeColors.black,
          ThemeColors.black.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.86, 1.0],
      ).createShader(bounds),
      child: child,
    );
  }
}

class _TitleMark extends StatelessWidget {
  const _TitleMark();

  @override
  Widget build(BuildContext context) {
    Widget line() =>
        Container(width: 18, height: 1, color: ThemeColors.vaultGold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(),
        const SizedBox(width: 6),
        const VaultDiamond(size: 22),
        const SizedBox(width: 6),
        line(),
      ],
    );
  }
}

class VaultOnboardingDots extends StatelessWidget {
  const VaultOnboardingDots({
    super.key,
    required this.count,
    required this.currentPage,
    required this.tone,
    this.dotSize = 7,
  });

  final int count;
  final int currentPage;
  final VaultOnboardingTone tone;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${currentPage + 1} of $count',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? dotSize * 2.6 : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive ? ThemeColors.vaultGold : tone.dotIdle,
              borderRadius: BorderRadius.circular(dotSize),
            ),
          );
        }),
      ),
    );
  }
}
