import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Icon + colour pair shown on a notification tile, keyed off the API's
/// free-form `type` string. Unknown types fall back to a generic bell so a
/// new backend notification type never crashes or looks broken.
(IconData, Color, Color) notificationTypeStyle(BuildContext context, String type) {
  final colors = context.colors;
  if (type.startsWith('PRODUCT')) {
    return (Icons.inventory_2_outlined, colors.infoFg, colors.infoTint);
  }
  if (type.startsWith('ORDER')) {
    return (Icons.shopping_bag_outlined, colors.purpleFg, colors.purpleTint);
  }
  if (type.startsWith('KYC') || type.startsWith('VENDOR')) {
    return (Icons.verified_user_outlined, colors.successFg, colors.successTint);
  }
  if (type.startsWith('PAYMENT') || type.startsWith('WALLET')) {
    return (Icons.account_balance_wallet_outlined, colors.warningFg, colors.warningTint);
  }
  return (Icons.notifications_none, colors.textSecondary, colors.infoTint);
}
