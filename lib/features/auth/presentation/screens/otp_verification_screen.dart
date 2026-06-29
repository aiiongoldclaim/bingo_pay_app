import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

const _resendCooldownSeconds = 30;
const _otpLength = 6;

class OtpScreenArgs {
  final String email;

  const OtpScreenArgs({required this.email});
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
    context.read<AuthBloc>().add(
      VerifyOtpRequested(email: widget.args.email, otp: _otpController.text),
    );
  }

  void _onResend() {
    if (_secondsRemaining > 0) return;
    _otpController.clear();
    context.read<AuthBloc>().add(ResendOtpRequested(email: widget.args.email));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          } else if (state is AuthOtpRequired) {
            _startResendTimer();
            AppSnackbar.showSuccess(context, 'OTP resent to ${state.email}');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Enter verification code',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a $_otpLength-digit code to ${widget.args.email}',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _OtpBoxesInput(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    final canVerify = _otpController.text.length == _otpLength;
                    return AppButton(
                      label: 'Verify',
                      onPressed: canVerify ? _onVerify : null,
                      isLoading: isLoading,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive the code?"),
                    TextButton(
                      onPressed: _secondsRemaining == 0 ? _onResend : null,
                      child: Text(
                        _secondsRemaining == 0
                            ? 'Resend OTP'
                            : 'Resend in ${_secondsRemaining}s',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: isActive ? 2 : 1,
                  ),
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
