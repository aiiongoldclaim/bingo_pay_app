import 'package:bingo_pay/features/payment/presentation/screens/widgets/invoice_card.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/success_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/pdf_file_handler.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../orders/data/datasources/orders_remote_datasource.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _generatingPdf = false;

  Future<void> _downloadInvoice(PaymentMethodState state) async {
    if (state.orderUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice is not available for this order yet.')),
      );
      return;
    }

    setState(() => _generatingPdf = true);
    try {
      final invoice = await GetIt.I<OrdersRemoteDataSource>()
          .downloadInvoice(state.orderUuid);
      await openOrSharePdf(invoice.bytes, invoice.filename);
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
    return BlocBuilder<PaymentMethodCubit, PaymentMethodState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            // backgroundColor: const Color(0xFF1A1D4E),
            backgroundColor: const Color(0xFF2B2FA8),
            bottomNavigationBar: AppBottomActionBar(
              primaryLabel: 'Go to Home',
              secondaryLabel: _generatingPdf ? 'Generating…' : 'Invoice',
              secondaryIcon: _generatingPdf
                  ? Icons.hourglass_top_outlined
                  : Icons.download_outlined,
              secondaryIconColor: ThemeColors.black,
              secondaryTextColor: ThemeColors.black,
              onPrimaryPressed: () => context.go(AppRoutes.home),
              onSecondaryPressed:
                  _generatingPdf ? () {} : () => _downloadInvoice(state),
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SuccessHeader(
                        orderId: state.orderId,
                        amount: state.formattedTotal,
                      ),
                      InvoiceCard(
                        orderId: state.orderId,
                        totalAmount: state.formattedTotal,
                        productName: state.productName,
                        deliveryCharge: state.deliveryCharge,
                        customerName: state.deliveryName.isNotEmpty
                            ? state.deliveryName
                            : 'Customer',
                        customerAddress: state.deliveryAddress.isNotEmpty
                            ? '${state.deliveryAddress}, ${state.deliveryCity} - ${state.deliveryPostal}'
                            : '',
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
