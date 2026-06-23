import 'package:flutter/cupertino.dart';

enum PaymentMethod { bingoldWallet, upi, creditDebit, payLater, cashOnDelivery }

class PaymentMethodModel {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailing;
  final PaymentMethod method;

  const PaymentMethodModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.method,
  });
}
