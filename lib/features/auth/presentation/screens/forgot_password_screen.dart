import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_shell.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            ForgotPasswordRequested(email: _emailController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        title: const Text('Forgot Password'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            AppSnackbar.showSuccess(
              context,
              'Password reset email sent. Please check your inbox.',
            );
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
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
                  SizedBox(height: 3.h),
                  const AuthBrandHeader(
                    title: 'Reset your password',
                    subtitle: "Enter your email and we'll send you a reset link",
                  ),
                  SizedBox(height: 3.h),
                  AuthCard(
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                        prefixIcon: const Icon(
                          Icons.mail_outline_rounded,
                          color: ThemeColors.inkDim,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) => AppButton(
                          label: 'Send Reset Link',
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
