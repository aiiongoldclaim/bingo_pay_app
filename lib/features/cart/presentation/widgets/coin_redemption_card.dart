import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class CoinRedemptionCard extends StatelessWidget {
  const CoinRedemptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ThemeColors.accent,
            child: Text(
              'B',
              style: TextStyle(
                color: ThemeColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Use 480 BINGOLD coins', style: AppTextStyles.titleMedium),
                Text(
                  'Save \$480 on this order',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),

          Switch(value: true, activeColor: ThemeColors.blue, onChanged: (_) {}),
        ],
      ),
    );
  }
}
