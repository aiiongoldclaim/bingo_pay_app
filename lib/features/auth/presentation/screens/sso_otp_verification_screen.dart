import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_shell.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        title: const Text('Sign In with BinGold'),
      ),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 3.h),
                AuthBrandHeader(
                  title: 'Enter sign-in code',
                  subtitle:
                      'We sent a $_otpLength-digit code to ${widget.email}',
                ),
                SizedBox(height: 3.h),
                AuthCard(
                  children: [
                    Center(
                      child: Pinput(
                        controller: _otpController,
                        focusNode: _otpFocusNode,
                        length: _otpLength,
                        autofocus: true,
                        keyboardType: TextInputType.number,
                        onCompleted: (_) => _submit(),
                        defaultPinTheme: PinTheme(
                          width: AppSizes.otpBoxWidth,
                          height: AppSizes.otpBoxHeight,
                          textStyle: theme.textTheme.titleLarge,
                          decoration: BoxDecoration(
                            border: Border.all(color: ThemeColors.line),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: AppSizes.otpBoxWidth,
                          height: AppSizes.otpBoxHeight,
                          textStyle: theme.textTheme.titleLarge,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ThemeColors.blue,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: AppSizes.otpBoxWidth,
                          height: AppSizes.otpBoxHeight,
                          textStyle: theme.textTheme.titleLarge,
                          decoration: BoxDecoration(
                            color: ThemeColors.blueSoft,
                            border: Border.all(color: ThemeColors.blue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => AppButton(
                        label: 'Verify & Sign In',
                        onPressed: _submit,
                        isLoading: state is AuthLoading,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Center(
                      child: TextButton(
                        onPressed: _secondsLeft == 0 ? _resend : null,
                        style: TextButton.styleFrom(
                          foregroundColor: ThemeColors.blue,
                        ),
                        child: Text(
                          _secondsLeft == 0
                              ? 'Resend OTP'
                              : 'Resend OTP in ${_secondsLeft}s',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
