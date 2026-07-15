import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SubmitVendorKycUseCase {
  final AuthRepository _repository;
  const SubmitVendorKycUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call(SubmitVendorKycParams params) =>
      _repository.submitVendorKyc(
        kybMode: params.kybMode,
        documents: params.documents,
      );
}

class KycDocumentSubmission extends Equatable {
  final String documentType;
  final String documentUrl;
  final String publicId;

  const KycDocumentSubmission({
    required this.documentType,
    required this.documentUrl,
    required this.publicId,
  });

  Map<String, dynamic> toJson() => {
        'documentType': documentType,
        'documentUrl': documentUrl,
        'publicId': publicId,
      };

  @override
  List<Object> get props => [documentType, documentUrl, publicId];
}

class SubmitVendorKycParams extends Equatable {
  final String kybMode;
  final List<KycDocumentSubmission> documents;

  const SubmitVendorKycParams({
    this.kybMode = 'ONLINE',
    required this.documents,
  });

  @override
  List<Object> get props => [kybMode, documents];
}
