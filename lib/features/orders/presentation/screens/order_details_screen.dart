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
        secondaryLabel: 'Copy Order ID',
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
          /// ── Header ──
          _OrderHeader(order: o),

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
          subtitle: o.cancelledAt != null
              ? formatDateTime(o.cancelledAt!)
              : '—',
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
        stepStatus: o.isPaid
            ? TrackingStatus.completed
            : TrackingStatus.current,
      ),
    );

    steps.add(
      TrackingStep(
        title: 'Delivered',
        subtitle: o.deliveredAt != null
            ? formatDateTime(o.deliveredAt!)
            : 'Not yet delivered',
        stepStatus: o.isDelivered
            ? TrackingStatus.completed
            : TrackingStatus.pending,
      ),
    );

    return steps;
  }
}

// ── Order Header ──────────────────────────────────────────────────────────────

class _OrderHeader extends StatelessWidget {
  final OrderModel order;

  const _OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrderPreviewImage(items: order.items, size: 22.w),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.ink,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  OrderStatusBadge(status: order.orderStatus),
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${order.formattedItemsLabel()} · ${order.shortDate}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13.sp,
                  color: ThemeColors.inkMid,
                ),
              ),
              SizedBox(height: 1.5.h),
              Text(
                'Total',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: ThemeColors.inkDim,
                ),
              ),
              Text(
                order.formattedTotal,
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Order Preview Image (single item, or a collage when there are many) ───────

class _OrderPreviewImage extends StatelessWidget {
  final List<OrderItemModel> items;
  final double size;

  const _OrderPreviewImage({required this.items, required this.size});

  @override
  Widget build(BuildContext context) {
    final images = items
        .map((e) => e.imageUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();

    if (images.length <= 1) {
      return _OrderItemImage(
        imageUrl: images.isEmpty ? null : images.first,
        size: size,
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ThemeColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _collageFor(images, items.length),
    );
  }

  Widget _collageFor(List<String> images, int totalCount) {
    Widget tile(String url) => Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => const _OrderItemImageFallback(size: 14),
    );

    Widget gap({double width = 0, double height = 0}) => SizedBox(
      width: width,
      height: height,
    );

    if (images.length == 2) {
      return Row(
        children: [
          Expanded(child: tile(images[0])),
          gap(width: 1),
          Expanded(child: tile(images[1])),
        ],
      );
    }

    if (images.length == 3) {
      return Row(
        children: [
          Expanded(child: tile(images[0])),
          gap(width: 1),
          Expanded(
            child: Column(
              children: [
                Expanded(child: tile(images[1])),
                gap(height: 1),
                Expanded(child: tile(images[2])),
              ],
            ),
          ),
        ],
      );
    }

    final extraCount = totalCount - 4;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: tile(images[0])),
              gap(width: 1),
              Expanded(child: tile(images[1])),
            ],
          ),
        ),
        gap(height: 1),
        Expanded(
          child: Row(
            children: [
              Expanded(child: tile(images[2])),
              gap(width: 1),
              Expanded(
                child: extraCount > 0
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          tile(images[3]),
                          Container(
                            color: Colors.black.withValues(alpha: 0.55),
                            alignment: Alignment.center,
                            child: Text(
                              '+$extraCount',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: ThemeColors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ],
                      )
                    : tile(images[3]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Order Item Tile ───────────────────────────────────────────────────────────

class _OrderItemTile extends StatelessWidget {
  final OrderItemModel item;

  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderItemImage(imageUrl: item.imageUrl),

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
                if ((item.secondaryLabel ?? '').isNotEmpty) ...[
                  SizedBox(height: 0.3.h),
                  Text(
                    item.secondaryLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 12.sp,
                      color: ThemeColors.inkMid,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                SizedBox(height: 0.5.h),
                Text(
                  item.purchaseMetaLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13.sp,
                    color: ThemeColors.inkDim,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 2.w),

          Padding(
            padding: EdgeInsets.only(top: 0.2.h),
            child: Text(
              item.formattedTotal,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemImage extends StatelessWidget {
  final String? imageUrl;
  final double? size;

  const _OrderItemImage({required this.imageUrl, this.size});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final dimension = size ?? 15.w;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: ThemeColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url == null || url.isEmpty
          ? _OrderItemImageFallback(size: dimension * 0.4)
          : Image.network(
              url,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _OrderItemImageFallback(size: dimension * 0.4),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _OrderItemImageFallback(size: dimension * 0.4),
            ),
    );
  }
}

class _OrderItemImageFallback extends StatelessWidget {
  final double size;

  const _OrderItemImageFallback({this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.inventory_2_outlined, color: ThemeColors.blue, size: size);
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
            order.shippingAmount > 0
                ? formatAmount(order.shippingAmount)
                : 'Free',
            valueColor: order.shippingAmount > 0 ? null : ThemeColors.green,
          ),
          SizedBox(height: 1.6.h),
          Divider(height: 1, color: ThemeColors.line),
          SizedBox(height: 1.6.h),
          _row('Total', order.formattedTotal, isBold: true),
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
