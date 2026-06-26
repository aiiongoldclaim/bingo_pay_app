import 'categories_model.dart';

class CategoryResponseModel {
  final bool success;
  final List<CategoryModel> data;

  const CategoryResponseModel({required this.success, required this.data});

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) =>
      CategoryResponseModel(
        success: json['success'] as bool,
        data: (json['data'] as List<dynamic>)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
