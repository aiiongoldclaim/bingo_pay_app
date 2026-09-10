import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../cubit/payment_cubit.dart';
import 'review_pay_metrics.dart';
import 'review_pay_widgets.dart';

// ── Coupon + notes (Buy Now flow only) — logic unchanged ───────────────────
class ReviewCouponNotesCard extends StatefulWidget {
  final ReviewPayMetrics metrics;

  const ReviewCouponNotesCard({super.key, required this.metrics});

  @override
  State<ReviewCouponNotesCard> createState() => _ReviewCouponNotesCardState();
}

class _ReviewCouponNotesCardState extends State<ReviewCouponNotesCard> {
  final _couponController = TextEditingController();
  final _notesController = TextEditingController();
  bool _couponApplied = false;

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyCoupon(BuildContext context) {
    final code = _couponController.text.trim();
    context.read<PaymentMethodCubit>().updateCouponCode(code);
    setState(() => _couponApplied = code.isNotEmpty);
    if (code.isNotEmpty) {
      AppSnackbar.showSuccess(context, 'Coupon "$code" applied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = widget.metrics;

    return ReviewCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReviewSectionLabel(
            metrics: m,
            label: 'Coupon Code',
            icon: Icons.confirmation_number_outlined,
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              Expanded(
                child: ReviewField(
                  metrics: m,
                  controller: _couponController,
                  hint: 'Enter coupon code',
                  textCapitalization: TextCapitalization.characters,
                  suffix: _couponApplied
                      ? Icon(
                          Icons.check_circle,
                          size: m.fieldTextSize + 6,
                          color: colors.statusSuccess,
                        )
                      : null,
                  onChanged: (_) {
                    if (_couponApplied) setState(() => _couponApplied = false);
                  },
                ),
              ),

              SizedBox(width: m.gapSm),

              SizedBox(
                height: m.fieldHeight,
                child: Material(
                  color: colors.brandSoft,
                  borderRadius: BorderRadius.circular(m.fieldRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _applyCoupon(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: m.cardPad * 0.9,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Apply',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colors.brand,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.fieldTextSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapLg),

          ReviewSectionLabel(
            metrics: m,
            label: 'Delivery Notes (optional)',
            icon: Icons.sticky_note_2_outlined,
          ),

          SizedBox(height: m.gapMd),

          ReviewField(
            metrics: m,
            controller: _notesController,
            hint: 'e.g. Leave at the door',
            maxLines: 2,
            maxLength: 200,
            onChanged: (value) =>
                context.read<PaymentMethodCubit>().updateNotes(value.trim()),
          ),
        ],
      ),
    );
  }
}
