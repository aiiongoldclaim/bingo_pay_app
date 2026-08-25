import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
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

  String get _otp => _otpController.text;

  void _submit() {
    final otp = _otpController.text.trim();

    if (otp.length != _otpLength) {
      AppSnackbar.showError(context, 'Enter the $_otpLength-digit code');
      return;
    }

    context.read<AuthBloc>().add(
      OtpVerifyRequested(email: widget.email, otp: otp),
    );
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    context.read<AuthBloc>().add(OtpResendRequested(email: widget.email));
  }

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          } else if (state is OtpResendSent) {
            AppSnackbar.showSuccess(context, 'OTP resent to ${widget.email}');
            _startCooldown();
          } else if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
        },
        child: SafeArea(
          child: AuthResponsiveLayout(
            title: 'Verify Your Email',
            subtitle:
                'Enter the $_otpLength-digit code we sent to\nyour email address.',
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
      ),
    );
  }

  void _backToLogin() {
    FocusScope.of(context).unfocus();
    LoginFormManager().clearForm();
    context.go(AppRoutes.login);
  }

  Widget _buildForm(BuildContext context, AuthMetrics m) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// 📧 EMAIL CHIP
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: m.fieldGap * 0.8,
              vertical: m.fieldGap * 0.5,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? ThemeColors.white.withValues(alpha: 0.05)
                  : ThemeColors.blueSoft,
              borderRadius: BorderRadius.circular(m.buttonRadius),
              border: Border.all(
                color: isDark
                    ? ThemeColors.white.withValues(alpha: 0.10)
                    : ThemeColors.line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mail_outline_rounded,
                  size: m.linkText + 3,
                  color: isDark ? ThemeColors.gold1 : ThemeColors.blue,
                ),
                SizedBox(width: m.fieldGap * 0.5),
                Flexible(
                  child: Text(
                    widget.email,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: m.linkText,
                      fontWeight: FontWeight.w600,
                      color: isDark ? ThemeColors.white : ThemeColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: m.blockGap),

        /// 🔢 LABEL
        Text(
          'Enter OTP',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: m.footerText + 1,
            fontWeight: FontWeight.w600,
            color: isDark ? ThemeColors.white : ThemeColors.ink,
          ),
        ),

        SizedBox(height: m.fieldGap * 0.6),

        /// 🔢 OTP INPUT
        _buildPinput(context, m, isDark, theme),

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
                color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
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
                  color: _secondsLeft == 0
                      ? theme.colorScheme.primary
                      : (isDark ? ThemeColors.inkDim : ThemeColors.textGrey),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: m.blockGap * 0.7),

        /// OR DIVIDER
        Row(
          children: [
            Expanded(child: Divider(color: _lineColor(isDark))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.fieldGap * 0.7),
              child: Text(
                'or',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: m.footerText,
                  color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
                ),
              ),
            ),
            Expanded(child: Divider(color: _lineColor(isDark))),
          ],
        ),

        SizedBox(height: m.blockGap * 0.7),

        /// 🔙 BACK TO LOGIN
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

  Widget _buildPinput(
    BuildContext context,
    AuthMetrics m,
    bool isDark,
    ThemeData theme,
  ) {
    final boxW = m.isTablet ? (m.isLandscape ? 50.0 : 56.0) : 48.0;
    final boxH = m.isTablet ? (m.isLandscape ? 58.0 : 64.0) : 56.0;

    final pinTextStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: m.isTablet ? 22 : 20,
      fontWeight: FontWeight.w700,
      color: isDark ? ThemeColors.white : ThemeColors.ink,
    );

    final fill = isDark
        ? ThemeColors.white.withValues(alpha: 0.04)
        : ThemeColors.surface;

    final border = isDark
        ? ThemeColors.white.withValues(alpha: 0.12)
        : ThemeColors.line;

    return Pinput(
      controller: _otpController,
      focusNode: _otpFocusNode,
      length: _otpLength,
      autofocus: true,
      keyboardType: TextInputType.number,
      onCompleted: (_) => _submit(),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      defaultPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.buttonRadius),
          border: Border.all(color: border),
        ),
      ),

      focusedPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.buttonRadius),
          border: Border.all(color: theme.colorScheme.primary, width: 1.8),
        ),
      ),

      submittedPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(m.buttonRadius),
          border: Border.all(color: theme.colorScheme.primary),
        ),
      ),

      errorPinTheme: PinTheme(
        width: boxW,
        height: boxH,
        textStyle: pinTextStyle,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(m.buttonRadius),
          border: Border.all(color: ThemeColors.red),
        ),
      ),
    );
  }

  Color _lineColor(bool isDark) =>
      isDark ? ThemeColors.white.withValues(alpha: 0.14) : ThemeColors.line;
}
