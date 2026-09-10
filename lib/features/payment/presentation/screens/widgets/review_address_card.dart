import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../address/domain/entities/address_entity.dart';
import '../../cubit/payment_cubit.dart';
import '../../cubit/payment_state.dart';
import 'review_pay_metrics.dart';
import 'review_pay_widgets.dart';

// ── Delivery address ───────────────────────────────────────────────────────
class ReviewAddressCard extends StatelessWidget {
  final ReviewPayMetrics metrics;
  final PaymentMethodState state;

  const ReviewAddressCard({super.key, required this.metrics, required this.state});

  Future<void> _openAddressList(
    BuildContext context,
    PaymentMethodState state,
  ) async {
    final paymentCubit = context.read<PaymentMethodCubit>();

    final picked = await context.push<AddressEntity>(
      AppRoutes.addressList,
      extra: state.deliveryAddressId,
    );

    if (picked == null) return;

    paymentCubit.updateDeliveryAddress(
      name: picked.fullName,
      phone: picked.phoneNumber,
      address: picked.addressLine1,
      city: picked.city,
      postal: picked.postalCode,
      addressId: picked.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    final fullAddress =
        '${state.deliveryAddress}, ${state.deliveryCity} - ${state.deliveryPostal}';

    return ReviewCard(
      metrics: m,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ReviewSectionLabel(
            metrics: m,
            label: 'Delivery Address',
            icon: Icons.location_on_outlined,
          ),

          SizedBox(height: m.gapMd),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.deliveryName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.addrNameSize,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      state.deliveryPhone,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.addrBodySize,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      fullAddress,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: m.addrBodySize,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: m.gapSm),

              SizedBox(
                height: m.changeBtnHeight,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openAddressList(context, state),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.brand, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Change',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: colors.brand,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: m.changeBtnFontSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
