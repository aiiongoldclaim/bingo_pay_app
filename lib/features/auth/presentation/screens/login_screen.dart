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
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// 🔵 TOP GRADIENT HERO
          Container(
            height: 38.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.blue,
                  ThemeColors.blueDeep,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          /// 💡 LIGHT BLOB
          const _Blob(
            top: 60,
            right: -40,
            size: 120,
            colors: [Colors.white, Colors.white54],
          ),

          /// 🌙 BOTTOM DECORATION BLOB
          const _Blob(
            bottom: 30,
            left: -160,
            size: 260,
            colors: [ThemeColors.blueDeep, Colors.black12],
          ),

          /// 🧠 LOGIC
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go(AppRoutes.home);
              } else if (state is AuthOtpRequired) {
                context.push(AppRoutes.registerOtp, extra: state.email);
              } else if (state is AuthError) {
                AppSnackbar.showError(context, state.failure.message);
              }
            },

            /// 📱 UI
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(height: 6.h),

                            /// 🔝 HEADER (INSIDE GRADIENT)
                            Column(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Welcome Back',
                                  style: AppTextStyles.headlineMedium
                                      .copyWith(color: Colors.white),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Login to your account',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: Colors.white70),
                                ),
                              ],
                            ),

                            SizedBox(height: 6.h),

                            /// 💎 FLOATING CARD
                            Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                                child: Column(
                                  children: [
                                    AppTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      isRequired: true,
                                      hint: 'Enter your email',
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      prefixIcon: const Icon(Icons.mail),
                                      validator: Validators.email,
                                    ),

                                    SizedBox(height: 2.h),

                                    AppTextField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      isRequired: true,
                                      hint: 'Enter your password',
                                      obscureText: _obscurePassword,
                                      validator: (v) => Validators.required(
                                        v,
                                        fieldName: 'Password',
                                      ),
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                    ),

                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => context.push(
                                            AppRoutes.forgotPassword),
                                        child: Text(
                                          'Forgot Password?',
                                          style: AppTextStyles.labelLarge
                                              .copyWith(
                                            color: ThemeColors.blue,
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 1.h),

                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) =>
                                          AppButton(
                                        label: 'Sign In',
                                        onPressed: _submit,
                                        isLoading: 
                                            state is AuthLoading,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            /// 👇 FOOTER
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style:
                                      AppTextStyles.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () =>
                                      context.go(AppRoutes.register),
                                  child: Text(
                                    'Sign Up',
                                    style: AppTextStyles.labelLarge
                                        .copyWith(
                                      color: ThemeColors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 2.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 SMALL BLOB
class _Blob extends StatelessWidget {
  final double? top, bottom, left, right;
  final double size;
  final List<Color> colors;

  const _Blob({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors:
                colors.map((c) => c.withOpacity(0.2)).toList(),
          ),
        ),
      ),
    );
  }
}