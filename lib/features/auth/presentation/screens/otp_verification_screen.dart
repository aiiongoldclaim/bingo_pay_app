import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/validators.dart'; // <- apne path ke hisaab se
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_interaction_blocker.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_widget_builder.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/services/login_form_manager.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_tablet_layout.dart';
import '../widgets/auth_terms_text.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            child: SafeArea(
              child: AuthResponsiveLayout(
                title: 'Verify Your Email',
                subtitle:
                'Enter the $_otpLength-digit code we sent to\n${widget.email},',
                topActionLabel: 'Sign In',
                onTopAction: _backToLogin,
                features: const [
                  AuthFeature(
                    icon: Icons.mark_email_read_rounded,
                    title: 'Check Your Inbox',
                    subtitle: 'The code was sent to your\nregistered email.',
                  ),
                  AuthFeature(
                    icon: Icons.schedule_rounded,
                    title: 'Expires Soon',
                    subtitle:
                    'Codes are valid for a short\ntime for your security.',
                  ),
                  AuthFeature(
                    icon: Icons.refresh_rounded,
                    title: 'Resend Anytime',
                    subtitle: "Didn't get it? Request a\nnew code after 30s.",
                  ),
                ],
                formBuilder: _buildForm,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthMetrics m) {
    final colors = context.c;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// LABEL + required *
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Enter OTP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: m.footerText + 1,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              TextSpan(
                text: ' *',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: m.footerText + 1,
                  fontWeight: FontWeight.w700,
                  // color: colors.statusWarning,
                  color: colors.error,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: m.fieldGap * 0.6),

        _buildPinput(context, m),

        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: _otpError == null
              ? const SizedBox(width: double.infinity, height: 0)
              : Padding(
            padding: EdgeInsets.only(top: m.fieldGap * 0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: m.fieldGap * 0.35),
                Expanded(
                  child: Text(
                    _otpError!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: m.footerText,
                      fontWeight: FontWeight.w500,
                      // color: colors.statusWarning,
                      color: colors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: m.blockGap),

        /// ✅ VERIFY
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => AppButton(
            label: 'Verify Code',
            onPressed: _submit,
            isLoading: state is AuthLoading,
          ),
        ),

        SizedBox(height: m.blockGap * 0.7),

        /// 🔁 RESEND
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code?",
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: m.footerText,
                color: colors.textSecondary,
              ),
            ),
            SizedBox(width: m.fieldGap * 0.4),
            GestureDetector(
              onTap: _secondsLeft == 0 ? _resend : null,
              behavior: HitTestBehavior.opaque,
              child: Text(
                _secondsLeft == 0 ? 'Resend' : 'Resend in ${_secondsLeft}s',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: m.footerText,
                  fontWeight: FontWeight.w700,
                  color: _secondsLeft == 0 ? colors.brand : colors.textMuted,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: m.blockGap * 0.7),

        /// OR DIVIDER
        Row(
          children: [
            Expanded(child: Divider(color: colors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.fieldGap * 0.7),
              child: Text(
                'or',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: m.footerText,
                  color: colors.textSecondary,
                ),
              ),
            ),
            Expanded(child: Divider(color: colors.border)),
          ],
        ),

        SizedBox(height: m.blockGap * 0.7),

        AppButton(
          label: 'Back to Login',
          variant: AppButtonVariant.outlined,
          onPressed: _backToLogin,
        ),

        SizedBox(height: m.blockGap * 0.8),

        AuthTermsText(m: m),
      ],
    );
  }

  Widget _buildPinput(BuildContext context, AuthMetrics m) {
    final colors = context.c;
    final hasError = _otpError != null;

    final boxW = m.isTablet ? (m.isLandscape ? 50.0 : 56.0) : 48.0;
    final boxH = m.isTablet ? (m.isLandscape ? 58.0 : 64.0) : 56.0;

    final pinTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: m.isTablet ? 22 : 20,
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    );

    BoxDecoration deco(Color fill, Color borderColor, {double width = 1}) =>
        BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.buttonRadius),
          border: Border.all(color: borderColor, width: width),
        );

    return Pinput(
      controller: _otpController,
      focusNode: _otpFocusNode,
      length: _otpLength,
      autofocus: true,
      keyboardType: TextInputType.number,
      forceErrorState: hasError,
      errorBuilder: (_, __) => const SizedBox.shrink(),
      onCompleted: (_) => _submit(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      defaultPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: deco(
          colors.surface,
          //hasError ? colors.statusWarning : colors.border
          hasError ? colors.error : colors.border, // CHANGE HERE
           ),
      ),

      focusedPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: deco(
          colors.surface,
          // hasError ? colors.statusWarning : colors.brand,
          hasError ? colors.error : colors.brand, // CHANGE HERE
          width: 1.8,
        ),
      ),

      submittedPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: deco(
          hasError ? colors.surface : colors.brandSoft,
          // hasError ? colors.statusWarning : colors.brand,
          hasError ? colors.error : colors.brand, // CHANGE HERE
        ),
      ),

      errorPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle.copyWith(
          // color: colors.statusWarning
          color: colors.error, // CHANGE HERE
          ),
        decoration: deco(colors.surface, 
        // colors.statusWarning,
        colors.error, // CHANGE HERE
         width: 1.5),
      ),
    );
  }
}