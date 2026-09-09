import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_theme_colors.dart';


class HeroWishlistButton extends StatefulWidget {
  const HeroWishlistButton({
    super.key,
    required this.auctionUuid,
  });

  final String auctionUuid;

  @override
  State<HeroWishlistButton> createState() => _HeroWishlistButtonState();
}

class _HeroWishlistButtonState extends State<HeroWishlistButton> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () => setState(() => _saved = !_saved),
      child: Container(
        width: 8.72.w,
        height: 8.72.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 17.sp,
          color: _saved ? colors.error : colors.textSecondary,
        ),
      ),
    );
  }
}
