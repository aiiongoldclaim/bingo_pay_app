import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class UploadKycDocumentUseCase {
  final AuthRepository _repository;
  const UploadKycDocumentUseCase(this._repository);

  Future<Either<Failure, KycEntity>> call(KycDocumentParams params) =>
      _repository.uploadKycDocument(
        filePath: params.filePath,
        documentType: params.documentType,
      );
}

class KycDocumentParams extends Equatable {
  final String filePath;
  final String documentType;
  const KycDocumentParams({required this.filePath, required this.documentType});
  @override
  List<Object> get props => [filePath, documentType];
}
