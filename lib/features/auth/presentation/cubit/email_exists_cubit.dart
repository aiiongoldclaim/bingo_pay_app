import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/check_user_exists_usecase.dart';
import 'email_exists_state.dart';

@injectable
class EmailExistsCubit extends Cubit<EmailExistsState> {
  final CheckUserExistsUseCase _checkUserExists;

  EmailExistsCubit(this._checkUserExists) : super(const EmailExistsInitial());

  Future<void> checkEmail(String email) async {
    emit(const EmailExistsChecking());
    final result = await _checkUserExists(email);
    result.match(
      (failure) => emit(const EmailExistsInitial()),
      (exists) => emit(EmailExistsResult(email: email, exists: exists)),
    );
  }

  void reset() => emit(const EmailExistsInitial());
}
