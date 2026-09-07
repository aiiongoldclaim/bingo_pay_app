import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import 'edit_profile_matrics.dart';

/// Loading placeholder for the Edit Profile screen, shown while load() is in
/// flight — mirrors the loaded layout (avatar, email card, info tiles)
/// instead of a bare spinner.
class EditProfileShimmer extends StatelessWidget {
  const EditProfileShimmer({super.key, required this.metrics});

  final EditProfileMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return AppShimmer(
      backgroundColor: colors.background,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapMd, m.pageHPad, m.gapLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar block
            Center(
              child: Column(
                children: [
                  Container(
                    width: m.avatarSize,
                    height: m.avatarSize,
                    decoration: BoxDecoration(
                      color: colors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: m.gapMd),
                  _Block(width: m.avatarSize * 0.9, height: m.avatarNameSize, colors: colors),
                  SizedBox(height: m.gapXs * 0.6),
                  _Block(width: m.avatarSize * 0.55, height: m.avatarHintSize, colors: colors),
                ],
              ),
            ),

            SizedBox(height: m.gapLg),

            // Email card
            Container(
              height: m.fieldHeight * 2,
              padding: EdgeInsets.all(m.cardPad),
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(m.cardRadius),
              ),
            ),

            SizedBox(height: m.gapMd),

            // Full name / phone tiles
            for (var i = 0; i < 2; i++) ...[
              _TileSkeleton(metrics: m, colors: colors),
              if (i == 0) SizedBox(height: m.gapMd),
            ],
          ],
        ),
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton({required this.metrics, required this.colors});

  final EditProfileMetrics metrics;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad * 0.85),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: m.fieldHeight * 0.85,
            height: m.fieldHeight * 0.85,
            decoration: BoxDecoration(
              color: colors.surfaceAlt,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: m.cardPad * 0.7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Block(width: 30.0, height: m.fieldLabelSize, colors: colors),
                SizedBox(height: m.gapXs),
                _Block(width: 100.0, height: m.fieldTextSize, colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    required this.colors,
  });

  final double width;
  final double height;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
