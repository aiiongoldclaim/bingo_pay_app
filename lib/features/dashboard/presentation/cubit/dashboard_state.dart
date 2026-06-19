import '../../../product_details/data/models/product_details_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;

  final String userName;
  final double walletAmount;
  final String goldWeight;

  final List<CategoryModel> categories;
  final List<ProductDetailModel> flashDeals;
  final List<ProductDetailModel> recommended;

  const HomeState({
    this.status = HomeStatus.initial,
    this.userName = '',
    this.walletAmount = 0,
    this.goldWeight = '',
    this.categories = const [],
    this.flashDeals = const [],
    this.recommended = const [],
  });

  HomeState copyWith({
    HomeStatus? status,
    String? userName,
    double? walletAmount,
    String? goldWeight,
    List<CategoryModel>? categories,
    List<ProductDetailModel>? flashDeals,
    List<ProductDetailModel>? recommended,
  }) {
    return HomeState(
      status: status ?? this.status,
      userName: userName ?? this.userName,
      walletAmount: walletAmount ?? this.walletAmount,
      goldWeight: goldWeight ?? this.goldWeight,
      categories: categories ?? this.categories,
      flashDeals: flashDeals ?? this.flashDeals,
      recommended: recommended ?? this.recommended,
    );
  }
}
