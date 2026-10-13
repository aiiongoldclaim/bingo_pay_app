import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';

enum StripeCheckoutReturn { success, cancelled }

// The server ends the return URL with `?from=success` or `?from=cancelled`.
final _returnMarker = RegExp(r'[?&]from=(success|cancelled)(?:[&#]|$)');

// Null unless `url` is the storefront page Stripe sends the customer back to.
// NOWPayments' crypto invoice page returns the same way.
StripeCheckoutReturn? stripeReturnOutcome(String url) {
  final host = Uri.tryParse(url)?.host ?? '';
  for (final gateway in const ['stripe.com', 'nowpayments.io']) {
    if (host == gateway || host.endsWith('.$gateway')) return null;
  }

  return switch (_returnMarker.firstMatch(url)?.group(1)) {
    'success' => StripeCheckoutReturn.success,
    'cancelled' => StripeCheckoutReturn.cancelled,
    _ => null,
  };
}

// Wallet and bank-app links (`bitcoin:`, `ethereum:`, `wc:`…) are not pages:
// the WebView cannot open them, the phone can.
bool opensOutsideWebView(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      uri.hasScheme &&
      !const {'http', 'https', 'about', 'data', 'blob'}.contains(uri.scheme);
}

// Stripe's hosted checkout page, or NOWPayments' invoice page, shown inside
// the app.
class StripeCheckoutView extends StatefulWidget {
  final String checkoutUrl;
  final ValueChanged<StripeCheckoutReturn> onReturn;

  const StripeCheckoutView({
    super.key,
    required this.checkoutUrl,
    required this.onReturn,
  });

  @override
  State<StripeCheckoutView> createState() => _StripeCheckoutViewState();
}

class _StripeCheckoutViewState extends State<StripeCheckoutView> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _loaded = false;
  bool _failed = false;
  bool _returned = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (_isReturn(request.url)) return NavigationDecision.prevent;
            if (opensOutsideWebView(request.url)) {
              launchUrl(
                Uri.parse(request.url),
                mode: LaunchMode.externalApplication,
              ).ignore();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          // Not every redirect goes through onNavigationRequest on every
          // platform, so the same check runs on these too.
          onPageStarted: _isReturn,
          onUrlChange: (change) => _isReturn(change.url ?? ''),
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (!_failed) _loaded = true;
          },
          // Only a page that never opened is ours to report. Once it is up,
          // a failed load belongs to Stripe or the bank, and taking the page
          // away could interrupt a payment. -999 is iOS saying one load was
          // replaced by the next, which is not a failure at all.
          onWebResourceError: (error) {
            if (!mounted || _loaded || _returned) return;
            if (error.errorCode == -999) return;
            if (error.isForMainFrame ?? false) setState(() => _failed = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  // When the customer is done, Stripe navigates to the storefront's status
  // page. The app has its own, so that navigation is stopped and reported
  // instead. It is only a hint about what happened — whether the card was
  // charged is always read from the server.
  bool _isReturn(String url) {
    final outcome = stripeReturnOutcome(url);
    if (outcome == null) return false;

    if (!_returned) {
      _returned = true;
      widget.onReturn(outcome);
    }
    return true;
  }

  void _retry() {
    setState(() {
      _failed = false;
      _progress = 0;
    });
    _controller.loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    if (_failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 40, color: colors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Could not open the payment page',
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nothing has been charged. Check your connection and try again.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(label: 'Try again', onPressed: _retry),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_progress < 100)
          LinearProgressIndicator(
            value: _progress / 100,
            minHeight: 2,
            color: colors.brand,
            backgroundColor: colors.border,
          ),
      ],
    );
  }
}
