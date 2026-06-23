import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/order_model.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersInitial());

  void loadOrders() {
    emit(OrdersLoading());
    Future.delayed(const Duration(milliseconds: 300), () {
      emit(
        OrdersLoaded(
          all: _mockOrders,
          filtered: _mockOrders,
          activeFilter: 'All',
        ),
      );
    });
  }

  void filterOrders(String filter) {
    final current = state;
    if (current is! OrdersLoaded) return;

    final filtered = filter == 'All'
        ? current.all
        : current.all.where((o) => o.status == filter).toList();

    emit(
      OrdersLoaded(all: current.all, filtered: filtered, activeFilter: filter),
    );
  }

  // ── Mock Data ──────────────────────────────────────────────────────────────

  static final List<OrderModel> _mockOrders = [
    OrderModel(
      orderId: '#BG-48217',
      orderDate: DateTime(2026, 6, 10),
      status: 'In Transit',
      totalAmount: 25480,
      itemCount: 2,
      mainItemName: 'Aurora Pro Wireless Headphones',
      mainItemBrand: 'SONARA',
      deliveryDate: 'Arrives Sat, 14 Jun',
      trackingId: 'BLR482179X',
      items: const [
        OrderItem(
          name: 'Aurora Pro Wireless Headphones',
          brand: 'SONARA',
          price: 18990,
          icon: Icons.headphones_outlined,
          iconColor: Color(0xFF1B4AE4),
          iconBg: Color(0xFFE7EDFD),
        ),
        OrderItem(
          name: 'Nimbus Smart Desk Lamp',
          brand: 'GLOW',
          price: 3490,
          icon: Icons.emoji_objects_outlined,
          iconColor: Color(0xFFE0913B),
          iconBg: Color(0xFFFFF0E0),
        ),
      ],
      trackingSteps: const [
        TrackingStep(
          title: 'Order placed',
          subtitle: '10 Jun, 9:24 AM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Packed',
          subtitle: '10 Jun, 6:10 PM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Shipped',
          subtitle: '11 Jun, 8:02 AM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Out for delivery',
          subtitle: 'Expected 14 Jun',
          stepStatus: TrackingStatus.current,
        ),
        TrackingStep(
          title: 'Delivered',
          subtitle: 'Arrives Sat, 14 Jun',
          stepStatus: TrackingStatus.pending,
        ),
      ],
    ),
    OrderModel(
      orderId: '#BG-47990',
      orderDate: DateTime(2026, 6, 2),
      status: 'Delivered',
      totalAmount: 64999,
      itemCount: 1,
      mainItemName: 'Helios 5G Smartphone 256GB',
      mainItemBrand: 'NOVA',
      deliveryDate: 'Delivered 5 Jun',
      trackingId: 'BLR479901X',
      items: const [
        OrderItem(
          name: 'Helios 5G Smartphone 256GB',
          brand: 'NOVA',
          price: 64999,
          icon: Icons.smartphone_outlined,
          iconColor: Color(0xFF1B4AE4),
          iconBg: Color(0xFFE7EDFD),
        ),
      ],
      trackingSteps: const [
        TrackingStep(
          title: 'Order placed',
          subtitle: '2 Jun, 10:00 AM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Packed',
          subtitle: '2 Jun, 4:00 PM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Shipped',
          subtitle: '3 Jun, 9:00 AM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Out for delivery',
          subtitle: '5 Jun',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Delivered',
          subtitle: '5 Jun, 2:30 PM',
          stepStatus: TrackingStatus.completed,
        ),
      ],
    ),
    OrderModel(
      orderId: '#BG-47512',
      orderDate: DateTime(2026, 5, 21),
      status: 'Delivered',
      totalAmount: 14670,
      itemCount: 3,
      mainItemName: 'Velvet Runner Knit Sneakers',
      mainItemBrand: 'STRIDE',
      deliveryDate: 'Delivered 24 May',
      trackingId: 'BLR475121X',
      items: [
        OrderItem(
          name: 'Velvet Runner Knit Sneakers',
          brand: 'STRIDE',
          price: 14670,
          icon: Icons.directions_run_outlined,
          iconColor: Color(0xFFC9A84C),
          iconBg: Color(0xFFFBF3DD),
        ),
      ],
      trackingSteps: [
        TrackingStep(
          title: 'Order placed',
          subtitle: '21 May, 11:00 AM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Packed',
          subtitle: '21 May, 5:00 PM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Shipped',
          subtitle: '22 May, 8:00 AM',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Out for delivery',
          subtitle: '24 May',
          stepStatus: TrackingStatus.completed,
        ),
        TrackingStep(
          title: 'Delivered',
          subtitle: '24 May, 1:00 PM',
          stepStatus: TrackingStatus.completed,
        ),
      ],
    ),
  ];
}

// ── Order Detail Cubit ────────────────────────────────────────────────────────

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit() : super(OrderDetailInitial());

  void loadOrder(OrderModel order) {
    emit(OrderDetailLoading());
    Future.delayed(const Duration(milliseconds: 200), () {
      emit(OrderDetailLoaded(order));
    });
  }
}
