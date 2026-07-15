import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_glass.dart';

/// Frosted-glass back button for the auth screens.
///
/// Built on [IconButton] (which reliably centers and paints its icon) rather
/// than a plain Icon inside a sized box, so the arrow always renders in both
/// light and dark themes.
class GlassBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const GlassBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final glass = context.glass;
    return IconButton(
      onPressed: onTap,
      iconSize: 22,
      icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
      style: IconButton.styleFrom(
        backgroundColor: glass.fill,
        fixedSize: const Size(44, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: glass.border),
        ),
      ),
    );
  }
}
