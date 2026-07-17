import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_glass.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/glass/glass_back_button.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/kyb_status_navigator.dart';

const _resendCooldownSeconds = 30;
const _otpLength = 6;

enum OtpType { register, login, forgotPassword }

class OtpScreenArgs {
  final String email;
  final OtpType otpType;

  const OtpScreenArgs({required this.email, required this.otpType});
}

class OtpVerificationScreen extends StatefulWidget {
  final OtpScreenArgs args;
  const OtpVerificationScreen({super.key, required this.args});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  Timer? _resendTimer;
  int _secondsRemaining = _resendCooldownSeconds;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));
    _startResendTimer();
  }

  void _startResendTimer() {
    _secondsRemaining = _resendCooldownSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _onVerify() {
    if (_otpController.text.length != _otpLength) return;
    switch (widget.args.otpType) {
      case OtpType.register:
        context.read<AuthBloc>().add(
              VerifyOtpRequested(
                email: widget.args.email,
                otp: _otpController.text,
              ),
            );
      case OtpType.login:
        context.read<AuthBloc>().add(
              BinGoldVerifyLoginRequested(
                email: widget.args.email,
                otp: _otpController.text,
              ),
            );
      case OtpType.forgotPassword:
        // TODO: dispatch forgot password OTP verify event
        break;
    }
  }

  void _onResend() {
    if (_secondsRemaining > 0) return;
    _otpController.clear();
    switch (widget.args.otpType) {
      case OtpType.register:
        context.read<AuthBloc>().add(
              ResendOtpRequested(email: widget.args.email),
            );
      case OtpType.login:
        context.read<AuthBloc>().add(
              BinGoldLoginOtpRequested(email: widget.args.email),
            );
      case OtpType.forgotPassword:
        // TODO: dispatch forgot password OTP resend event
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegisterFlow = widget.args.otpType == OtpType.register;

    return GlassScaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            if (ModalRoute.of(context)?.isCurrent ?? true) {
              AppSnackbar.showError(context, state.failure.message);
            }
          } else if (state is AuthOtpRequired) {
            _startResendTimer();
            AppSnackbar.showSuccess(context, 'OTP resent to ${state.email}');
          } else if (state is AuthPasswordSetupRequired) {
            context.push(AppRoutes.setPassword);
          } else if (state is AuthAuthenticated) {
            handlePostAuthKybNavigation(context, state.user);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GlassBackButton(
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 24),
                if (isRegisterFlow) ...[
                  const StepProgressBar(currentStep: 3, totalSteps: 4),
                  const SizedBox(height: 16),
                  Text(
                    'Step 3 of 4',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text.rich(
                  TextSpan(
                    text: 'Enter the code we sent to\n',
                    style: TextStyle(
                      fontSize: 24,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: context.colors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: widget.args.email,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _OtpBoxesInput(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _secondsRemaining == 0 ? _onResend : null,
                    child: Text(
                      _secondsRemaining == 0
                          ? 'Resend code'
                          : 'Resend code in ${_secondsRemaining.toString().padLeft(2, '0')}s',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    final canVerify =
                        _otpController.text.length == _otpLength;
                    return AppButton(
                      label: 'Verify',
                      onPressed: canVerify ? _onVerify : null,
                      isLoading: isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Segmented progress bar for the multi-step auth flow.
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < totalSteps; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < currentStep
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpBoxesInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _OtpBoxesInput({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpLength, (index) {
              final digit = index < controller.text.length
                  ? controller.text[index]
                  : '';
              final isActive = index == controller.text.length;
              return Container(
                width: 44,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.glass.fill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? theme.colorScheme.primary
                        : context.colors.border,
                    width: isActive ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.glass.shadow,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(digit, style: theme.textTheme.headlineSmall),
              );
            }),
          ),
          Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: _otpLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
