// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../../../payment/presentation/screens/payment_screen.dart';
// import '../cubit/cart_cubit.dart';
// import '../cubit/cart_state.dart';
//
// class CartBottomBar extends StatelessWidget {
//   const CartBottomBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<CartCubit, CartState>(
//       builder: (context, state) {
//         final totalStr = '\$${state.totalAmount.toStringAsFixed(0)}';
//         // final totalStr = '\$${500}';
//
//         return Container(
//           padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.08),
//                 blurRadius: 16,
//                 offset: const Offset(0, -3),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             top: false,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Payable',
//                           style: AppTextStyles.bodyMedium
//                               .copyWith(color: ThemeColors.inkMid)),
//                       Text(totalStr,
//                           style: AppTextStyles.headlineMedium
//                               .copyWith(color: const Color(0xFF1A1D4E))),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: AppButton(
//                     label: 'Checkout',
//                     onPressed: state.items.isEmpty
//                         ? null
//                         : () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => PaymentScreen(
//                                   cartItems: state.items,
//                                   isCart: true,
//                                   productName:
//                                       'Cart (${state.totalItems} items)',
//                                 ),
//                               ),
//                             ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../payment/presentation/screens/payment_screen.dart';

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
    final c = context.c;
    final m = CartMetrics.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapSm,
        m.pageHPad,
        m.gapSm * 0.5,
      ),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: CartPayButton(items: items, total: total, itemCount: itemCount),
      ),
    );
  }
}

/// Portrait bottom bar + landscape right rail — dono me reuse
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
    final c = context.c;
    final m = CartMetrics.of(context);

    final totalStr = '\$${total.toStringAsFixed(2)}';
    final isEnabled = items.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: m.payHeight,
          child: Material(
            color: isEnabled ? c.brand : c.border,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: isEnabled
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(
                          cartItems: items,
                          isCart: true,
                          productName: 'Cart ($itemCount items)',
                        ),
                      ),
                    )
                  : null,
              child: Center(
                child: Text(
                  'PROCEED TO PAY  •  $totalStr',
                  style: AppTextStyles.buttonText.copyWith(
                    color: isEnabled ? c.surface : c.textMuted,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.payFontSize,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: m.gapSm * 0.7),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: m.payNoteSize + 3,
              color: c.textMuted,
            ),
            SizedBox(width: m.gapXs),
            Flexible(
              child: Text(
                'Secure Payments. Easy Returns. 100% Authentic.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textMuted,
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
