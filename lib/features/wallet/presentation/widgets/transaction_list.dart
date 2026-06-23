import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    this.title = 'Transactions',
    this.filterLabel = 'Filter',
    this.onFilter,
    this.emptyMessage = 'No transactions yet.',
  });

  final List<TransactionTileData> transactions;
  final String title;
  final String filterLabel;
  final VoidCallback? onFilter;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ListHeader(title: title, filterLabel: filterLabel, onFilter: onFilter),
        const SizedBox(height: 14),
        transactions.isEmpty
            ? _EmptyState(message: emptyMessage)
            : _TransactionCard(transactions: transactions),
      ],
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.title,
    required this.filterLabel,
    this.onFilter,
  });

  final String title;
  final String filterLabel;
  final VoidCallback? onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        if (onFilter != null)
          GestureDetector(
            onTap: onFilter,
            child: Text(
              filterLabel,
              style: AppTextStyles.labelLarge.copyWith(color: ThemeColors.blue),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodyMedium,
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transactions});
  final List<TransactionTileData> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.ink.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 64,
          endIndent: 16,
          color: ThemeColors.line,
        ),
        itemBuilder: (_, i) => TransactionTile(data: transactions[i]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction Tile
// ─────────────────────────────────────────────────────────────────────────────

/// A single row showing icon, title/subtitle, and a signed amount.
/// Can be used standalone or inside [TransactionList].
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.data});

  final TransactionTileData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _TileIcon(
            icon: data.icon,
            iconColor:
                data.iconColor ?? _fallbackIconColor(data.amountIsCredit),
            backgroundColor:
                data.iconBackgroundColor ??
                _fallbackIconBg(data.amountIsCredit),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: AppTextStyles.labelLarge),
                const SizedBox(height: 3),
                Text(data.subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            data.formattedAmount,
            style: AppTextStyles.labelLarge.copyWith(
              color:
                  data.amountColor ??
                  (data.amountIsCredit ? ThemeColors.green : ThemeColors.ink),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _fallbackIconColor(bool isCredit) =>
      isCredit ? ThemeColors.green : ThemeColors.inkMid;

  Color _fallbackIconBg(bool isCredit) =>
      isCredit ? ThemeColors.greenSoft : ThemeColors.line2;
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(child: Icon(icon, size: 18, color: iconColor)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class
// ─────────────────────────────────────────────────────────────────────────────

/// Pure data object for [TransactionTile] — no dependency on any domain model.
///
/// Use [TransactionTileData.fromDomain] to convert your [TransactionModel].
class TransactionTileData {
  const TransactionTileData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.formattedAmount,
    required this.amountIsCredit,
    this.iconColor,
    this.iconBackgroundColor,
    this.amountColor,
    this.onTap,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Pre-formatted string, e.g. "−₹22,642" or "+₹10,000".
  final String formattedAmount;
  final bool amountIsCredit;

  /// Optional overrides — if null, defaults based on [amountIsCredit].
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? amountColor;
  final VoidCallback? onTap;

  // ── Convenience factory ───────────────────────────────────────────────────

  /// Converts a domain [TransactionModel] + [TransactionType] into display data.
  ///
  /// Import your domain types and wire this up in your cubit/mapper layer,
  /// keeping the widget layer free of domain imports.
  static TransactionTileData fromValues({
    required String id,
    required String title,
    required String subtitle,
    required double amount,
    required TransactionTileType type,
    VoidCallback? onTap,
  }) {
    final isCredit = amount > 0;
    final abs = amount.abs().toInt();
    final formatted = '${isCredit ? '+' : '−'}₹${_formatInr(abs)}';

    final icon = _iconFor(type);
    final iconBg = _iconBgFor(type);
    final iconColor = _iconColorFor(type);

    return TransactionTileData(
      id: id,
      title: title,
      subtitle: subtitle,
      icon: icon,
      formattedAmount: formatted,
      amountIsCredit: isCredit,
      iconColor: iconColor,
      iconBackgroundColor: iconBg,
      onTap: onTap,
    );
  }

  static String _formatInr(int val) {
    if (val >= 1000) {
      final t = val ~/ 1000;
      final r = val % 1000;
      return '$t,${r.toString().padLeft(3, '0')}';
    }
    return val.toString();
  }

  static IconData _iconFor(TransactionTileType t) {
    switch (t) {
      case TransactionTileType.debit:
        return Icons.delete_outline_rounded;
      case TransactionTileType.credit:
        return Icons.add_rounded;
      case TransactionTileType.cashback:
        return Icons.card_giftcard_rounded;
      case TransactionTileType.goldSaving:
        return Icons.toll_rounded;
    }
  }

  static Color _iconBgFor(TransactionTileType t) {
    switch (t) {
      case TransactionTileType.debit:
      case TransactionTileType.goldSaving:
        return ThemeColors.line2;
      case TransactionTileType.credit:
      case TransactionTileType.cashback:
        return ThemeColors.greenSoft;
    }
  }

  static Color _iconColorFor(TransactionTileType t) {
    switch (t) {
      case TransactionTileType.debit:
        return ThemeColors.inkMid;
      case TransactionTileType.goldSaving:
        return ThemeColors.inkDim;
      case TransactionTileType.credit:
      case TransactionTileType.cashback:
        return ThemeColors.green;
    }
  }
}

/// UI-layer enum — mirrors your domain [TransactionType] but lives in the
/// widget layer so the widget has no domain import.
enum TransactionTileType { debit, credit, cashback, goldSaving }
