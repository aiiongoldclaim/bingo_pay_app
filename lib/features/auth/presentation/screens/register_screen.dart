import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/slugify.dart';
import '../../../../core/utils/input_formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/user_existence_entity.dart';
import '../../domain/usecases/check_email_exists_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/widgets/glass/glass_back_button.dart';
import '../../../../core/widgets/glass/glass_scaffold.dart';
import '../widgets/country_picker.dart';
import 'otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _shopNameController = TextEditingController();
  final _shopSlugController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _supportPhoneController = TextEditingController();

  // Personal step focus nodes
  final _fullNameFocus = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // Business step focus nodes
  final _shopNameFocus = FocusNode();
  final _businessNameFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _gstFocus = FocusNode();
  final _panFocus = FocusNode();
  final _supportEmailFocus = FocusNode();
  final _supportPhoneFocus = FocusNode();

  final _checkEmailExists = getIt<CheckEmailExistsUseCase>();
  bool _checkingEmail = false;
  bool _isLoginOtpFlow = false;
  String? _lastCheckedEmail;

  int _step = 0;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  List<Country> _countries = [];
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _shopNameController.addListener(_onShopNameChanged);
    // Check email existence on ANY unfocus (tapping another field, keyboard
    // next, tapping outside) — not just the keyboard submit action.
    _emailFocusNode.addListener(_onEmailFocusChanged);
    _loadCountries();
  }

  void _onEmailFocusChanged() {
    if (!_emailFocusNode.hasFocus) _maybeCheckEmail();
  }

  /// Runs the email-exists check if the email is valid and hasn't already
  /// been checked (so unfocus + submit don't fire the API twice).
  void _maybeCheckEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty || Validators.email(email) != null) return;
    if (_checkingEmail || email == _lastCheckedEmail) return;
    _lastCheckedEmail = email;
    _checkEmail(email);
  }

  Future<void> _loadCountries() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/countries_phone.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _countries = jsonList.map((e) => Country.fromJson(e)).toList();
        _selectedCountry = _countries.firstWhere(
          (c) => c.code.toUpperCase() == 'IN',
          orElse: () => _countries.isNotEmpty
              ? _countries.first
              : const Country(
                  name: 'India',
                  code: 'IN',
                  dialCode: '+91',
                  minLength: 10,
                  maxLength: 10,
                ),
        );
      });
    } catch (e) {
      setState(() {
        _selectedCountry = const Country(
          name: 'India',
          code: 'IN',
          dialCode: '+91',
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
      backgroundColor: Colors.transparent,
      builder: (context) => CountryPickerBottomSheet(
        countries: _countries,
        initialSelectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            _selectedCountry = country;
            _phoneController.clear();
          });
        },
      ),
    );
  }

  String _getFlagEmoji(String countryCode) =>
      CountryPickerBottomSheet.getFlagEmoji(countryCode);

  void _onShopNameChanged() {
    _shopSlugController.text = slugify(_shopNameController.text);
  }

  Future<void> _checkEmail(String email) async {
    setState(() => _checkingEmail = true);
    
    final result = await _checkEmailExists(email);
    if (!mounted) return;
    setState(() => _checkingEmail = false);
    result.match(
      (failure) {},
      (existence) {
        if (!existence.checked) return; // gateway down — silent continue
        if (existence.exists) {
          if (!existence.hasLocalPassword) {
            _showBinGoldContinueDialog(email);
          } else {
            _showEmailExistsDialog(email);
          }
        } else if (existence.hasLocalProfile) {
          _prefillFromProfile(existence);
        }
      },
    );
  }

  void _prefillFromProfile(UserExistenceEntity existence) {
    final fullName = existence.fullName?.trim() ?? '';
    if (fullName.isNotEmpty) {
      _fullNameController.text = fullName;
    }
    final phone = existence.phone?.trim() ?? '';
    if (phone.isNotEmpty && _selectedCountry != null) {
      final dialCode = _selectedCountry!.dialCode;
      final stripped = phone.startsWith(dialCode)
          ? phone.substring(dialCode.length).trim()
          : phone.replaceAll(RegExp(r'^\+\d+\s*'), '');
      _phoneController.text = stripped;
    }
  }

  void _showBinGoldContinueDialog(String email) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.8),
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Account found on BinGold',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: context.colors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: email,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' is linked to a BinGold account. We\'ll send a verification code to continue.',
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _isLoginOtpFlow = true;
                    context.read<AuthBloc>().add(
                          BinGoldLoginOtpRequested(email: email),
                        );
                  },
                  child: const Text(
                    'Send Verification Code',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmailExistsDialog(String email) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: context.colors.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.shade300,
                      Colors.deepOrange.shade500,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Account already exists',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: context.colors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'An account with '),
                    TextSpan(
                      text: email,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const TextSpan(
                        text: ' already exists. Please log in instead.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1A1A1A),
                    foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    context.go(AppRoutes.login);
                  },
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shopNameController.removeListener(_onShopNameChanged);
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _shopNameController.dispose();
    _shopSlugController.dispose();
    _businessNameController.dispose();
    _descriptionController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _supportEmailController.dispose();
    _supportPhoneController.dispose();
    _fullNameFocus.dispose();
    _emailFocusNode.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _shopNameFocus.dispose();
    _businessNameFocus.dispose();
    _descriptionFocus.dispose();
    _gstFocus.dispose();
    _panFocus.dispose();
    _supportEmailFocus.dispose();
    _supportPhoneFocus.dispose();
    super.dispose();
  }

  void _goToBusinessStep() {
    if (_personalFormKey.currentState?.validate() ?? false) {
      setState(() => _step = 1);
    }
  }

  void _submitVendor() {
    if (_businessFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            VendorRegisterRequested(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              phone: _phoneController.text.trim(),
              password: _passwordController.text,
              shopName: _shopNameController.text.trim(),
              shopSlug: _shopSlugController.text.trim(),
              businessName: _businessNameController.text.trim(),
              description: _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
              gstNumber: _gstController.text.trim().isEmpty
                  ? null
                  : _gstController.text.trim(),
              panNumber: _panController.text.trim().isEmpty
                  ? null
                  : _panController.text.trim(),
              supportEmail: _supportEmailController.text.trim().isEmpty
                  ? null
                  : _supportEmailController.text.trim(),
              supportPhone: _supportPhoneController.text.trim().isEmpty
                  ? null
                  : _supportPhoneController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            if (ModalRoute.of(context)?.isCurrent ?? true) {
              AppSnackbar.showError(context, state.failure.message);
            }
          } else if (state is AuthOtpRequired) {
            final isLoginOtpFlow = _isLoginOtpFlow;
            _isLoginOtpFlow = false;
            if (isLoginOtpFlow) {
              AppSnackbar.showSuccess(context, state.message);
            }
            context.push(
              AppRoutes.registerOtp,
              extra: OtpScreenArgs(
                email: state.email,
                otpType: isLoginOtpFlow ? OtpType.login : OtpType.register,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                if (_step == 0)
                  _buildPersonalStep(context)
                else
                  _buildBusinessStep(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return GlassBackButton(
                onTap: isLoading
                    ? null
                    : () {
                        if (_step == 0) {
                          context.go(AppRoutes.login);
                        } else {
                          setState(() => _step = 0);
                        }
                      },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        StepProgressBar(currentStep: _step + 1, totalSteps: 4),
        const SizedBox(height: 16),
        Text(
          'Step ${_step + 1} of 4',
          style: TextStyle(
            fontSize: 13,
            color: context.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _step == 0 ? 'Tell us about yourself' : 'Set up your shop',
          style: TextStyle(
            fontSize: 24,
            height: 1.3,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _step == 0
              ? 'Your name and login details for the account.'
              : 'Shop name, registration and support contacts.',
          style: TextStyle(
            fontSize: 14,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalStep(BuildContext context) {
    return Form(
      key: _personalFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PersonalDetailsFields(
            fullNameController: _fullNameController,
            fullNameFocus: _fullNameFocus,
            emailController: _emailController,
            emailFocusNode: _emailFocusNode,
            phoneFocus: _phoneFocus,
            checkingEmail: _checkingEmail,
            phoneController: _phoneController,
            passwordController: _passwordController,
            passwordFocus: _passwordFocus,
            confirmPasswordController: _confirmPasswordController,
            confirmPasswordFocus: _confirmPasswordFocus,
            obscurePassword: _obscurePassword,
            obscureConfirm: _obscureConfirm,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleConfirm: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            selectedCountryFlag: _selectedCountry != null
                ? _getFlagEmoji(_selectedCountry!.code)
                : '🇮🇳',
            selectedCountryDialCode: _selectedCountry?.dialCode ?? '+91',
            minPhoneLength: _selectedCountry?.minLength ?? 10,
            maxPhoneLength: _selectedCountry?.maxLength ?? 10,
            onSelectCountry: _showCountryPicker,
            onEmailSubmitted: _maybeCheckEmail,
          ),
          const SizedBox(height: 32),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => AppButton(
              label: 'Continue',
              onPressed: _goToBusinessStep,
              isLoading: state is AuthLoading,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessStep(BuildContext context) {
    return Form(
      key: _businessFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BusinessDetailsFields(
            shopNameController: _shopNameController,
            shopNameFocus: _shopNameFocus,
            shopSlugController: _shopSlugController,
            businessNameController: _businessNameController,
            businessNameFocus: _businessNameFocus,
            descriptionController: _descriptionController,
            descriptionFocus: _descriptionFocus,
            gstController: _gstController,
            gstFocus: _gstFocus,
            panController: _panController,
            panFocus: _panFocus,
            supportEmailController: _supportEmailController,
            supportEmailFocus: _supportEmailFocus,
            supportPhoneController: _supportPhoneController,
            supportPhoneFocus: _supportPhoneFocus,
          ),
          const SizedBox(height: 32),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => AppButton(
              label: 'Create Account',
              onPressed: _submitVendor,
              isLoading: state is AuthLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalDetailsFields extends StatelessWidget {
  final TextEditingController fullNameController;
  final FocusNode fullNameFocus;
  final TextEditingController emailController;
  final FocusNode emailFocusNode;
  final FocusNode phoneFocus;
  final bool checkingEmail;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
  final TextEditingController confirmPasswordController;
  final FocusNode confirmPasswordFocus;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final String selectedCountryFlag;
  final String selectedCountryDialCode;
  final int minPhoneLength;
  final int maxPhoneLength;
  final VoidCallback onSelectCountry;
  final VoidCallback onEmailSubmitted;

  const _PersonalDetailsFields({
    required this.fullNameController,
    required this.fullNameFocus,
    required this.emailController,
    required this.emailFocusNode,
    required this.phoneFocus,
    required this.checkingEmail,
    required this.phoneController,
    required this.passwordController,
    required this.passwordFocus,
    required this.confirmPasswordController,
    required this.confirmPasswordFocus,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.selectedCountryFlag,
    required this.selectedCountryDialCode,
    required this.minPhoneLength,
    required this.maxPhoneLength,
    required this.onSelectCountry,
    required this.onEmailSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: fullNameController,
          focusNode: fullNameFocus,
          nextFocusNode: emailFocusNode,
          label: 'Full Name',
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          inputFormatters: AppInputFormatters.name(),
          validator: (v) => Validators.name(v, fieldName: 'full name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: emailController,
          focusNode: emailFocusNode,
          nextFocusNode: phoneFocus,
          label: 'Email Address',
          isRequired: true,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: AppInputFormatters.email(),
          validator: Validators.email,
          onSubmitted: onEmailSubmitted,
          suffixIcon: checkingEmail
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneController,
          focusNode: phoneFocus,
          nextFocusNode: passwordFocus,
          label: 'Phone Number',
          isRequired: true,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Phone number is required';
            }
            final cleanVal = value.trim();
            if (cleanVal.length < minPhoneLength) {
              return 'Must be at least $minPhoneLength digits';
            }
            if (cleanVal.length > maxPhoneLength) {
              return 'Must be at most $maxPhoneLength digits';
            }
            return null;
          },
          prefixIcon: GestureDetector(
            onTap: onSelectCountry,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(selectedCountryFlag,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Text(
                    selectedCountryDialCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            LengthLimitingTextInputFormatter(maxPhoneLength),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          focusNode: passwordFocus,
          nextFocusNode: confirmPasswordFocus,
          label: 'Password',
          isRequired: true,
          obscureText: obscurePassword,
          validator: Validators.password,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: confirmPasswordController,
          focusNode: confirmPasswordFocus,
          label: 'Confirm Password',
          isRequired: true,
          obscureText: obscureConfirm,
          validator: (v) =>
              Validators.confirmPassword(v, passwordController.text),
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirm
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            onPressed: onToggleConfirm,
          ),
        ),
      ],
    );
  }
}

class _BusinessDetailsFields extends StatelessWidget {
  final TextEditingController shopNameController;
  final FocusNode shopNameFocus;
  final TextEditingController shopSlugController;
  final TextEditingController businessNameController;
  final FocusNode businessNameFocus;
  final TextEditingController descriptionController;
  final FocusNode descriptionFocus;
  final TextEditingController gstController;
  final FocusNode gstFocus;
  final TextEditingController panController;
  final FocusNode panFocus;
  final TextEditingController supportEmailController;
  final FocusNode supportEmailFocus;
  final TextEditingController supportPhoneController;
  final FocusNode supportPhoneFocus;

  const _BusinessDetailsFields({
    required this.shopNameController,
    required this.shopNameFocus,
    required this.shopSlugController,
    required this.businessNameController,
    required this.businessNameFocus,
    required this.descriptionController,
    required this.descriptionFocus,
    required this.gstController,
    required this.gstFocus,
    required this.panController,
    required this.panFocus,
    required this.supportEmailController,
    required this.supportEmailFocus,
    required this.supportPhoneController,
    required this.supportPhoneFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'Shop Info'),
        AppTextField(
          controller: shopNameController,
          focusNode: shopNameFocus,
          nextFocusNode: businessNameFocus,
          label: 'Shop Name',
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          inputFormatters: AppInputFormatters.businessName(60),
          validator: (v) => Validators.required(v, fieldName: 'Shop name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: shopSlugController,
          label: 'Shop Slug',
          hint: 'Auto-generated from shop name',
          enabled: false,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: businessNameController,
          focusNode: businessNameFocus,
          nextFocusNode: descriptionFocus,
          label: 'Business Name',
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          inputFormatters: AppInputFormatters.businessName(80),
          validator: (v) => Validators.required(v, fieldName: 'Business name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: descriptionController,
          focusNode: descriptionFocus,
          label: 'Description',
          hint: 'Brief description of your business',
          maxLines: 3,
          inputFormatters: AppInputFormatters.text(500),
        ),
        const SizedBox(height: 28),
        _sectionLabel(context, 'Tax & Compliance  •  Optional'),
        AppTextField(
          controller: gstController,
          focusNode: gstFocus,
          nextFocusNode: panFocus,
          label: 'GST Number',
          inputFormatters: AppInputFormatters.gst(),
          validator: Validators.gst,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: panController,
          focusNode: panFocus,
          nextFocusNode: supportEmailFocus,
          label: 'PAN Number',
          inputFormatters: AppInputFormatters.pan(),
          validator: Validators.pan,
        ),
        const SizedBox(height: 28),
        _sectionLabel(context, 'Support Contact  •  Optional'),
        AppTextField(
          controller: supportEmailController,
          focusNode: supportEmailFocus,
          nextFocusNode: supportPhoneFocus,
          label: 'Support Email',
          keyboardType: TextInputType.emailAddress,
          inputFormatters: AppInputFormatters.email(),
          validator: Validators.optionalEmail,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: supportPhoneController,
          focusNode: supportPhoneFocus,
          label: 'Support Phone',
          keyboardType: TextInputType.phone,
          inputFormatters: AppInputFormatters.digits(15),
          validator: (v) => Validators.optionalPhone(v, minLength: 7, maxLength: 15),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.colors.textSecondary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
