import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../security/email_qr_codec.dart';
import '../theme/app_dimensions.dart';

Future<void> showEmailQrSheet(BuildContext context, {required String email}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
    ),
    builder: (context) => _EmailQrSheet(email: email),
  );
}

class _EmailQrSheet extends StatelessWidget {
  final String email;

  const _EmailQrSheet({required this.email});

  @override
  Widget build(BuildContext context) {
    final payload = EmailQrCodec.encrypt(email);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('My QR code', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppDimensions.md),
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: QrImageView(data: payload, size: 220),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              "Your Bingold Wallet QR code. Share this with your customers to receive payments directly into your wallet.",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
