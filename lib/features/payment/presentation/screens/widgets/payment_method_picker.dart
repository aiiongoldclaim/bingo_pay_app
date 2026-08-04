import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../cubit/payment_cubit.dart';
import '../../cubit/payment_state.dart';

Future<void> showPaymentMethodPicker(
  BuildContext context,
  PaymentMethod selected,
) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _PaymentMethodSheet(
      selected: selected,
      onSelect: (method) {
        Navigator.pop(sheetContext);
        context.read<PaymentMethodCubit>().selectPaymentMethod(method);
      },
    ),
  );
}

class _PaymentMethodSheet extends StatelessWidget {
  final PaymentMethod selected;
  final void Function(PaymentMethod) onSelect;

  const _PaymentMethodSheet({required this.selected, required this.onSelect});

  static const _options = [
    (PaymentMethod.wallet, Icons.account_balance_wallet_outlined, 'Bingold Wallet'),
    (PaymentMethod.cashOnDelivery, Icons.payments_outlined, 'Cash on Delivery'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment method', style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          ..._options.map(
            (opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(opt.$2, color: ThemeColors.blue),
              title: Text(opt.$3, style: AppTextStyles.bodyMedium),
              trailing: selected == opt.$1
                  ? const Icon(Icons.check, color: ThemeColors.blue)
                  : null,
              onTap: () => onSelect(opt.$1),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
