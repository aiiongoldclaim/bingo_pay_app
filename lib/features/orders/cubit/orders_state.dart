import '../data/models/order_model.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> all;
  final List<OrderModel> filtered;
  final String activeFilter; // 'All' | 'In Transit' | 'Delivered' | 'Cancelled'

  OrdersLoaded({
    required this.all,
    required this.filtered,
    required this.activeFilter,
  });
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}

// ── Order Detail States ───────────────────────────────────────────────────────

abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final OrderModel order;
  OrderDetailLoaded(this.order);
}

class OrderDetailError extends OrderDetailState {
  final String message;
  OrderDetailError(this.message);
}
