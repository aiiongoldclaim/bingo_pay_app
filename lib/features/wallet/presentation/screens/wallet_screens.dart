import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/model/wallet_model.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../widgets/gold_banner.dart';
import '../widgets/transaction_list.dart';
import '../widgets/wallet_balance_card.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: CustomAppBar(
        // leading: IconButton(
        //   icon: const Icon(
        //     Icons.arrow_back_ios_new_rounded,
        //     color: ThemeColors.ink,
        //     size: 20,
        //   ),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: 'Wallet',
        actionIcon1: Icons.access_time_rounded,
        onAction1: () {},
      ),
      // appBar: _WalletAppBar(),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          return switch (state) {
            WalletLoading() => const Center(
              child: CircularProgressIndicator(color: ThemeColors.blue),
            ),
            WalletError(:final message) => Center(
              child: Text(message, style: AppTextStyles.bodyMedium),
            ),
            WalletLoaded() => _WalletBody(state: state),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body — maps WalletLoaded → widget data
// ─────────────────────────────────────────────────────────────────────────────

class _WalletBody extends StatelessWidget {
  const _WalletBody({required this.state});

  final WalletLoaded state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WalletCubit>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ── Balance card ────────────────────────────────────────────────────
        WalletCard(
          walletName: 'BINGOLD Wallet',
          balance: '\$12,480',
          subTitle: '≈ 1.84 g digital gold · 480 coins',
          onAddMoney: () {
            debugPrint('Add Money');
          },
          onSend: () {
            debugPrint('Send');
          },
        ),

        const SizedBox(height: 14),

        // ── Gold invest banner ───────────────────────────────────────────────
        GoldInvestBanner(
          title: 'Grow with digital gold',
          subtitle:
              '${state.goldRate.karat} · \$${state.goldRate.pricePerGram.toStringAsFixed(0)}/g'
              ' · +${state.goldRate.changePercent}% today',
          buttonLabel: 'Invest',
          onTap: cubit.onInvest,
        ),

        const SizedBox(height: 22),

        // ── Transactions ─────────────────────────────────────────────────────
        TransactionList(
          onFilter: cubit.onFilter,
          transactions: state.transactions
              .map(_toTileData)
              .toList(growable: false),
        ),
      ],
    );
  }

  static TransactionTileData _toTileData(TransactionModel tx) {
    return TransactionTileData.fromValues(
      id: tx.id,
      title: tx.title,
      subtitle: tx.subtitle,
      amount: tx.amount,
      type: _toTileType(tx.type),
    );
  }

  static TransactionTileType _toTileType(TransactionType t) {
    switch (t) {
      case TransactionType.debit:
        return TransactionTileType.debit;
      case TransactionType.credit:
        return TransactionTileType.credit;
      case TransactionType.cashback:
        return TransactionTileType.cashback;
      case TransactionType.goldSaving:
        return TransactionTileType.goldSaving;
    }
  }
}
