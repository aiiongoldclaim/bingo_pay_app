import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import 'home_metrics.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({
    super.key,
    required this.metrics,
    required this.hintText,
    this.onTap,
    this.onCameraTap,
  });

  final HomeMetrics metrics;
  final String hintText;
  final VoidCallback? onTap;
  final VoidCallback? onCameraTap;

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: metrics.searchHeight,
        padding: EdgeInsets.symmetric(horizontal: metrics.pagePadding * 0.85),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(metrics.searchRadius),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: metrics.searchIconSize,
              color: c.textMuted,
            ),
            SizedBox(width: metrics.pagePadding * 0.7),
            Expanded(
              child: Text(
                hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: metrics.searchFontSize,
                  color: c.textMuted,
                ),
              ),
            ),
            InkResponse(
              onTap: onCameraTap,
              radius: metrics.searchIconSize,
              child: Icon(
                Icons.photo_camera_outlined,
                size: metrics.searchIconSize,
                color: c.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
