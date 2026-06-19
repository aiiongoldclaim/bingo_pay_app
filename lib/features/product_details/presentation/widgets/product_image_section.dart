import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/theme/theme_colors.dart';

/// Top section: custom app bar (back / share / favourite) + product
/// image placeholder + page-indicator dots.
/// Stateless — receives everything it needs as parameters.
class ProductImageSection extends StatelessWidget {
  final IconData icon;
  final String? imageUrl;
  final bool isFavourite;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleFavourite;

  const ProductImageSection({
    super.key,
    required this.icon,
    this.imageUrl,
    required this.isFavourite,
    required this.onBack,
    required this.onShare,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.surface2,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _AppBarRow(
              isFavourite: isFavourite,
              onBack: onBack,
              onShare: onShare,
              onToggleFavourite: onToggleFavourite,
            ),
            _ProductImage(icon: icon, imageUrl: imageUrl),
            _PageDots(),
          ],
        ),
      ),
    );
  }
}

class _AppBarRow extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleFavourite;

  const _AppBarRow({
    required this.isFavourite,
    required this.onBack,
    required this.onShare,
    required this.onToggleFavourite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleIconButton(icon: Icons.arrow_back_ios_new, onTap: onBack),
          Row(
            children: [
              _CircleIconButton(icon: Icons.ios_share_outlined, onTap: onShare),
              SizedBox(width: 3.w),
              _CircleIconButton(
                icon: isFavourite ? Icons.favorite : Icons.favorite_border,
                iconColor: isFavourite ? ThemeColors.red : ThemeColors.ink,
                backgroundColor: isFavourite
                    ? ThemeColors.red.withOpacity(0.1)
                    : ThemeColors.surface,
                borderColor: isFavourite
                    ? ThemeColors.red.withOpacity(0.3)
                    : ThemeColors.line,
                onTap: onToggleFavourite,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? ThemeColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor ?? ThemeColors.line, width: 1),
        ),
        child: Icon(icon, size: 18.sp, color: iconColor ?? ThemeColors.ink),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final IconData icon;
  final String? imageUrl;

  const _ProductImage({required this.icon, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28.h,
      width: double.infinity,
      child: Center(
        child: imageUrl != null
            ? Image.network(imageUrl!, fit: BoxFit.contain)
            : Icon(icon, size: 40.w, color: ThemeColors.blue),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            width: index == 0 ? 6.w : 2.w,
            height: 0.8.h,
            decoration: BoxDecoration(
              color: index == 0 ? ThemeColors.blue : ThemeColors.line,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
