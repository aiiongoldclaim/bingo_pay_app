import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const PaymentSuccessScreen({super.key, required this.data});

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
              const Icon(Icons.check_circle, color: Colors.green, size: 100),

              const SizedBox(height: 20),

              const Text(
                'Payment Successful',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Text('Merchant: $merchant'),

              Text('Amount: \$ $amount'),

              Text('Reference: $reference'),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.home);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
