import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_interaction_blocker.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/vault_brand.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_metrics.dart';
import '../widgets/auth_terms_checkbox.dart';
import '../widgets/country_picker.dart';
import '../widgets/password_requirements.dart';
import '../widgets/sso_login_dialog.dart';
import '../widgets/vault_auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  bool _agreedToTerms = false;
  bool _showTermsError = false;

  Timer? _emailDebounce;
  String? _checkedEmail;
  bool? _emailExists;
  bool _checkingEmail = false;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _emailDebounce?.cancel();

    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    _emailDebounce?.cancel();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    _emailDebounce?.cancel();

    setState(() {
      _checkedEmail = null;
      _emailExists = null;
      _checkingEmail = false;
    });

    final email = value.trim();
    if (Validators.email(email) != null) return;

    _emailDebounce = Timer(const Duration(milliseconds: 600), () {
      context.read<AuthBloc>().add(EmailExistenceCheckRequested(email: email));
    });
  }

  void _submit() {
    if (_isSubmitting) return;
    if (_emailExists == true) {
      AppSnackbar.showError(context, 'This email is already registered');
      return;
    }

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!_agreedToTerms) {
      setState(() => _showTermsError = true);
    }

    if (!isFormValid || !_agreedToTerms) {
      return;
    }

    final dialCode = _selectedCountry?.dialCode ?? '+91';

    _isSubmitting = true;
    context.read<AuthBloc>().add(
      RegisterRequested(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        countryId: dialCode.startsWith('+')
            ? dialCode.substring(1)
            : dialCode,
        phone: _phoneController.text.trim(),
      ),
    );
  }

  void _showSsoDialog(String email) {
    SsoLoginDialog.show(
      context,
      email: email,
      onUseDifferentEmail: () => Navigator.of(context).pop(),
      onSendOtp: () {
        _awaitingSsoOtp = true;
        context.read<AuthBloc>().add(SsoOtpSendRequested(email: email));
      },
    );
  }

  bool _awaitingSsoOtp = false;

  List<Country> _countries = [];
  Country? _selectedCountry;

  Future<void> _loadCountries() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/countries_phone.json',
      );
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _countries = jsonList.map((e) => Country.fromJson(e)).toList();
        _selectedCountry = _countries.firstWhere(
          (c) => c.code.toUpperCase() == 'IN',
          orElse: () => _countries.isNotEmpty
              ? _countries.first
              : const Country(
                  name: "India",
                  code: "IN",
                  dialCode: "+91",
                  minLength: 10,
                  maxLength: 10,
                ),
        );
      });
    } catch (e) {
      setState(() {
        _selectedCountry = const Country(
          name: "India",
          code: "IN",
          dialCode: "+91",
          minLength: 10,
          maxLength: 10,
        );
      });
    }
  }

  void _showCountryPicker() {
    if (_countries.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return CountryPickerBottomSheet(
          countries: _countries,
          initialSelectedCountry: _selectedCountry,
          onCountrySelected: (country) {
            setState(() {
              _selectedCountry = country;
              _phoneController.clear();
            });
          },
        );
      },
    );
  }

  String _getFlagEmoji(String countryCode) {
    return CountryPickerBottomSheet.getFlagEmoji(countryCode);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.vaultAuthBackground,
      resizeToAvoidBottomInset: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is! AuthLoading) {
            _isSubmitting = false;
          }
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          } else if (state is AuthOtpRequired) {
            context.push(AppRoutes.registerOtp, extra: state.email);
          } else if (state is SsoOtpRequired) {
            if (_awaitingSsoOtp) {
              _awaitingSsoOtp = false;
              context.push(AppRoutes.ssoLoginOtp, extra: state.email);
            }
          } else if (state is EmailExistenceChecking) {
            setState(() => _checkingEmail = true);
          } else if (state is EmailExistenceChecked) {
            if (state.email != _emailController.text.trim()) return;

            setState(() {
              _checkingEmail = false;
              _checkedEmail = state.email;
              _emailExists = state.exists;
            });

            if (state.requiresSsoLogin) {
              _showSsoDialog(state.email);
            }
          } else if (state is EmailExistenceCheckFailed) {
            if (state.email != _emailController.text.trim()) return;

            setState(() {
              _checkingEmail = false;
              _checkedEmail = null;
              _emailExists = null;
            });
          }
        },
        buildWhen: (prev, curr) =>
            (prev is AuthLoading) != (curr is AuthLoading),

        builder: (context, state) {
          return AppInteractionBlocker(
            isBlocking: state is AuthLoading,
            child: VaultAuthScaffold(
              builder: (context, m) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VaultAuthHeader(
                    m: m,
                    title: 'Create Account',
                    subtitle:
                        'Join TheVaults and unlock\na world of premium shopping.',
                  ),
                  SizedBox(height: m.blockGap * 1.2),
                  _buildForm(context, m),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AuthMetrics m) {
    final colors = context.colors;
    final c = context.colors;
    final gap = m.fieldGap * 0.8;
    final fieldStyle = vaultFieldTextStyle(m, isDark: c.isDark);

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteractionIfError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _fullNameController,
            focusNode: _fullNameFocus,
            label: '',
            validator: Validators.name,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _emailFocus.requestFocus();
            },
            cursorColor: ThemeColors.vaultPlumSoft,
            style: fieldStyle,
            decoration: vaultFieldDecoration(
              m,
              hint: 'Full Name',
              icon: Icons.person_outline_rounded,
              isDark: c.isDark,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
            ],
          ),

          SizedBox(height: gap),

          AppTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: '',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _phoneFocus.requestFocus();
            },
            validator: Validators.email,
            onChanged: _onEmailChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.\-]')),
            ],
            cursorColor: ThemeColors.vaultPlumSoft,
            style: fieldStyle,
            decoration: vaultFieldDecoration(
              m,
              hint: 'Email address',
              icon: Icons.mail_outline_rounded,
              isDark: c.isDark,
              suffix: _checkingEmail
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(c.vaultAuthIcon),
                        ),
                      ),
                    )
                  : _emailExists == null ||
                        _checkedEmail != _emailController.text.trim()
                  ? null
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        _emailExists!
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        color: _emailExists!
                            ? colors.error
                            : colors.statusSuccess,
                      ),
                    ),
            ),
          ),

          if (!_checkingEmail &&
              _emailExists == true &&
              _checkedEmail == _emailController.text.trim())
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'This email is already registered',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: m.footerText,
                  color: colors.error,
                ),
              ),
            ),

          SizedBox(height: gap),

          AppTextField(
            label: '',
            controller: _phoneController,
            focusNode: _phoneFocus,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _passwordFocus.requestFocus();
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }

              final cleanVal = value.trim();

              if (cleanVal.length < (_selectedCountry?.minLength ?? 10)) {
                return 'Phone number must be at least '
                    '${_selectedCountry?.minLength ?? 10} digits';
              }

              if (cleanVal.length > (_selectedCountry?.maxLength ?? 10)) {
                return 'Phone number must be at most '
                    '${_selectedCountry?.maxLength ?? 10} digits';
              }

              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(
                _selectedCountry?.maxLength ?? 10,
              ),
            ],
            cursorColor: ThemeColors.vaultPlumSoft,
            style: fieldStyle,
            decoration: vaultFieldDecoration(
              m,
              hint: 'Phone Number',
              isDark: c.isDark,
              prefix: _CountryPrefix(
                m: m,
                flag: _getFlagEmoji(_selectedCountry?.code ?? 'IN'),
                dialCode: _selectedCountry?.dialCode ?? '+91',
                onTap: _showCountryPicker,
              ),
            ),
          ),

          SizedBox(height: gap),

          AppTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: '',
            obscureText: _obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _confirmPasswordFocus.requestFocus();
            },
            validator: Validators.password,
            onChanged: (_) => setState(() {}),
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            cursorColor: ThemeColors.vaultPlumSoft,
            style: fieldStyle,
            decoration: vaultFieldDecoration(
              m,
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              isDark: c.isDark,
              suffix: IconButton(
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
          ),

          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: m.fieldGap * 0.5),
            PasswordRequirements(value: _passwordController.text, metrics: m),
          ],

          SizedBox(height: gap),

          AppTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            label: '',
            obscureText: _obscureConfirm,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();
              _submit();
            },
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            validator: (v) =>
                Validators.confirmPassword(v, _passwordController.text),
            cursorColor: ThemeColors.vaultPlumSoft,
            style: fieldStyle,
            decoration: vaultFieldDecoration(
              m,
              hint: 'Confirm Password',
              icon: Icons.lock_reset_rounded,
              isDark: c.isDark,
              suffix: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                },
              ),
            ),
          ),

          SizedBox(height: m.blockGap * 0.9),

          /// TERMS AND CONDITIONS
          AuthTermsCheckbox(
            m: m,
            value: _agreedToTerms,
            showError: _showTermsError && !_agreedToTerms,
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value;
                if (value) _showTermsError = false;
              });
            },
          ),

          SizedBox(height: m.blockGap * 1.1),

          /// CREATE ACCOUNT
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => VaultPillButton(
              label: 'Create Account',
              height: m.buttonHeight,
              onPressed: _submit,
              isLoading: state is AuthLoading,
            ),
          ),

          SizedBox(height: m.blockGap),

          /// SIGN IN
          VaultFooterLink(
            prefix: 'Already have an account?',
            action: 'Sign In',
            fontSize: m.footerText + 1,
            onTap: () {
              context.go(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}

class _CountryPrefix extends StatelessWidget {
  final AuthMetrics m;
  final String flag;
  final String dialCode;
  final VoidCallback onTap;

  const _CountryPrefix({
    required this.m,
    required this.flag,
    required this.dialCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(left: m.pagePadH, right: 10),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: c.vaultAuthBorder, width: 1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_iphone_rounded,
              size: 22,
              color: c.isDark ? ThemeColors.vaultGoldLight : ThemeColors.vaultInk,
            ),
            const SizedBox(width: 8),
            Text(flag, style: TextStyle(fontSize: m.linkText + 2)),
            const SizedBox(width: 4),
            Text(
              dialCode,
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: m.linkText,
                color: c.vaultAuthTitle,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: m.linkText + 4,
              color: c.vaultAuthBody,
            ),
          ],
        ),
      ),
    );
  }
}

