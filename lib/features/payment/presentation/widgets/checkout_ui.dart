import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_formatter.dart';
import '../cubit/payment_state.dart';

// Shared pieces of the checkout screens: Checkout, Review & Pay, success.

String money(num value) => '\$${formatGroupedAmount(value)}';

TextStyle checkoutText(
  Color color, {
  double size = 14,
  FontWeight weight = FontWeight.w500,
}) => AppTextStyles.bodyMedium.copyWith(
  color: color,
  fontFamily: 'Inter',
  fontSize: size,
  fontWeight: weight,
);

// A titled group: a quiet label (and an optional action), then a card.
class CheckoutSection extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const CheckoutSection({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: checkoutText(
                    colors.textSecondary,
                    size: 13,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
              ?action,
            ],
          ),
        ),
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

// One line of an order summary; `total` makes it the bold last line.
class CheckoutLine extends StatelessWidget {
  final String label;
  final String value;
  final bool total;
  final Color? color;

  const CheckoutLine(
    this.label,
    this.value, {
    super.key,
    this.total = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: total
                  ? checkoutText(
                      colors.textPrimary,
                      size: 16,
                      weight: FontWeight.w700,
                    )
                  : checkoutText(colors.textSecondary),
            ),
          ),
          Text(
            value,
            style: total
                ? checkoutText(colors.brand, size: 18, weight: FontWeight.w800)
                : checkoutText(
                    color ?? colors.textPrimary,
                    weight: FontWeight.w600,
                  ),
          ),
        ],
      ),
    );
  }
}

// What is being bought: the buy-now line, or each cart item, with its price.
class CheckoutItems extends StatelessWidget {
  final PaymentMethodState state;

  const CheckoutItems({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final lines = state.isCartFlow
        ? [
            for (final i in state.cartItems)
              (i.product.title, i.quantity, i.totalPrice),
          ]
        : [(state.productName, state.quantity, state.productPriceValue)];

    return Column(
      children: [
        for (final (name, qty, price) in lines)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: name),
                        if (qty > 1)
                          TextSpan(
                            text: '  × $qty',
                            style: checkoutText(context.colors.textMuted),
                          ),
                      ],
                    ),
                    style: checkoutText(
                      context.colors.textPrimary,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  money(price),
                  style: checkoutText(
                    context.colors.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// The bottom bar: a secure-checkout note over the main button.
class CheckoutBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CheckoutBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 13,
                      color: colors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Secure checkout',
                      style: checkoutText(colors.textMuted, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: label,
                  isLoading: isLoading,
                  onPressed: onPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A centred column no wider than a phone, for tablets and landscape.
class CheckoutBody extends StatelessWidget {
  final List<Widget> children;

  const CheckoutBody({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
