import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _countryIdController = TextEditingController(text: '91');
  final _phoneNumberController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Timer? _emailDebounce;
  String? _checkedEmail;
  bool? _emailExists;
  bool _checkingEmail = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _countryIdController.dispose();
    _phoneNumberController.dispose();
    _emailDebounce?.cancel();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    _emailDebounce?.cancel();
    setState(() {
      _checkedEmail = null;
      _emailExists = null;
      _checkingEmail = false;
    });
    final email = value.trim();
    if (Validators.email(email) != null) return;
    _emailDebounce = Timer(const Duration(milliseconds: 600), () {
      context
          .read<AuthBloc>()
          .add(EmailExistenceCheckRequested(email: email));
    });
  }

  void _submit() {
    if (_emailExists == true) {
      AppSnackbar.showError(context, 'This email is already registered');
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              countryId: _countryIdController.text.trim(),
              phoneNumber: _phoneNumberController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          } else if (state is AuthOtpRequired) {
            context.push(AppRoutes.registerOtp, extra: state.email);
          } else if (state is EmailExistenceChecking) {
            setState(() => _checkingEmail = true);
          } else if (state is EmailExistenceChecked) {
            if (state.email != _emailController.text.trim()) return;
            setState(() {
              _checkingEmail = false;
              _checkedEmail = state.email;
              _emailExists = state.exists;
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    onChanged: _onEmailChanged,
                    suffixIcon: _checkingEmail
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : _emailExists == null ||
                                _checkedEmail != _emailController.text.trim()
                            ? null
                            : Icon(
                                _emailExists!
                                    ? Icons.error_outline
                                    : Icons.check_circle_outline,
                                color: _emailExists!
                                    ? AppColors.error
                                    : AppColors.success,
                              ),
                  ),
                  if (!_checkingEmail &&
                      _emailExists == true &&
                      _checkedEmail == _emailController.text.trim())
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 4),
                      child: Text(
                        'This email is already registered',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        child: AppTextField(
                          controller: _countryIdController,
                          label: 'Code',
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              Validators.required(v, fieldName: 'Code'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _phoneNumberController,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              Validators.required(v, fieldName: 'Phone number'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirm,
                    validator: (v) =>
                        Validators.confirmPassword(v, _passwordController.text),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Create Account',
                      onPressed: _submit,
                      isLoading: state is AuthLoading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
