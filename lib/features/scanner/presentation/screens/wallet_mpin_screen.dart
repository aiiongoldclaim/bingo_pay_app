import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../tvs_wallet/presentation/widgets/tvs_format.dart';
import '../../data/tvs_qr_datasource.dart';

enum MpinMode { create, verify, change, reset }

// Why the MPIN screen was opened. `onPin` runs with the MPIN once it is
// entered (and saved, when creating or resetting): it returns an error to show
// and ask again, or null to close the screen with `true`. Opened without args,
// the screen manages the MPIN: creates one, or changes the one that is set.
class MpinArgs {
  final MpinMode mode;
  final Future<String?> Function(String pin)? onPin;
  final String? subtitle; // e.g. "Pay 250.00 INR to Chai Point"
  final int length; // of the MPIN already set; a new one is always 4

  const MpinArgs({
    required this.mode,
    this.onPin,
    this.subtitle,
    this.length = 4,
  });
}

// Pays (or sends) with the MPIN: opens the MPIN screen, creating an MPIN first
// when none is set, and runs `attempt` with the MPIN typed. A wrong or locked
// MPIN keeps the screen open to retry; any other refusal closes it and comes
// back as `failure`. Null when the user backed out.
Future<({Map<String, dynamic>? result, Object? failure})?> runWithMpin(
  BuildContext context, {
  required bool isSet,
  int length = 4,
  String? subtitle,
  required Future<Map<String, dynamic>> Function(String pin) attempt,
}) async {
  Map<String, dynamic>? result;
  Object? failure;
  final done = await context.push<bool>(
    AppRoutes.walletMpin,
    extra: MpinArgs(
      mode: isSet ? MpinMode.verify : MpinMode.create,
      length: length,
      subtitle: subtitle,
      onPin: (pin) async {
        try {
          result = await attempt(pin);
        } on TvsQrException catch (e) {
          if (e.code == 'PIN_LOCKED') {
            return _lockedMessage(getIt<TvsQrDataSource>(), e.message);
          }
          if (e.code == 'PIN_INVALID') return e.message;
          failure = e;
        } catch (e) {
          failure = e;
        }
        return null;
      },
    ),
  );
  if (done != true) return null;
  return (result: result, failure: failure);
}

// A locked MPIN, until when: the refusal doesn't say, the MPIN status does.
Future<String> _lockedMessage(TvsQrDataSource api, String fallback) async {
  try {
    final until = (await api.pinStatus())['lockedUntil'];
    if (until != null) return _lockedUntil(until);
  } catch (_) {}
  return fallback;
}

String _lockedUntil(Object until) =>
    'Locked after wrong tries until ${tvsTime(until)}. '
    'Forgot MPIN? unlocks it now.';

enum _Step { current, otp, enter, fresh, confirm }

class WalletMpinScreen extends StatefulWidget {
  final MpinArgs? args;

  const WalletMpinScreen({super.key, this.args});

  @override
  State<WalletMpinScreen> createState() => _WalletMpinScreenState();
}

class _WalletMpinScreenState extends State<WalletMpinScreen> {
  static const _newLength = 4;
  static const _otpLength = 6;
  static const _resendWait = 30; // seconds between reset codes, as on the web

  final _api = getIt<TvsQrDataSource>();

  MpinArgs? _args; // null while the manage screen loads the MPIN status
  List<_Step> _steps = const [];
  int _at = 0;
  String _digits = '';
  String _current = '';
  String _otp = '';
  String _fresh = '';
  String? _error;
  String? _codeSentTo;
  bool _busy = false;
  int _wait = 0; // seconds until another code can be sent
  Timer? _ticker;

  _Step get _step => _steps[_at];

  int get _length => switch (_step) {
    _Step.otp => _otpLength,
    _Step.current || _Step.enter => _args!.length,
    _ => _newLength,
  };

  @override
  void initState() {
    super.initState();
    final args = widget.args;
    if (args == null) {
      _loadStatus();
    } else {
      _start(args);
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _api.pinStatus();
      if (!mounted) return;
      setState(() {
        _start(
          MpinArgs(
            mode: status['isSet'] == true ? MpinMode.change : MpinMode.create,
            length: status['length'] as int? ?? _newLength,
          ),
        );
        final until = status['lockedUntil'];
        if (until != null) _error = _lockedUntil(until);
      });
    } catch (e) {
      if (mounted) setState(() => _error = _message(e));
    }
  }

  void _start(MpinArgs args) {
    _args = args;
    _steps = switch (args.mode) {
      MpinMode.verify => const [_Step.enter],
      MpinMode.create => const [_Step.fresh, _Step.confirm],
      MpinMode.change => const [_Step.current, _Step.fresh, _Step.confirm],
      MpinMode.reset => const [_Step.otp, _Step.fresh, _Step.confirm],
    };
    _at = 0;
    _digits = '';
    if (args.mode == MpinMode.reset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sendCode();
      });
    }
  }

  Future<void> _sendCode() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final sent = await _api.requestPinReset();
      _codeSentTo = '${sent['sentTo']}';
      _wait = _resendWait;
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted || _wait <= 1) t.cancel();
        if (mounted) setState(() => _wait--);
      });
    } catch (e) {
      final args = _args!;
      // Nothing to reset yet: create an MPIN instead.
      if (e is TvsQrException && e.code == 'PIN_NOT_SET') {
        _start(
          MpinArgs(
            mode: MpinMode.create,
            onPin: args.onPin,
            subtitle: args.subtitle,
          ),
        );
      } else {
        _error = _message(e);
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  void _press(String digit) {
    if (_busy || _digits.length >= _length) return;
    HapticFeedback.selectionClick();
    setState(() {
      _digits += digit;
      _error = null;
    });
    // A beat so the last dot is seen filling before the screen moves on.
    if (_digits.length == _length) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _complete();
      });
    }
  }

  void _backspace() {
    if (_busy || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  Future<void> _complete() async {
    final value = _digits;
    // A digit deleted in the pause, or an earlier tap already submitted.
    if (_busy || value.length != _length) return;
    switch (_step) {
      case _Step.current:
        _current = value;
        _next();
      case _Step.otp:
        _otp = value;
        _next();
      case _Step.fresh:
        if (_weak(value)) {
          return _goTo(
            _Step.fresh,
            'Too easy to guess. Avoid repeated digits and sequences like 1234.',
          );
        }
        _fresh = value;
        _next();
      case _Step.confirm:
        if (value != _fresh) {
          return _goTo(_Step.fresh, 'MPINs didn’t match. Try again.');
        }
        await _save();
      case _Step.enter:
        await _submit(value);
    }
  }

  void _next() => setState(() {
    _at++;
    _digits = '';
  });

  void _goTo(_Step step, [String? error]) => setState(() {
    _at = _steps.indexOf(step);
    _digits = '';
    _error = error;
    _busy = false;
  });

  // Mirrors the API's rule, so a weak MPIN is refused before it is confirmed.
  static bool _weak(String pin) =>
      RegExp(r'^(\d)\1+$').hasMatch(pin) ||
      '0123456789'.contains(pin) ||
      '9876543210'.contains(pin);

  Future<void> _save() async {
    final args = _args!;
    setState(() => _busy = true);
    try {
      switch (args.mode) {
        case MpinMode.change:
          await _api.setPin(_fresh, currentPin: _current);
        case MpinMode.reset:
          await _api.confirmPinReset(_otp, _fresh);
        default:
          await _api.setPin(_fresh);
      }
    } catch (e) {
      // Back to whichever entry was wrong.
      final code = e is TvsQrException ? e.code : null;
      final back = switch (code) {
        'PIN_INVALID' || 'PIN_LOCKED' => _Step.current,
        'OTP_INVALID' => _Step.otp,
        _ => _Step.fresh,
      };
      final message = code == 'PIN_LOCKED'
          ? await _lockedMessage(_api, _message(e))
          : _message(e);
      if (!mounted) return;
      return _goTo(_steps.contains(back) ? back : _Step.fresh, message);
    }
    if (!mounted) return;

    final onPin = args.onPin;
    if (onPin == null) {
      AppSnackbar.showSuccess(
        context,
        args.mode == MpinMode.create ? 'MPIN created' : 'MPIN updated',
      );
      context.pop(true);
      return;
    }
    // Saved: from here on the MPIN is only entered, should a retry be needed.
    setState(
      () => _start(
        MpinArgs(mode: MpinMode.verify, onPin: onPin, subtitle: args.subtitle),
      ),
    );
    await _submit(_fresh);
  }

  Future<void> _submit(String pin) async {
    setState(() => _busy = true);
    final error = await _args!.onPin!(pin);
    if (!mounted) return;
    if (error == null) return context.pop(true);
    setState(() {
      _busy = false;
      _digits = '';
      _error = error;
    });
  }

  // A reset finishes what this screen was for (it carries the same onPin).
  Future<void> _forgot() async {
    final args = _args!;
    final done = await context.push<bool>(
      AppRoutes.walletMpin,
      extra: MpinArgs(
        mode: MpinMode.reset,
        onPin: args.onPin,
        subtitle: args.subtitle,
      ),
    );
    if (done == true && mounted) context.pop(true);
  }

  String _message(Object e) => ErrorHandler.mapObjectToFailure(e).message;

  (String, String) get _copy => switch (_step) {
    _Step.current => ('Enter current MPIN', 'Enter the MPIN you use now.'),
    _Step.otp => (
      'Enter reset code',
      _codeSentTo == null
          ? 'We’re emailing you a 6-digit code.'
          : 'Enter the 6-digit code sent to $_codeSentTo.',
    ),
    _Step.enter => (
      'Enter MPIN',
      _args!.subtitle ?? 'Enter your wallet MPIN to continue.',
    ),
    _Step.fresh => (
      _args!.mode == MpinMode.create ? 'Create your MPIN' : 'Set a new MPIN',
      'Choose 4 digits. You’ll enter them to approve larger wallet payments.',
    ),
    _Step.confirm => ('Confirm MPIN', 'Enter the same 4 digits again.'),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Loading the MPIN status: the same layout, as a shimmering skeleton.
    final loading = _args == null && _error == null;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(title: 'Wallet MPIN'),
      body: SafeArea(
        child: _args == null && !loading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_error!, textAlign: TextAlign.center),
                ),
              )
            : LayoutBuilder(
                builder: (context, box) {
                  final landscape = box.maxWidth > box.maxHeight;
                  final keyHeight = landscape ? 48.0 : 68.0;
                  final keypad = loading
                      ? _KeypadSkeleton(keyHeight: keyHeight)
                      : _Keypad(
                          enabled: !_busy,
                          keyHeight: keyHeight,
                          onDigit: _press,
                          onBackspace: _backspace,
                        );
                  final entry = loading
                      ? const _EntrySkeleton()
                      : _entry(colors);
                  final layout = Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: landscape ? 760 : 420,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: landscape
                            ? Row(
                                children: [
                                  Expanded(child: entry),
                                  const SizedBox(width: 24),
                                  Expanded(child: Center(child: keypad)),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(child: entry),
                                  keypad,
                                  const SizedBox(height: 16),
                                ],
                              ),
                      ),
                    ),
                  );
                  return loading
                      ? AppShimmer(
                          backgroundColor: colors.background,
                          child: layout,
                        )
                      : layout;
                },
              ),
      ),
    );
  }

  Widget _entry(AppThemeColors colors) {
    final (title, subtitle) = _copy;
    final canForget = _step == _Step.enter || _step == _Step.current;
    final slots = _Slots(
      length: _length,
      digits: _digits,
      obscure: _step != _Step.otp,
      error: _error != null,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline_rounded, color: colors.brand),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          // Sending the code, saving or paying: the slots shimmer. Dots already
          // typed stay filled, with the shimmer running over them.
          _busy
              ? Semantics(
                  label: 'Please wait',
                  child: ShimmerLoading(
                    baseColor: _digits.isEmpty ? null : colors.brand,
                    highlightColor: _digits.isEmpty
                        ? null
                        : Color.lerp(colors.brand, Colors.white, 0.6),
                    child: slots,
                  ),
                )
              : slots,
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: Text(
              _busy ? '' : _error ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (canForget)
            TextButton(
              onPressed: _busy ? null : _forgot,
              child: const Text('Forgot MPIN?'),
            ),
          if (_step == _Step.otp)
            TextButton(
              onPressed: _busy || _wait > 0 ? null : _sendCode,
              child: Text(
                _wait > 0 ? 'Send a new code in ${_wait}s' : 'Resend code',
              ),
            ),
        ],
      ),
    );
  }
}

// The heading and dots, as boxes, while the MPIN status loads.
class _EntrySkeleton extends StatelessWidget {
  const _EntrySkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 24),
          const ShimmerBox(
            width: 56,
            height: 56,
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          const SizedBox(height: 16),
          const ShimmerBox(width: 180, height: 22),
          const SizedBox(height: 10),
          const ShimmerBox(width: 240, height: 14),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 4; i++)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ShimmerBox(
                    width: 18,
                    height: 18,
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// The number pad's keys, as dots, while the MPIN status loads.
class _KeypadSkeleton extends StatelessWidget {
  final double keyHeight;

  const _KeypadSkeleton({required this.keyHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < 4; r++)
          Row(
            children: [
              for (var c = 0; c < 3; c++)
                Expanded(
                  child: SizedBox(
                    height: keyHeight,
                    // The pad's bottom-left corner has no key.
                    child: r == 3 && c == 0
                        ? null
                        : const Center(
                            child: ShimmerBox(
                              width: 32,
                              height: 32,
                              borderRadius: BorderRadius.all(
                                Radius.circular(16),
                              ),
                            ),
                          ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

// Dots for an MPIN, boxes showing the digits for the emailed code.
class _Slots extends StatelessWidget {
  final int length;
  final String digits;
  final bool obscure;
  final bool error;

  const _Slots({
    required this.length,
    required this.digits,
    required this.obscure,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final edge = error ? colors.error : colors.brand;

    return Semantics(
      label: '${digits.length} of $length digits entered',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(length, (i) {
          final filled = i < digits.length;
          if (obscure) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? edge : Colors.transparent,
                border: Border.all(
                  color: filled || error ? edge : colors.border,
                  width: 2,
                ),
              ),
            );
          }
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 40,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: filled || error ? edge : colors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              filled ? digits[i] : '',
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// The app's own number pad, so the MPIN never goes through the system keyboard.
class _Keypad extends StatelessWidget {
  final bool enabled;
  final double keyHeight;
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _Keypad({
    required this.enabled,
    required this.keyHeight,
    required this.onDigit,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget key({
      required Widget child,
      required String label,
      required VoidCallback onTap,
    }) {
      return Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: child),
        ),
      );
    }

    Widget digit(String d) => key(
      label: d,
      onTap: () => onDigit(d),
      child: Text(
        d,
        style: AppTextStyles.headlineMedium.copyWith(
          color: enabled ? colors.textPrimary : colors.textDisabled,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    final rows = [
      for (final r in const [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
      ])
        r.map(digit).toList(),
      [
        const SizedBox.shrink(),
        digit('0'),
        key(
          label: 'Delete',
          onTap: onBackspace,
          child: Icon(
            Icons.backspace_outlined,
            color: enabled ? colors.textPrimary : colors.textDisabled,
          ),
        ),
      ],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in rows)
          Row(
            children: [
              for (final cell in row)
                Expanded(
                  child: SizedBox(height: keyHeight, child: cell),
                ),
            ],
          ),
      ],
    );
  }
}
