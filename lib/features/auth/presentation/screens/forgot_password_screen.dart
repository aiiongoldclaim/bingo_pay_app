import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_interaction_blocker.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../../../../core/error/failures.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/vault_auth_widgets.dart';

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
    return Scaffold(
      backgroundColor: ThemeColors.vaultLoginCream,
      resizeToAvoidBottomInset: false,
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
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: ThemeColors.vaultLoginCream,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final m = AuthMetrics.of(constraints);
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
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
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            m.pagePadH * 0.7,
                            h * 0.09,
                            m.pagePadH * 0.7,
                            w > h ? m.blockGap : bottomW * 0.40,
                          ),
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final content = SizedBox(
                                width: c.maxWidth.clamp(0.0, 480.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildHeader(context, m),
                                    SizedBox(height: m.blockGap),
                                    _buildCard(context, m),
                                    SizedBox(height: m.blockGap),
                                    _buildFooter(context, m),
                                  ],
                                ),
                              );

                              if (w > h) {
                                return SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  child: Center(child: content),
                                );
                              }

                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topCenter,
                                child: content,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthMetrics m) {
    return VaultWordmark(
      fontSize: m.brandTitle * 1.3,
      tagline: 'TIMELESS LUXURY FOR YOU',
      taglineColor: ThemeColors.vaultInk,
    );
  }

  Widget _buildCard(BuildContext context, AuthMetrics m) {
    final radius = BorderRadius.circular(m.buttonRadius * 1.6);

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pagePadH * 1.1,
        m.blockGap,
        m.pagePadH * 1.1,
        m.blockGap * 1.1,
      ),
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: radius,
        border: Border.all(color: ThemeColors.vaultLoginFieldBorder),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.vaultPlumDeep.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              AppImages.vaultForgotPassword,
              height: m.isTablet ? 160 : 130,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          SizedBox(height: m.fieldGap * 0.6),
          Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kVaultSerif,
              fontSize: m.heroTitle,
              fontWeight: FontWeight.w600,
              color: ThemeColors.vaultInk,
            ),
          ),
          SizedBox(height: m.fieldGap * 0.5),
          Center(
            child: Container(
              width: 40,
              height: 1.5,
              color: ThemeColors.vaultGold,
            ),
          ),
          SizedBox(height: m.fieldGap * 0.6),
          Text(
            "Enter your registered email address and\nwe'll send you a reset link",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: m.linkText,
              height: 1.5,
              color: ThemeColors.vaultBody,
            ),
          ),
          SizedBox(height: m.blockGap),
          _buildForm(context, m),
        ],
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
            label: '',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              _submit();
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.\-]')),
            ],
            validator: Validators.email,
            cursorColor: ThemeColors.vaultPlumSoft,
            style: vaultFieldTextStyle(m),
            decoration: vaultFieldDecoration(
              m,
              hint: 'Email address',
              icon: Icons.mail_outline_rounded,
            ),
          ),

          SizedBox(height: m.blockGap),

          /// SEND RESET LINK
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => VaultGradientButton(
              label: 'Send Reset Link',
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

  Widget _buildFooter(BuildContext context, AuthMetrics m) {
    Widget goldLine(Alignment from) => Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: from,
                end: Alignment(-from.x, 0),
                colors: [
                  ThemeColors.vaultGold,
                  ThemeColors.vaultGold.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            goldLine(Alignment.centerRight),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: m.fieldGap * 0.6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VaultDiamond(size: 10),
                  SizedBox(width: m.fieldGap * 0.4),
                  Text(
                    'OR',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: m.footerText,
                      letterSpacing: 1.2,
                      color: ThemeColors.vaultGoldDeep,
                    ),
                  ),
                  SizedBox(width: m.fieldGap * 0.4),
                  const VaultDiamond(size: 10),
                ],
              ),
            ),
            goldLine(Alignment.centerLeft),
          ],
        ),

        SizedBox(height: m.blockGap * 0.8),

        Text(
          'Remember your password?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: m.linkText,
            color: ThemeColors.vaultBody,
          ),
        ),

        SizedBox(height: m.fieldGap * 0.6),

        VaultOutlineGoldButton(
          label: 'Back to Login',
          height: m.buttonHeight * 0.92,
          fontSize: m.linkText + 1,
          onTap: () {
            context.go(AppRoutes.login);
          },
        ),
      ],
    );
  }
}
