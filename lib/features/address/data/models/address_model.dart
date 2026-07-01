import '../../domain/entities/address_entity.dart';

class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String? landmark;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    this.landmark,
    required this.isDefault,
  });

  /// 🔁 JSON → Model
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'].toString(),
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postalCode'] ?? '',
      landmark: json['landmark'],
      isDefault: json['isDefault'] ?? false,
    );
  }

  /// 🔁 Model → JSON (API Payload)
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "phone": phone,
      "addressLine1": addressLine1,
      "addressLine2": addressLine2,
      "city": city,
      "state": state,
      "country": country,
      "postalCode": postalCode,
      "landmark": landmark,
      "isDefault": isDefault,
    };
  }

  /// 🔁 Model → Entity
  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      fullName: fullName,
      phoneNumber: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      landmark: landmark,
      isDefaultAddress: isDefault,
    );
  }

  /// 🔁 Entity → Model
  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      fullName: entity.fullName,
      phone: entity.phoneNumber,
      addressLine1: entity.addressLine1,
      addressLine2: entity.addressLine2,
      city: entity.city,
      state: entity.state,
      country: entity.country,
      postalCode: entity.postalCode,
      landmark: entity.landmark,
      isDefault: entity.isDefaultAddress,
    );
  }
}