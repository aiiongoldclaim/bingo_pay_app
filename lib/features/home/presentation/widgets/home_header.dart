import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import 'home_metrics.dart';
import '../models/vault_section.dart';
import 'vault_experience_selector.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.metrics,
    required this.selectedSection,
    this.onSectionChanged,
  });

  final HomeMetrics metrics;
  final VaultSection selectedSection;
  final ValueChanged<VaultSection>? onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return VaultExperienceSelector(
      metrics: metrics,
      selectedSection: selectedSection,
      onSectionChanged: onSectionChanged,
    );
  }
}


class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
    this.onTap,
    this.badgeCount = 0,
    this.badgeColor,
  });

  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;
  final int badgeCount;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: size, color: color),
          if (badgeCount > 0)
            Positioned(
              top: -size * 0.28,
              right: -size * 0.28,
              child: Container(
                width: size * 0.62,
                height: size * 0.62,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  AppStrings.cartBadgeCount(badgeCount),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
