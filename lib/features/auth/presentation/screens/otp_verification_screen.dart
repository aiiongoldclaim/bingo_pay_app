import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_interaction_blocker.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_widget_builder.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/services/login_form_manager.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/vault_auth_widgets.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _otpLength = 6;
  static const _resendCooldownSeconds = 30;

  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  Timer? _cooldownTimer;
  int _secondsLeft = _resendCooldownSeconds;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _otpController.addListener(_onOtpChanged);
  }

  @override
  void dispose() {
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    _otpFocusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_otpError != null) setState(() => _otpError = null);
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
    // if (context.read<AuthBloc>().state is AuthLoading) return;
    FocusScope.of(context).unfocus();

    final error = Validators.otp(_otpController.text, length: _otpLength);
    if (error != null) {
      setState(() => _otpError = error);
      return;
    }

    setState(() => _otpError = null);
    context.read<AuthBloc>().add(
      OtpVerifyRequested(email: widget.email, otp: _otpController.text.trim()),
    );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    // if (context.read<AuthBloc>().state is AuthLoading) return;
    _otpController.clear();
    setState(() => _otpError = null);
    context.read<AuthBloc>().add(OtpResendRequested(email: widget.email));
  }

  void _showRateLimitError(BuildContext context, RateLimitFailure failure) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (_) => failure.buildErrorWidget(
        onRetry: () {
          Navigator.pop(context);
          _resend();
        },
        fullScreen: false,
      ),
    );
  }

  void _backToLogin() {
    FocusScope.of(context).unfocus();
    LoginFormManager().clearForm();
    context.go(AppRoutes.login);
  }

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.vaultAuthBackground,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Sync resend cooldown with server's Retry-After on rate limit
            if (state.failure is RateLimitFailure) {
              final rateLimitFailure = state.failure as RateLimitFailure;
              final retryAfter = rateLimitFailure.retryAfterSeconds ?? 60;
              setState(() {
                _secondsLeft = retryAfter;
              });
              _startCooldown();
              // Show rate limit error widget
              _showRateLimitError(context, rateLimitFailure);
            } else {
              // Regular error displayed under OTP field
              setState(() => _otpError = state.failure.message);
            }
          } else if (state is OtpResendSent) {
            AppSnackbar.showSuccess(context, 'OTP resent to ${widget.email}');
            _startCooldown();
          } else if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
        },
        buildWhen: (prev, curr) =>
        (prev is AuthLoading) != (curr is AuthLoading),

        builder: (context, state) {
          return AppInteractionBlocker(
            isBlocking: state is AuthLoading,
            dismissKeyboard: false, // 👈 Pinput ke liye
            child: VaultAuthScaffold(
              builder: (context, m) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VaultAuthHeader(
                    m: m,
                    title: 'Verify Your Email',
                    subtitle: 'We have sent a $_otpLength-digit code to',
                    subtitleBold: widget.email,
                    illustration: Image.asset(
                      AppImages.vaultOtpVerify,
                      height: m.isTablet ? 220 : 180,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(height: m.blockGap * 1.2),
                  _buildForm(context, m),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthMetrics m) {
    final colors = context.c;
    final c = context.colors;
    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildPinput(context, m),

        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _otpError == null
              ? const SizedBox(width: double.infinity, height: 0)
              : Padding(
            padding: EdgeInsets.only(top: m.fieldGap * 0.5),
            child: Text(
              _otpError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: m.footerText,
                fontWeight: FontWeight.w500,
                color: colors.error,
              ),
            ),
          ),
        ),

        SizedBox(height: m.blockGap),

        Center(
          child: GestureDetector(
            onTap: _secondsLeft == 0 ? _resend : null,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text.rich(
                TextSpan(
                  text: _secondsLeft == 0 ? "Didn't receive the code?  " : '',
                  style: TextStyle(color: c.vaultAuthBody),
                  children: [
                    TextSpan(
                      text: _secondsLeft == 0
                          ? 'Resend Code'
                          : 'Resend Code in $mm:$ss',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _secondsLeft == 0 ? c.vaultAuthLink : c.vaultAuthTitle,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: m.footerText + 1,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: m.blockGap),

        /// ✅ VERIFY
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => VaultPillButton(
            label: 'Verify',
            height: m.buttonHeight,
            onPressed: _submit,
            isLoading: state is AuthLoading,
          ),
        ),

        SizedBox(height: m.blockGap),

        /// BACK TO LOGIN
        VaultFooterLink(
          prefix: 'Wrong email?',
          action: 'Back to Login',
          fontSize: m.footerText + 1,
          onTap: _backToLogin,
        ),
      ],
    );
  }

  Widget _buildPinput(BuildContext context, AuthMetrics m) {
    final colors = context.c;
    final c = context.colors;
    final hasError = _otpError != null;

    final boxW = m.isTablet ? (m.isLandscape ? 50.0 : 56.0) : 48.0;
    final boxH = m.isTablet ? (m.isLandscape ? 58.0 : 64.0) : 56.0;

    final pinTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: m.isTablet ? 22 : 20,
      fontWeight: FontWeight.w700,
      color: c.vaultAuthTitle,
    );

    BoxDecoration deco(Color fill, Color borderColor, {double width = 1}) =>
        BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: width),
        );

    return Pinput(
      controller: _otpController,
      focusNode: _otpFocusNode,
      length: _otpLength,
      autofocus: true,
      keyboardType: TextInputType.number,
      forceErrorState: hasError,
      errorBuilder: (_, _) => const SizedBox.shrink(),
      onCompleted: (_) => _submit(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      defaultPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: deco(c.vaultAuthSurface, hasError ? colors.error : c.vaultAuthBorder),
      ),

      focusedPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: deco(
          c.vaultAuthSurface,
          hasError ? colors.error : ThemeColors.vaultGold,
          width: 1.8,
        ),
      ),

      submittedPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: deco(
          c.vaultAuthSurface,
          hasError ? colors.error : ThemeColors.vaultGold,
        ),
      ),

      errorPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle.copyWith(color: colors.error),
        decoration: deco(c.vaultAuthSurface, colors.error, width: 1.5),
      ),
    );
  }
}

