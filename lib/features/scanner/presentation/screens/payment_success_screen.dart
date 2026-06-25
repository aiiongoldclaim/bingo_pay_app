import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';

class TransferScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransferScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final amount = data['amount'];
    final merchant = data['merchantName'];
    final reference = data['reference'];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: ThemeColors.green,
                size: 100,
              ),

              const SizedBox(height: 20),

              const Text(
                'Payment Successful',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 7.h),

              Text('Merchant: $merchant'),

              Text('Amount: \$ $amount'),

              Text('Reference: $reference'),

              SizedBox(height: 5.h),

              AppButton(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                label: 'Done',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
