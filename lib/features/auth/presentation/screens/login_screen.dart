import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_interaction_blocker.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_footer_section.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_widget_builder.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/services/login_form_manager.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_tablet_layout.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _loginFormManager = LoginFormManager();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  Failure? _currentError;

  @override
  void initState() {
    super.initState();
    _loginFormManager.registerControllers(
      _emailController,
      _passwordController,
      _emailFocusNode,
      _passwordFocusNode,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.unfocus();
      _passwordFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _loginFormManager.unregisterControllers();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (_isSubmitting) return;
    // if (context.read<AuthBloc>().state is AuthLoading) return;
    _isSubmitting = true;
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else {
      _isSubmitting = false;
    }
  }

  void _onEmailSubmitted(String value) {
    _passwordFocusNode.requestFocus();
  }

  void _onPasswordSubmitted(String value) {
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is! AuthLoading) {
            _isSubmitting = false;
          }
          if (state is AuthAuthenticated) {
            setState(() => _currentError = null);
            context.go(AppRoutes.home);
          } else if (state is AuthOtpRequired) {
            setState(() => _currentError = null);
            context.push(AppRoutes.registerOtp, extra: state.email);
          } else if (state is AuthError) {
            setState(() => _currentError = state.failure);
            if (state.failure is! RateLimitFailure) {
              AppSnackbar.showError(context, state.failure.message);
            }
          }
        },

        buildWhen: (prev, curr) =>
        (prev is AuthLoading) != (curr is AuthLoading) ||
        (prev is AuthError) != (curr is AuthError),

        builder: (context, state) {
          if (_currentError != null) {
            return SafeArea(
              child: _currentError!.buildErrorWidget(
                onRetry: () {
                  setState(() => _currentError = null);
                  if (_formKey.currentState?.validate() ?? false) {
                    _submit();
                  }
                },
                fullScreen: true,
              ),
            );
          }

          return AppInteractionBlocker(
            isBlocking: state is AuthLoading,
            child: SafeArea(
              child: AuthResponsiveLayout(
                title: 'Welcome Back!',
                subtitle:
                'Log in to your account and\ncontinue your shopping journey.',
                formBuilder: _buildForm,
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildForm(BuildContext context, AuthMetrics m) {
    final colors = context.colors;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email',
            isRequired: true,
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: _onEmailSubmitted,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9@.\-]'),
              ),
            ],
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
            ),
            validator: Validators.email,
          ),

          SizedBox(height: m.fieldGap),

          AppTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            isRequired: true,
            hint: 'Enter your password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _onPasswordSubmitted,
            validator: (v) => Validators.required(
              v,
              fieldName: 'Password',
            ),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(AppRoutes.forgotPassword),
              child: Text(
                'Forgot Password?',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: m.linkText,
                  color: colors.brand,
                ),
              ),
            ),
          ),

          SizedBox(height: m.fieldGap * 0.5),

          /// LOGIN
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => SizedBox(
              height: m.buttonHeight,
              child: AppButton(
                label: 'Login',
                onPressed: _submit,
                isLoading: state is AuthLoading,
              ),
            ),
          ),

          SizedBox(height: m.blockGap * 0.7),

          /// OR DIVIDER
          Row(
            children: [
              Expanded(child: Divider(color: colors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: m.fieldGap * 0.7),
                child: Text(
                  'or',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: m.footerText,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: colors.border)),
            ],
          ),

          SizedBox(height: m.blockGap * 0.7),

          AuthFooterLink(
            prefix: AppStrings.alreadyAccount,
            action: AppStrings.signup,
            onTap: () {
              context.go(AppRoutes.register);
            },
          ),
        ],
      ),
    );
  }


}
