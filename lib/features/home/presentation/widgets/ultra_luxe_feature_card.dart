import 'package:flutter/material.dart';

import '../models/vault_theme_colors.dart';
import 'home_metrics.dart';

class UltraLuxeFeatureCard extends StatelessWidget {
  const UltraLuxeFeatureCard({
    super.key,
    required this.metrics,
    required this.activeTheme,
    required this.title,
    required this.subtitle,
    this.icon = Icons.workspace_premium_rounded,
    this.onTap,
  });

  final HomeMetrics metrics;
  final VaultThemeColors activeTheme;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gold = activeTheme.primary;
    final radius = metrics.heroRadius * 1.1;
    final pad = metrics.pagePadding;
    final iconBox = metrics.headerIconSize * 1.9;
    final btnBox = metrics.headerIconSize * 1.7;
    final gap = metrics.pagePadding * 0.6;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [activeTheme.pageBackground, activeTheme.headerGradientMiddle],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: activeTheme.secondary, width: 1.2),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -iconBox * 1.2,
                right: -iconBox * 0.8,
                child: IgnorePointer(
                  child: Container(
                    width: iconBox * 3.4,
                    height: iconBox * 3.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          gold.withValues(alpha: 0.16),
                          gold.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -iconBox * 1.6,
                left: -iconBox * 0.6,
                child: IgnorePointer(
                  child: Container(
                    width: iconBox * 3.0,
                    height: iconBox * 3.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          gold.withValues(alpha: 0.10),
                          gold.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: pad,
                  vertical: pad * 0.85,
                ),
                child: Row(
                  children: [
                    Container(
                      width: iconBox,
                      height: iconBox,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: gold.withValues(alpha: 0.14),
                        border: Border.all(
                          color: gold.withValues(alpha: 0.55),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: gold,
                        size: iconBox * 0.55,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: gold,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              fontSize: metrics.sectionTitleSize * 0.9,
                            ),
                          ),
                          SizedBox(height: metrics.pagePadding * 0.2),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: activeTheme.text,
                              fontSize: metrics.heroBodySize * 0.92,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: gap * 0.6),
                    Container(
                      width: btnBox,
                      height: btnBox,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeTheme.button,
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: activeTheme.buttonText,
                        size: btnBox * 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
