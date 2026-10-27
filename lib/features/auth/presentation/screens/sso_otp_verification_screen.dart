import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/vault_auth_widgets.dart';

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
    _cooldownTimer?.cancel();
    _otpController.dispose();
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
    if (_isResending) return;
    if (_secondsLeft > 0) return;

    setState(() => _isResending = true);
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

    return Scaffold(
      backgroundColor: ThemeColors.vaultLoginCream,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthLoading || state is SsoOtpSending) {
                setState(() => _isResending = true);
              } else if (state is AuthError) {
                setState(() => _isResending = false);
                AppSnackbar.showError(context, state.failure.message);
              } else if (state is SsoOtpRequired) {
                // Only handle SsoOtpRequired if this is from resend (check if we initiated it)
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
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: ThemeColors.vaultLoginCream,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final m = AuthMetrics.of(constraints);
                  final w = constraints.maxWidth;
                  final topW = (w * 0.48).clamp(150.0, 380.0);
                  final bottomW = (w * 0.66).clamp(220.0, 520.0);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 0,
                        right: 0,
                        width: topW,
                        child: const VaultCornerArt(
                          asset: AppImages.vaultLoginCornerTop,
                          corner: Alignment.topRight,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        width: bottomW,
                        child: const VaultCornerArt(
                          asset: AppImages.vaultLoginCornerBottom,
                          corner: Alignment.bottomLeft,
                        ),
                      ),

                      SafeArea(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            m.pagePadH * 0.7,
                            0,
                            m.pagePadH * 0.7,
                            m.blockGap,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 480),
                              child: _buildContent(m),
                            ),
                          ),
                        ),
                      ),

                      SafeArea(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: m.pagePadH * 0.3),
                            child: IconButton(
                              onPressed: () => context.pop(),
                              tooltip: 'Back',
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: ThemeColors.vaultInk,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
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
                      color: ThemeColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ThemeColors.vaultLoginFieldBorder,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor:
                                AlwaysStoppedAnimation(ThemeColors.vaultGold),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Sending OTP...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: ThemeColors.vaultInk,
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

  Widget _buildContent(AuthMetrics m) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: m.blockGap * 2.2),
        VaultWordmark(
          fontSize: m.brandTitle * 1.3,
          showDiamond: false,
          tagline: 'TIMELESS LUXURY FOR YOU',
          taglineColor: ThemeColors.vaultInk,
        ),
        SizedBox(height: m.blockGap * 1.2),
        const Center(
          child: VaultIconBadge(
            icon: Icons.mark_email_read_outlined,
            size: 104,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.6),
        Text(
          'Verify Your Email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kVaultSerif,
            fontSize: m.heroTitle * 1.1,
            fontWeight: FontWeight.w600,
            color: ThemeColors.vaultInk,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.4),
        Text(
          "We've sent a $_otpLength-digit code to",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: m.linkText,
            color: ThemeColors.vaultBody,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.2),
        Text(
          widget.email,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: m.linkText,
            fontWeight: FontWeight.w700,
            color: ThemeColors.vaultPlumSoft,
          ),
        ),
        SizedBox(height: m.blockGap * 1.2),
        _OtpInput(
          controller: _otpController,
          focusNode: _otpFocusNode,
          length: _otpLength,
          m: m,
          onCompleted: (_) => _submit(),
        ),
        SizedBox(height: m.fieldGap),
        _ResendRow(
          secondsLeft: _secondsLeft,
          onResend: _resend,
          metrics: m,
          isResending: _isResending,
        ),
        SizedBox(height: m.blockGap * 1.1),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => VaultGradientButton(
            label: 'Verify OTP',
            height: m.buttonHeight,
            fontSize: m.linkText + 2,
            onPressed: _submit,
            isLoading: state is AuthLoading,
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
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final AuthMetrics m;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final gap = m.fieldGap * 0.5;
        final maxBox = (c.maxWidth - gap * (length - 1)) / length;
        final target = m.isTablet ? 60.0 : 50.0;
        final w = maxBox < target ? maxBox : target;
        final h = w * 1.14;

        PinTheme themed({
          required Color fill,
          required Color border,
          double bw = 1,
        }) {
          return PinTheme(
            width: w,
            height: h,
            textStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: w * 0.44,
              fontWeight: FontWeight.w700,
              color: ThemeColors.vaultInk,
            ),
            decoration: BoxDecoration(
              color: fill,
              border: Border.all(color: border, width: bw),
              borderRadius: BorderRadius.circular(m.buttonRadius),
            ),
          );
        }

        return Center(
          child: Pinput(
            controller: controller,
            focusNode: focusNode,
            length: length,
            autofocus: true,
            keyboardType: TextInputType.number,
            onCompleted: onCompleted,
            cursor: Container(
              width: 1.5,
              height: h * 0.4,
              color: ThemeColors.vaultPlumSoft,
            ),
            separatorBuilder: (_) => SizedBox(width: gap),
            defaultPinTheme: themed(
              fill: ThemeColors.vaultLoginFieldFill,
              border: ThemeColors.vaultLoginFieldBorder,
            ),
            focusedPinTheme: themed(
              fill: ThemeColors.white,
              border: ThemeColors.vaultGold,
              bw: 1.5,
            ),
            submittedPinTheme: themed(
              fill: ThemeColors.white,
              border: ThemeColors.vaultGold,
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
    required this.onResend,
    required this.isResending,
  });

  final AuthMetrics metrics;
  final int secondsLeft;
  final VoidCallback onResend;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    final canResend = secondsLeft == 0 && !isResending;
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

    final mutedStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: metrics.linkText,
      color: ThemeColors.vaultBody,
    );
    final actionStyle = mutedStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: ThemeColors.vaultPlumSoft,
    );

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text("Didn't receive the code? ", style: mutedStyle),

          if (isResending)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(ThemeColors.vaultGold),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Sending OTP...', style: actionStyle),
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
                  style: canResend
                      ? actionStyle
                      : actionStyle.copyWith(color: ThemeColors.vaultBody),
                ),
              ),
            ),

          if (!canResend && !isResending)
            Text(
              ' ($minutes:$seconds)',
              style: mutedStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: ThemeColors.vaultGoldDeep,
              ),
            ),
        ],
      ),
    );
  }
}
