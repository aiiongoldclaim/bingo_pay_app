import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../cubit/email_exists_cubit.dart';
import '../cubit/email_exists_state.dart';
import '../widgets/country_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _emailExistsCubit = getIt<EmailExistsCubit>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  List<Country> _countries = [];
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final countries = await Country.loadAll();
    if (!mounted) return;
    setState(() {
      _countries = countries;
      _selectedCountry = countries.firstWhere(
        (c) => c.dialCode == '+91',
        orElse: () => countries.first,
      );
    });
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _emailExistsCubit.close();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onEmailFocusChange() {
    if (_emailFocusNode.hasFocus) return;
    final email = _emailController.text.trim();
    if (Validators.email(email) != null) return;
    _emailExistsCubit.checkEmail(email);
  }

  void _showAccountExistsDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account already exists'),
        content: const Text(
          'An account with this email already exists. Please login instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.go(AppRoutes.login);
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  void _openCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CountryPickerBottomSheet(
        countries: _countries,
        initialSelectedCountry: _selectedCountry,
        onCountrySelected: (country) =>
            setState(() => _selectedCountry = country),
      ),
    );
  }

  void _submit() {
    final emailExistsState = _emailExistsCubit.state;
    if (emailExistsState is EmailExistsResult &&
        emailExistsState.exists &&
        emailExistsState.email == _emailController.text.trim()) {
      _showAccountExistsDialog();
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final countryId =
          (_selectedCountry?.dialCode ?? '').replaceAll(RegExp(r'\D'), '');
      context.read<AuthBloc>().add(
            RegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              countryId: countryId,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                AppSnackbar.showError(context, state.failure.message);
              }
            },
          ),
          BlocListener<EmailExistsCubit, EmailExistsState>(
            bloc: _emailExistsCubit,
            listener: (context, state) {
              if (state is EmailExistsResult &&
                  state.exists &&
                  state.email == _emailController.text.trim()) {
                _showAccountExistsDialog();
              }
            },
          ),
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          validator: (v) =>
                              Validators.name(v, fieldName: 'First name'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          validator: (v) =>
                              Validators.name(v, fieldName: 'Last name'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<EmailExistsCubit, EmailExistsState>(
                    bloc: _emailExistsCubit,
                    builder: (context, state) => AppTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      suffixIcon: state is EmailExistsChecking
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _countries.isEmpty ? null : _openCountryPicker,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_selectedCountry != null) ...[
                                Text(
                                  CountryPickerBottomSheet.getFlagEmoji(
                                    _selectedCountry!.code,
                                  ),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(_selectedCountry!.dialCode),
                              ],
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          validator: (v) => Validators.phoneNumber(
                            v,
                            minLength: _selectedCountry?.minLength,
                            maxLength: _selectedCountry?.maxLength,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    obscureText: _obscureConfirm,
                    validator: (v) =>
                        Validators.confirmPassword(v, _passwordController.text),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Create Account',
                      onPressed: _submit,
                      isLoading: state is AuthLoading,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
