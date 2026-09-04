import '../../../categories/data/models/categories_model.dart';
import '../../data/models/product_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final String userName;
  final double bigoldBalance;
  final List<CategoryModel> categories;
  final List<ProductModel> flashDeals;
  final List<ProductModel> recommended;

  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.userName = '',
    this.bigoldBalance = 0.0,
    this.categories = const [],
    this.flashDeals = const [],
    this.recommended = const [],
    this.errorMessage,
  });

  String get formattedBigoldBalance {
    if (bigoldBalance <= 0) return '0.00 Bigod';
    String s = bigoldBalance.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return '$s Bigod';
  }


  /// Same trim-to-8-decimals rule as [formattedBigoldBalance] (no unit
  /// suffix, for tight spaces like the dashboard wallet chip). A flat
  /// toStringAsFixed(2) would round every sub-cent Bigold balance — the
  /// normal case for this currency — down to a misleading "$0.00".
  String get compactBigoldBalance {
    if (bigoldBalance <= 0) return '\$0.00';
    String s = bigoldBalance.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return '\$$s';
  }

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    double? bigoldBalance,
    List<CategoryModel>? categories,
    List<ProductModel>? flashDeals,
    List<ProductModel>? recommended,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      bigoldBalance: bigoldBalance ?? this.bigoldBalance,
      categories: categories ?? this.categories,
      flashDeals: flashDeals ?? this.flashDeals,
      recommended: recommended ?? this.recommended,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
