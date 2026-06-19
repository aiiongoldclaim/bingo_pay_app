import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../product_details/data/models/product_mock_data.dart';
import '../../data/models/category_model.dart';
import 'dashboard_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading));

    await Future.delayed(const Duration(milliseconds: 500));

    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        userName: "Aarav Mehta",
        walletAmount: 12480,
        goldWeight: "1.84g gold",
        categories: [
          CategoryModel(
            title: "Electronics",
            icon: Icons.devices_outlined,
            backgroundColor: const Color(0xFFE8ECF8),
            iconColor: Colors.blue,
          ),

          CategoryModel(
            title: "Fashion",
            icon: Icons.shopping_bag_outlined,
            backgroundColor: const Color(0xFFF7EFD7),
            iconColor: const Color(0xFFC9A84C),
          ),

          CategoryModel(
            title: "Audio",
            icon: Icons.headphones_outlined,
            backgroundColor: const Color(0xFFE8F3EC),
            iconColor: Colors.green,
          ),

          CategoryModel(
            title: "Home & Living",
            icon: Icons.chair_outlined,
            backgroundColor: const Color(0xFFF5EBDD),
            iconColor: Colors.brown,
          ),

          CategoryModel(
            title: "Beauty",
            icon: Icons.face_retouching_natural,
            backgroundColor: const Color(0xFFF7E5EF),
            iconColor: Colors.pink,
          ),

          CategoryModel(
            title: "Sports",
            icon: Icons.sports_basketball_outlined,
            backgroundColor: const Color(0xFFE8F0FF),
            iconColor: Colors.deepPurple,
          ),
        ],
        flashDeals: ProductMockData.flashDeals(),
        recommended: ProductMockData.recommended(),
      ),
    );
  }
}
