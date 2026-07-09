import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // kept for future refinements; currently unused



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
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 🔵 HERO GRADIENT
          Container(
            height: 38.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeColors.blue, ThemeColors.blueDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // ✨ LIGHT BLOBS
          const _Blob(
            top: 60,
            right: -40,
            size: 120,
            colors: [Colors.white, Colors.white54],
          ),
          const _Blob(
            bottom: -90,
            left: -60,
            size: 240,
            colors: [ThemeColors.blueDeep, Colors.black12],
          ),

          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is PasswordResetSent) {
                AppSnackbar.showSuccess(context, state.message);
                Navigator.of(context).pop();
              } else if (state is AuthError) {
                AppSnackbar.showError(context, state.failure.message);
              }
            },
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 6.h),

                            // 🔝 HEADER
                            Column(
                              children: const [
                                Icon(
                                  Icons.lock_reset_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Reset your password',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Enter your email and we'll send you a reset link",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            SizedBox(height: 6.h),

                            // 💎 FLOATING CARD
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
                                autovalidateMode:
                                    AutovalidateMode.onUserInteractionIfError,
                                child: Column(
                                  children: [
                                    AppTextField(
                                      controller: _emailController,
                                      label: 'Email',
                                      isRequired: true,
                                      hint: 'Enter your email',
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      validator: Validators.email,
                                      prefixIcon: const Icon(
                                        Icons.mail_outline_rounded,
                                        color: ThemeColors.inkDim,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, state) => AppButton(
                                        label: 'Send Reset Link',
                                        onPressed: _submit,
                                        isLoading: state is AuthLoading,
                                      ),
                                    ),

                                    SizedBox(height: 14),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Remembered it?",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: ThemeColors.inkMid),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: Text(
                                            'Back to Sign In',
                                            style: TextStyle(
                                              color: ThemeColors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),
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
            colors: colors.map((c) => c.withOpacity(0.2)).toList(),
          ),
        ),
      ),
    );
  }
}

