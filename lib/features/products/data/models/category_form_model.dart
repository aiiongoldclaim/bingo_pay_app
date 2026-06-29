class FormAttributeOption {
  final String id;
  final String value;
  final int sortOrder;

  const FormAttributeOption({
    required this.id,
    required this.value,
    required this.sortOrder,
  });

  factory FormAttributeOption.fromJson(Map<String, dynamic> json) =>
      FormAttributeOption(
        id: json['id'].toString(),
        value: json['value'] as String? ?? '',
        sortOrder: json['sortOrder'] as int? ?? 0,
      );
}

class FormAttribute {
  final String id;
  final String uuid;
  final String name;
  final String fieldType;
  final bool isRequired;
  final bool isVariant;
  final int sortOrder;
  final List<FormAttributeOption> options;

  const FormAttribute({
    required this.id,
    required this.uuid,
    required this.name,
    required this.fieldType,
    required this.isRequired,
    required this.isVariant,
    required this.sortOrder,
    required this.options,
  });

  factory FormAttribute.fromJson(Map<String, dynamic> json) => FormAttribute(
        id: json['id'].toString(),
        uuid: json['uuid'] as String? ?? '',
        name: json['name'] as String? ?? '',
        fieldType: json['fieldType'] as String? ?? 'TEXT',
        isRequired: json['isRequired'] as bool? ?? false,
        isVariant: json['isVariant'] as bool? ?? false,
        sortOrder: json['sortOrder'] as int? ?? 0,
        options: (json['options'] as List? ?? [])
            .whereType<Map>()
            .map((e) => FormAttributeOption.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
            .toList(),
      );
}

class CategoryFormData {
  final List<FormAttribute> specificationAttributes;
  final List<FormAttribute> variantAttributes;

  const CategoryFormData({
    required this.specificationAttributes,
    required this.variantAttributes,
  });

  bool get hasSpecifications => specificationAttributes.isNotEmpty;
}
