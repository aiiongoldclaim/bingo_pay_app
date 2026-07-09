import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_shell.dart';

/// Shown right after a BinGold SSO login OTP is verified — the user is
/// signed in with a BinGold account but has no local password yet, so this
/// screen collects one via `/api/v1/auth/set-password` before landing on
/// the dashboard.
class SsoSetPasswordScreen extends StatefulWidget {
  final String email;
  const SsoSetPasswordScreen({super.key, required this.email});

  @override
  State<SsoSetPasswordScreen> createState() => _SsoSetPasswordScreenState();
}

class _SsoSetPasswordScreenState extends State<SsoSetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SsoSetPasswordRequested(password: _passwordController.text),
      );
    }
  }

  Future<void> _confirmAbandon() async {
    final leaveAnyway = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set a password to continue'),
        content: const Text(
          'Your BinGold account is verified but has no local password yet. '
          "If you leave now without setting one, you won't be able to sign "
          'in or access your account until you restart this SSO login and '
          'set a password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Leave Anyway'),
          ),
        ],
      ),
    );

    if (leaveAnyway == true && mounted) {
      // Tokens were already saved when the SSO OTP was verified, so leaving
      // half-authenticated would strand the user in a broken state. Log
      // them out and send them back to a clean login screen instead.
      context.read<AuthBloc>().add(const LogoutRequested());
      context.go(AppRoutes.login);
    }
  }

  Widget _buildPasswordRequirements() {
    final value = _passwordController.text;
    final requirements = <String, bool>{
      'At least 8 characters': value.length >= 8,
      'One uppercase letter (A-Z)': RegExp(r'[A-Z]').hasMatch(value),
      'One lowercase letter (a-z)': RegExp(r'[a-z]').hasMatch(value),
      'One number (0-9)': RegExp(r'[0-9]').hasMatch(value),
      'One special character (!@#\$%...)': RegExp(
        r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\];/\\]',
      ).hasMatch(value),
    };

    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: requirements.entries
            .map((entry) => _passwordRequirementRow(entry.key, entry.value))
            .toList(),
      ),
    );
  }

  Widget _passwordRequirementRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: met ? AppColors.success : ThemeColors.inkDim,
          ),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: met ? AppColors.success : ThemeColors.inkDim,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmAbandon();
      },
      child: Scaffold(
        backgroundColor: ThemeColors.background,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              AppSnackbar.showError(context, state.failure.message);
            } else if (state is AuthAuthenticated) {
              context.go(AppRoutes.home);
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 6.h),
                    AuthBrandHeader(
                      title: 'Secure Your Account',
                      subtitle:
                          'Set a password for ${widget.email} to finish signing in',
                    ),
                    SizedBox(height: 4.h),
                    AuthCard(
                      children: [
                        AppTextField(
                          controller: _passwordController,
                          label: 'New Password',
                          isRequired: true,
                          hint: 'Create a password',
                          obscureText: _obscurePassword,
                          validator: Validators.password,
                          onChanged: (_) => setState(() {}),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: ThemeColors.inkDim,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: ThemeColors.inkDim,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        if (_passwordController.text.isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          _buildPasswordRequirements(),
                        ],
                        SizedBox(height: 2.h),
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          isRequired: true,
                          hint: 'Re-enter your password',
                          obscureText: _obscureConfirm,
                          validator: (v) => Validators.confirmPassword(
                            v,
                            _passwordController.text,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: ThemeColors.inkDim,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: ThemeColors.inkDim,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) => AppButton(
                            label: 'Continue',
                            onPressed: _submit,
                            isLoading: state is AuthLoading,
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
        ),
      ),
    );
  }
}
