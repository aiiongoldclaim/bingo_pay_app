enum TransactionType { debit, credit, cashback, goldSaving }

class WalletModel {
  final double balanceInr;
  final double goldGrams;
  final int coins;
  final String walletName;

  const WalletModel({
    required this.balanceInr,
    required this.goldGrams,
    required this.coins,
    this.walletName = 'BINGOLD Wallet',
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    balanceInr: (json['balanceInr'] as num).toDouble(),
    goldGrams: (json['goldGrams'] as num).toDouble(),
    coins: json['coins'] as int,
    walletName: json['walletName'] as String? ?? 'BINGOLD Wallet',
  );
}

class TransactionModel {
  final String id;
  final String title;
  final String subtitle; // "Order #BG-48231 · Today"
  final double amount; // negative = debit, positive = credit
  final TransactionType type;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
  });

  bool get isCredit => amount > 0;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
      );
}

class GoldRateModel {
  final String karat; // "24K"
  final double pricePerGram; // 6842
  final double changePercent; // +1.2

  const GoldRateModel({
    required this.karat,
    required this.pricePerGram,
    required this.changePercent,
  });
}
