import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/constants/image_constants.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_interaction_blocker.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../../../../core/error/failures.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../data/services/login_form_manager.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/vault_auth_widgets.dart';

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
    return Scaffold(
      backgroundColor: ThemeColors.vaultLoginCream,
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is! AuthLoading) {
            _isSubmitting = false;
          }
          if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          } else if (state is AuthOtpRequired) {
            context.push(AppRoutes.registerOtp, extra: state.email);
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
                                    SizedBox(height: m.blockGap * 1.3),
                                    _buildForm(context, m),
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
    return Column(
      children: [
        VaultGoldShader(
          child: Icon(
            Icons.spa_outlined,
            size: m.brandTitle * 2,
            color: ThemeColors.white,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.3),
        VaultWordmark(
          fontSize: m.brandTitle * 1.75,
          showDiamond: false,
          tagline: 'TIMELESS LUXURY FOR YOU',
          taglineColor: ThemeColors.vaultInk,
        ),
        SizedBox(height: m.fieldGap),
        Container(width: 64, height: 1.5, color: ThemeColors.vaultGold),
        SizedBox(height: m.blockGap),
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: kVaultSerif,
            fontSize: m.heroTitle * 1.1,
            fontWeight: FontWeight.w600,
            color: ThemeColors.vaultInk,
          ),
        ),
        SizedBox(height: m.fieldGap * 0.4),
        Text(
          'Login to explore exclusive collections\nand continue your journey',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: m.linkText,
            height: 1.5,
            color: ThemeColors.vaultBody,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(
    AuthMetrics m, {
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.sp),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
        fontSize: m.linkText + 1,
        color: ThemeColors.vaultBody,
      ),
      filled: true,
      fillColor: ThemeColors.vaultLoginFieldFill,
      contentPadding: EdgeInsets.symmetric(
        horizontal: m.pagePadH,
        vertical: m.buttonHeight * 0.22,
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.only(left: m.pagePadH, right: m.pagePadH * 0.7),
        child: Icon(icon, size: 22, color: ThemeColors.vaultInk),
      ),
      isDense: true,
      prefixIconConstraints: const BoxConstraints(minWidth: 0),
      suffixIconConstraints: const BoxConstraints(minWidth: 0),
      suffixIcon: suffix == null
          ? null
          : Padding(
              padding: EdgeInsets.only(right: m.pagePadH * 0.4),
              child: suffix,
            ),
      border: border(ThemeColors.vaultLoginFieldBorder),
      enabledBorder: border(ThemeColors.vaultLoginFieldBorder),
      focusedBorder: border(ThemeColors.vaultGold, 1.5),
      errorBorder: border(ThemeColors.red),
      focusedErrorBorder: border(ThemeColors.red, 1.5),
      errorStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: m.footerText,
        color: ThemeColors.red,
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthMetrics m) {
    final inputStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: m.linkText + 1,
      color: ThemeColors.vaultInk,
    );

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: _onEmailSubmitted,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9@.\-]'),
              ),
            ],
            validator: Validators.email,
            style: inputStyle,
            cursorColor: ThemeColors.vaultPlumSoft,
            decoration: _fieldDecoration(
              m,
              hint: 'Email address',
              icon: Icons.mail_outline_rounded,
            ),
          ),

          SizedBox(height: m.fieldGap * 0.8),

          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _onPasswordSubmitted,
            validator: (v) => Validators.required(
              v,
              fieldName: 'Password',
            ),
            style: inputStyle,
            cursorColor: ThemeColors.vaultPlumSoft,
            decoration: _fieldDecoration(
              m,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                visualDensity: VisualDensity.compact,
                iconSize: 22,
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: ThemeColors.vaultInk,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push(AppRoutes.forgotPassword),
              child: Text(
                'Forgot Password?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: m.linkText,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.vaultPlumSoft,
                ),
              ),
            ),
          ),

          SizedBox(height: m.fieldGap * 0.4),

          /// LOGIN
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => VaultGradientButton(
              label: 'Login',
              height: m.buttonHeight,
              fontSize: m.linkText + 2,
              onPressed: _submit,
              isLoading: state is AuthLoading,
            ),
          ),

          SizedBox(height: m.blockGap * 1.1),

          /// OR DIVIDER
          Row(
            children: [
              const Expanded(
                child: Divider(color: ThemeColors.vaultLoginDivider),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: m.fieldGap),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: m.footerText,
                    color: ThemeColors.vaultBody,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: ThemeColors.vaultLoginDivider),
              ),
            ],
          ),

          SizedBox(height: m.blockGap * 0.9),

          Text.rich(
            TextSpan(
              text: 'New to ',
              children: [
                TextSpan(
                  text: 'TheVaults',
                  style: TextStyle(color: ThemeColors.vaultInk),
                ),
                const TextSpan(text: '?'),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: m.linkText,
              color: ThemeColors.vaultBody,
            ),
          ),

          SizedBox(height: m.fieldGap * 0.6),

          Center(
            child: FractionallySizedBox(
              widthFactor: 0.64,
              child: VaultOutlineGoldButton(
                label: 'Create an Account',
                height: m.buttonHeight * 0.92,
                fontSize: m.linkText + 1,
                onTap: () {
                  context.go(AppRoutes.register);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

