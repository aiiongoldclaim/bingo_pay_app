import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../../../account/data/account_model/account_profile_response.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import 'dashboard_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final client = GetIt.I<ApiClient>();
    String userName = '';
    double bigoldBalance = 0.0;

    // Fetch real profile data
    try {
      final profileRes = await client.dio.get(ApiEndpoints.profile);
      final profile = AccountResponseModel.fromJson(
        profileRes.data as Map<String, dynamic>,
      );
      userName = profile.account.fullName;
    } catch (_) {}

    // Fetch products
    try {
      final url = '${AppConfig.categoriesApiBaseUrl}/api/v1/products';
      final response = await client.dio.get(
        url,
        queryParameters: {'page': 1, 'limit': 20},
      );
      final raw = response.data as Map<String, dynamic>;
      final dataList = (raw['data'] as List<dynamic>?) ?? [];
      final products = dataList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(state.copyWith(
        status: HomeStatus.loaded,
        userName: userName,
        bigoldBalance: bigoldBalance,
        categories: _staticCategories(),
        flashDeals: products.take(6).toList(),
        recommended: products,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: HomeStatus.loaded,
        userName: userName,
        bigoldBalance: bigoldBalance,
        categories: _staticCategories(),
        flashDeals: [],
        recommended: [],
      ));
    }
  }

  List<CategoryModel> _staticCategories() => [
        CategoryModel(
          title: 'Electronics',
          icon: Icons.devices_outlined,
          backgroundColor: const Color(0xFFE8ECF8),
          iconColor: Colors.blue,
        ),
        CategoryModel(
          title: 'Fashion',
          icon: Icons.shopping_bag_outlined,
          backgroundColor: const Color(0xFFF7EFD7),
          iconColor: const Color(0xFFC9A84C),
        ),
        CategoryModel(
          title: 'Audio',
          icon: Icons.headphones_outlined,
          backgroundColor: const Color(0xFFE8F3EC),
          iconColor: Colors.green,
        ),
        CategoryModel(
          title: 'Home & Living',
          icon: Icons.chair_outlined,
          backgroundColor: const Color(0xFFF5EBDD),
          iconColor: Colors.brown,
        ),
        CategoryModel(
          title: 'Beauty',
          icon: Icons.face_retouching_natural,
          backgroundColor: const Color(0xFFF7E5EF),
          iconColor: Colors.pink,
        ),
        CategoryModel(
          title: 'Sports',
          icon: Icons.sports_basketball_outlined,
          backgroundColor: const Color(0xFFE8F0FF),
          iconColor: Colors.deepPurple,
        ),
      ];
}
