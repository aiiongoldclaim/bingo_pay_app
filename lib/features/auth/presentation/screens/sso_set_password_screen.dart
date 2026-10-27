import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/leave_without_password_dialog.dart';
import '../widgets/password_requirements.dart';
import '../widgets/vault_auth_widgets.dart';

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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _showInitialWarning();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showInitialWarning() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: ThemeColors.black.withValues(alpha: 0.6),
          builder: (dialogContext) => _InitialPasswordWarningDialog(
            email: widget.email,
            onDismiss: () => Navigator.of(dialogContext).pop(),
          ),
        );
      }
    });
  }

  void _submit() {
    if (_isSubmitting) return;
    _isSubmitting = true;
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        SsoSetPasswordRequested(password: _passwordController.text),
      );
    } else {
      _isSubmitting = false;
    }
  }

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmAbandon();
      },
      child: Scaffold(
        backgroundColor: ThemeColors.vaultLoginCream,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is! AuthLoading) {
              _isSubmitting = false;
            }
            if (state is AuthError) {
              AppSnackbar.showError(context, state.failure.message);
            } else if (state is AuthAuthenticated) {
              context.go(AppRoutes.home);
            }
          },
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: ThemeColors.vaultLoginCream,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final m = AuthMetrics.of(constraints);
                final w = constraints.maxWidth;
                final topW = (w * 0.48).clamp(150.0, 380.0);
                final bottomW = (w * 0.66).clamp(220.0, 520.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      width: topW,
                      child: const VaultCornerArt(
                        asset: AppImages.vaultLoginCornerTop,
                        corner: Alignment.topRight,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      width: bottomW,
                      child: const VaultCornerArt(
                        asset: AppImages.vaultLoginCornerBottom,
                        corner: Alignment.bottomLeft,
                      ),
                    ),

                    SafeArea(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          m.pagePadH * 0.7,
                          0,
                          m.pagePadH * 0.7,
                          m.blockGap,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: m.blockGap * 2.2),
                                VaultWordmark(
                                  fontSize: m.brandTitle * 1.3,
                                  showDiamond: false,
                                  tagline: 'TIMELESS LUXURY FOR YOU',
                                  taglineColor: ThemeColors.vaultInk,
                                ),
                                SizedBox(height: m.blockGap * 1.4),
                                _buildHeadline(m),
                                SizedBox(height: m.blockGap),
                                _buildForm(m),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline(AuthMetrics m) {
    return Column(
      children: [
        Image.asset(
          AppImages.vaultPadlock,
          height: m.isTablet ? 170 : 140,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
        SizedBox(height: m.fieldGap * 0.6),
        Text(
          'Set Your Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kVaultSerif,
            fontSize: m.heroTitle * 1.05,
            fontWeight: FontWeight.w600,
            height: 1.1,
            color: ThemeColors.vaultInk,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.4),
        Container(width: 40, height: 1.5, color: ThemeColors.vaultGold),
        SizedBox(height: m.fieldGap * 0.5),
        Text(
          'Create a secure password to complete your account setup',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: m.linkText,
            height: 1.45,
            color: ThemeColors.vaultBody,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(AuthMetrics m) {
    final fieldStyle = vaultFieldTextStyle(m);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _passwordController,
            label: '',
            obscureText: _obscurePassword,
            validator: Validators.password,
            onChanged: (_) => setState(() {}),
            cursorColor: ThemeColors.vaultPlumSoft,
            style: fieldStyle,
            decoration: vaultFieldDecoration(
              m,
              hint: 'New Password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),

          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: m.fieldGap * 0.6),
            PasswordRequirements(metrics: m, value: _passwordController.text),
          ],

          SizedBox(height: m.fieldGap * 0.8),
          AppTextField(
            controller: _confirmPasswordController,
            label: '',
            obscureText: _obscureConfirm,
            validator: (v) =>
                Validators.confirmPassword(v, _passwordController.text),
            cursorColor: ThemeColors.vaultPlumSoft,
            style: fieldStyle,
            decoration: vaultFieldDecoration(
              m,
              hint: 'Confirm Password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),

          SizedBox(height: m.blockGap * 1.1),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => VaultGradientButton(
              label: 'Continue',
              height: m.buttonHeight,
              fontSize: m.linkText + 2,
              onPressed: _submit,
              isLoading: state is AuthLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _InitialPasswordWarningDialog extends StatelessWidget {
  final String email;
  final VoidCallback onDismiss;

  const _InitialPasswordWarningDialog({
    required this.email,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
            decoration: BoxDecoration(
              color: ThemeColors.vaultLoginCream,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: ThemeColors.vaultLoginFieldBorder),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.vaultPlumDeep.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- Warning Badge ----
                const VaultIconBadge(icon: Icons.lock_outline_rounded, size: 96),
                const SizedBox(height: 12),

                // ---- Title ----
                const Text(
                  'Set Your Password Now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kVaultSerif,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: ThemeColors.vaultInk,
                  ),
                ),
                const SizedBox(height: 8),
                Container(width: 40, height: 1.5, color: ThemeColors.vaultGold),
                const SizedBox(height: 12),

                // ---- Body ----
                const Text(
                  'Your account has been verified via email, but you need to set a password to complete setup. This password will be required to sign in and access your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    height: 1.5,
                    color: ThemeColors.vaultBody,
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Consequence Section ----
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ThemeColors.red.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ThemeColors.red.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 18,
                        color: ThemeColors.red,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'If you skip this step, you won\'t be able to sign in or access your account until you complete this process again.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            height: 1.4,
                            color: ThemeColors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Action Button ----
                SizedBox(
                  width: double.infinity,
                  child: VaultGradientButton(
                    label: 'I Understand',
                    height: 50,
                    fontSize: 15,
                    onPressed: onDismiss,
                    isLoading: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
