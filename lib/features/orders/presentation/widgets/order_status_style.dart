import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';

enum OrderStatusTone { pending, processing, shipping, delivered, cancelled }

@immutable
class OrderStatusStyle {
  final Color foreground;
  final Color background;
  final IconData icon;

  const OrderStatusStyle({
    required this.foreground,
    required this.background,
    required this.icon,
  });

  /// API `orderStatus` (PENDING / PROCESSING / SHIPPED / …) → tone.
  /// Naya status aane par sirf yahan case add karna hoga.
  static OrderStatusTone toneOf(String raw) {
    switch (raw.toUpperCase().trim()) {
      case 'DELIVERED':
      case 'COMPLETED':
        return OrderStatusTone.delivered;
      case 'CANCELLED':
      case 'FAILED':
      case 'REFUNDED':
        return OrderStatusTone.cancelled;
      case 'SHIPPED':
      case 'IN_TRANSIT':
      case 'OUT_FOR_DELIVERY':
        return OrderStatusTone.shipping;
      case 'PROCESSING':
      case 'CONFIRMED':
      case 'PACKED':
        return OrderStatusTone.processing;
      default:
        return OrderStatusTone.pending;
    }
  }

  static OrderStatusStyle of(BuildContext context, String rawStatus) {
    final c = context.c;
    switch (toneOf(rawStatus)) {
      case OrderStatusTone.delivered:
        return OrderStatusStyle(
          foreground: c.statusSuccess,
          background: c.statusSuccessSoft,
          icon: Icons.check_circle_outline_rounded,
        );
      case OrderStatusTone.pending:
        return OrderStatusStyle(
          foreground: c.statusWarning,
          background: c.statusWarningSoft,
          icon: Icons.access_time_rounded,
        );
      case OrderStatusTone.cancelled:
        return OrderStatusStyle(
          foreground: const Color(0xFFE0533B),
          background: c.surfaceAlt,
          icon: Icons.cancel_outlined,
        );
      case OrderStatusTone.shipping:
      case OrderStatusTone.processing:
        return OrderStatusStyle(
          foreground: c.statusInfo,
          background: c.brandSoft,
          icon: Icons.local_shipping_outlined,
        );
    }
  }

  /// Filter tab label ↔ order match. Cubit ka `filterOrders` bhi isi
  /// convention pe chalta hai, isliye counts consistent rehte hain.
  static bool matchesFilter(String filter, String orderStatus) {
    if (filter == 'All') return true;
    return titleOf(orderStatus) == filter;
  }

  static String titleOf(String raw) {
    switch (toneOf(raw)) {
      case OrderStatusTone.delivered:
        return 'Delivered';
      case OrderStatusTone.cancelled:
        return 'Cancelled';
      case OrderStatusTone.shipping:
        return 'Shipped';
      case OrderStatusTone.processing:
        return 'Processing';
      case OrderStatusTone.pending:
        return 'Pending';
    }
  }

  /// Detail screen ka title — status ke hisaab se badalta hai
  static String screenTitleFor(String rawStatus) {
    switch (toneOf(rawStatus)) {
      case OrderStatusTone.cancelled:
        return 'Cancelled Item Details';
      case OrderStatusTone.delivered:
        return 'Delivered Order Details';
      default:
        return 'Order Details';
    }
  }

  /// Timeline ke saath dikhne wali illustration
  static String illustrationFor(String rawStatus) {
    const dir = 'assets/images/orders';
    switch (toneOf(rawStatus)) {
      case OrderStatusTone.cancelled:
        return '$dir/order_cancelled.png';
      case OrderStatusTone.delivered:
        return '$dir/order_delivered.png';
      case OrderStatusTone.shipping:
        return '$dir/order_shipped.png';
      case OrderStatusTone.processing:
        return '$dir/order_packed.png';
      case OrderStatusTone.pending:
        return '$dir/order_placed.png';
    }
  }

  /// Item card ka trailing action
  static String itemActionFor(String rawStatus) {
    switch (toneOf(rawStatus)) {
      case OrderStatusTone.cancelled:
      case OrderStatusTone.delivered:
        return 'Buy Again';
      default:
        return 'Cancel Item';
    }
  }
}
