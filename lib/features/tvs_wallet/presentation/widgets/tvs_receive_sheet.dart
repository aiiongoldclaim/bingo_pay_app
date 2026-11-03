import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import 'tvs_ui.dart';

// My member QR: members scan it in the app to send me coins, or send to my
// email. The value is the one the transfer API resolves: tvs:u:<user uuid>.
class TvsReceiveSheet extends StatelessWidget {
  final String userUuid;
  final String email;

  const TvsReceiveSheet({
    super.key,
    required this.userUuid,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final code = 'tvs:u:$userUuid';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Receive TVS Coins',
              style: tvsText(
                colors.textPrimary,
                size: 18,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TvsQr(code, size: 200),
            const SizedBox(height: 16),
            Text(
              'Members scan this in the app, or send to your email. Both of you need a verified wallet.',
              textAlign: TextAlign.center,
              style: tvsText(colors.textSecondary, size: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: email));
                      AppSnackbar.showSuccess(context, 'Email copied');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(email, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Share',
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text: 'Send me TVS Coins: $email (member code $code)',
                    ),
                  ),
                  icon: const Icon(Icons.share_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
