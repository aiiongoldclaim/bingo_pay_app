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
  });

  final HomeMetrics metrics;
  final List<HomeBannerData> banners;
  final ValueChanged<HomeBannerData>? onBannerTap;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final m = widget.metrics;

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
            ),
            options: CarouselOptions(
              height: m.heroHeight,
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
        SizedBox(height: m.pagePadding * 0.6),
        _DotsIndicator(
          metrics: m,
          count: widget.banners.length,
          activeIndex: _current,
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.metrics,
    required this.count,
    required this.activeIndex,
  });

  final HomeMetrics metrics;
  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final dotHeight = metrics.heroEyebrowSize * 0.32;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: dotHeight * 0.8),
          width: active ? dotHeight * 6 : dotHeight * 3,
          height: dotHeight,
          decoration: BoxDecoration(
            color: active ? c.brand : c.brandSoft,
            borderRadius: BorderRadius.circular(dotHeight),
          ),
        );
      }),
    );
  }
}
