// import 'package:flutter/material.dart';
//
// import '../../../../../core/constants/app_sizes.dart';
// import '../../../../../core/theme/app_text_styles.dart';
// import '../../../../../core/theme/theme_colors.dart';
// import 'invoice_item_tile.dart';
//
// class InvoiceCard extends StatelessWidget {
//   const InvoiceCard({
//     super.key,
//     required this.orderId,
//     required this.totalAmount,
//     required this.customerName,
//     required this.customerAddress,
//     this.productName = '',
//     this.deliveryCharge = 0.0,
//   });
//
//   final String orderId;
//   final String totalAmount;
//   final String productName;
//   final String customerName;
//   final String customerAddress;
//   final double deliveryCharge;
//
//   static String _month(int m) {
//     const months = [
//       'Jan','Feb','Mar','Apr','May','Jun',
//       'Jul','Aug','Sep','Oct','Nov','Dec'
//     ];
//     return months[m - 1];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final dateStr = '${now.day} ${_month(now.month)} ${now.year}';
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
//       decoration: BoxDecoration(
//         color: ThemeColors.white,
//         borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
//         boxShadow: [
//           BoxShadow(
//             color: ThemeColors.deepPurple.withValues(alpha: 0.18),
//             blurRadius: 32,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── Gradient header ─────────────────────────────────────────
//           Container(
//             padding: const EdgeInsets.all(AppSizes.paddingMd),
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF4C1E76), Color(0xFF3F185F)],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.vertical(
//                   top: Radius.circular(AppSizes.radius2Xl)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   height: 46,
//                   width: 46,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withValues(alpha: 0.18),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(Icons.store_rounded,
//                       color: Colors.white, size: 24),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Bingold Pay',
//                         style: AppTextStyles.titleMedium
//                             .copyWith(color: Colors.white),
//                       ),
//                           Text(
//                             'Invoice INV-${orderId.replaceAll('BG-', '')}',
//                             style: AppTextStyles.labelLarge
//                                 .copyWith(color: Colors.white),
//                           ),
//
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Tax Invoice',
//                             style: AppTextStyles.bodyMedium.copyWith(
//                                 color: Colors.white.withValues(alpha: 0.75)),
//                           ),
//
//                               Text(
//                                 dateStr,
//                                 style: AppTextStyles.bodyMedium.copyWith(
//                                     color: Colors.white.withValues(alpha: 0.75)),
//                               ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // ── Billed To ───────────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.all(AppSizes.paddingMd),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1A1D4E).withValues(alpha: 0.07),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: const Icon(Icons.location_on_outlined,
//                       size: 18, color: ThemeColors.black),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('BILLED TO',
//                           style: AppTextStyles.labelMedium
//                               .copyWith(color: ThemeColors.black)),
//                       const SizedBox(height: 4),
//                       Text(customerName,
//                           style: AppTextStyles.titleMedium),
//                       if (customerAddress.isNotEmpty) ...[
//                         const SizedBox(height: 2),
//                         Text(customerAddress,
//                             style: AppTextStyles.bodyMedium
//                                 .copyWith(color: ThemeColors.inkMid)),
//                       ],
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
//             child: Divider(height: 1, color: ThemeColors.inkMid.withValues(alpha: 0.25)),
//           ),
//
//           // ── Item ────────────────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingX),
//             child: InvoiceItemTile(
//               title: productName.isNotEmpty ? productName : 'Product',
//               subtitle: 'Qty 1 • incl. GST',
//               price: totalAmount,
//             ),
//           ),
//
//           // ── Summary ─────────────────────────────────────────────────
//           Padding(
//             // padding: const EdgeInsets.all(AppSizes.paddingX),
//             padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd, vertical: AppSizes.paddingSm),
//             child: Column(
//               children: [
//                 if (deliveryCharge > 0) ...[
//                   _summaryRow(
//                     'Delivery',
//                     '\$${deliveryCharge.toStringAsFixed(0)}',
//                     color: ThemeColors.green,
//                   ),
//                   const SizedBox(height: 8),
//                 ],
//                 Divider(
//                     height: 1,
//                     color: ThemeColors.inkMid.withValues(alpha: 0.25)),
//                 _summaryRow('Amount paid', totalAmount, isBold: true),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _summaryRow(
//     String title,
//     String value, {
//     Color? color,
//     bool isBold = false,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: isBold
//               ? AppTextStyles.titleMedium
//               : AppTextStyles.bodyMedium
//                   .copyWith(color: ThemeColors.inkMid),
//         ),
//         Text(
//           value,
//           style: isBold
//               ? AppTextStyles.titleLarge.copyWith(
//                   color: ThemeColors.green,
//                   fontWeight: FontWeight.w800,
//                 )
//               : AppTextStyles.bodyMedium.copyWith(color: color),
//         ),
//       ],
//     );
//   }
// }
import 'package:bingo_pay/features/payment/presentation/screens/widgets/payment_success_matrics.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';


class InvoiceCard extends StatelessWidget {
  final String orderId;
  final String totalAmount;
  final String productName;
  final String deliveryCharge;
  final String customerName;
  final String customerAddress;

  const InvoiceCard({
    super.key,
    required this.orderId,
    required this.totalAmount,
    required this.productName,
    required this.deliveryCharge,
    required this.customerName,
    required this.customerAddress,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _today {
    final now = DateTime.now();
    return '${now.day} ${_months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = PaymentSuccessMetrics.of(context);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: c.isDark ? 0.24 : 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(metrics: m, orderId: orderId, date: _today),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: m.bodyPad,
              vertical: m.bodyPad * 0.9,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoRow(
                  metrics: m,
                  icon: Icons.location_on_outlined,
                  label: 'BILLED TO',
                  title: customerName,
                  subtitle: customerAddress,
                ),

                _Sep(metrics: m),

                _InfoRow(
                  metrics: m,
                  icon: Icons.shopping_bag_outlined,
                  title: productName,
                  subtitle: 'Qty 1 • incl. GST',
                  trailing: totalAmount,
                ),

                if (deliveryCharge.isNotEmpty) ...[
                  _Sep(metrics: m),
                  _InfoRow(
                    metrics: m,
                    icon: Icons.local_shipping_outlined,
                    title: 'Delivery',
                    trailing: "Free",
                  ),
                ],

                _Sep(metrics: m),

                _PaidRow(metrics: m, amount: totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final String orderId;
  final String date;

  const _Header({
    required this.metrics,
    required this.orderId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.headerPad),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.brand, c.brand.withValues(alpha: 0.86)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: m.merchantAvatar,
                height: m.merchantAvatar,
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.storefront_outlined,
                  size: m.merchantIconSize,
                  color: c.surface,
                ),
              ),

              SizedBox(width: m.headerPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bingold Pay',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: m.merchantNameSize,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.8),
                    Text(
                      orderId.isEmpty ? 'Invoice' : 'Invoice INV-$orderId',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.invoiceNoSize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd * 0.9),

          Row(
            children: [
              Text(
                'Tax Invoice',
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.surface.withValues(alpha: 0.82),
                  fontFamily: 'Inter',
                  fontSize: m.metaSize,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                size: m.metaSize + 3,
                color: c.surface.withValues(alpha: 0.82),
              ),
              SizedBox(width: m.gapXs * 1.2),
              Text(
                date,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.surface.withValues(alpha: 0.92),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: m.metaSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final IconData icon;
  final String? label;
  final String title;
  final String? subtitle;
  final String? trailing;

  const _InfoRow({
    required this.metrics,
    required this.icon,
    required this.title,
    this.label,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: m.rowIconBox,
          height: m.rowIconBox,
          decoration: BoxDecoration(
            color: c.brandSoft,
            borderRadius: BorderRadius.circular(m.rowIconRadius),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: m.rowIconSize, color: c.brand),
        ),

        SizedBox(width: m.bodyPad * 0.7),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.rowLabelSize,
                    letterSpacing: 0.8,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.7),
              ],

              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.rowTitleSize,
                  height: 1.3,
                ),
              ),

              if (subtitle != null && subtitle!.isNotEmpty) ...[
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  subtitle!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.rowSubSize,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),

        if (trailing != null) ...[
          SizedBox(width: m.gapSm),
          Padding(
            padding: EdgeInsets.only(top: m.gapXs * 0.6),
            child: Text(
              trailing!,
              style: AppTextStyles.titleMedium.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: m.rowAmountSize,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PaidRow extends StatelessWidget {
  final PaymentSuccessMetrics metrics;
  final String amount;

  const _PaidRow({required this.metrics, required this.amount});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      children: [
        Container(
          width: m.rowIconBox,
          height: m.rowIconBox,
          decoration: BoxDecoration(
            color: c.brandSoft,
            borderRadius: BorderRadius.circular(m.rowIconRadius),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.account_balance_wallet_outlined,
            size: m.rowIconSize,
            color: c.brand,
          ),
        ),

        SizedBox(width: m.bodyPad * 0.7),

        Expanded(
          child: Text(
            'Amount Paid',
            style: AppTextStyles.labelLarge.copyWith(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.rowTitleSize,
            ),
          ),
        ),

        Text(
          amount,
          style: AppTextStyles.titleLarge.copyWith(
            color: c.success,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: m.paidAmountSize,
          ),
        ),
      ],
    );
  }
}

class _Sep extends StatelessWidget {
  final PaymentSuccessMetrics metrics;

  const _Sep({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: metrics.bodyPad * 0.75),
      child: Divider(height: 1, thickness: 1, color: c.border),
    );
  }
}