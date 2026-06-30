import 'categories_model.dart';

class CategoryResponseModel {
  final bool success;
  final List<CategoryModel> data;

  const CategoryResponseModel({required this.success, required this.data});

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>;
    final list = outer['data'] as List<dynamic>;
    return CategoryResponseModel(
      success: json['success'] as bool,
      data: list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
