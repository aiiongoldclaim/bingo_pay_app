import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';
import 'package:bingo_pay/core/theme/app_text_styles.dart';

import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../cubit/orders_cubit.dart';
import '../../cubit/orders_state.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_info_card.dart';
import '../widgets/order_tacking.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderDetailCubit()..loadOrder(order),
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
      appBar: CustomAppBar(
        // leading: Icon(Icons.arrow_back_ios_new_outlined),
        title: 'Order ${order.orderId}',
        actionIcon1: Icons.headphones_outlined,
        onAction1: () {},
      ),

      body: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) {
          if (state is OrderDetailLoading || state is OrderDetailInitial) {
            return const Center(
              child: CircularProgressIndicator(color: ThemeColors.blue),
            );
          }
          if (state is OrderDetailLoaded) {
            return _buildBody(context, state.order);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: AppBottomActionBar(
        primaryLabel: 'Track Live',
        secondaryLabel: 'Need Help',
        secondaryIcon: Icons.headphones_outlined,
        onPrimaryPressed: () {},
        onSecondaryPressed: () {},
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, OrderModel o) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── Arrival Banner ──
          _ArrivalBanner(order: o),

          SizedBox(height: 2.h),

          /// ── Tracking Timeline ──
          TrackingTimeline(steps: o.trackingSteps),

          SizedBox(height: 2.h),

          /// ── Items Header ──
          Text(
            'Items · ${o.items.length}',
            style: AppTextStyles.titleLarge.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 1.h),

          /// ── Items List ──
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
              separatorBuilder: (_, __) => Divider(
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

          OrderInfoCard(
            address: 'Home · Bandra West, Mumbai 400050',
            payment: 'BINGOLD Wallet + UPI · ₹25,480',
            invoiceNo: 'INV-48217 · Download PDF',
            onDownloadInvoice: () {},
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}

// ── Arrival Banner ────────────────────────────────────────────────────────────

class _ArrivalBanner extends StatelessWidget {
  final OrderModel order;

  const _ArrivalBanner({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.6.h),
      decoration: BoxDecoration(
        color: ThemeColors.blueSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: ThemeColors.blueDeep,
            size: 20.sp,
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.deliveryDate,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.bold,
                  color: ThemeColors.blueDeep,
                ),
              ),
              Text(
                'Tracking ID · ${order.trackingId}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 15.sp,
                  color: ThemeColors.inkMid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Order Item Tile ───────────────────────────────────────────────────────────

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          /// Icon
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 20.sp),
          ),

          SizedBox(width: 3.w),

          /// Brand + Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.brand.toUpperCase(),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 15.sp,
                    letterSpacing: 1,
                    color: ThemeColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // SizedBox(height: 0.3.h),
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.ink,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  item.formattedPrice,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
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
