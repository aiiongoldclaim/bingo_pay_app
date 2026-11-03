import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/idempotency_key_generator.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import '../../../scanner/presentation/screens/wallet_mpin_screen.dart';
import '../../../scanner/presentation/widgets/review_payment_amount_section.dart';
import '../../../scanner/presentation/widgets/review_payment_metrics.dart';
import '../../../scanner/presentation/widgets/review_payment_note_section.dart';
import '../widgets/tvs_format.dart';
import '../widgets/tvs_ui.dart';

// Send own coins to another verified member: find them, enter the amount,
// MPIN when it's above the limit, sent. Closes with `true` once sent.
class TvsSendScreen extends StatefulWidget {
  final String? to; // e.g. from a scanned member QR (tvs:u:<uuid>)

  const TvsSendScreen({super.key, this.to});

  @override
  State<TvsSendScreen> createState() => _TvsSendScreenState();
}

class _TvsSendScreenState extends State<TvsSendScreen> {
  final _api = getIt<TvsQrDataSource>();
  late final _to = TextEditingController(text: widget.to);
  final _amount = TextEditingController();
  final _note = TextEditingController();

  Map<String, dynamic>? _found; // the recipient, once looked up
  String? _key; // one per transfer; a retry of the same one reuses it
  String? _error;
  bool _busy = false;

  String get _currency => '${_found?['recipient']?['currency'] ?? ''}';

  bool get _valid {
    final a = _amount.text;
    return RegExp(r'^\d{1,10}(\.\d{1,2})?$').hasMatch(a) &&
        (num.tryParse(a) ?? 0) > 0;
  }

  @override
  void initState() {
    super.initState();
    if (widget.to != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _find();
      });
    }
  }

  @override
  void dispose() {
    _to.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final found = await _api.resolveRecipient(_to.text.trim());
      if (mounted) setState(() => _found = found);
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Map<String, dynamic>> _attempt(String? pin) {
    _key ??= IdempotencyKeyGenerator.generate().substring(0, 64);
    return _api.sendCoins(
      to: _to.text.trim(),
      amount: _amount.text,
      idempotencyKey: _key!,
      note: _note.text.trim(),
      pin: pin,
    );
  }

  Future<void> _send() async {
    final limit = num.tryParse('${_found?['pinAbove']}');
    if (limit != null && num.parse(_amount.text) > limit) {
      return _sendWithMpin();
    }
    setState(() => _busy = true);
    try {
      _sent(await _attempt(null));
    } catch (e) {
      _failed(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendWithMpin() async {
    var isSet = true;
    var length = 4;
    try {
      final pin = await _api.pinStatus();
      isSet = pin['isSet'] == true;
      length = pin['length'] as int? ?? 4;
    } catch (_) {} // the API asks again if this guess was wrong
    if (!mounted) return;
    final outcome = await runWithMpin(
      context,
      isSet: isSet,
      length: length,
      subtitle:
          'Send ${tvsCoins(_amount.text, _currency)} to '
          '${_found?['recipient']?['name']}',
      attempt: _attempt,
    );
    if (!mounted || outcome == null) return;
    final sent = outcome.result;
    if (sent != null) return _sent(sent);
    _failed(outcome.failure!);
  }

  void _sent(Map<String, dynamic> r) {
    if (!mounted) return;
    AppSnackbar.showSuccess(
      context,
      'Sent ${tvsCoins(r['amount'], r['currency'])} to ${r['to']?['name'] ?? 'member'}',
    );
    context.pop(true);
  }

  void _failed(Object e) {
    if (!mounted) return;
    // The PIN limit changed since the lookup: ask for the MPIN now.
    if (e is TvsQrException &&
        (e.code == 'PIN_REQUIRED' || e.code == 'PIN_NOT_SET')) {
      _sendWithMpin();
      return;
    }
    AppSnackbar.showError(context, _message(e));
  }

  String _message(Object e) => ErrorHandler.mapObjectToFailure(e).message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final m = ReviewPaymentMetrics.of(context);
    final found = _found;
    final canSend = found?['canSend'] == true;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(title: 'Send TVS Coins'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _to,
                    autofocus: widget.to == null,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _find(),
                    onChanged: (_) => setState(() {
                      _found = null; // a different person: look up again
                      _key = null;
                      _error = null;
                    }),
                    decoration: InputDecoration(
                      labelText: 'To',
                      hintText: 'Email, phone or member code',
                      prefixIcon: const Icon(Icons.person_search_outlined),
                      errorText: _error,
                      filled: true,
                      fillColor: colors.surfaceAlt,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  if (found != null) ...[
                    const SizedBox(height: 12),
                    _Recipient(found: found),
                  ],
                  if (canSend) ...[
                    const SizedBox(height: 32),
                    ReviewPaymentAmountSection(
                      metrics: m,
                      controller: _amount,
                      currency: _currency,
                      error: null,
                      autofocus: true,
                      onChanged: (_) => setState(() => _key = null),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Only your own coins can be sent. Bonus stays with you.',
                      textAlign: TextAlign.center,
                      style: tvsText(colors.textMuted, size: 12),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ReviewPaymentNoteSection(
                        metrics: m,
                        controller: _note,
                        onChanged: (_) {},
                        maxLength: 140,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: canSend
                  ? AppButton(
                      label: _valid
                          ? 'Send ${tvsCoins(_amount.text, _currency)}'
                          : 'Send',
                      isLoading: _busy,
                      onPressed: _valid && !_busy ? _send : null,
                    )
                  : AppButton(
                      label: 'Find member',
                      isLoading: _busy,
                      onPressed: _to.text.trim().length >= 3 && !_busy
                          ? _find
                          : null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Recipient extends StatelessWidget {
  final Map<String, dynamic> found;

  const _Recipient({required this.found});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ok = found['canSend'] == true;
    final color = ok ? colors.statusSuccess : colors.error;
    final name = '${found['recipient']?['name'] ?? 'Member'}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.brandSoft,
            child: Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: tvsText(colors.brand, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tvsText(colors.textPrimary, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  ok
                      ? 'You can send up to ${tvsCoins(found['available'], found['recipient']?['currency'])}'
                      : '${found['reason']}',
                  style: tvsText(
                    ok ? colors.textSecondary : colors.error,
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            ok ? Icons.verified_rounded : Icons.block_rounded,
            color: color,
            semanticLabel: ok ? 'Can receive' : 'Can’t receive',
          ),
        ],
      ),
    );
  }
}
