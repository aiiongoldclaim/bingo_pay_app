import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String uuid;
  final String name;
  final String slug;
  final String? description;
  final String? image;

  const CategoryEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [id, uuid, name, slug, description, image];
}
