// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/widgets/app_button.dart';
//
// class TransferScreen extends StatelessWidget {
//   final Map<String, dynamic> data;
//
//   const TransferScreen({super.key, required this.data});
//
//   @override
//   Widget build(BuildContext context) {
//     final amount = data['amount'];
//     final merchant = data['merchantName'];
//     final reference = data['reference'];
//
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.check_circle,
//                 color: ThemeColors.green,
//                 size: 100,
//               ),
//
//               const SizedBox(height: 20),
//
//               const Text(
//                 'Payment Successful',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//
//               SizedBox(height: 7.h),
//
//               Text('Merchant: $merchant'),
//
//               Text('Amount: \$$amount'),
//
//               Text('Reference: $reference'),
//
//               SizedBox(height: 5.h),
//
//               AppButton(
//                 onPressed: () {
//                   context.go(AppRoutes.home);
//                 },
//                 label: 'Done',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/transfer_success_metrics.dart';


class TransferScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const TransferScreen({super.key, required this.data});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _scale = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _amount => '${widget.data['amount'] ?? 0}';
  String get _merchant => '${widget.data['merchantName'] ?? '-'}';
  String get _reference => '${widget.data['reference'] ?? '-'}';

  String get _dateLabel {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour < 12 ? 'AM' : 'PM';
    return '${now.day} ${months[now.month - 1]} ${now.year}, $h:$min $ampm';
  }

  void _copyReference() {
    Clipboard.setData(ClipboardData(text: _reference));
    AppSnackbar.showSuccess(context, 'Reference ID copied');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final m = TransferSuccessMetrics.of(context);

              final hero = _SuccessHero(
                metrics: m,
                scale: _scale,
                amount: _amount,
              );

              final details = _DetailsCard(
                metrics: m,
                merchant: _merchant,
                reference: _reference,
                date: _dateLabel,
                onCopy: _copyReference,
              );

              final actions = _Actions(metrics: m);

              return Column(
                children: [
                  _SuccessTopBar(metrics: m),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.maxContentWidth,
                        ),
                        child: m.isLandscape
                            ? Padding(
                          padding: EdgeInsets.fromLTRB(
                            m.pageHPad,
                            m.gapMd,
                            m.pageHPad,
                            m.gapLg,
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            children: [
                              Expanded(child: hero),
                              SizedBox(width: m.gapLg),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      details,
                                      SizedBox(height: m.gapLg),
                                      actions,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                            : SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            m.pageHPad,
                            m.gapLg,
                            m.pageHPad,
                            m.gapLg,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.stretch,
                            children: [
                              hero,
                              SizedBox(height: m.gapLg),
                              details,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (!m.isLandscape)
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        m.pageHPad,
                        m.gapSm,
                        m.pageHPad,
                        m.gapSm * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.background,
                        border: Border(
                          top: BorderSide(color: colors.border, width: 1),
                        ),
                      ),
                      child: SafeArea(top: false, child: actions),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _SuccessTopBar extends StatelessWidget {
  final TransferSuccessMetrics metrics;

  const _SuccessTopBar({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: m.pageHPad,
        vertical: m.pageVPad,
      ),
      child: Center(
        child: Text(
          'TheVaults',
          style: AppTextStyles.titleLarge.copyWith(
            color: colors.brand,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w600,
            fontSize: m.logoSize,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

// ── Hero: tick + amount ────────────────────────────────────────────────────
class _SuccessHero extends StatelessWidget {
  final TransferSuccessMetrics metrics;
  final Animation<double> scale;
  final String amount;

  const _SuccessHero({
    required this.metrics,
    required this.scale,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: scale,
          child: Container(
            width: m.tickOuter,
            height: m.tickOuter,
            decoration: BoxDecoration(
              color: colors.statusSuccessSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: m.tickInner,
              height: m.tickInner,
              decoration: BoxDecoration(
                color: colors.statusSuccess,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check_rounded,
                size: m.tickIconSize,
                color: colors.surface,
              ),
            ),
          ),
        ),

        SizedBox(height: m.gapLg),

        Text(
          'Payment Successful',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleLarge.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.titleSize,
            height: 1.25,
          ),
        ),

        SizedBox(height: m.gapSm),

        Text(
          'Your transfer has been completed',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.subtitleSize,
            height: 1.4,
          ),
        ),

        SizedBox(height: m.gapLg),

        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '\$$amount',
            style: AppTextStyles.displayLarge.copyWith(
              color: colors.brand,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: m.amountSize,
              height: 1.1,
            ),
          ),
        ),

        SizedBox(height: m.gapXs),

        Text(
          'Amount paid',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.amountSubSize,
          ),
        ),
      ],
    );
  }
}

// ── Details ────────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final TransferSuccessMetrics metrics;
  final String merchant;
  final String reference;
  final String date;
  final VoidCallback onCopy;

  const _DetailsCard({
    required this.metrics,
    required this.merchant,
    required this.reference,
    required this.date,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row(metrics: m, label: 'Paid to', value: merchant),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapMd * 0.7),
            child: Divider(height: 1, thickness: 1, color: colors.border),
          ),

          _Row(metrics: m, label: 'Date & Time', value: date),

          Padding(
            padding: EdgeInsets.symmetric(vertical: m.gapMd * 0.7),
            child: Divider(height: 1, thickness: 1, color: colors.border),
          ),

          _Row(
            metrics: m,
            label: 'Reference ID',
            value: reference,
            onCopy: onCopy,
          ),

          SizedBox(height: m.gapMd),

          Container(
            padding: EdgeInsets.all(m.cardPad * 0.7),
            decoration: BoxDecoration(
              color: colors.statusSuccessSoft,
              borderRadius: BorderRadius.circular(m.cardRadius * 0.7),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: m.rowLabelSize + 5,
                  color: colors.statusSuccess,
                ),
                SizedBox(width: m.gapSm),
                Expanded(
                  child: Text(
                    'Transaction completed securely',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.statusSuccess,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: m.rowLabelSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final TransferSuccessMetrics metrics;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _Row({
    required this.metrics,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.rowLabelSize,
          ),
        ),

        SizedBox(width: m.gapMd),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLarge.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: m.rowValueSize,
              height: 1.35,
            ),
          ),
        ),

        if (onCopy != null) ...[
          SizedBox(width: m.gapXs * 1.4),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: EdgeInsets.all(m.gapXs * 0.8),
              child: Icon(
                Icons.copy_rounded,
                size: m.copyIconSize,
                color: colors.brand,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Actions ────────────────────────────────────────────────────────────────
class _Actions extends StatelessWidget {
  final TransferSuccessMetrics metrics;

  const _Actions({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: m.btnHeight,
          child: Material(
            color: colors.brand,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.go(AppRoutes.home),
              child: Center(
                child: Text(
                  'DONE',
                  style: AppTextStyles.buttonText.copyWith(
                    color: colors.surface,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.btnFontSize,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: m.gapSm),

        SizedBox(
          height: m.btnHeight,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.go(AppRoutes.buyerTransactions),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.brand.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: m.btnFontSize + 4,
                      color: colors.brand,
                    ),
                    SizedBox(width: m.gapSm * 0.8),
                    Text(
                      'VIEW TRANSACTIONS',
                      style: AppTextStyles.buttonText.copyWith(
                        color: colors.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.btnFontSize,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}