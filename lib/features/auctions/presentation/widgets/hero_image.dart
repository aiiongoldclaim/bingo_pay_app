import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';

class HeroImage extends StatelessWidget {
  final String? imageUrl;

  const HeroImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AspectRatio(
      aspectRatio: 1.15,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _placeholder(colors);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return Center(
                  child: CircularProgressIndicator(
                    color: colors.onHeroBanner,
                  ),
                );
              },
            )
          : _placeholder(colors),
    );
  }

  Widget _placeholder(AppThemeColors colors) {
    return Container(
      color: colors.surfaceAlt,
      child: Icon(
        Icons.image_outlined,
        size: 60,
        color: colors.textMuted,
      ),
    );
  }
}