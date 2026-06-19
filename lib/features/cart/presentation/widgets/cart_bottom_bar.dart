import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';

class CartBottomBar extends StatelessWidget {
  const CartBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: ThemeColors.surface,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Payable', style: AppTextStyles.bodyMedium),
                  Text('₹25,642', style: AppTextStyles.headlineMedium),
                ],
              ),
            ),

            Expanded(
              flex: 2,
              child: AppButton(label: 'Checkout', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}
