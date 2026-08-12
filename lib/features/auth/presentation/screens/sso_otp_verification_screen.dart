import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_secure_note.dart';

class SsoOtpVerificationScreen extends StatefulWidget {
  final String email;
  const SsoOtpVerificationScreen({super.key, required this.email});

  @override
  State<SsoOtpVerificationScreen> createState() =>
      _SsoOtpVerificationScreenState();
}

class _SsoOtpVerificationScreenState extends State<SsoOtpVerificationScreen> {
  static const _otpLength = 6;
  static const _resendCooldownSeconds = 30;

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  Timer? _cooldownTimer;
  int _secondsLeft = _resendCooldownSeconds;

  // ------------------------- LOGIC — same, kuchh nahi badla -------------------------

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _secondsLeft = _resendCooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _submit() {
    final otp = _otpController.text.trim();

    if (otp.length != _otpLength) {
      AppSnackbar.showError(context, 'Enter the $_otpLength-digit code');
      return;
    }

    context.read<AuthBloc>().add(
      SsoOtpVerifyRequested(email: widget.email, otp: otp),
    );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    context.read<AuthBloc>().add(SsoOtpSendRequested(email: widget.email));
  }

  // ------------------------------------ UI ------------------------------------

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.setDeviceType(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ThemeColors.ink : ThemeColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          } else if (state is SsoOtpRequired) {
            AppSnackbar.showSuccess(context, 'OTP resent to ${widget.email}');
            _startCooldown();
          } else if (state is SsoSetPasswordRequired) {
            context.pushReplacement(
              AppRoutes.ssoSetPassword,
              extra: state.email,
            );
          } else if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final m = AuthMetrics.of(constraints);
            final wide = m.isTablet && m.isLandscape;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      m.pagePadH,
                      m.pagePadV,
                      m.pagePadH,
                      m.pagePadV,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: m.contentMaxWidth,
                        ),
                        child: wide
                            ? _WideLayout(
                                m: m,
                                isDark: isDark,
                                onBack: () => context.pop(),
                                form: _form(m, isDark, alignStart: true),
                              )
                            : _NarrowLayout(
                                m: m,
                                isDark: isDark,
                                onBack: () => context.pop(),
                                form: _form(m, isDark, alignStart: false),
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    m.pagePadH,
                    m.fieldGap * 0.5,
                    m.pagePadH,
                    m.pagePadV,
                  ),
                  child: AuthSecureNote(m: m, isDark: isDark),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _form(AuthMetrics m, bool isDark, {required bool alignStart}) {
    final cross = alignStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final align = alignStart ? TextAlign.left : TextAlign.center;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: m.formMaxWidth),
      child: Column(
        crossAxisAlignment: cross,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Verify Your Email',
            textAlign: align,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: m.heroTitle,
              fontWeight: FontWeight.w700,
              color: isDark ? ThemeColors.white : ThemeColors.ink,
            ),
          ),
          SizedBox(height: m.fieldGap * 0.45),
          Text(
            "We've sent a $_otpLength-digit code to",
            textAlign: align,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: m.heroBody,
              color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
            ),
          ),
          SizedBox(height: m.fieldGap * 0.2),
          _EmailRow(
            m: m,
            isDark: isDark,
            email: widget.email,
            alignStart: alignStart,
            onEdit: () => context.pop(),
          ),
          SizedBox(height: m.blockGap),
          _OtpInput(
            controller: _otpController,
            focusNode: _otpFocusNode,
            length: _otpLength,
            m: m,
            isDark: isDark,
            alignStart: alignStart,
            onCompleted: (_) => _submit(),
          ),
          // SizedBox(height: m.blockGap),
          SizedBox(height: m.blockGap * 2),

          _ResendRow(
            m: m,
            isDark: isDark,
            secondsLeft: _secondsLeft,
            alignStart: alignStart,
            onResend: _resend,
          ),
          SizedBox(height: m.blockGap),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Verify OTP',
                onPressed: _submit,
                isLoading: state is AuthLoading,
                height: m.buttonHeight,
                fontSize: m.linkText + 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone (portrait + landscape) aur tablet portrait —
class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.m,
    required this.isDark,
    required this.onBack,
    required this.form,
  });

  final AuthMetrics m;
  final bool isDark;
  final VoidCallback onBack;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final showHero = m.isTablet || !m.isLandscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(m: m, isDark: isDark, onBack: onBack),
        SizedBox(height: m.blockGap),
        if (showHero) ...[
          Center(
            child: _HeroArt(m: m, isDark: isDark),
          ),
          SizedBox(height: m.blockGap),
        ],
        Center(child: form),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.m,
    required this.isDark,
    required this.onBack,
    required this.form,
  });

  final AuthMetrics m;
  final bool isDark;
  final VoidCallback onBack;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopBar(m: m, isDark: isDark, onBack: onBack),
        SizedBox(height: m.sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 5, child: form),
            SizedBox(width: m.paneGap),
            Expanded(
              flex: 4,
              child: Center(
                child: _HeroArt(m: m, isDark: isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.m, required this.isDark, required this.onBack});

  final AuthMetrics m;
  final bool isDark;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final ink = isDark ? ThemeColors.white : ThemeColors.ink;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkResponse(
          onTap: onBack,
          radius: 24,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_rounded, size: 22, color: ink),
          ),
        ),
        SizedBox(width: m.fieldGap * 0.6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'The',
                    style: TextStyle(color: ink),
                  ),
                  TextSpan(
                    text: 'Vault',
                    style: TextStyle(
                      color: isDark
                          ? ThemeColors.purpleLight
                          : ThemeColors.purple,
                    ),
                  ),
                ],
              ),
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: m.brandTitle,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            SizedBox(height: m.brandTagline * 0.25),
            Text(
              'YOUR EVERYDAY STORE',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: m.brandTagline,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w600,
                color: isDark ? ThemeColors.textGrey : ThemeColors.inkDim,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.m, required this.isDark});

  final AuthMetrics m;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.asset(AppImages.onboard1Dark, fit: BoxFit.contain),
    );
  }
}

class _EmailRow extends StatelessWidget {
  const _EmailRow({
    required this.m,
    required this.isDark,
    required this.email,
    required this.alignStart,
    required this.onEdit,
  });

  final AuthMetrics m;
  final bool isDark;
  final String email;
  final bool alignStart;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignStart
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            email,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: m.heroBody,
              fontWeight: FontWeight.w700,
              color: isDark ? ThemeColors.gold1 : ThemeColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.m,
    required this.isDark,
    required this.alignStart,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final AuthMetrics m;
  final bool isDark;
  final bool alignStart;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final digitColor = isDark ? ThemeColors.white : ThemeColors.ink;
    final boxFill = isDark
        ? ThemeColors.white.withValues(alpha: 0.04)
        : ThemeColors.white;
    final boxBorder = isDark
        ? ThemeColors.white.withValues(alpha: 0.14)
        : ThemeColors.line;
    final accent = isDark ? ThemeColors.purpleLight : ThemeColors.purple;

    return LayoutBuilder(
      builder: (context, c) {
        final gap = m.fieldGap * 0.5;
        final maxBox = (c.maxWidth - gap * (length - 1)) / length;
        final target = m.isTablet ? 64.0 : 52.0;
        final w = maxBox < target ? maxBox : target;
        final h = w * 1.14;

        PinTheme themed({
          required Color fill,
          required Color border,
          double bw = 1.2,
        }) {
          return PinTheme(
            width: w,
            height: h,
            textStyle: TextStyle(
              fontFamily: 'Roboto',
              fontSize: w * 0.44,
              fontWeight: FontWeight.w700,
              color: digitColor,
            ),
            decoration: BoxDecoration(
              color: fill,
              border: Border.all(color: border, width: bw),
              borderRadius: BorderRadius.circular(m.buttonRadius),
            ),
          );
        }

        return Align(
          alignment: alignStart ? Alignment.centerLeft : Alignment.center,
          child: Pinput(
            controller: controller,
            focusNode: focusNode,
            length: length,
            autofocus: true,
            keyboardType: TextInputType.number,
            onCompleted: onCompleted,
            separatorBuilder: (_) => SizedBox(width: gap),
            defaultPinTheme: themed(fill: boxFill, border: boxBorder),
            focusedPinTheme: themed(fill: boxFill, border: accent, bw: 2),
            submittedPinTheme: themed(
              fill: accent.withValues(alpha: isDark ? 0.18 : 0.10),
              border: accent,
            ),
          ),
        );
      },
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.m,
    required this.isDark,
    required this.secondsLeft,
    required this.alignStart,
    required this.onResend,
  });

  final AuthMetrics m;
  final bool isDark;
  final int secondsLeft;
  final bool alignStart;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft == 0;
    final accent = isDark ? ThemeColors.purpleLight : ThemeColors.purple;
    final muted = isDark ? ThemeColors.textGrey : ThemeColors.inkDim;
    final mm = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (secondsLeft % 60).toString().padLeft(2, '0');

    return Align(
      alignment: alignStart ? Alignment.centerLeft : Alignment.center,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Didn't receive the code? ",
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: m.linkText,
              color: muted,
            ),
          ),
          InkWell(
            onTap: canResend ? onResend : null,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Text(
                'Resend OTP',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: m.linkText,
                  fontWeight: FontWeight.w700,
                  color: canResend ? accent : muted,
                ),
              ),
            ),
          ),
          if (!canResend)
            Text(
              ' ($mm:$ss)',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: m.linkText,
                color: muted,
              ),
            ),
        ],
      ),
    );
  }
}
