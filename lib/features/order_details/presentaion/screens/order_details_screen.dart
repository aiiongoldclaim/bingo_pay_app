import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/pdf_file_handler.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../order_details/presentaion/widgets/od_item_tile.dart';
import '../../../order_details/presentaion/widgets/order_address_card.dart';
import '../../../order_details/presentaion/widgets/order_details_metrics.dart';
import '../../../order_details/presentaion/widgets/order_info_tile.dart';
import '../../../order_details/presentaion/widgets/order_price_details.dart';
import '../../../order_details/presentaion/widgets/order_shell.dart';
import '../../../order_details/presentaion/widgets/order_status_banner.dart';
import '../../../order_details/presentaion/widgets/order_tacking.dart';
import '../../../orders/cubit/orders_cubit.dart';
import '../../../orders/cubit/orders_state.dart';
import '../../../orders/data/datasources/orders_remote_datasource.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/widgets/order_status_style.dart';

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
    final m = OrderDetailMetrics.of(context);
    final c = context.c;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.contentMaxWidth),
            child: Column(
              children: [
                OdHeader(
                  metrics: m,
                  brandName: 'TheVaults',
                  onBack: () => context.pop(),
                  onHelp: () => context.go(AppRoutes.help),
                ),
                Expanded(
                  child: BlocListener<OrderDetailCubit, OrderDetailState>(
                    listener: (context, state) {
                      if (state is OrderCancelled) {
                        AppSnackbar.showSuccess(
                          context,
                          'Order cancelled successfully',
                        );
                      }
                      if (state is OrderCancelError) {
                        AppSnackbar.showError(context, state.message);
                      }
                    },
                    child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
                      builder: (context, state) {
                        if (state is OrderDetailLoading ||
                            state is OrderDetailInitial ||
                            state is OrderCancelling) {
                          return Center(
                            child: CircularProgressIndicator(color: c.brand),
                          );
                        }
                        if (state is OrderDetailLoaded ||
                            state is OrderCancelled) {
                          final currentOrder = state is OrderCancelled
                              ? state.order
                              : (state as OrderDetailLoaded).order;
                          final addressText = state is OrderDetailLoaded
                              ? state.addressText
                              : null;
                          return RefreshIndicator(
                            onRefresh: () async {
                              await context.read<OrderDetailCubit>().loadOrder(
                                order,
                              );
                            },
                            color: c.brand,
                            backgroundColor: c.surface,
                            child: _Body(
                              metrics: m,
                              order: currentOrder,
                              addressText: addressText,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (context, state) {
          final currentOrder = state is OrderDetailLoaded
              ? state.order
              : state is OrderCancelled
              ? state.order
              : order;
          final cubit = context.read<OrderDetailCubit>();
          final canCancel = cubit.canCancelOrder(currentOrder);

          return AppBottomActionBar(
            primaryLabel: canCancel ? 'Cancel Order' : 'Need Help',
            onPrimaryPressed: canCancel
                ? () => _showCancelConfirmation(context, currentOrder)
                : () => AppSnackbar.showSuccess(
                    context,
                    'Our support team will reach out to you shortly.',
                  ),
            secondaryLabel: 'Download Invoice',
            secondaryIcon: Icons.receipt_long_outlined,
            onSecondaryPressed: () => _downloadInvoice(context, currentOrder),
          );
        },
      ),
    );
  }

  // ── UNCHANGED ────────────────────────────────────────────
  Future<void> _downloadInvoice(BuildContext context, OrderModel o) async {
    try {
      final invoice = await getIt<OrdersRemoteDataSource>().downloadInvoice(
        o.uuid,
      );
      await openOrSharePdf(invoice.bytes, invoice.filename);
    } catch (_) {
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          'Failed to download invoice. Please try again.',
        );
      }
    }
  }

  Future<void> _showCancelConfirmation(
      BuildContext context,
      OrderModel order,
      ) async {
    final cubit = context.read<OrderDetailCubit>();

    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Cancel Order?',
      message:
      'Are you sure you want to cancel this order? This action cannot be undone.',
      confirmLabel: 'Cancel Order',
      cancelLabel: 'Keep Order',
      isDestructive: true,
      icon: Icons.close_rounded,
    );

    if (!confirmed) return;
    cubit.cancelOrder(order);
  }
}

// ─────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.metrics,
    required this.order,
    required this.addressText,
  });

  final OrderDetailMetrics metrics;
  final OrderModel order;
  final String? addressText;

  @override
  Widget build(BuildContext context) {
    final m = metrics;
    final tone = OrderStatusStyle.toneOf(order.orderStatus);
    final isCancelled = tone == OrderStatusTone.cancelled;
    final isDelivered = tone == OrderStatusTone.delivered;

    final sections = <Widget>[
      OdTitleBlock(
        metrics: m,
        title: OrderStatusStyle.screenTitleFor(order.orderStatus),
        orderId: order.orderNumber,
        placedAt: order.fullPlacedAt,
        onCopy: () {
          Clipboard.setData(ClipboardData(text: order.orderNumber));
          AppSnackbar.showSuccess(context, 'Order number copied');
        },
      ),
      SizedBox(height: m.sectionGap),

      // Banner sirf terminal states pe
      if (isCancelled || isDelivered) ...[
        OdStatusBanner(
          metrics: m,
          status: order.orderStatus,
          title: isCancelled ? 'Cancelled' : 'Delivered',
          message: isCancelled
              ? 'Your item has been cancelled'
              : 'Your order was delivered successfully',
          timestamp: isCancelled
              ? (order.cancelledAt != null
                    ? 'Cancelled on ${formatDateTime(order.cancelledAt!)}'
                    : null)
              : (order.deliveredAt != null
                    ? 'Delivered on ${formatDateTime(order.deliveredAt!)}'
                    : null),
          actionLabel: isCancelled ? 'View Policy' : null,
          onAction: isCancelled ? () => context.push(AppRoutes.help) : null,
        ),
        SizedBox(height: m.sectionGap),
      ],

      OdTrackingCard(
        metrics: m,
        steps: _buildTimeline(order),
        illustrationAsset: OrderStatusStyle.illustrationFor(order.orderStatus),
      ),
      SizedBox(height: m.sectionGap),

      // Cancellation reason — API me field nahi hai, isliye notes fallback
      if (isCancelled && (order.notes ?? '').isNotEmpty) ...[
        OdNavRow(
          metrics: m,
          title: 'Reason for Cancellation',
          subtitle: order.notes!,
          onTap: () {

          },
        ),
        SizedBox(height: m.sectionGap),
      ],

      OdSectionLabel(metrics: m, label: 'Delivery Address'),
      SizedBox(height: m.sectionGap * 0.5),
      OdAddressCard(
        metrics: m,
        addressText: addressText ?? 'Address on file',
        actionLabel: null,
      ),
      SizedBox(height: m.sectionGap),

      if (order.items.isNotEmpty) ...[
        OdSectionLabel(
          metrics: m,
          label: isCancelled ? 'Cancelled Item' : 'Order Items',
        ),
        SizedBox(height: m.sectionGap * 0.5),
        OdCard(
          metrics: m,
          padded: false,
          child: Column(
            children: [
              for (var i = 0; i < order.items.length; i++) ...[
                if (i > 0) Divider(height: 1, color: context.c.border),
                OdItemTile(
                  metrics: m,
                  item: order.items[i],
                  actionLabel: OrderStatusStyle.itemActionFor(
                    order.orderStatus,
                  ),
                  actionAsButton: isCancelled || isDelivered,
                  onAction: () {},
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: m.sectionGap),
      ],

      OdSectionLabel(metrics: m, label: 'Price Details'),
      SizedBox(height: m.sectionGap * 0.5),
      OdPriceDetails(metrics: m, order: order),
      SizedBox(height: m.sectionGap),

      OdPaymentCard(
        metrics: m,
        title: 'Payment Method',
        subtitle: order.displayPaymentMethod,
        actionLabel: 'View',
        onAction: () {},
      ),
      SizedBox(height: m.sectionGap),

      OdInfoBanner(
        metrics: m,
        icon: isCancelled ? Icons.help_outline_rounded : Icons.shield_outlined,
        title: isCancelled ? 'Need help?' : 'Safe and Secure Payments',
        subtitle: isCancelled
            ? 'Read our cancellation policy or chat with our support team.'
            : 'We ensure 100% secure payments for a worry-free shopping',


      ),

      SizedBox(height: m.sectionGap + MediaQuery.paddingOf(context).bottom),
    ];

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(top: m.sectionGap * 0.5),
      children: sections,
    );
  }

  // ── UNCHANGED: timeline building ─────────────────────────
  List<TrackingStep> _buildTimeline(OrderModel o) {
    if (o.tracking != null && o.tracking!.timeline.isNotEmpty) {
      return _buildTimelineFromTracking(o);
    }

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

  List<TrackingStep> _buildTimelineFromTracking(OrderModel o) {
    final tracking = o.tracking!;
    final steps = <TrackingStep>[];

    for (int i = 0; i < tracking.timeline.length; i++) {
      final step = tracking.timeline[i];
      final isCompleted = step.completed;
      final isCurrent = !isCompleted && step.status == tracking.currentStatus;

      steps.add(
        TrackingStep(
          title: _formatStatusTitle(step.status),
          subtitle: isCompleted
              ? 'Completed'
              : isCurrent
              ? 'In progress'
              : 'Pending',
          stepStatus: isCompleted
              ? TrackingStatus.completed
              : isCurrent
              ? TrackingStatus.current
              : TrackingStatus.pending,
          isError: o.isCancelled && step.status == 'CANCELLED',
        ),
      );
    }
    return steps;
  }

  String _formatStatusTitle(String status) {
    const statusTitles = {
      'PENDING': 'Order pending',
      'CONFIRMED': 'Order confirmed',
      'PROCESSING': 'Processing',
      'PACKED': 'Packed',
      'SHIPPED': 'Shipped',
      'OUT_FOR_DELIVERY': 'Out for delivery',
      'DELIVERED': 'Delivered',
      'CANCELLED': 'Cancelled',
    };
    return statusTitles[status] ?? titleCaseStatus(status);
  }
}
