import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_footer_section.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_tablet_layout.dart';
import '../widgets/auth_terms_text.dart';

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            AppSnackbar.showSuccess(context, state.message);
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
        },
        child: SafeArea(
          child: AuthResponsiveLayout(
            title: 'Forgot Password',
            subtitle:
                "Enter your email and we'll send you\na link to reset your password.",
            onTopAction: () => Navigator.of(context).pop(),
            formBuilder: _buildForm,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthMetrics m) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            prefixIcon: const Icon(Icons.mail_outline_rounded),
          ),

          SizedBox(height: m.blockGap),

          /// SEND RESET LINK
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => AppButton(
              label: 'Send Reset Link',
              onPressed: _submit,
              isLoading: state is AuthLoading,
            ),
          ),

          SizedBox(height: m.blockGap * 0.7),

          /// OR DIVIDER
          Row(
            children: [
              Expanded(child: Divider(color: _lineColor(isDark))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: m.fieldGap * 0.7),
                child: Text(
                  'or',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: m.footerText,
                    color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
                  ),
                ),
              ),
              Expanded(child: Divider(color: _lineColor(isDark))),
            ],
          ),

          SizedBox(height: m.blockGap),

          /// BACK TO SIGN IN
          AuthFooterLink(
            prefix: AppStrings.secureLogin,
            action: AppStrings.signin,
            onTap: () {
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }

  Color _lineColor(bool isDark) =>
      isDark ? ThemeColors.white.withValues(alpha: 0.14) : ThemeColors.line;
}
