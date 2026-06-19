
import 'package:bingo_pay/features/orders/cubit/orders_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/order_model.dart';


class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState.initial()) {
    loadOrders();
  }

  void loadOrders() {
    emit(state.copyWith(status: OrdersStatus.loading));

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 800), () {
      final orders = [
        OrderModel(
          orderId: "BG-47990",
          orderDate: DateTime(2026, 6, 2),
          status: "Delivered",
          totalAmount: 64999,
          itemCount: 1,
          mainItemName: "Helios 5G Smartphone 256GB",
          deliveryDate: "5 Jun",
        ),
        OrderModel(
          orderId: "BG-47512",
          orderDate: DateTime(2026, 5, 21),
          status: "Delivered",
          totalAmount: 14670,
          itemCount: 1,
          mainItemName: "Velvet Runner Knit Sneakers",
          deliveryDate: "24 May",
        ),
        OrderModel(
          orderId: "BG-46880",
          orderDate: DateTime(2026, 5, 8),
          status: "Cancelled",
          totalAmount: 12450,
          itemCount: 1,
          mainItemName: "Solara Pro Earbuds",
          deliveryDate: "",
        ),
      ];

      emit(state.copyWith(
        status: OrdersStatus.success,
        orders: orders,
        filteredOrders: orders,
      ));
    });
  }

  void filterOrders(String tab) {
    final filtered = tab == "All"
        ? state.orders
        : state.orders.where((order) => order.status.toLowerCase() == tab.toLowerCase()).toList();

    emit(state.copyWith(filteredOrders: filtered, selectedTab: tab));
  }
}