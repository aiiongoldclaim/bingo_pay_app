import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'home_banner_data.dart';
import 'home_metrics.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.metrics,
    required this.banner,
    this.onTap,
    this.overlayGradient,
    this.borderColor,
    this.fallbackIconColor,
    this.fallbackBackgroundColor,
  });

  final HomeMetrics metrics;
  final HomeBannerData banner;
  final VoidCallback? onTap;
  final Gradient? overlayGradient;
  final Color? borderColor;
  final Color? fallbackIconColor;
  final Color? fallbackBackgroundColor;

  static const _animationDuration = Duration(milliseconds: 350);
  static const _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(metrics.heroRadius),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1.2)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(metrics.heroRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                banner.imageAsset,
                fit: BoxFit.fill,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: fallbackBackgroundColor ?? colors.surfaceAlt,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_outlined,
                    size: metrics.categoryIconSize,
                    color: fallbackIconColor ?? colors.textMuted,
                  ),
                ),
              ),
              if (overlayGradient != null)
                DecoratedBox(
                  decoration: BoxDecoration(gradient: overlayGradient),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageRatioBuilder extends StatefulWidget {
  const ImageRatioBuilder({
    super.key,
    required this.assetPath,
    required this.builder,
    this.fallbackRatio = 2.0,
  });

  final String assetPath;
  final double fallbackRatio;
  final Widget Function(BuildContext context, double aspectRatio) builder;

  @override
  State<ImageRatioBuilder> createState() => _ImageRatioBuilderState();
}

class _ImageRatioBuilderState extends State<ImageRatioBuilder> {
  double? _ratio;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ImageRatioBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _ratio = null;
      _resolve();
    }
  }

  void _resolve() {
    _detach();
    final provider = AssetImage(widget.assetPath);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    final listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        final ui.Image img = info.image;
        final ratio = img.width / img.height;
        if (mounted && _ratio != ratio) {
          setState(() => _ratio = ratio);
        }
      },
      onError: (_, __) {
        if (mounted) setState(() => _ratio = widget.fallbackRatio);
      },
    );
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  void _detach() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _ratio ?? widget.fallbackRatio);
}
