import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/kyc_entity.dart';

part 'kyc_model.g.dart';

@JsonSerializable()
class KycModel extends KycEntity {
  const KycModel({required super.status, super.rejectionReason});

  factory KycModel.fromJson(Map<String, dynamic> json) =>
      _$KycModelFromJson(json);

  Map<String, dynamic> toJson() => _$KycModelToJson(this);
}
