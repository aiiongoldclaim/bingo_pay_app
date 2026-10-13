// Payloads are the API's maps (see TvsQrDataSource).
class PaymentState {
  final Map<String, dynamic>? shop; // from /qr/resolve
  final Map<String, dynamic>? quote; // for the amount and code typed now
  final String? error; // why resolve or quote failed
  final bool quoting;
  final bool paying;

  const PaymentState({
    this.shop,
    this.quote,
    this.error,
    this.quoting = false,
    this.paying = false,
  });

  bool get canPay => shop?['canPay'] == true;

  bool get canSubmit =>
      canPay &&
      quote?['sufficient'] == true &&
      !quoting &&
      !paying;

  static const _keep = Object();

  PaymentState copyWith({
    Object? shop = _keep,
    Object? quote = _keep,
    Object? error = _keep,
    bool? quoting,
    bool? paying,
  }) {
    return PaymentState(
      shop: identical(shop, _keep) ? this.shop : shop as Map<String, dynamic>?,
      quote:
          identical(quote, _keep) ? this.quote : quote as Map<String, dynamic>?,
      error: identical(error, _keep) ? this.error : error as String?,
      quoting: quoting ?? this.quoting,
      paying: paying ?? this.paying,
    );
  }
}
