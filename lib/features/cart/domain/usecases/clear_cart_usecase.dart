import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/cart_repository.dart';

@injectable
class ClearCartUseCase {
  final CartRepository repository;

  const ClearCartUseCase(this.repository);

  Future<Either<Failure, String>> call() => repository.clearCart();
}
