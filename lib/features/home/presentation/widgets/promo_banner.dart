// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
//
// class PromoBanner extends StatelessWidget {
//   const PromoBanner({
//     super.key,
//     required this.title,
//     required this.heading,
//     required this.buttonText,
//     this.onTap,
//     this.icon = Icons.card_giftcard_rounded,
//   });
//
//   final String title;
//   final String heading;
//   final String buttonText;
//   final VoidCallback? onTap;
//   final IconData icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 5.w),
//       height: 22.h,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: ThemeColors.accent,
//         borderRadius: BorderRadius.circular(AppSizes.cardRadius),
//       ),
//       child: Stack(
//         children: [
//           /// Background Gift Icon
//           Positioned(
//             right: -2.w,
//             bottom: -2.h,
//             child: Icon(
//               icon,
//               size: 28.w,
//               color: ThemeColors.white.withOpacity(.25),
//             ),
//           ),
//
//           /// Content
//           Padding(
//             padding: EdgeInsets.all(AppSizes.paddingLg.toDouble()),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title.toUpperCase(),
//                   style: AppTextStyles.bannerTitle.copyWith(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//
//                 SizedBox(height: 0.8.h),
//
//                 Expanded(
//                   child: Text(
//                     heading,
//                     style: AppTextStyles.bannerHeading.copyWith(
//                       fontSize: 20.sp,
//                       color: ThemeColors.accentInk,
//                     ),
//                   ),
//                 ),
//
//                 GestureDetector(
//                   onTap: onTap,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 5.w,
//                       vertical: 1.4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: ThemeColors.accentInk,
//                       borderRadius: BorderRadius.circular(AppSizes.radiusXl),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           buttonText,
//                           style: AppTextStyles.buttonText.copyWith(
//                             fontSize: 15.sp,
//                             color: ThemeColors.white,
//                           ),
//                         ),
//                         SizedBox(width: 2.w),
//                         Icon(
//                           Icons.arrow_forward_rounded,
//                           color: ThemeColors.white,
//                           size: AppSizes.iconMd,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
  });

  final HomeMetrics metrics;
  final HomeBannerData banner;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(metrics.heroRadius),
        child: Image.asset(
          banner.imageAsset,
          fit: BoxFit.fill, // container ab exact ratio ka hai
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => Container(
            color: c.surfaceAlt,
            alignment: Alignment.center,
            child: Icon(
              Icons.image_outlined,
              size: metrics.categoryIconSize,
              color: c.textMuted,
            ),
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
