// Checkout charges (tax, delivery, fees) worked out from the rules the server
// publishes at GET /settings/charges (Settings → Charges), the same way the
// server's charge-calculator.ts prices an order. Rules arrive in the order
// the server applies them.
//
// shortcut: the public rules leave out `base`, `minAmount` and `maxAmount`;
// they are used when present, otherwise a percentage is of the item subtotal
// with no floor or cap. Until the endpoint returns them, a rule set up with
// those can make the app's figures differ from what the server charges.

class ChargeLine {
  final double subtotal;
  final int quantity;
  final bool isService;
  final String vendor;

  const ChargeLine({
    required this.subtotal,
    this.quantity = 1,
    this.isService = false,
    this.vendor = 'single',
  });
}

double _round2(num v) => (v * 100).round() / 100;

num? _num(Object? v) => v is num ? v : num.tryParse('${v ?? ''}');

// `method` is the payment rail (BIGOD, STRIPE, NOWPAYMENTS, TVS_WALLET): a rule
// limited to some methods is skipped for any other, and when there is none.
({double tax, double shipping, double fee}) computeCharges(
  List<Map<String, dynamic>> rules,
  List<ChargeLine> lines, {
  String? method,
}) {
  var tax = 0.0, shipping = 0.0, fee = 0.0, running = 0.0;

  for (final rule in rules) {
    final methods = (rule['paymentMethods'] as List?) ?? const [];
    if (methods.isNotEmpty && (method == null || !methods.contains(method))) {
      continue;
    }

    final appliesTo = rule['appliesTo'] ?? 'ALL';
    final matching = lines
        .where(
          (l) =>
              appliesTo == 'ALL' ||
              (l.isService ? 'SERVICE' : 'PRODUCT') == appliesTo,
        )
        .toList();
    if (matching.isEmpty) continue;

    final subtotal = _round2(matching.fold(0.0, (s, l) => s + l.subtotal));
    final minOrder = _num(rule['minOrderValue']);
    if (minOrder != null && subtotal < minOrder) continue;
    final freeAbove = _num(rule['freeAbove']);
    if (freeAbove != null && subtotal >= freeAbove) continue;

    final value = _num(rule['value']) ?? 0;
    var amount = switch (rule['calcType']) {
      'PERCENTAGE' =>
        (rule['base'] == 'SUBTOTAL_WITH_CHARGES' ? subtotal + running : subtotal) *
            (value / 100),
      'PER_ITEM' => value * matching.fold<int>(0, (s, l) => s + l.quantity),
      'PER_VENDOR' => value * matching.map((l) => l.vendor).toSet().length,
      _ => value, // FLAT
    }.toDouble();

    final minAmount = _num(rule['minAmount']);
    if (minAmount != null && amount < minAmount) amount = minAmount.toDouble();
    final maxAmount = _num(rule['maxAmount']);
    if (maxAmount != null && amount > maxAmount) amount = maxAmount.toDouble();
    amount = _round2(amount);
    if (!(amount > 0)) continue;

    running = _round2(running + amount);
    switch (rule['bucket']) {
      case 'TAX':
        tax += amount;
      case 'SHIPPING':
        shipping += amount;
      case 'FEE':
        fee += amount;
    }
  }

  return (tax: _round2(tax), shipping: _round2(shipping), fee: _round2(fee));
}
