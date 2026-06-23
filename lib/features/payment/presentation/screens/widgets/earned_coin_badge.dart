import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';

class EarnedCoinBadge extends StatelessWidget {
  final int coins;

  const EarnedCoinBadge({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 12, child: Text('B')),

          const SizedBox(width: 8),

          Text(
            '+$coins BINGOLD coins earned',
            style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
