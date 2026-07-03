import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_info_card.dart';
import '../widgets/order_status.dart';
import '../widgets/order_tacking.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDetailCubit>()..loadOrder(order),
      child: _OrderDetailView(order: order),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final OrderModel order;

  const _OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: CustomAppBar(title: 'Order ${order.orderNumber}'),

      body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading || state is OrderDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeColors.blue),
            );
          }
          if (state is OrderDetailLoaded) {
            return _buildBody(context, state.order, state.addressText);
          }
          return const SizedBox.shrink();
        },
      ),

      bottomNavigationBar: AppBottomActionBar(
        primaryLabel: 'Need Help',
        onPrimaryPressed: () => AppSnackbar.showSuccess(
          context,
          'Our support team will reach out to you shortly.',
        ),
        secondaryLabel: 'Copy Order #',
        secondaryIcon: Icons.copy_rounded,
        onSecondaryPressed: () {
          Clipboard.setData(ClipboardData(text: order.orderNumber));
          AppSnackbar.showSuccess(context, 'Order number copied');
        },
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, OrderModel o, String? addressText) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── Hero ──
          _HeroCard(order: o),

          SizedBox(height: 2.h),

          /// ── Tracking Timeline (built from real order timestamps) ──
          TrackingTimeline(steps: _buildTimeline(o)),

          SizedBox(height: 2.h),

          if (o.items.isNotEmpty) ...[
            Text(
              'Items · ${o.items.length}',
              style: AppTextStyles.titleLarge.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              decoration: BoxDecoration(
                color: ThemeColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: ThemeColors.line),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: o.items.length,
                separatorBuilder: (_, _) => Divider(
                  color: ThemeColors.line,
                  height: 1,
                  indent: 4.w,
                  endIndent: 4.w,
                ),
                itemBuilder: (context, index) =>
                    _OrderItemTile(item: o.items[index]),
              ),
            ),
            SizedBox(height: 2.h),
          ],

          Text(
            'Order summary',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),

          _PriceSummaryCard(order: o),

          SizedBox(height: 2.h),

          OrderInfoCard(
            tiles: [
              OrderInfoTile(
                icon: Icons.location_on_outlined,
                title: 'Delivery address',
                subtitle: addressText ?? 'Address on file',
              ),
              OrderInfoTile(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Payment',
                subtitle: '${o.displayPaymentMethod} · ${o.formattedTotal}',
                trailing: OrderStatusBadge(status: o.paymentStatus),
              ),
              if ((o.notes ?? '').isNotEmpty)
                OrderInfoTile(
                  icon: Icons.sticky_note_2_outlined,
                  title: 'Delivery notes',
                  subtitle: o.notes!,
                ),
              OrderInfoTile(
                icon: Icons.confirmation_number_outlined,
                title: 'Order placed',
                subtitle: o.fullPlacedAt,
              ),
            ],
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  List<TrackingStep> _buildTimeline(OrderModel o) {
    final steps = <TrackingStep>[
      TrackingStep(
        title: 'Order placed',
        subtitle: o.fullPlacedAt,
        stepStatus: TrackingStatus.completed,
      ),
    ];

    if (o.isCancelled) {
      steps.add(
        TrackingStep(
          title: 'Order cancelled',
          subtitle: o.cancelledAt != null ? formatDateTime(o.cancelledAt!) : '—',
          stepStatus: TrackingStatus.completed,
          isError: true,
        ),
      );
      return steps;
    }

    steps.add(
      TrackingStep(
        title: o.isPaid ? 'Payment received' : 'Payment pending',
        subtitle: o.paidAt != null
            ? formatDateTime(o.paidAt!)
            : 'Awaiting confirmation',
        stepStatus: o.isPaid ? TrackingStatus.completed : TrackingStatus.current,
      ),
    );

    steps.add(
      TrackingStep(
        title: 'Delivered',
        subtitle: o.deliveredAt != null
            ? formatDateTime(o.deliveredAt!)
            : 'Not yet delivered',
        stepStatus: o.isDelivered ? TrackingStatus.completed : TrackingStatus.pending,
      ),
    );

    return steps;
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final OrderModel order;

  const _HeroCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final icon = order.isCancelled
        ? Icons.cancel_outlined
        : order.isDelivered
        ? Icons.check_circle_outline_rounded
        : Icons.local_shipping_outlined;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: ThemeColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.blue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                decoration: BoxDecoration(
                  color: ThemeColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14.sp, color: ThemeColors.white),
                    SizedBox(width: 1.5.w),
                    Text(
                      order.displayOrderStatus,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                order.shortDate,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: ThemeColors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Text(
            order.orderNumber,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: ThemeColors.white,
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            order.formattedItemsLabel(),
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13.sp,
              color: ThemeColors.white.withValues(alpha: 0.75),
            ),
          ),

          SizedBox(height: 2.5.h),

          Text(
            'Total',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              color: ThemeColors.white.withValues(alpha: 0.75),
            ),
          ),
          Text(
            order.formattedTotal,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: ThemeColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order Item Tile ───────────────────────────────────────────────────────────

class _OrderItemTile extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final skuSuffix = (item.sku?.isNotEmpty ?? false) ? ' · ${item.sku}' : '';
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
              color: ThemeColors.blueSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.inventory_2_outlined,
              color: ThemeColors.blue,
              size: 18.sp,
            ),
          ),

          SizedBox(width: 3.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.ink,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  'Qty ${item.quantity} × ${item.formattedUnitPrice}$skuSuffix',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13.sp,
                    color: ThemeColors.inkDim,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 2.w),

          Text(
            item.formattedTotal,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Price Summary Card ────────────────────────────────────────────────────────

class _PriceSummaryCard extends StatelessWidget {
  final OrderModel order;

  const _PriceSummaryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.line),
      ),
      child: Column(
        children: [
          _row('Subtotal', formatAmount(order.subtotalAmount)),
          if (order.discountAmount > 0) ...[
            SizedBox(height: 1.2.h),
            _row(
              'Discount',
              '- ${formatAmount(order.discountAmount)}',
              valueColor: ThemeColors.green,
            ),
          ],
          SizedBox(height: 1.2.h),
          _row('Tax', formatAmount(order.taxAmount)),
          SizedBox(height: 1.2.h),
          _row(
            'Shipping',
            order.shippingAmount > 0 ? formatAmount(order.shippingAmount) : 'Free',
            valueColor: order.shippingAmount > 0 ? null : ThemeColors.green,
          ),
          SizedBox(height: 1.6.h),
          Divider(height: 1, color: ThemeColors.line),
          SizedBox(height: 1.6.h),
          _row(
            'Total',
            order.formattedTotal,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: isBold ? 15.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? ThemeColors.ink : ThemeColors.inkMid,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: isBold ? 16.sp : 14.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isBold ? ThemeColors.ink : ThemeColors.ink),
          ),
        ),
      ],
    );
  }
}
