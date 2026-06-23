import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';

class SuccessActionBar extends StatelessWidget {
  final VoidCallback onInvoiceTap;
  final VoidCallback onTrackOrderTap;

  const SuccessActionBar({
    super.key,
    required this.onInvoiceTap,
    required this.onTrackOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onInvoiceTap,
              icon: const Icon(Icons.download),
              label: const Text('Invoice'),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onTrackOrderTap,
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('Track Order'),
            ),
          ),
        ],
      ),
    );
  }
}
