import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/wallet_model.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit() : super(const WalletLoading());

  Future<void> loadWallet() async {
    try {
      emit(const WalletLoading());
      await Future.delayed(const Duration(milliseconds: 350));

      final now = DateTime.now();

      emit(
        WalletLoaded(
          wallet: const WalletModel(
            balanceInr: 12480,
            goldGrams: 1.84,
            coins: 480,
          ),
          goldRate: const GoldRateModel(
            karat: '24K',
            pricePerGram: 6842,
            changePercent: 1.2,
          ),
          transactions: [
            TransactionModel(
              id: 'txn_1',
              title: 'Aurora Pro Headphones',
              subtitle: 'Order #BG-48231 · Today',
              amount: -22642,
              type: TransactionType.debit,
              date: now,
            ),
            TransactionModel(
              id: 'txn_2',
              title: 'Added money',
              subtitle: 'UPI · GPay · Today',
              amount: 10000,
              type: TransactionType.credit,
              date: now,
            ),
            TransactionModel(
              id: 'txn_3',
              title: 'Cashback · Festive Days',
              subtitle: 'BINGOLD reward · Yesterday',
              amount: 480,
              type: TransactionType.cashback,
              date: now.subtract(const Duration(days: 1)),
            ),
            TransactionModel(
              id: 'txn_4',
              title: 'Gold savings · 0.5g',
              subtitle: 'Auto-invest · 8 Jun',
              amount: -3120,
              type: TransactionType.goldSaving,
              date: now.subtract(const Duration(days: 2)),
            ),
          ],
        ),
      );
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  void onAddMoney() {
    // TODO: navigate to add money flow
  }

  void onSend() {
    // TODO: navigate to send money flow
  }

  void onInvest() {
    // TODO: navigate to gold investment flow
  }

  void onFilter() {
    // TODO: show transaction filter sheet
  }
}
