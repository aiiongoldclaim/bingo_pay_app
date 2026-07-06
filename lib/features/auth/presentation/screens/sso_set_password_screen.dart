import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/router/app_routes.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        obscureText: _obscurePassword,
                        validator: Validators.password,
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
                      SizedBox(height: 2.h),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
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
                      SizedBox(height: 1.h),
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
    );
  }
}
