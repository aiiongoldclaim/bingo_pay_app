class AttributeOptionModel {
  final String id;
  final String categoryAttributeId;
  final String value;
  final int sortOrder;

  const AttributeOptionModel({
    required this.id,
    required this.categoryAttributeId,
    required this.value,
    required this.sortOrder,
  });

  factory AttributeOptionModel.fromJson(Map<String, dynamic> json) {
    return AttributeOptionModel(
      id: json['id'].toString(),
      categoryAttributeId: json['categoryAttributeId'].toString(),
      value: json['value'] as String? ?? '',
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
