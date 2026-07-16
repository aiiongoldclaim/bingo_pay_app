import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/kyb_status_navigator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            VendorLoginRequested(
              identifier: _identifierController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Only the topmost route shows the error. Otherwise a pushed
            // child (e.g. Forgot Password) and this screen both fire and the
            // snackbar appears twice.
            if (ModalRoute.of(context)?.isCurrent ?? true) {
              AppSnackbar.showError(context, state.failure.message);
            }
            log('AuthError: ${state.failure.message}', name: 'LoginScreen');
          } else if (state is AuthAuthenticated) {
            handlePostAuthKybNavigation(context, state.user);
          }
        },
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildFormCard(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF24347C), AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Soft colour glows behind the glass sheet (Liquid Glass hero).
          Positioned(
            top: -60,
            left: -50,
            child: _HeroGlow(color: const Color(0xFF5D82FF), size: 240),
          ),
          Positioned(
            top: 60,
            right: -70,
            child: _HeroGlow(color: AppColors.secondary, size: 200),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BINGO PAY',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Run your shop.\nGet paid faster.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Products, orders & payments in one place.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Frosted sheet over the navy hero.
        color: context.colors.card.withValues(alpha: 0.94),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.colors.textMuted.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            _buildForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
        padding: EdgeInsets.zero,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _identifierController,
                focusNode: _emailFocus,
                nextFocusNode: _passwordFocus,
                label: 'Email',
                isRequired: true,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: AppInputFormatters.email(),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                onSubmitted: _submit,
                label: 'Password',
                isRequired: true,
                obscureText: _obscurePassword,
                validator: Validators.loginPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AppButton(
                  label: 'Sign In',
                  onPressed: _submit,
                  isLoading: state is AuthLoading,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.register),
                    child: const Text('Register'),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

class _HeroGlow extends StatelessWidget {
  final Color color;
  final double size;

  const _HeroGlow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.45),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}
