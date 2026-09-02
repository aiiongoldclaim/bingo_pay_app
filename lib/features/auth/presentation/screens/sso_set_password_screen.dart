import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_secure_note.dart';
import '../widgets/leave_without_password_dialog.dart';
import '../widgets/password_requirements.dart';

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

  // Future<void> _confirmAbandon() async {
  //   final leaveAnyway = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) => AlertDialog(
  //       title: const Text('Set a password to continue'),
  //       content: const Text(
  //         'Your TheVault account is verified but has no local password yet. '
  //         "If you leave now without setting one, you won't be able to sign "
  //         'in or access your account until you restart this SSO login and '
  //         'set a password.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(dialogContext).pop(false),
  //           child: const Text('Stay'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.of(dialogContext).pop(true),
  //           style: TextButton.styleFrom(foregroundColor: AppColors.error),
  //           child: const Text('Leave Anyway'),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (leaveAnyway == true && mounted) {
  //     // Tokens were already saved when the SSO OTP was verified, so leaving
  //     // half-authenticated would strand the user in a broken state. Log
  //     // them out and send them back to a clean login screen instead.
  //     context.read<AuthBloc>().add(const LogoutRequested());
  //     context.go(AppRoutes.login);
  //   }
  // }

  // ------------------------------------ UI ------------------------------------
  Future<void> _confirmAbandon() async {
    final leaveAnyway = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: ThemeColors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => const LeaveWithoutPasswordDialog(),
    );

    if (leaveAnyway == true && mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.setDeviceType(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmAbandon();
      },
      child: Scaffold(
        backgroundColor: isDark ? ThemeColors.ink : ThemeColors.background,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              AppSnackbar.showError(context, state.failure.message);
            } else if (state is AuthAuthenticated) {
              context.go(AppRoutes.home);
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final matrics = AuthMetrics.of(constraints);
              final wide = matrics.isTablet && matrics.isLandscape;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  matrics.pagePadH,
                  matrics.pagePadV,
                  matrics.pagePadH,
                  matrics.pagePadV,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - (matrics.pagePadV * 2),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: matrics.contentMaxWidth,
                            ),
                            child: wide
                                ? _WideLayout(
                                    m: matrics,
                                    isDark: isDark,
                                    screen: this,
                                  )
                                : _NarrowLayout(
                                    m: matrics,
                                    isDark: isDark,
                                    screen: this,
                                  ),
                          ),
                        ),

                        const Spacer(),
                        SizedBox(height: matrics.blockGap),
                        AuthSecureNote(metrics: matrics),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildTopBar(AuthMetrics m, bool isDark) {
    final ink = isDark ? ThemeColors.white : ThemeColors.ink;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InkResponse(
          onTap: _confirmAbandon,
          radius: 24,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_rounded, size: 22, color: ink),
          ),
        ),
        SizedBox(width: m.fieldGap * 0.6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'The',
                    style: TextStyle(color: ink),
                  ),
                  TextSpan(
                    text: 'Vaults',
                    style: TextStyle(
                      color: isDark
                          ? ThemeColors.primaryPurple
                          : ThemeColors.deepPurple,
                    ),
                  ),
                ],
              ),
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: m.brandTitle,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            SizedBox(height: m.brandTagline * 0.25),
            Text(
              'YOUR EVERYDAY STORE',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: m.brandTagline,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w600,
                color: isDark ? ThemeColors.textGrey : ThemeColors.inkDim,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildHeadline(AuthMetrics m, bool isDark, {required bool alignStart}) {
    final align = alignStart ? TextAlign.left : TextAlign.center;
    final cross = alignStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: cross,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Reset Password',
          textAlign: align,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: m.heroTitle,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: isDark ? ThemeColors.white : ThemeColors.ink,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.45),
        Text(
          'Enter your new password and make your account secure',
          textAlign: align,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: m.heroBody,
            height: 1.45,
            color: isDark ? ThemeColors.inkDim : ThemeColors.inkMid,
          ),
        ),
      ],
    );
  }

  Widget buildForm(AuthMetrics m, bool isDark) {
    final iconColor = isDark ? ThemeColors.textGrey : ThemeColors.inkDim;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: m.formMaxWidth),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _passwordController,
              label: 'New Password',
              isRequired: true,
              hint: 'Enter new password',
              obscureText: _obscurePassword,
              validator: Validators.password,
              onChanged: (_) => setState(() {}),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: iconColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: iconColor,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),

            // ---- checklist ab New Password ke theek neeche ----
            if (_passwordController.text.isNotEmpty) ...[
              SizedBox(height: m.fieldGap * 0.6),
              PasswordRequirements(metrics: m, value: _passwordController.text),
            ],

            SizedBox(height: m.fieldGap),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              isRequired: true,
              hint: 'Confirm new password',
              obscureText: _obscureConfirm,
              validator: (v) =>
                  Validators.confirmPassword(v, _passwordController.text),
              prefixIcon: Icon(Icons.lock_outline_rounded, color: iconColor),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: iconColor,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            SizedBox(height: m.blockGap * 2),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) => AppButton(
                label: 'Continue',
                onPressed: _submit,
                isLoading: state is AuthLoading,
                height: m.buttonHeight,
                fontSize: m.linkText + 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.m,
    required this.isDark,
    required this.screen,
  });

  final AuthMetrics m;
  final bool isDark;
  final _SsoSetPasswordScreenState screen;

  @override
  Widget build(BuildContext context) {
    final showHero = m.isTablet || !m.isLandscape;

    final screenH = MediaQuery.of(context).size.height;
    final heroCap = (screenH * 0.22).clamp(120.0, 260.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        screen.buildTopBar(m, isDark),
        SizedBox(height: m.blockGap),

        // 1) IMAGE
        if (showHero) ...[
          Center(
            child: _HeroArt(m: m, isDark: isDark, maxHeight: heroCap),
          ),
          SizedBox(height: m.blockGap * 0.7),
        ],

        screen.buildHeadline(m, isDark, alignStart: true),
        SizedBox(height: m.blockGap),

        screen.buildForm(m, isDark),
      ],
    );
  }
}

/// Tablet landscape — LEFT art | divider | RIGHT headline + form
class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.m,
    required this.isDark,
    required this.screen,
  });

  final AuthMetrics m;
  final bool isDark;
  final _SsoSetPasswordScreenState screen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        screen.buildTopBar(m, isDark),
        SizedBox(height: m.blockGap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// LEFT — sirf image
              Expanded(
                flex: 5,
                child: Center(
                  child: _HeroArt(m: m, isDark: isDark),
                ),
              ),

              /// MIDDLE DIVIDER
              _PaneDivider(m: m),

              /// RIGHT — Reset Password + subtitle + form
              Expanded(
                flex: 6,
                child: _FitPane(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      screen.buildHeadline(m, isDark, alignStart: true),
                      SizedBox(height: m.blockGap),
                      screen.buildForm(m, isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FitPane extends StatelessWidget {
  const _FitPane({required this.child, this.minScale = 0.85});

  final Widget child;
  final double minScale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (!c.hasBoundedHeight) return child;
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: c.maxHeight / minScale),
              child: SizedBox(width: c.maxWidth, child: child),
            ),
          ),
        );
      },
    );
  }
}

/// Panes ke beech thin fading divider.
class _PaneDivider extends StatelessWidget {
  const _PaneDivider({required this.m});

  final AuthMetrics m;

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).dividerColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.paneGap),
      child: SizedBox(
        width: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                line.withValues(alpha: 0),
                line.withValues(alpha: 0.55),
                line.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroArt extends StatelessWidget {
  const _HeroArt({required this.m, required this.isDark, this.maxHeight});

  final AuthMetrics m;
  final bool isDark;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: m.heroImageMax * 1.6,
        maxHeight: maxHeight ?? double.infinity,
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.asset(
          AppImages.onboard1Dark,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
