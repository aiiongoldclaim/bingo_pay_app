import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';

class SupportChatFab extends StatelessWidget {
  final VoidCallback onTap;

  const SupportChatFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: colors.brand,
      foregroundColor: colors.surface,
      icon: const Icon(Icons.support_agent_rounded),
      label: Text(
        'Chat',
        style: AppTextStyles.buttonText.copyWith(
          color: colors.surface,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
