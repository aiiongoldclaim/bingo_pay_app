class AccountModel {
  final String id;
  final String fullName;
  final String email;
  final String membershipTier; // "Gold member", "Silver member"
  final double walletBalance;
  final int coins;
  final int wishlistCount;
  final String? avatarUrl;

  const AccountModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.membershipTier,
    required this.walletBalance,
    required this.coins,
    required this.wishlistCount,
    this.avatarUrl,
  });

  String get initial => fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
    id: json['id'] as String,
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    membershipTier: json['membershipTier'] as String,
    walletBalance: (json['walletBalance'] as num).toDouble(),
    coins: json['coins'] as int,
    wishlistCount: json['wishlistCount'] as int,
    avatarUrl: json['avatarUrl'] as String?,
  );
}

class AccountMenuItem {
  final String title;
  final String subtitle;
  final String iconAsset; // key for icon lookup
  final String route;

  const AccountMenuItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.route,
  });
}
