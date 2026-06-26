import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final String userName;
  final double bigoldBalance;
  final List<CategoryModel> categories;
  final List<ProductModel> flashDeals;
  final List<ProductModel> recommended;

  const HomeState({
    this.status = HomeStatus.initial,
    this.userName = '',
    this.bigoldBalance = 0.0,
    this.categories = const [],
    this.flashDeals = const [],
    this.recommended = const [],
  });

  String get formattedBigoldBalance {
    if (bigoldBalance <= 0) return '0.00 Bigod';
    final fixed8 = bigoldBalance.toStringAsFixed(8);
    final decimals = fixed8.split('.').last;
    final allZero = decimals.split('').every((c) => c == '0');
    final amount = allZero ? bigoldBalance.toStringAsFixed(2) : fixed8;
    return '$amount Bigod';
  }

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    double? bigoldBalance,
    List<CategoryModel>? categories,
    List<ProductModel>? flashDeals,
    List<ProductModel>? recommended,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      bigoldBalance: bigoldBalance ?? this.bigoldBalance,
      categories: categories ?? this.categories,
      flashDeals: flashDeals ?? this.flashDeals,
      recommended: recommended ?? this.recommended,
    );
  }
}
