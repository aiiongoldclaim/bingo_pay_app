import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_interaction_blocker.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/custom_footer_section.dart';
import '../../../../core/error/failures.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_tablet_layout.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (context.read<AuthBloc>().state is AuthLoading) return;
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
      ForgotPasswordRequested(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSent) {
            AppSnackbar.showSuccess(context, state.message);
            Navigator.of(context).pop();
          } else if (state is AuthError) {
            if (state.failure is! RateLimitFailure) {
              AppSnackbar.showError(context, state.failure.message);
            }
          }
        },
        buildWhen: (prev, curr) =>
            (prev is AuthLoading) != (curr is AuthLoading),

        builder: (context, state) {
          return AppInteractionBlocker(
            isBlocking: state is AuthLoading,
            child: Stack(
              fit: StackFit.expand,
              children: [

                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 140,
                  child: AuthBottomWave(),
                ),
                SafeArea(
                  child: AuthResponsiveLayout(
                    title: AppStrings.forgotPassword,
                    subtitle:
                        "No worries! Enter your email address and we'll send "
                        'you a link to reset your password.',
                    centeredHero: true,
                    heroImageAsset: AppImages.lock,
                    centeredImageGap: 16,
                    centeredBrandOnTop: true,
                    onTopAction: () => Navigator.of(context).pop(),
                    formBuilder: _buildForm,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthMetrics m) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email Address',
            hint: 'Enter your email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _submit();
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.\-]')),
            ],
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
              suffixIcon: Icons.arrow_forward_rounded,
              gradient: ThemeColors.authCtaGradient,
            ),
          ),

          SizedBox(height: m.blockGap),

          /// BACK TO LOGIN
          FittedBox(
            fit: BoxFit.scaleDown,
            child: AuthFooterLink(
              prefix: AppStrings.rememberPassword,
              action: AppStrings.loginCta,
              onTap: () {
                context.go(AppRoutes.login);
              },
            ),
          ),
        ],
      ),
    );
  }
}
