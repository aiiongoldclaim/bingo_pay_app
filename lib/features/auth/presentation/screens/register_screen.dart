import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/slugify.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/kyc_step_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
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

  String _selectedRole = 'buyer';
  int _step = 0;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _shopSlugEdited = false;

  @override
  void initState() {
    super.initState();
    _shopNameController.addListener(_onShopNameChanged);
  }

  void _onShopNameChanged() {
    if (_shopSlugEdited) return;
    _shopSlugController.text = slugify(_shopNameController.text);
  }

  @override
  void dispose() {
    _shopNameController.removeListener(_onShopNameChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
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
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _step = 0;
    });
  }

  void _submitBuyer() {
    if (_personalFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(BuyerRegisterRequested(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  void _goToBusinessStep() {
    if (_personalFormKey.currentState?.validate() ?? false) {
      setState(() => _step = 1);
    }
  }

  void _submitVendor() {
    if (_businessFormKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(VendorRegisterRequested(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
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
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                Text('I am a:', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        label: 'Buyer',
                        icon: Icons.shopping_bag_outlined,
                        isSelected: _selectedRole == 'buyer',
                        onTap: () => _selectRole('buyer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        label: 'Vendor',
                        icon: Icons.storefront_outlined,
                        isSelected: _selectedRole == 'vendor',
                        onTap: () => _selectRole('vendor'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (_selectedRole == 'vendor') ...[
                  KycStepIndicator(currentStep: _step, totalSteps: 2),
                  const SizedBox(height: 8),
                  Text(_step == 0
                      ? 'Step 1 of 2: Personal Details'
                      : 'Step 2 of 2: Business Details'),
                  const SizedBox(height: 24),
                ],
                if (_selectedRole == 'buyer' || _step == 0)
                  Form(
                    key: _personalFormKey,
                    child: _PersonalDetailsFields(
                      firstNameController: _firstNameController,
                      lastNameController: _lastNameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscurePassword: _obscurePassword,
                      obscureConfirm: _obscureConfirm,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleConfirm: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  )
                else
                  Form(
                    key: _businessFormKey,
                    child: _BusinessDetailsFields(
                      shopNameController: _shopNameController,
                      shopSlugController: _shopSlugController,
                      businessNameController: _businessNameController,
                      descriptionController: _descriptionController,
                      gstController: _gstController,
                      panController: _panController,
                      supportEmailController: _supportEmailController,
                      supportPhoneController: _supportPhoneController,
                      onShopSlugChanged: () => _shopSlugEdited = true,
                    ),
                  ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    if (_selectedRole == 'buyer') {
                      return AppButton(
                        label: 'Create Account',
                        onPressed: _submitBuyer,
                        isLoading: isLoading,
                      );
                    }
                    if (_step == 0) {
                      return AppButton(
                        label: 'Next',
                        onPressed: _goToBusinessStep,
                        isLoading: isLoading,
                      );
                    }
                    return Column(
                      children: [
                        AppButton(
                          label: 'Create Account',
                          onPressed: _submitVendor,
                          isLoading: isLoading,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Back',
                          variant: AppButtonVariant.outlined,
                          onPressed:
                              isLoading ? null : () => setState(() => _step = 0),
                        ),
                      ],
                    );
                  },
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
    );
  }
}

class _PersonalDetailsFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  const _PersonalDetailsFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: firstNameController,
          label: 'First Name',
          validator: (v) => Validators.required(v, fieldName: 'First name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: lastNameController,
          label: 'Last Name',
          validator: (v) => Validators.required(v, fieldName: 'Last name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          label: 'Password',
          obscureText: obscurePassword,
          validator: Validators.password,
          suffixIcon: IconButton(
            icon: Icon(obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          obscureText: obscureConfirm,
          validator: (v) =>
              Validators.confirmPassword(v, passwordController.text),
          suffixIcon: IconButton(
            icon: Icon(obscureConfirm
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
            onPressed: onToggleConfirm,
          ),
        ),
      ],
    );
  }
}

class _BusinessDetailsFields extends StatelessWidget {
  final TextEditingController shopNameController;
  final TextEditingController shopSlugController;
  final TextEditingController businessNameController;
  final TextEditingController descriptionController;
  final TextEditingController gstController;
  final TextEditingController panController;
  final TextEditingController supportEmailController;
  final TextEditingController supportPhoneController;
  final VoidCallback onShopSlugChanged;

  const _BusinessDetailsFields({
    required this.shopNameController,
    required this.shopSlugController,
    required this.businessNameController,
    required this.descriptionController,
    required this.gstController,
    required this.panController,
    required this.supportEmailController,
    required this.supportPhoneController,
    required this.onShopSlugChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: shopNameController,
          label: 'Shop Name',
          validator: (v) => Validators.required(v, fieldName: 'Shop name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: shopSlugController,
          label: 'Shop Slug',
          onChanged: (_) => onShopSlugChanged(),
          validator: (v) => Validators.required(v, fieldName: 'Shop slug'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: businessNameController,
          label: 'Business Name',
          validator: (v) =>
              Validators.required(v, fieldName: 'Business name'),
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: descriptionController,
          label: 'Description (optional)',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: gstController,
          label: 'GST Number (optional)',
          validator: Validators.gst,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: panController,
          label: 'PAN Number (optional)',
          validator: Validators.pan,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: supportEmailController,
          label: 'Support Email (optional)',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: supportPhoneController,
          label: 'Support Phone (optional)',
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
