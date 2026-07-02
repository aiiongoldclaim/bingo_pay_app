import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/cart_repository.dart';

@injectable
class RemoveCartItemUseCase {
  final CartRepository repository;

  const RemoveCartItemUseCase(this.repository);

  Future<Either<Failure, String>> call({required int itemId}) {
    return repository.removeItem(itemId: itemId);
  }
}
