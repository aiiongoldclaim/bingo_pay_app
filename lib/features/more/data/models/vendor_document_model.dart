class VendorDocumentModel {
  final String id;
  final String? userId;
  final String vendorId;
  final String documentType;
  final String documentUrl;
  final String verificationStatus;
  final String? remarks;
  final String? verifiedById;
  final DateTime? verifiedAt;
  final DateTime? createdAt;
  final String? publicId;

  const VendorDocumentModel({
    required this.id,
    required this.vendorId,
    required this.documentType,
    required this.documentUrl,
    required this.verificationStatus,
    this.userId,
    this.remarks,
    this.verifiedById,
    this.verifiedAt,
    this.createdAt,
    this.publicId,
  });

  bool get isApproved => verificationStatus.toUpperCase() == 'APPROVED';
  bool get isPending => verificationStatus.toUpperCase() == 'PENDING';
  bool get isRejected => verificationStatus.toUpperCase() == 'REJECTED';

  /// "GST_CERTIFICATE" → "Gst Certificate"
  String get documentTypeLabel => documentType
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');

  factory VendorDocumentModel.fromJson(Map<String, dynamic> json) {
    return VendorDocumentModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString(),
      vendorId: json['vendorId']?.toString() ?? '',
      documentType: json['documentType']?.toString() ?? '',
      documentUrl: json['documentUrl']?.toString() ?? '',
      verificationStatus: json['verificationStatus']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
      verifiedById: json['verifiedById']?.toString(),
      verifiedAt: DateTime.tryParse(json['verifiedAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      publicId: json['publicId']?.toString(),
    );
  }
}
