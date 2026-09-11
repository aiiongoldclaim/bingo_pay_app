import 'package:flutter/material.dart';

import '../../../../address/domain/entities/address_entity.dart';
import '../../cubit/payment_state.dart';
import 'payment_address_section.dart';
import 'payment_metrics.dart';
import 'payment_progress_stepper.dart';
import 'payment_wallet_card.dart';

// ── Portrait ───────────────────────────────────────────────────────────────
class PaymentPortraitBody extends StatelessWidget {
  final PaymentMetrics metrics;
  final PaymentMethodState state;
  final bool submitted;
  final String? selectedAddressId;
  final AddressEntity? selectedAddress;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;
  final Widget summary;

  const PaymentPortraitBody({
    super.key,
    required this.metrics,
    required this.state,
    required this.submitted,
    required this.selectedAddressId,
    required this.selectedAddress,
    required this.onSelect,
    required this.onDeleted,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, m.gapLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PaymentProgressStepper(currentStep: 3),
          SizedBox(height: m.gapLg),
          PaymentAddressSection(
            metrics: m,
            selectedAddressId: selectedAddressId,
            onSelect: onSelect,
            onDeleted: onDeleted,
            showError: submitted && selectedAddress == null,
          ),
          SizedBox(height: m.gapMd),
          PaymentWalletCard(state: state, metrics: m),
          SizedBox(height: m.gapMd),
          summary,
        ],
      ),
    );
  }
}

// ── Landscape: address+wallet left, summary rail right ─────────────────────
class PaymentLandscapeBody extends StatelessWidget {
  final PaymentMetrics metrics;
  final PaymentMethodState state;
  final bool submitted;
  final String? selectedAddressId;
  final AddressEntity? selectedAddress;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;
  final Widget summary;
  final Widget continueBar;

  const PaymentLandscapeBody({
    super.key,
    required this.metrics,
    required this.state,
    required this.submitted,
    required this.selectedAddressId,
    required this.selectedAddress,
    required this.onSelect,
    required this.onDeleted,
    required this.summary,
    required this.continueBar,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PaymentProgressStepper(currentStep: 3),
                  SizedBox(height: m.gapLg),
                  PaymentAddressSection(
                    metrics: m,
                    selectedAddressId: selectedAddressId,
                    onSelect: onSelect,
                    onDeleted: onDeleted,
                    showError: submitted && selectedAddress == null,
                  ),
                  SizedBox(height: m.gapMd),
                  PaymentWalletCard(state: state, metrics: m),
                ],
              ),
            ),
          ),

          SizedBox(width: m.gapLg),

          SizedBox(
            width: m.railWidth,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: m.gapSm, bottom: m.gapLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  summary,
                  SizedBox(height: m.gapMd),
                  continueBar,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
