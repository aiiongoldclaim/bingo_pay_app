import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'home_banner_data.dart';
import 'home_metrics.dart';
import 'promo_banner.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({
    super.key,
    required this.metrics,
    required this.banners,
    this.onBannerTap,
    this.overlayGradient,
    this.borderColor,
    this.activeDotColor,
    this.inactiveDotColor,
    this.fallbackIconColor,
    this.fallbackBackgroundColor,
  });

  final HomeMetrics metrics;
  final List<HomeBannerData> banners;
  final ValueChanged<HomeBannerData>? onBannerTap;
  final Gradient? overlayGradient;

  final Color? borderColor;
  final Color? activeDotColor;
  final Color? inactiveDotColor;
  final Color? fallbackIconColor;
  final Color? fallbackBackgroundColor;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final m = widget.metrics;
    return ImageRatioBuilder(
      assetPath: widget.banners.first.imageAsset,
      fallbackRatio: m.heroAspectRatio,
      builder: (context, ratio) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.pagePadding),
              child: CarouselSlider.builder(
                itemCount: widget.banners.length,
                itemBuilder: (context, index, realIndex) => PromoBanner(
                  metrics: m,
                  banner: widget.banners[index],
                  onTap: () => widget.onBannerTap?.call(widget.banners[index]),
                  overlayGradient: widget.overlayGradient,
                  borderColor: widget.borderColor,
                  fallbackIconColor: widget.fallbackIconColor,
                  fallbackBackgroundColor: widget.fallbackBackgroundColor,
                ),
                options: CarouselOptions(
                  aspectRatio: ratio,
                  viewportFraction: 1,
                  autoPlay: widget.banners.length > 1,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 600),
                  autoPlayCurve: Curves.easeInOutCubic,
                  enableInfiniteScroll: widget.banners.length > 1,
                  padEnds: false,
                  onPageChanged: (index, _) => setState(() => _current = index),
                ),
              ),
            ),
            SizedBox(height: m.pagePadding * 0.75),
            _DotsIndicator(
              metrics: m,
              count: widget.banners.length,
              activeIndex: _current,
              activeColor: widget.activeDotColor,
              inactiveColor: widget.inactiveDotColor,
            ),
          ],
        );
      },
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.metrics,
    required this.count,
    required this.activeIndex,
    this.activeColor,
    this.inactiveColor,
  });

  final HomeMetrics metrics;
  final int count;
  final int activeIndex;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final resolvedActive = activeColor ?? colors.brand;
    final resolvedInactive = inactiveColor ?? colors.brandSoft;
    final dotHeight = metrics.heroEyebrowSize * 0.32;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: dotHeight * 0.8),
          width: active ? dotHeight * 6 : dotHeight * 3,
          height: dotHeight,
          decoration: BoxDecoration(
            color: active ? resolvedActive : resolvedInactive,
            borderRadius: BorderRadius.circular(dotHeight),
          ),
        );
      }),
    );
  }
}
