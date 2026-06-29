// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../data/account_model/account_model.dart';
// import 'account_state.dart';
//
// class AccountCubit extends Cubit<AccountState> {
//   AccountCubit() : super(const AccountLoading());
//
//   /// Mock data — swap with repository.fetchAccount() when backend ready.
//   Future<void> loadAccount() async {
//     try {
//       emit(const AccountLoading());
//       await Future.delayed(const Duration(milliseconds: 350));
//       emit(
//         const AccountLoaded(
//           account: AccountModel(
//             id: 'usr_001',
//             fullName: 'Aarav Mehta',
//             email: 'aarav.mehta@email.com',
//             membershipTier: 'Gold member',
//             walletBalance: 12480,
//             coins: 480,
//             wishlistCount: 24,
//           ),
//         ),
//       );
//     } catch (e) {
//       emit(AccountError(e.toString()));
//     }
//   }
//
//   void onEditProfile() {
//     // TODO: navigate to edit profile
//   }
//
//   void onMenuTap(String route) {
//     // TODO: navigate via GoRouter to route
//   }
//
//   void onWalletTap() {
//     // TODO: navigate to wallet screen
//   }
// }

// lib/features/account/presentation/cubit/account_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecase/get_account_usecase.dart';
import 'account_state.dart';

export 'account_state.dart';

@injectable
class AccountCubit extends Cubit<AccountState> {
  final GetProfileUseCase _getProfile;

  AccountCubit(this._getProfile) : super(const AccountInitial());

  Future<void> loadProfile() async {
    emit(const AccountLoading());
    final result = await _getProfile();
    result.fold(
      (failure) => emit(AccountError(failure.message)),
      (account) => emit(AccountLoaded(account)),
    );
  }

  Future<void> refresh() async {
    await loadProfile();
  }

  void onEditProfile() {
    // TODO
  }
}
