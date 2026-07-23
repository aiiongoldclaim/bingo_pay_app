import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final String id;
  final String uuid;
  final String name;
  final String? logo;
  final String? description;
  final bool isActive;

  const BrandEntity({
    required this.id,
    required this.uuid,
    required this.name,
    this.logo,
    this.description,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, uuid, name, logo, description, isActive];
}
