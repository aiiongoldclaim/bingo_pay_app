// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../domain/entities/brand_entity.dart';
//
// class BrandChip extends StatelessWidget {
//   const BrandChip({super.key, required this.brand});
//
//   final BrandEntity brand;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: ThemeColors.surface,
//         borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//         border: Border.all(color: ThemeColors.line),
//       ),
//       child: Text(
//         brand.name,
//         style: TextStyle(
//           fontSize: 16.sp,
//           fontWeight: FontWeight.w600,
//           fontFamily: 'Roboto',
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/brand_entity.dart';
import 'categories_metrics.dart';

class BrandChip extends StatelessWidget {
  const BrandChip({
    super.key,
    required this.metrics,
    required this.brand,
    this.logoUrl,
    this.onTap,
  });

  final CategoriesMetrics metrics;
  final BrandEntity brand;

  /// API se aane wala logo. Null hoga to brand name text fallback dikhega.
  final String? logoUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(m.brandRadius),
      child: SizedBox(
        width: m.brandTileWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.brandTileWidth,
              height: m.brandTileHeight,
              padding: EdgeInsets.all(m.pagePadding * 0.6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(m.brandRadius),
                border: Border.all(color: c.border),
              ),
              child: hasLogo
                  ? Image.network(
                      logoUrl!,
                      fit: BoxFit.contain,
                      // Dark mode me black logos gayab ho jaate hain
                      color: c.isDark ? c.textPrimary : null,
                      errorBuilder: (_, __, ___) =>
                          _NameFallback(metrics: m, name: brand.name),
                    )
                  : _NameFallback(metrics: m, name: brand.name),
            ),
            SizedBox(height: m.pagePadding * 0.45),
            Flexible(
              child: Text(
                brand.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: m.brandNameSize,
                  height: 1.2,
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameFallback extends StatelessWidget {
  const _NameFallback({required this.metrics, required this.name});

  final CategoriesMetrics metrics;
  final String name;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        name.toUpperCase(),
        maxLines: 1,
        style: TextStyle(
          fontSize: metrics.brandNameSize * 1.3,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: c.textPrimary,
        ),
      ),
    );
  }
}
