import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_currency.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../../data/models/vendor_order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String uuid;

  const OrderDetailScreen({super.key, required this.uuid});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

// Strict forward-only sequence enforced by vendor-order-validation.service.ts:
// PENDING -> CONFIRMED -> PROCESSING -> PACKED -> SHIPPED -> OUT_FOR_DELIVERY -> DELIVERED
const Map<String, (String action, String label)> _nextStatusAction = {
  'PENDING': ('CONFIRM', 'Confirm Order'),
  'CONFIRMED': ('PROCESS', 'Start Processing'),
  'PROCESSING': ('PACK', 'Mark as Packed'),
  'PACKED': ('SHIP', 'Ship Order'),
  'SHIPPED': ('OUT_FOR_DELIVERY', 'Out for Delivery'),
  'OUT_FOR_DELIVERY': ('DELIVER', 'Mark Delivered'),
};

const List<String> _orderStatusFlow = [
  'PENDING',
  'CONFIRMED',
  'PROCESSING',
  'PACKED',
  'SHIPPED',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
];

// vendor-order-validation.service.ts rejects CANCEL once processing starts
const Set<String> _cancellableStatuses = {'PENDING', 'CONFIRMED'};

const Map<String, String> _orderStatusLabels = {
  'PENDING': 'Pending',
  'CONFIRMED': 'Confirmed',
  'PROCESSING': 'Processing',
  'PACKED': 'Packed',
  'SHIPPED': 'Shipped',
  'OUT_FOR_DELIVERY': 'Out for Delivery',
  'DELIVERED': 'Delivered',
};

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<VendorOrderDetailModel?> _orderFuture;
  bool _updatingStatus = false;

  @override
  void initState() {
    super.initState();
    _orderFuture = _fetch();
  }

  Future<VendorOrderDetailModel?> _fetch() {
    return getIt<OrderRemoteDataSource>().getVendorOrderDetail(widget.uuid);
  }

  Future<void> _updateStatus(VendorOrderDetailModel order, String action) async {
    if (action == 'CANCEL') {
      if (!_cancellableStatuses.contains(order.orderStatus.toUpperCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This order can no longer be cancelled')),
        );
        return;
      }
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Order'),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes, Cancel')),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _updatingStatus = true);
    try {
      await getIt<OrderRemoteDataSource>().updateVendorOrderStatus(uuid: order.uuid, action: action);
      if (!mounted) return;
      setState(() {
        _orderFuture = _fetch();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order status updated')));
    } catch (e, st) {
      debugPrint('[OrderDetailScreen] updateVendorOrderStatus failed uuid=${order.uuid} action=$action error=$e');
      debugPrint(st.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: ${friendlyErrorMessage(e)}')));
    } finally {
      if (mounted) setState(() => _updatingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<VendorOrderDetailModel?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load order: ${friendlyErrorMessage(snapshot.error)}'));
          }
          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Order not found'));
          }
          return _OrderDetailBody(order: order);
        },
      ),
      bottomNavigationBar: FutureBuilder<VendorOrderDetailModel?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          final order = snapshot.data;
          if (order == null) return const SizedBox.shrink();
          final status = order.orderStatus.toUpperCase();
          if (status == 'CANCELLED' || status == 'DELIVERED') {
            return const SizedBox.shrink();
          }
          final next = _nextStatusAction[status];
          final cancellable = _cancellableStatuses.contains(status);
          if (!cancellable && next == null) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Row(
                children: [
                  if (cancellable)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _updatingStatus ? null : () => _updateStatus(order, 'CANCEL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel Order'),
                      ),
                    ),
                  if (next != null) ...[
                    if (cancellable) const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _updatingStatus ? null : () => _updateStatus(order, next.$1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _updatingStatus
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(next.$2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  final VendorOrderDetailModel order;

  const _OrderDetailBody({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderNumber.isNotEmpty ? order.orderNumber : 'Order #${order.id}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  _StatusPill(status: order.orderStatus),
                ],
              ),
              const SizedBox(height: 4),
              Text(dateFormat.format(order.createdAt), style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
              if (order.paymentMethod.isNotEmpty || order.paymentStatus.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  '${order.paymentMethod} · ${order.paymentStatus}',
                  style: TextStyle(color: context.colors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(order.notes!, style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
              ],
            ],
          ),
        ),
        if (order.customer != null) ...[
          const SizedBox(height: AppDimensions.sm + 4),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(order.customer!.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (order.customer!.phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(order.customer!.phone, style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                  ),
                if (order.customer!.email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(order.customer!.email, style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                  ),
              ],
            ),
          ),
        ],
        if (order.address != null) ...[
          const SizedBox(height: AppDimensions.sm + 4),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Address', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                if (order.address!.fullName.isNotEmpty)
                  Text(order.address!.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (order.address!.phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(order.address!.phone, style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                  ),
                const SizedBox(height: 6),
                Text(
                  order.address!.formattedLines,
                  style: TextStyle(fontSize: 13, color: context.colors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimensions.sm + 4),
        if (order.orderStatus.toUpperCase() == 'CANCELLED')
          _Card(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: context.colors.errorTint, shape: BoxShape.circle),
                  child: Icon(Icons.close_rounded, color: context.colors.errorFg, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Cancelled',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.errorFg),
                      ),
                      if (order.cancelledAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            dateFormat.format(order.cancelledAt!),
                            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Status', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                _OrderStatusStepper(order: order, dateFormat: dateFormat),
              ],
            ),
          ),
        const SizedBox(height: AppDimensions.sm + 4),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Items', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              for (final item in order.items) _ItemRow(item: item),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.sm + 4),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Amount', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _AmountRow(label: 'Subtotal', value: order.subtotalAmount),
              _AmountRow(label: 'Discount', value: -order.discountAmount),
              _AmountRow(label: 'Tax', value: order.taxAmount),
              _AmountRow(label: 'Shipping', value: order.shippingAmount),
              const Divider(height: AppDimensions.lg),
              _AmountRow(label: 'Total', value: order.totalAmount, isTotal: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(color: context.colors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

enum _StepState { completed, current, upcoming }

class _OrderStatusStepper extends StatelessWidget {
  final VendorOrderDetailModel order;
  final DateFormat dateFormat;

  const _OrderStatusStepper({required this.order, required this.dateFormat});

  DateTime? _timestampFor(String status) => switch (status) {
    'PENDING' => order.placedAt,
    'SHIPPED' => order.shippedAt,
    'DELIVERED' => order.deliveredAt,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _orderStatusFlow.indexOf(order.orderStatus.toUpperCase());
    return Column(
      children: [
        for (var i = 0; i < _orderStatusFlow.length; i++)
          _StatusStepRow(
            label: _orderStatusLabels[_orderStatusFlow[i]]!,
            timestamp: _timestampFor(_orderStatusFlow[i]),
            dateFormat: dateFormat,
            state: i < currentIndex
                ? _StepState.completed
                : i == currentIndex
                ? _StepState.current
                : _StepState.upcoming,
            isLast: i == _orderStatusFlow.length - 1,
          ),
      ],
    );
  }
}

class _StatusStepRow extends StatelessWidget {
  final String label;
  final DateTime? timestamp;
  final DateFormat dateFormat;
  final _StepState state;
  final bool isLast;

  const _StatusStepRow({
    required this.label,
    required this.timestamp,
    required this.dateFormat,
    required this.state,
    required this.isLast,
  });

  static const _currentColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = switch (state) {
      _StepState.completed => AppColors.success,
      _StepState.current => isDark ? AppColors.primary : _currentColor,
      _StepState.upcoming => context.colors.border,
    };
    final lineColor = state == _StepState.upcoming ? context.colors.border : AppColors.success;
    final labelColor = state == _StepState.upcoming ? context.colors.textMuted : context.colors.textPrimary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state == _StepState.upcoming ? context.colors.card : dotColor,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: state == _StepState.completed
                    ? const Icon(Icons.check, size: 10, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: lineColor, margin: const EdgeInsets.symmetric(vertical: 2)),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: state == _StepState.current ? FontWeight.w700 : FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                  Text(
                    timestamp != null ? dateFormat.format(timestamp!) : '',
                    style: TextStyle(fontSize: 11, color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final VendorOrderDetailItemModel item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                if (item.variantTitle.isNotEmpty)
                  Text(item.variantTitle, style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
                if (item.sku.isNotEmpty)
                  Text('SKU: ${item.sku}', style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
                Text('Qty: ${item.quantity} × ${AppCurrency.formatPrecise(item.unitPrice)}',
                    style: TextStyle(fontSize: 12, color: context.colors.textSecondary)),
              ],
            ),
          ),
          Text(
            AppCurrency.formatPrecise(item.totalAmount),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isTotal;

  const _AmountRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isTotal ? 16 : 13,
      fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
      color: isTotal ? context.colors.textPrimary : context.colors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(AppCurrency.formatPrecise(value), style: style),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (bg, fg) = switch (status.toUpperCase()) {
      'PENDING' => (colors.warningTint, colors.warningFg),
      'CONFIRMED' || 'PROCESSING' => (colors.infoTint, colors.infoFg),
      'SHIPPED' => (colors.purpleTint, colors.purpleFg),
      'DELIVERED' => (colors.successTint, colors.successFg),
      'CANCELLED' => (colors.errorTint, colors.errorFg),
      _ => (colors.inputFill, colors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppDimensions.radiusCircular)),
      child: Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
