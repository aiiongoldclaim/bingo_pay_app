import 'package:bingo_pay/features/payment/presentation/screens/widgets/invoice_card.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_success_matrics.dart';
import 'package:bingo_pay/features/payment/presentation/screens/widgets/success_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/pdf_file_handler.dart';
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
    final c = context.c;

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
            backgroundColor: c.background,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    c.brandSoft,
                    c.brandSoft.withValues(alpha: 0.45),
                    c.background,
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
                              ? _LandscapeBody(
                              metrics: m, header: header, card: card)
                              : _PortraitBody(
                              metrics: m, header: header, card: card),
                        ),
                      ),
                    ),

                    _SuccessActionBar(
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

// ── Portrait ───────────────────────────────────────────────────────────────
class _PortraitBody extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final Widget header;
  final Widget card;

  const _PortraitBody({
    required this.metrics,
    required this.header,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.pageVPad, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          SizedBox(height: m.gapLg),
          card,
        ],
      ),
    );
  }
}

// ── Landscape: hero left, invoice rail right ───────────────────────────────
class _LandscapeBody extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final Widget header;
  final Widget card;

  const _LandscapeBody({
    required this.metrics,
    required this.header,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.pageVPad, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: header,
            ),
          ),
          SizedBox(width: m.gapLg),
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom actions ─────────────────────────────────────────────────────────
class _SuccessActionBar extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final bool generating;
  final VoidCallback? onDownload;
  final VoidCallback onHome;

  const _SuccessActionBar({
    required this.metrics,
    required this.generating,
    required this.onDownload,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(m.cardRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: c.isDark ? 0.28 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: m.barHPad,
            vertical: m.barVPad,
          ),
          child: Row(
            children: [
              Expanded(
                child: _BarButton(
                  metrics: m,
                  label: generating ? 'Generating…' : 'Download Invoice',
                  icon: generating
                      ? Icons.hourglass_top_outlined
                      : Icons.download_outlined,
                  filled: false,
                  onTap: onDownload,
                ),
              ),
              SizedBox(width: m.gapSm * 1.2),
              Expanded(
                child: _BarButton(
                  metrics: m,
                  label: 'Go to Home',
                  icon: Icons.home_outlined,
                  filled: true,
                  onTap: onHome,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  const _BarButton({
    required this.metrics,
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    final fg = filled ? c.surface : c.brand;

    return SizedBox(
      height: m.btnHeight,
      child: Material(
        color: filled ? c.brand : c.surface,
        borderRadius: BorderRadius.circular(m.btnRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: onTap == null ? 0.6 : 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(m.btnRadius),
                border: filled
                    ? null
                    : Border.all(color: c.brand, width: 1.4),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: m.btnIconSize, color: fg),
                  SizedBox(width: m.gapSm * 0.7),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.buttonText.copyWith(
                        color: fg,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.btnFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}