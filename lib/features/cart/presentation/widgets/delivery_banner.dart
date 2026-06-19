import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
class FreeDeliveryBanner extends StatelessWidget {
  const FreeDeliveryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.greenSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: ThemeColors.green),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "You've unlocked free delivery on this order",
              style: AppTextStyles.labelLarge.copyWith(
                color: ThemeColors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
