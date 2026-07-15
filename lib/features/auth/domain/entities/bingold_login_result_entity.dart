import 'package:equatable/equatable.dart';
import 'user_entity.dart';

class BinGoldLoginResultEntity extends Equatable {
  final UserEntity user;
  final bool requiresPasswordSetup;

  const BinGoldLoginResultEntity({
    required this.user,
    required this.requiresPasswordSetup,
  });

  @override
  List<Object?> get props => [user, requiresPasswordSetup];
}
