class BulkRowError {
  final String field;
  final String message;

  const BulkRowError({required this.field, required this.message});

  factory BulkRowError.fromJson(Map<String, dynamic> json) {
    return BulkRowError(
      field: json['field']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
    );
  }
}

class BulkInvalidRow {
  final int rowNumber;
  final List<BulkRowError> errors;

  const BulkInvalidRow({required this.rowNumber, required this.errors});

  factory BulkInvalidRow.fromJson(Map<String, dynamic> json) {
    final errorsJson = json['errors'] as List? ?? [];
    return BulkInvalidRow(
      rowNumber: (json['rowNumber'] as num?)?.toInt() ?? 0,
      errors: errorsJson
          .whereType<Map>()
          .map(
            (e) => BulkRowError.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(),
    );
  }
}

class BulkImportResultModel {
  final int totalRows;
  final int? validCount;
  final int? invalidCount;
  final bool hasErrors;
  final List<BulkInvalidRow> invalidRows;
  final String? jobUuid;
  final String? message;

  const BulkImportResultModel({
    required this.totalRows,
    this.validCount,
    this.invalidCount,
    required this.hasErrors,
    required this.invalidRows,
    this.jobUuid,
    this.message,
  });

  factory BulkImportResultModel.fromJson(Map<String, dynamic> json) {
    final invalidRowsJson = json['invalidRows'] as List? ?? [];
    return BulkImportResultModel(
      totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
      validCount: (json['validCount'] as num?)?.toInt(),
      invalidCount: (json['invalidCount'] as num?)?.toInt(),
      hasErrors: json['hasErrors'] as bool? ?? false,
      invalidRows: invalidRowsJson
          .whereType<Map>()
          .map(
            (e) => BulkInvalidRow.fromJson(
              e.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(),
      jobUuid: json['jobUuid']?.toString(),
      message: json['message']?.toString(),
    );
  }
}
