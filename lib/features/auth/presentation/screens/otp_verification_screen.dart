import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const _otpLength = 6;
  static const _resendCooldownSeconds = 30;

  // final _controllers =
  //     List.generate(_otpLength, (_) => TextEditingController());
  // final _focusNodes = List.generate(_otpLength, (_) => FocusNode());

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
    // for (final c in _controllers) {
    //   c.dispose();
    // }
    // for (final f in _focusNodes) {
    //   f.dispose();
    // }
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

  // String get _otp => _controllers.map((c) => c.text).join();
  String get _otp => _otpController.text;

  // void _onDigitChanged(int index, String value) {
  //   if (value.isNotEmpty && index < _otpLength - 1) {
  //     _focusNodes[index + 1].requestFocus();
  //   } else if (value.isEmpty && index > 0) {
  //     _focusNodes[index - 1].requestFocus();
  //   }
  //   if (_otp.length == _otpLength) {
  //     _submit();
  //   }
  // }

  // void _submit() {
  //   if (_otp.length != _otpLength) {
  //     AppSnackbar.showError(context, 'Enter the $_otpLength-digit code');
  //     return;
  //   }
  //   context.read<AuthBloc>().add(
  //     OtpVerifyRequested(email: widget.email, otp: _otp),
  //   );
  // }

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Enter verification code',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a $_otpLength-digit code to ${widget.email}',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Pinput(
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
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  focusedPinTheme: PinTheme(
                    width: AppSizes.otpBoxWidth,
                    height: AppSizes.otpBoxHeight,
                    textStyle: theme.textTheme.titleLarge,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
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
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(.08),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: List.generate(
                //     _otpLength,
                //     (i) => SizedBox(
                //       width: AppSizes.otpBoxWidth,
                //       height: AppSizes.otpBoxHeight,
                //       child: TextField(
                //         controller: _controllers[i],
                //         focusNode: _focusNodes[i],
                //         textAlign: TextAlign.center,
                //         keyboardType: TextInputType.number,
                //         maxLength: 1,
                //         style: theme.textTheme.titleLarge,
                //         inputFormatters: [
                //           FilteringTextInputFormatter.digitsOnly,
                //         ],
                //         decoration: const InputDecoration(counterText: ''),
                //         onChanged: (value) => _onDigitChanged(i, value),
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => AppButton(
                    label: 'Verify',
                    onPressed: _submit,
                    isLoading: state is AuthLoading,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _secondsLeft == 0 ? _resend : null,
                    child: Text(
                      _secondsLeft == 0
                          ? 'Resend OTP'
                          : 'Resend OTP in ${_secondsLeft}s',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
