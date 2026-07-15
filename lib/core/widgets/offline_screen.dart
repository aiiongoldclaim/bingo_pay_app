import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass/glass_card.dart';
import 'glass/mesh_background.dart';

/// Full-screen Liquid Glass page shown while the device is offline.
///
/// Rendered as an overlay above the whole app (see `App.build`), so the
/// screen underneath keeps its state and reappears untouched the moment
/// connectivity returns.
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFF9DB4FF) : AppColors.primary;

    return MeshBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              radius: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity:
                        Tween(begin: 0.55, end: 1.0).animate(CurvedAnimation(
                      parent: _pulse,
                      curve: Curves.easeInOut,
                    )),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.12),
                      ),
                      child: Icon(Icons.wifi_off_rounded,
                          size: 40, color: accent),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Internet Connection',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Please check your connection.\nWe'll bring you right back once you're online.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: colors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Waiting for connection…',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: colors.textSecondary),
                      ),
                    ],
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
