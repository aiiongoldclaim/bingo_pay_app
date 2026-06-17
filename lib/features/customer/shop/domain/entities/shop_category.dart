import 'package:equatable/equatable.dart';

class ShopCategory extends Equatable {
  final String slug;
  final String name;
  final String description;
  final int productCount;

  const ShopCategory({
    required this.slug,
    required this.name,
    required this.description,
    required this.productCount,
  });

  @override
  List<Object> get props => [slug, name, description, productCount];
}
