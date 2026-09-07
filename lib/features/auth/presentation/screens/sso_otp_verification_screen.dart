import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
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
  bool _isResending = false;
  bool _isInitialLoad = true;


  @override
  void initState() {
    super.initState();
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
        setState(() => _isInitialLoad = false);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _cooldownTimer?.cancel();
    _otpFocusNode.dispose();
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
      _otpFocusNode.requestFocus();

      AppSnackbar.showError(
        context,
        'Enter the $_otpLength-digit code',
      );

      return;
    }

    FocusScope.of(context).unfocus();

    context.read<AuthBloc>().add(
      SsoOtpVerifyRequested(
        email: widget.email,
        otp: otp,
      ),
    );
  }

  void _resend() {
    if (_secondsLeft > 0) return;

    _otpController.clear();

    context.read<AuthBloc>().add(
      SsoOtpSendRequested(
        email: widget.email,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  // ------------------------------------ UI ------------------------------------

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.setDeviceType(context);
    final colors = context.colors;


    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading) {
                setState(() => _isResending = true);
              } else if (state is AuthError) {
                setState(() => _isResending = false);
                AppSnackbar.showError(context, state.failure.message);
              } else if (state is SsoOtpRequired) {
                // Only handle SsoOtpRequired if this is from resend (when not on initial load)
                if (!_isInitialLoad) {
                  setState(() => _isResending = false);
                  _startCooldown();
                  AppSnackbar.showSuccess(context, 'OTP resent to ${widget.email}');
                }
              } else if (state is SsoSetPasswordRequired) {
                setState(() => _isResending = false);
                if (mounted) {
                  context.pushReplacement(
                    AppRoutes.ssoSetPassword,
                    extra: state.email,
                  );
                }
              } else if (state is AuthAuthenticated) {
                setState(() => _isResending = false);
                if (mounted) {
                  context.go(AppRoutes.home);
                }
              }
            },
            child: LayoutBuilder(
          builder: (context, constraints) {
            final m = AuthMetrics.of(constraints);
            final isWide = m.isTablet && m.isLandscape;

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
                        child: isWide
                            ? _WideLayout(
                                m: m,
                                onBack: () => context.pop(),
                                form: _form(m, alignStart: true),
                              )
                            : _NarrowLayout(
                                metrics: m,
                                onBack: () => context.pop(),
                                form: _form(m, alignStart: false),
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
                  child: AuthSecureNote(metrics: m,),
                ),
              ],
            );
          },
            ),
          ),
          // Loading Overlay for Resend
          if (_isResending)
            Positioned.fill(
              child: Container(
                color: ThemeColors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(colors.brand),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sending OTP...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _form(AuthMetrics m, {required bool alignStart}) {
    final colors = context.colors;
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
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: m.fieldGap * 0.45),
          Text(
            "We've sent a $_otpLength-digit code to",
            textAlign: align,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: m.heroBody,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: m.fieldGap * 0.2),
          _EmailRow(
            m: m,
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
            alignStart: alignStart,
            onCompleted: (_) => _submit(),
          ),
          // SizedBox(height: m.blockGap),
          SizedBox(height: m.blockGap * 2),

          _ResendRow(
            secondsLeft: _secondsLeft,
            alignStart: alignStart,
            onResend: _resend,
            metrics: m,
            isResending: _isResending,
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
    required this.metrics,
    required this.onBack,
    required this.form,
  });

  final AuthMetrics metrics;
  final VoidCallback onBack;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final showHero = metrics.isTablet || !metrics.isLandscape;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TopBar(m: metrics, onBack: onBack),

        SizedBox(height: metrics.blockGap),

        if (showHero) ...[
          Center(child: _HeroArt(m: metrics)),
          SizedBox(height: metrics.blockGap),
        ],

        Center(child: form),
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.m,
    required this.onBack,
    required this.form,
  });

  final AuthMetrics m;
  final VoidCallback onBack;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TopBar(m: m, onBack: onBack),
        SizedBox(height: m.sectionGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 5, child: form),
            SizedBox(width: m.paneGap),
            Expanded(
              flex: 4,
              child: Center(
                child: _HeroArt(m: m,),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.m, required this.onBack});

  final AuthMetrics m;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkResponse(
          onTap: onBack,
          radius: 24,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_rounded, size: 22, color: colors.textPrimary,),
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
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  TextSpan(
                    text: 'Vault',
                    style: TextStyle(
                      color: colors.brand
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
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.m});

  final AuthMetrics m;


  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AspectRatio(
      aspectRatio: 1,
      child: Image.asset(colors.isDark ? AppImages.onboard1Dark : AppImages.onboard1,fit: BoxFit.contain,),

    );
  }
}

class _EmailRow extends StatelessWidget {
  const _EmailRow({
    required this.m,
    required this.email,
    required this.alignStart,
    required this.onEdit,
  });

  final AuthMetrics m;
  final String email;
  final bool alignStart;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              color: colors.brand,
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

    required this.alignStart,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final AuthMetrics m;
  final bool alignStart;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
              fontFamily: 'Inter',
              fontSize: w * 0.44,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
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
            defaultPinTheme: themed(
              fill: colors.surface,
              border: colors.border,
            ),
            focusedPinTheme: themed(
              fill: colors.surface,
              border: colors.brand,
            ),
            submittedPinTheme: themed(
              fill: colors.brandSoft,
              border: colors.brand,
            ),
          ),
        );
      },
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.metrics,
    required this.secondsLeft,
    required this.alignStart,
    required this.onResend,
    required this.isResending,
  });

  final AuthMetrics metrics;
  final int secondsLeft;
  final bool alignStart;
  final VoidCallback onResend;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final canResend = secondsLeft == 0 && !isResending;
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

    return Align(
      alignment: alignStart ? Alignment.centerLeft : Alignment.center,
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Didn't receive the code? ",
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: metrics.linkText,
              color: colors.textMuted,
            ),
          ),

          if (isResending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(colors.brand),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Sending OTP...',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: metrics.linkText,
                      fontWeight: FontWeight.w700,
                      color: colors.brand,
                    ),
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: canResend ? onResend : null,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                child: Text(
                  'Resend OTP',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: metrics.linkText,
                    fontWeight: FontWeight.w700,
                    color: canResend ? colors.brand : colors.textMuted,
                  ),
                ),
              ),
            ),

          if (!canResend && !isResending)
            Text(
              ' ($minutes:$seconds)',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: metrics.linkText,
                color: colors.textMuted,
              ),
            ),
        ],
      ),
    );
  }
}
