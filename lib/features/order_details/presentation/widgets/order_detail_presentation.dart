import 'package:flutter/material.dart';

import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/widgets/order_status_style.dart';

@immutable
class OrderDetailPresentation {
  final String pageTitle;
  final String itemsSectionTitle;
  final String? illustrationAsset;

  /// Cancelled/failed pe hi top banner dikhta hai
  final bool showStatusBanner;
  final String bannerTitle;
  final String bannerBody;
  final String? bannerMeta;
  final String bannerCtaLabel;

  /// Item card ka right-side action
  final String? itemActionLabel;

  final String footerTitle;
  final String footerBody;

  const OrderDetailPresentation({
    required this.pageTitle,
    required this.itemsSectionTitle,
    required this.illustrationAsset,
    required this.showStatusBanner,
    required this.bannerTitle,
    required this.bannerBody,
    required this.bannerMeta,
    required this.bannerCtaLabel,
    required this.itemActionLabel,
    required this.footerTitle,
    required this.footerBody,
  });

  static const String _dir = 'assets/images/orders';

  factory OrderDetailPresentation.of(OrderModel order) {
    final tone = OrderStatusStyle.toneOf(order.orderStatus);

    switch (tone) {
      case OrderStatusTone.cancelled:
        return OrderDetailPresentation(
          pageTitle: 'Cancelled Item Details',
          itemsSectionTitle: 'Cancelled Item',
          illustrationAsset: '$_dir/cancelled.png',
          showStatusBanner: true,
          bannerTitle: 'Cancelled',
          bannerBody: 'Your item has been cancelled',
          bannerMeta: order.cancelledAt != null
              ? 'Cancelled on ${formatDateTime(order.cancelledAt!)}'
              : null,
          bannerCtaLabel: 'View Policy',
          itemActionLabel: 'Buy Again',
          footerTitle: 'Need help?',
          footerBody:
              'Read our cancellation policy or chat with our support team.',
        );

      case OrderStatusTone.delivered:
        return const OrderDetailPresentation(
          pageTitle: 'Order Details',
          itemsSectionTitle: 'Order Items',
          illustrationAsset: '$_dir/delivered.png',
          showStatusBanner: false,
          bannerTitle: '',
          bannerBody: '',
          bannerMeta: null,
          bannerCtaLabel: '',
          itemActionLabel: 'Buy Again',
          footerTitle: 'Safe and Secure Payments',
          footerBody:
              'We ensure 100% secure payments for a worry-free shopping',
        );

      case OrderStatusTone.shipping:
        return const OrderDetailPresentation(
          pageTitle: 'Order Details',
          itemsSectionTitle: 'Order Items',
          illustrationAsset: '$_dir/shipping.png',
          showStatusBanner: false,
          bannerTitle: '',
          bannerBody: '',
          bannerMeta: null,
          bannerCtaLabel: '',
          itemActionLabel: null,
          footerTitle: 'Safe and Secure Payments',
          footerBody:
              'We ensure 100% secure payments for a worry-free shopping',
        );

      case OrderStatusTone.processing:
      case OrderStatusTone.pending:
        return const OrderDetailPresentation(
          pageTitle: 'Order Details',
          itemsSectionTitle: 'Order Items',
          illustrationAsset: '$_dir/processing.png',
          showStatusBanner: false,
          bannerTitle: '',
          bannerBody: '',
          bannerMeta: null,
          bannerCtaLabel: '',
          itemActionLabel: 'Cancel Item',
          footerTitle: 'Safe and Secure Payments',
          footerBody:
              'We ensure 100% secure payments for a worry-free shopping',
        );
    }
  }
}
