// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sizer/sizer.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_colors.dart';
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
// import '../widgets/sso_login_dialog.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _countryIdController = TextEditingController(text: '91');
//   final _phoneController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;

//   Timer? _emailDebounce;
//   String? _checkedEmail;
//   bool? _emailExists;
//   bool _checkingEmail = false;

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _countryIdController.dispose();
//     _phoneController.dispose();
//     _emailDebounce?.cancel();
//     super.dispose();
//   }

//   void _onEmailChanged(String value) {
//     _emailDebounce?.cancel();
//     setState(() {
//       _checkedEmail = null;
//       _emailExists = null;
//       _checkingEmail = false;
//     });
//     final email = value.trim();
//     if (Validators.email(email) != null) return;
//     _emailDebounce = Timer(const Duration(milliseconds: 600), () {
//       context
//           .read<AuthBloc>()
//           .add(EmailExistenceCheckRequested(email: email));
//     });
//   }

//   void _submit() {
//     if (_emailExists == true) {
//       AppSnackbar.showError(context, 'This email is already registered');
//       return;
//     }
//     if (_formKey.currentState?.validate() ?? false) {
//       context.read<AuthBloc>().add(
//             RegisterRequested(
//               fullName: _fullNameController.text.trim(),
//               email: _emailController.text.trim(),
//               password: _passwordController.text,
//               countryId: _countryIdController.text.trim(),
//               phone: _phoneController.text.trim(),
//             ),
//           );
//     }
//   }

//   void _showSsoDialog(String email) {
//     SsoLoginDialog.show(
//       context,
//       email: email,
//       onUseDifferentEmail: () => Navigator.of(context).pop(),
//       onSendOtp: () {
//         Navigator.of(context).pop();
//         context.read<AuthBloc>().add(SsoOtpSendRequested(email: email));
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ThemeColors.background,
//       body: BlocListener<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state is AuthError) {
//             AppSnackbar.showError(context, state.failure.message);
//           } else if (state is AuthOtpRequired) {
//             context.push(AppRoutes.registerOtp, extra: state.email);
//           } else if (state is SsoOtpRequired) {
//             context.push(AppRoutes.ssoLoginOtp, extra: state.email);
//           } else if (state is EmailExistenceChecking) {
//             setState(() => _checkingEmail = true);
//           } else if (state is EmailExistenceChecked) {
//             if (state.email != _emailController.text.trim()) return;
//             setState(() {
//               _checkingEmail = false;
//               _checkedEmail = state.email;
//               _emailExists = state.exists;
//             });
//             if (state.requiresSsoLogin) {
//               _showSsoDialog(state.email);
//             }
//           } else if (state is EmailExistenceCheckFailed) {
//             if (state.email != _emailController.text.trim()) return;
//             setState(() {
//               _checkingEmail = false;
//               _checkedEmail = null;
//               _emailExists = null;
//             });
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
//                   SizedBox(height: 4.h),
//                   const AuthBrandHeader(
//                     title: 'Create Account',
//                     subtitle: 'Join BingoPay and start paying smarter',
//                   ),
//                   SizedBox(height: 3.h),
//                   AuthCard(
//                     children: [
//                       AppTextField(
//                         controller: _fullNameController,
//                         label: 'Full Name',
//                         validator: Validators.name,
//                         prefixIcon: const Icon(
//                           Icons.person_outline_rounded,
//                           color: ThemeColors.inkDim,
//                         ),
//                       ),
//                       SizedBox(height: 2.h),
//                       AppTextField(
//                         controller: _emailController,
//                         label: 'Email',
//                         keyboardType: TextInputType.emailAddress,
//                         validator: Validators.email,
//                         onChanged: _onEmailChanged,
//                         prefixIcon: const Icon(
//                           Icons.mail_outline_rounded,
//                           color: ThemeColors.inkDim,
//                         ),
//                         suffixIcon: _checkingEmail
//                             ? const Padding(
//                                 padding: EdgeInsets.all(12),
//                                 child: SizedBox(
//                                   width: 16,
//                                   height: 16,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               )
//                             : _emailExists == null ||
//                                     _checkedEmail !=
//                                         _emailController.text.trim()
//                                 ? null
//                                 : Icon(
//                                     _emailExists!
//                                         ? Icons.error_outline
//                                         : Icons.check_circle_outline,
//                                     color: _emailExists!
//                                         ? AppColors.error
//                                         : AppColors.success,
//                                   ),
//                       ),
//                       if (!_checkingEmail &&
//                           _emailExists == true &&
//                           _checkedEmail == _emailController.text.trim())
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4, left: 4),
//                           child: Text(
//                             'This email is already registered',
//                             style: AppTextStyles.bodySmall.copyWith(
//                               color: AppColors.error,
//                             ),
//                           ),
//                         ),
//                       SizedBox(height: 2.h),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: 90,
//                             child: AppTextField(
//                               controller: _countryIdController,
//                               label: 'Code',
//                               keyboardType: TextInputType.number,
//                               validator: (v) =>
//                                   Validators.required(v, fieldName: 'Code'),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: AppTextField(
//                               controller: _phoneController,
//                               label: 'Phone Number',
//                               keyboardType: TextInputType.phone,
//                               validator: (v) => Validators.required(
//                                 v,
//                                 fieldName: 'Phone number',
//                               ),
//                             ),
//                           ),
//                         ],
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
//                       SizedBox(height: 2.h),
//                       AppTextField(
//                         controller: _confirmPasswordController,
//                         label: 'Confirm Password',
//                         obscureText: _obscureConfirm,
//                         validator: (v) => Validators.confirmPassword(
//                           v,
//                           _passwordController.text,
//                         ),
//                         prefixIcon: const Icon(
//                           Icons.lock_outline_rounded,
//                           color: ThemeColors.inkDim,
//                         ),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureConfirm
//                                 ? Icons.visibility_outlined
//                                 : Icons.visibility_off_outlined,
//                             color: ThemeColors.inkDim,
//                           ),
//                           onPressed: () => setState(
//                             () => _obscureConfirm = !_obscureConfirm,
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 1.h),
//                       BlocBuilder<AuthBloc, AuthState>(
//                         builder: (context, state) => AppButton(
//                           label: 'Create Account',
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
//                         'Already have an account?',
//                         style: AppTextStyles.bodyMedium,
//                       ),
//                       TextButton(
//                         onPressed: () => context.go(AppRoutes.login),
//                         style: TextButton.styleFrom(
//                           foregroundColor: ThemeColors.blue,
//                         ),
//                         child: Text(
//                           'Sign In',
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

//MERGERED CODE
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../widgets/country_picker.dart';
import '../widgets/password_requirements.dart';
import '../widgets/sso_login_dialog.dart';

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
  final _countryIdController = TextEditingController(text: '91');
  final _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

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
    _countryIdController.dispose();
    _phoneController.dispose();
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
    if (_emailExists == true) {
      AppSnackbar.showError(context, 'This email is already registered');
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          countryId: _countryIdController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
    }
  }

  void _showSsoDialog(String email) {
    SsoLoginDialog.show(
      context,
      email: email,
      onUseDifferentEmail: () => Navigator.of(context).pop(),
      onSendOtp: () {
        context.read<AuthBloc>().add(SsoOtpSendRequested(email: email));
      },
    );
  }

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

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          } else if (state is AuthOtpRequired) {
            context.push(AppRoutes.registerOtp, extra: state.email);
          } else if (state is SsoOtpRequired) {
            context.push(AppRoutes.ssoLoginOtp, extra: state.email);
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
        child: AuthResponsiveLayout(
          title: 'Create Account',
          subtitle: 'Join TheVaults and start\nShopping smarter every day.',
          // topActionLabel: 'Sign In',
          onTopAction: () => context.go(AppRoutes.login),
          formBuilder: _buildForm,
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
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            isRequired: true,
            validator: Validators.name,
            prefixIcon: const Icon(Icons.person_outline_rounded),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s]")),
            ],
          ),

          SizedBox(height: m.fieldGap),

          AppTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            onChanged: _onEmailChanged,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
            ],
            prefixIcon: const Icon(Icons.mail_outline_rounded),
            suffixIcon: _checkingEmail
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          isDark ? ThemeColors.gold1 : ThemeColors.blue,
                        ),
                      ),
                    ),
                  )
                : _emailExists == null ||
                      _checkedEmail != _emailController.text.trim()
                ? null
                : Icon(
                    _emailExists!
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: _emailExists! ? ThemeColors.red : ThemeColors.green,
                  ),
          ),

          if (!_checkingEmail &&
              _emailExists == true &&
              _checkedEmail == _emailController.text.trim())
            Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'This email is already registered',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: m.footerText,
                  color: ThemeColors.red,
                ),
              ),
            ),

          SizedBox(height: m.fieldGap),

          AppTextField(
            label: "Phone Number",
            hint: "Enter Phone Number",
            isRequired: true,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              final cleanVal = value.trim();
              if (cleanVal.length < (_selectedCountry?.minLength ?? 10)) {
                return 'Phone number must be at least ${_selectedCountry?.minLength ?? 10} digits';
              }
              if (cleanVal.length > (_selectedCountry?.maxLength ?? 10)) {
                return 'Phone number must be at most ${_selectedCountry?.maxLength ?? 10} digits';
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
            prefixIcon: _CountryPrefix(
              m: m,
              flag: _getFlagEmoji(_selectedCountry?.code ?? "IN"),
              dialCode: _selectedCountry?.dialCode ?? "+91",
              onTap: _showCountryPicker,
            ),
          ),

          SizedBox(height: m.fieldGap),

          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            isRequired: true,
            obscureText: _obscurePassword,
            validator: Validators.password,
            onChanged: (_) => setState(() {}),
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: m.fieldGap * 0.5),
            PasswordRequirements(value: _passwordController.text, metrics: m),
          ],

          SizedBox(height: m.fieldGap),

          AppTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            isRequired: true,
            obscureText: _obscureConfirm,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r"\s"))],
            validator: (v) =>
                Validators.confirmPassword(v, _passwordController.text),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),

          SizedBox(height: m.blockGap * 2),

          /// CREATE ACCOUNT
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => AppButton(
              label: 'Create Account',
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

          SizedBox(height: m.blockGap * 0.7),

          /// SIGN IN
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

// ─────────────────── SUB WIDGETS ───────────────────

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(right: 12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: isDark
                  ? ThemeColors.white.withValues(alpha: 0.14)
                  : ThemeColors.line,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: TextStyle(fontSize: m.linkText + 4)),
            const SizedBox(width: 6),
            Text(
              dialCode,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: m.linkText,
                color: isDark ? ThemeColors.white : ThemeColors.ink,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: m.linkText + 4,
              color: isDark ? ThemeColors.gold1 : ThemeColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// class _PasswordRequirements extends StatelessWidget {
//   final AuthMetrics m;
//   final String value;
//
//   const _PasswordRequirements({required this.m, required this.value});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     final requirements = <String, bool>{
//       'At least 8 characters': value.length >= 8,
//       'One uppercase letter (A-Z)': RegExp(r'[A-Z]').hasMatch(value),
//       'One lowercase letter (a-z)': RegExp(r'[a-z]').hasMatch(value),
//       'One number (0-9)': RegExp(r'[0-9]').hasMatch(value),
//       'One special character (!@#\$%...)': RegExp(
//         r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\];/\\]',
//       ).hasMatch(value),
//     };
//
//     final dim = isDark ? ThemeColors.inkDim : ThemeColors.textGrey;
//
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: m.fieldGap * 0.7,
//         vertical: m.fieldGap * 0.6,
//       ),
//       decoration: BoxDecoration(
//         color: isDark
//             ? ThemeColors.white.withValues(alpha: 0.04)
//             : ThemeColors.surface2,
//         borderRadius: BorderRadius.circular(m.buttonRadius),
//         border: Border.all(
//           color: isDark
//               ? ThemeColors.white.withValues(alpha: 0.08)
//               : ThemeColors.line,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: requirements.entries.map((e) {
//           final met = e.value;
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 2.5),
//             child: Row(
//               children: [
//                 Icon(
//                   met
//                       ? Icons.check_circle_rounded
//                       : Icons.radio_button_unchecked_rounded,
//                   size: m.footerText + 2,
//                   color: met ? ThemeColors.green : dim,
//                 ),
//                 SizedBox(width: m.fieldGap * 0.4),
//                 Expanded(
//                   child: Text(
//                     e.key,
//                     style: AppTextStyles.bodySmall.copyWith(
//                       fontSize: m.footerText,
//                       color: met ? ThemeColors.green : dim,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
