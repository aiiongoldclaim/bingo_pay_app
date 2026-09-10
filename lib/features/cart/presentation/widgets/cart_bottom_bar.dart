import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../payment/presentation/screens/payment_args.dart';

import '../../domain/entities/cart_item_entity.dart';
import 'cart_metrics.dart';

class CartBottomBar extends StatelessWidget {
  final List<CartItemEntity> items;
  final double total;
  final int itemCount;

  const CartBottomBar({
    super.key,
    required this.items,
    required this.total,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = CartMetrics.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapSm,
        m.pageHPad,
        m.gapSm * 0.5,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: CartPayButton(items: items, total: total, itemCount: itemCount),
      ),
    );
  }
}


class CartPayButton extends StatelessWidget {
  final List<CartItemEntity> items;
  final double total;
  final int itemCount;

  const CartPayButton({
    super.key,
    required this.items,
    required this.total,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = CartMetrics.of(context);

    final totalStr = '\$${total.toStringAsFixed(2)}';
    final isEnabled = items.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: AppStrings.proceedToPay(totalStr),
          height: m.payHeight,
          fontSize: m.payFontSize,
          onPressed: isEnabled
              ? () => context.push(
                  AppRoutes.payment,
                  extra: PaymentArgs(
                    vendorEmail: null,
                    productName: 'Cart ($itemCount items)',
                    productPrice: 0.0,
                    variantUuid: null,
                    quantity: 1,
                    cartItems: items,
                    isCart: true,
                  ),
                )
              : null,
        ),

        SizedBox(height: m.gapSm * 0.7),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: m.payNoteSize + 3,
              color: colors.textMuted,
            ),
            SizedBox(width: m.gapXs),
            Flexible(
              child: Text(
                AppStrings.securePaymentsNote,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textMuted,
                  fontFamily: 'Inter',
                  fontSize: m.payNoteSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
