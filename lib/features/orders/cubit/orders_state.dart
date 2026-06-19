import '../data/models/order_model.dart';

enum OrdersStatus { initial, loading, success, failure }

class OrdersState {
  final OrdersStatus status;
  final List<OrderModel> orders;
  final List<OrderModel> filteredOrders;
  final String selectedTab;

  OrdersState({
    required this.status,
    required this.orders,
    required this.filteredOrders,
    required this.selectedTab,
  });

  factory OrdersState.initial() => OrdersState(
    status: OrdersStatus.initial,
    orders: [],
    filteredOrders: [],
    selectedTab: "All",
  );

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderModel>? orders,
    List<OrderModel>? filteredOrders,
    String? selectedTab,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}
