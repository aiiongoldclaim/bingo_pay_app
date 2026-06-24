import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/di/injection.dart';

import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class ReviewPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String qrCode;

  const ReviewPaymentScreen({
    super.key,
    required this.data,
    required this.qrCode,
  });

  @override
  State<ReviewPaymentScreen> createState() => _ReviewPaymentScreenState();
}

class _ReviewPaymentScreenState extends State<ReviewPaymentScreen> {
  // @override
  // void initState() {
  //   super.initState();
  //
  //   context.read<PaymentCubit>().getMerchantDetails(widget.qrCode);
  // }

  @override
  Widget build(BuildContext context) {
    final merchantName = widget.data['merchantName'];
    final merchantEmail = widget.data['merchantEmail'];
    final amount = widget.data['amount'];
    final reference = widget.data['reference'];

    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          // context.push(
          //   AppRoutes.paymentSuccess,
          //   extra: {
          //     'amount': amount,
          //     'merchantName': merchantName,
          //     'reference': reference,
          //   },
          // );
        }

        if (state is PaymentFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Review Payment')),
        body: Padding(
          padding: EdgeInsets.all(5.w),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      _row('Merchant', merchantName),
                      _row('Email', merchantEmail),
                      _row('Amount', '\$ $amount'),
                      _row('Reference', reference),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  final loading = state is PaymentLoading;

                  return AppButton(
                    label: loading ? 'Processing...' : 'Pay Now',
                    onPressed: loading
                        ? null
                        : () async {
                            final customerEmail =
                                await getIt<SecureStorageService>().getEmail();

                            if (customerEmail == null) {
                              return;
                            }

                            context.read<PaymentCubit>().pay(
                              customerEmail: customerEmail,
                              merchantEmail: merchantEmail,
                              amount: amount,
                              reference: reference,
                            );
                          },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value ?? '_'),
        ],
      ),
    );
  }
}
