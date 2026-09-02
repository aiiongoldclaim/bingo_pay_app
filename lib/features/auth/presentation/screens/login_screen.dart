// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/utils/validators.dart';
// import '../../../../core/widgets/app_button.dart';
// import '../../../../core/widgets/app_snackbar.dart';
// import '../../../../core/widgets/app_text_field.dart';
// import '../bloc/auth_bloc.dart';
// import '../bloc/auth_event.dart';
// import '../bloc/auth_state.dart';
// import '../widgets/auth_shell.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _obscurePassword = true;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _submit() {
//     if (_formKey.currentState?.validate() ?? false) {
//       context.read<AuthBloc>().add(
//             LoginRequested(
//               email: _emailController.text.trim(),
//               password: _passwordController.text,
//             ),
//           );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeColors.background,
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthAuthenticated) {
//             context.go(AppRoutes.home);
//           } else if (state is AuthOtpRequired) {
//             context.push(AppRoutes.registerOtp, extra: state.email);
//           } else if (state is AuthError) {
//             AppSnackbar.showError(context, state.failure.message);
//           }
//         },
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.symmetric(horizontal: 6.w),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   SizedBox(height: 6.h),
//                   const AuthBrandHeader(
//                     title: 'Welcome Back',
//                     subtitle: 'Sign in to continue to BingoPay',
//                   ),
//                   SizedBox(height: 4.h),
//                   AuthCard(
//                     children: [
//                       AppTextField(
//                         controller: _emailController,
//                         label: 'Email',
//                         keyboardType: TextInputType.emailAddress,
//                         prefixIcon: const Icon(
//                           Icons.mail_outline_rounded,
//                           color: ThemeColors.inkDim,
//                         ),
//                         // validator: Validators.email,
//                       ),
//                       SizedBox(height: 2.h),
//                       AppTextField(
//                         controller: _passwordController,
//                         label: 'Password',
//                         obscureText: _obscurePassword,
//                         validator: Validators.password,
//                         prefixIcon: const Icon(
//                           Icons.lock_outline_rounded,
//                           color: ThemeColors.inkDim,
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                             color: ThemeColors.inkDim,
//                           ),
//                           onPressed: () => setState(
//                             () => _obscurePassword = !_obscurePassword,
//                           ),
//                         ),
//                       ),
//                       Align(
//                         alignment: Alignment.centerRight,
//                         child: TextButton(
//                           onPressed: () =>
//                               context.push(AppRoutes.forgotPassword),
//                           style: TextButton.styleFrom(
//                             foregroundColor: ThemeColors.blue,
//                             padding: EdgeInsets.zero,
//                             minimumSize: Size.zero,
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           child: Text(
//                             'Forgot Password?',
//                             style: AppTextStyles.labelLarge.copyWith(
//                               color: ThemeColors.blue,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 1.h),
//                       BlocBuilder<AuthBloc, AuthState>(
//                         builder: (context, state) => AppButton(
//                           label: 'Sign In',
//                           onPressed: _submit,
//                           isLoading: state is AuthLoading,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 3.h),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Don't have an account?",
//                         style: AppTextStyles.bodyMedium,
//                       ),
//                       TextButton(
//                         onPressed: () => context.go(AppRoutes.register),
//                         style: TextButton.styleFrom(
//                           foregroundColor: ThemeColors.blue,
//                         ),
//                         child: Text(
//                           'Register',
//                           style: AppTextStyles.labelLarge.copyWith(
//                             color: ThemeColors.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 3.h),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

//NEW
import 'package:flutter/material.dart';
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
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/services/login_form_manager.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_tablet_layout.dart';
import '../widgets/auth_terms_text.dart';

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
    if (context.read<AuthBloc>().state is AuthLoading) return;
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
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
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          } else if (state is AuthOtpRequired) {
            context.push(AppRoutes.registerOtp, extra: state.email);
          } else if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
        },

        buildWhen: (prev, curr) =>
        (prev is AuthLoading) != (curr is AuthLoading),

        builder: (context, state) {
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
              Expanded(child: Divider(color: ThemeColors.mediumPurple)),
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
