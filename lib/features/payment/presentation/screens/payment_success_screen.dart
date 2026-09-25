import 'package:bingo_pay/features/payment/presentation/screens/widgets/invoice_card.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_success_matrics.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/success_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/pdf_file_handler.dart';
import '../../../../core/utils/review_helper.dart';
import '../../../bookings/data/datasources/booking_remote_datasources.dart';
import '../../../orders/data/datasources/orders_remote_datasource.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import 'widgets/payment_success_action_bar.dart';
import 'widgets/payment_success_body.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    // Show in-app review dialog 2 seconds after successful payment
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ReviewHelper.showReviewDialog(
          context,
          title: 'Payment Successful! 🎉',
          subtitle: 'Help us improve by rating this app',
          positiveRatingMessage:
              'Thank you! Please share your positive experience on the Play Store.',
          negativeRatingMessage:
              'We appreciate your feedback. Let us know how we can improve.',
        );
      }
    });
  }

  Future<void> _downloadInvoice(PaymentMethodState state) async {
    if (state.orderUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice is not available for this order yet.')),
      );
      return;
    }

    setState(() => _generatingPdf = true);
    try {
      final List<int> bytes;
      final String filename;
      if (state.isServiceBooking) {
        final invoice = await GetIt.I<BookingRemoteDatasources>()
            .downloadInvoice(state.orderUuid);
        bytes = invoice.bytes;
        filename = invoice.filename;
      } else {
        final invoice = await GetIt.I<OrdersRemoteDataSource>()
            .downloadInvoice(state.orderUuid);
        bytes = invoice.bytes;
        filename = invoice.filename;
      }
      await openOrSharePdf(bytes, filename);
    } catch (e, st) {
      debugPrint('[Invoice] Download failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download invoice. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) {
        final m = PaymentSuccessMetrics.of(context);

        final header = SuccessHeader(
          orderId: state.orderId,
          amount: state.formattedTotal,
        );

        final card = InvoiceCard(
          orderId: state.orderId,
          totalAmount: state.formattedTotal,
          productName: state.productName,
          deliveryCharge: state.deliveryCharge.toString(),
          customerName:
          state.deliveryName.isNotEmpty ? state.deliveryName : 'Customer',
          customerAddress: state.deliveryAddress.isNotEmpty
              ? '${state.deliveryAddress}, ${state.deliveryCity} - ${state.deliveryPostal}'
              : '',
        );

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: colors.background,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.brandSoft,
                    colors.brandSoft.withValues(alpha: 0.45),
                    colors.background,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(maxWidth: m.maxContentWidth),
                          child: m.isLandscape
                              ? PaymentSuccessLandscapeBody(
                              metrics: m, header: header, card: card)
                              : PaymentSuccessPortraitBody(
                              metrics: m, header: header, card: card),
                        ),
                      ),
                    ),

                    PaymentSuccessActionBar(
                      metrics: m,
                      generating: _generatingPdf,
                      onDownload:
                      _generatingPdf ? null : () => _downloadInvoice(state),
                      onHome: () => context.go(AppRoutes.home),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
