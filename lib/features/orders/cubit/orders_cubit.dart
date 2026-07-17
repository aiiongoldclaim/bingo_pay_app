import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../address/data/datasources/address_remote_datasources.dart';
import '../data/datasources/orders_remote_datasource.dart';
import '../data/models/order_model.dart';
import 'orders_state.dart';

@injectable
class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRemoteDataSource _remote;

  OrdersCubit(this._remote) : super(OrdersInitial());

  Future<void> loadOrders() async {
    emit(OrdersLoading());
    try {
      final orders = await _remote.getOrders();
      orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
      emit(OrdersLoaded(all: orders, filtered: orders, activeFilter: 'All'));
    } catch (_) {
      emit(OrdersError('Unable to load your orders. Please try again.'));
    }
  }

  void filterOrders(String filter) {
    final current = state;
    if (current is! OrdersLoaded) return;

    final filtered = filter == 'All'
        ? current.all
        : current.all
            .where((o) => o.displayOrderStatus == filter)
            .toList();

    emit(
      OrdersLoaded(all: current.all, filtered: filtered, activeFilter: filter),
    );
  }
}

// ── Order Detail Cubit ────────────────────────────────────────────────────────

@injectable
class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrdersRemoteDataSource _ordersRemote;
  final AddressRemoteDataSource _addressRemote;

  OrderDetailCubit(this._ordersRemote, this._addressRemote)
    : super(OrderDetailInitial());

  Future<void> loadOrder(OrderModel order) async {
    emit(OrderDetailLoading());

    // The list endpoint only returns order summaries (no line items), so
    // fetch the full detail-by-id record; fall back to the summary object
    // passed via navigation if that call fails.
    var detailed = order;
    try {
      detailed = await _ordersRemote.getOrderDetail(order.uuid);
    } catch (_) {
      detailed = order;
    }

    String? addressText;
    if (detailed.addressId != null && detailed.addressId!.isNotEmpty) {
      try {
        final address = await _addressRemote.getAddressDetails(
          detailed.addressId!,
        );
        final line2 = (address.addressLine2?.isNotEmpty ?? false)
            ? ', ${address.addressLine2}'
            : '';
        addressText =
            '${address.addressLine1}$line2, ${address.city}, ${address.state} ${address.postalCode}';
      } catch (_) {
        addressText = null;
      }
    }

    emit(OrderDetailLoaded(detailed, addressText: addressText));
  }

  Future<void> cancelOrder(OrderModel order) async {
    if (!canCancelOrder(order)) {
      emit(OrderCancelError('Cannot cancel this order. It is already out for delivery or has been delivered.'));
      return;
    }

    emit(OrderCancelling());
    try {
      await _ordersRemote.cancelOrder(order.uuid);
      emit(OrderCancelled(order.copyWith(orderStatus: 'CANCELLED')));
    } catch (e) {
      emit(OrderCancelError('Failed to cancel order. Please try again.'));
    }
  }

  bool canCancelOrder(OrderModel order) {
    final cancelableStatuses = ['PENDING', 'CONFIRMED', 'PROCESSING', 'PACKED'];
    return cancelableStatuses.contains(order.orderStatus.toUpperCase()) &&
        !order.isCancelled;
  }
}
