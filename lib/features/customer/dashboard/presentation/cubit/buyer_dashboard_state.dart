import 'package:equatable/equatable.dart';

class BuyerDashboardState extends Equatable {
  final bool isLoading;
  final BuyerDashboardData? data;
  final String? errorMessage;

  const BuyerDashboardState({
    required this.isLoading,
    this.data,
    this.errorMessage,
  });

  const BuyerDashboardState.initial()
      : isLoading = false,
        data = null,
        errorMessage = null;

  const BuyerDashboardState.loading()
      : isLoading = true,
        data = null,
        errorMessage = null;

  const BuyerDashboardState.loaded(BuyerDashboardData data)
      : isLoading = false,
        data = data,
        errorMessage = null;

  const BuyerDashboardState.error(String message)
      : isLoading = false,
        data = null,
        errorMessage = message;

  @override
  List<Object?> get props => [isLoading, data, errorMessage];
}

class BuyerDashboardData extends Equatable {
  final BuyerProfile profile;
  final List<RecentOrder> recentOrders;
  final ActiveOrder? activeOrder;
  final List<SavedItem> savedItems;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final RewardSummary rewards;

  const BuyerDashboardData({
    required this.profile,
    required this.recentOrders,
    required this.activeOrder,
    required this.savedItems,
    required this.addresses,
    required this.paymentMethods,
    required this.rewards,
  });

  const BuyerDashboardData.empty()
      : profile = const BuyerProfile.mockEmpty(),
        recentOrders = const [],
        activeOrder = null,
        savedItems = const [],
        addresses = const [],
        paymentMethods = const [],
        rewards = const RewardSummary.empty();

  @override
  List<Object?> get props => [
        profile,
        recentOrders,
        activeOrder,
        savedItems,
        addresses,
        paymentMethods,
        rewards,
      ];
}

class BuyerProfile extends Equatable {
  final String name;
  final String statusLabel;
  final String avatarInitials;

  const BuyerProfile({
    required this.name,
    required this.statusLabel,
    required this.avatarInitials,
  });

  const BuyerProfile.mockEmpty()
      : name = '',
        statusLabel = '',
        avatarInitials = '';

  factory BuyerProfile.mock({
    required String name,
    required String statusLabel,
  }) {
    return BuyerProfile(
      name: name,
      statusLabel: statusLabel,
      avatarInitials: _initialsFromName(name),
    );
  }

  static String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first;
    if (parts.length == 1) {
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [name, statusLabel, avatarInitials];
}

class RecentOrder extends Equatable {
  final String id;
  final String title;
  final String statusLabel;

  const RecentOrder({
    required this.id,
    required this.title,
    required this.statusLabel,
  });

  @override
  List<Object?> get props => [id, title, statusLabel];
}

class ActiveOrder extends Equatable {
  final String id;
  final String statusLabel;
  final String etaLabel;

  const ActiveOrder({
    required this.id,
    required this.statusLabel,
    required this.etaLabel,
  });

  @override
  List<Object?> get props => [id, statusLabel, etaLabel];
}

class SavedItem extends Equatable {
  final String id;
  final String title;

  const SavedItem({required this.id, required this.title});

  @override
  List<Object?> get props => [id, title];
}

class Address extends Equatable {
  final String id;
  final String line1;
  final String city;

  const Address({
    required this.id,
    required this.line1,
    required this.city,
  });

  @override
  List<Object?> get props => [id, line1, city];
}

class PaymentMethod extends Equatable {
  final String id;
  final String label;
  final String suffix;

  const PaymentMethod({
    required this.id,
    required this.label,
    required this.suffix,
  });

  @override
  List<Object?> get props => [id, label, suffix];
}

class RewardSummary extends Equatable {
  final num walletBalance;
  final int rewardPoints;

  const RewardSummary({required this.walletBalance, required this.rewardPoints});

  const RewardSummary.empty() : walletBalance = 0, rewardPoints = 0;

  @override
  List<Object?> get props => [walletBalance, rewardPoints];
}

