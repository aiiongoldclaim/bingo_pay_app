import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/category_entity.dart';

/// Box-shaped category card for the Categories grid: the API image on top in
/// a square, the name below it.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.style,
    this.onTap,
  });

  final CategoryEntity category;
  final CategoryTileStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final radius = BorderRadius.circular(style.radius);

    return Semantics(
      button: true,
      label: category.name,
      child: Material(
        color: colors.surface,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.brand.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.all(style.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: _CategoryImage(category: category, style: style),
                  ),
                  SizedBox(height: style.gap),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontCategory,
                        fontSize: style.nameSize,
                        fontWeight: FontWeight.w500,
                        height: CategoryTileStyle.nameLineHeight,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  const _CategoryImage({required this.category, required this.style});

  final CategoryEntity category;
  final CategoryTileStyle style;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final url = category.image;
    final fallback = Center(
      child: Icon(category.icon, size: style.iconSize, color: colors.brand),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(style.radius * 0.7),
      child: ColoredBox(
        color: colors.brandSoft,
        child: url == null || url.isEmpty
            ? fallback
            : LayoutBuilder(
                builder: (context, constraints) {
                  // Decode at display size so a large upload doesn't sit in
                  // the image cache at full resolution.
                  final cacheSize =
                      (constraints.maxWidth *
                              MediaQuery.devicePixelRatioOf(context))
                          .round();
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    cacheWidth: cacheSize > 0 ? cacheSize : null,
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : fallback,
                    errorBuilder: (_, _, _) => fallback,
                  );
                },
              ),
      ),
    );
  }
}

/// Sizes for [CategoryTile], derived from the tile width so the card scales
/// with the grid instead of the screen.
class CategoryTileStyle {
  const CategoryTileStyle._({
    required this.padding,
    required this.gap,
    required this.radius,
    required this.nameSize,
    required this.iconSize,
  });

  static const double nameLineHeight = 1.25;

  final double padding;
  final double gap;
  final double radius;
  final double nameSize;
  final double iconSize;

  factory CategoryTileStyle.forWidth(double tileWidth) {
    return CategoryTileStyle._(
      padding: (tileWidth * 0.07).clamp(6, 12).toDouble(),
      gap: (tileWidth * 0.06).clamp(6, 10).toDouble(),
      radius: (tileWidth * 0.14).clamp(12, 18).toDouble(),
      nameSize: (tileWidth * 0.11).clamp(12, 15).toDouble(),
      iconSize: (tileWidth * 0.32).clamp(28, 52).toDouble(),
    );
  }

  /// Card height for a [tileWidth]-wide card: square image plus two lines of
  /// name at the user's text scale, so large fonts never overflow.
  double heightFor(double tileWidth, TextScaler textScaler) {
    final imageSize = tileWidth - padding * 2;
    final nameHeight = textScaler.scale(nameSize) * nameLineHeight * 2;
    return padding * 2 + imageSize + gap + nameHeight + 2;
  }
}
