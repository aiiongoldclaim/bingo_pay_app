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
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
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
import '../widgets/country_picker.dart';
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
    // TODO: implement initState
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
      context
          .read<AuthBloc>()
          .add(EmailExistenceCheckRequested(email: email));
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
        Navigator.of(context).pop();
        context.read<AuthBloc>().add(SsoOtpSendRequested(email: email));
      },
    );
  }

  List<Country> _countries = [];
  Country? _selectedCountry;

  Future<void> _loadCountries() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/countries_phone.json');
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
      // backgroundColor: Colors.transparent,
      backgroundColor: ThemeColors.background, // or Colors.white
      builder: (context) {
        return CountryPickerBottomSheet(
          countries: _countries,
          initialSelectedCountry: _selectedCountry,
          onCountrySelected: (country) {
            setState(() {
              _selectedCountry = country;
              _phoneController.clear(); // Clear existing number when country changes to avoid validation mismatch
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
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: Stack(
        children: [
          const _Blob(
            top: -80,
            left: -60,
            size: 220,
            colors: [ThemeColors.blue, ThemeColors.blueDeep],
          ),
          const _Blob(
            bottom: -120,
            right: -60,
            size: 260,
            colors: [ThemeColors.blueDeep, Colors.black],
          ),
          const _Blob(
            top: 180,
            right: -40,
            size: 140,
            colors: [ThemeColors.blue, ThemeColors.accent],
          ),

          BlocListener<AuthBloc, AuthState>(
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
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteractionIfError,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 4.h),

                              const AuthBrandHeader(
                                title: 'Create Account',
                                subtitle:
                                    'Join BingoPay and start paying smarter',
                              ),

                              SizedBox(height: 3.h),

                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        Colors.white.withOpacity(0.06),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: AuthCard(
                                  children: [
                                    AppTextField(
                                      controller:
                                          _fullNameController,
                                      label: 'Full Name',
                                      validator: Validators.name,
                                      prefixIcon: const Icon(
                                          Icons.person_outline),
                                    ),
                                    SizedBox(height: 2.h),

                                    AppTextField(
                                      controller:
                                          _emailController,
                                      label: 'Email',
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      validator: Validators.email,
                                      onChanged: _onEmailChanged,
                                      prefixIcon: const Icon(
                                          Icons.mail_outline),
                                      suffixIcon: _checkingEmail
                                          ? const Padding(
                                              padding:
                                                  EdgeInsets.all(12),
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth:
                                                            2),
                                              ),
                                            )
                                          : _emailExists ==
                                                      null ||
                                                  _checkedEmail !=
                                                      _emailController
                                                          .text
                                                          .trim()
                                              ? null
                                              : Icon(
                                                  _emailExists!
                                                      ? Icons
                                                          .error_outline
                                                      : Icons
                                                          .check_circle_outline,
                                                  color: _emailExists!
                                                      ? AppColors
                                                          .error
                                                      : AppColors
                                                          .success,
                                                ),
                                    ),

                                    if (!_checkingEmail &&
                                        _emailExists == true &&
                                        _checkedEmail ==
                                            _emailController.text
                                                .trim())
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(
                                                top: 4,
                                                left: 4),
                                        child: Text(
                                          'This email is already registered',
                                          style: AppTextStyles
                                              .bodySmall
                                              .copyWith(
                                            color:
                                                AppColors.error,
                                          ),
                                        ),
                                      ),

                                    SizedBox(height: 2.h),

                                    // Row(
                                    //   children: [
                                    //     SizedBox(
                                    //       width: 90,
                                    //       child: AppTextField(
                                    //         controller:
                                    //             _countryIdController,
                                    //         label: 'Code',
                                    //         keyboardType:
                                    //             TextInputType
                                    //                 .number,
                                    //         validator: (v) =>
                                    //             Validators.required(
                                    //                 v,
                                    //                 fieldName:
                                    //                     'Code'),
                                    //       ),
                                    //     ),
                                    //     const SizedBox(width: 12),
                                    //     Expanded(
                                    //       child: AppTextField(
                                    //         controller:
                                    //             _phoneController,
                                    //         label:
                                    //             'Phone Number',
                                    //         keyboardType:
                                    //             TextInputType
                                    //                 .phone,
                                    //         validator: (v) =>
                                    //             Validators.required(
                                    //           v,
                                    //           fieldName:
                                    //               'Phone number',
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),


          
            AppTextField(
  label: "Phone Number",
  hint: "Enter Phone Number",
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
  prefixIcon: GestureDetector(
    onTap: _showCountryPicker,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getFlagEmoji(_selectedCountry?.code ?? "IN"),
            style: TextStyle(fontSize: 5.w),
          ),
          SizedBox(width: 2.w),
          Text(
            _selectedCountry?.dialCode ?? "+91",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    ),
  ),
)
,


                                    SizedBox(height: 2.h),

                                    AppTextField(
                                      controller:
                                          _passwordController,
                                      label: 'Password',
                                      obscureText:
                                          _obscurePassword,
                                      validator:
                                          Validators.password,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscurePassword
                                                ? Icons
                                                    .visibility
                                                : Icons
                                                    .visibility_off),
                                        onPressed: () =>
                                            setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
                                      ),
                                    ),

                                    SizedBox(height: 2.h),

                                    AppTextField(
                                      controller:
                                          _confirmPasswordController,
                                      label:
                                          'Confirm Password',
                                      obscureText:
                                          _obscureConfirm,
                                      validator: (v) =>
                                          Validators
                                              .confirmPassword(
                                        v,
                                        _passwordController
                                            .text,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _obscureConfirm
                                                ? Icons
                                                    .visibility
                                                : Icons
                                                    .visibility_off),
                                        onPressed: () =>
                                            setState(() =>
                                                _obscureConfirm =
                                                    !_obscureConfirm),
                                      ),
                                    ),

                                    SizedBox(height: 2.h),

                                    BlocBuilder<AuthBloc,
                                        AuthState>(
                                      builder: (context,
                                              state) =>
                                          AppButton(
                                        label:
                                            'Create Account',
                                        onPressed: _submit,
                                        isLoading:
                                            state is AuthLoading,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: 3.h),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: AppTextStyles
                                        .bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.go(
                                            AppRoutes.login),
                                    child: Text(
                                      'Sign In',
                                      style: AppTextStyles
                                          .labelLarge
                                          .copyWith(
                                              color:
                                                  ThemeColors
                                                      .blue),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 3.h),
                            ],
                          ),
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
            colors:
                colors.map((c) => c.withOpacity(0.25)).toList(),
          ),
        ),
      ),
    );
  }
}