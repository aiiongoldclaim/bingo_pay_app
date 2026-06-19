import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class CouponCard extends StatelessWidget {
  const CouponCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.blue, style: BorderStyle.solid),
        color: ThemeColors.surface,
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, color: ThemeColors.blue),

          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FESTIVE10 applied',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: ThemeColors.blue,
                  ),
                ),
                Text('You saved ₹2,848', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),

          Icon(Icons.check, color: ThemeColors.green),
        ],
      ),
    );
  }
}
