// lib/features/orders/data/order_model.dart

import 'package:flutter/material.dart';

class OrderModel {
  final String orderId;
  final DateTime orderDate;
  final String status; // "Delivered" | "In Transit" | "Cancelled" | "Pending"
  final double totalAmount;
  final int itemCount;
  final String mainItemName;
  final String? mainItemBrand;
  final String? imageUrl;
  final String deliveryDate;
  final String trackingId;
  final List<OrderItem> items;
  final List<TrackingStep> trackingSteps;

  OrderModel({
    required this.orderId,
    required this.orderDate,
    required this.status,
    required this.totalAmount,
    required this.itemCount,
    required this.mainItemName,
    this.mainItemBrand,
    this.imageUrl,
    required this.deliveryDate,
    required this.trackingId,
    required this.items,
    required this.trackingSteps,
  });

  String get formattedDate =>
      '${orderDate.day} ${monthName(orderDate.month)} ${orderDate.year}';

  String monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  bool get isInTransit => status == 'In Transit';
  bool get isDelivered => status == 'Delivered';
  bool get isCancelled => status == 'Cancelled';
}

class OrderItem {
  final String name;
  final String brand;
  final double price;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const OrderItem({
    required this.name,
    required this.brand,
    required this.price,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  String get formattedPrice =>
      '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

class TrackingStep {
  final String title;
  final String subtitle;
  final TrackingStatus stepStatus;

  const TrackingStep({
    required this.title,
    required this.subtitle,
    required this.stepStatus,
  });
}

enum TrackingStatus { completed, current, pending }
