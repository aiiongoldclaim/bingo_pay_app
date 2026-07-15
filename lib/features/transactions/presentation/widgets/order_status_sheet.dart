import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/order_mock_data.dart';

Future<OrderStatus?> showOrderStatusSheet(BuildContext context, {required OrderStatus current}) {
  return showModalBottomSheet<OrderStatus>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Update order status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            for (final status in OrderStatus.values)
              ListTile(
                title: Text(status.label),
                trailing: status == current ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () => Navigator.of(context).pop(status),
              ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
