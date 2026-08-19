// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';
// import '../../../../core/utils/validators.dart';
// import '../../domain/entities/address_entity.dart';
// import '../cubit/address_cubit.dart';
//
// class AddEditAddressScreen extends StatefulWidget {
//   final AddressEntity? existingAddress;
//
//   const AddEditAddressScreen({super.key, this.existingAddress});
//
//   @override
//   State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
// }
//
// class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController nameCtrl;
//   late TextEditingController phoneCtrl;
//   late TextEditingController addressCtrl;
//   late TextEditingController cityCtrl;
//   late TextEditingController stateCtrl;
//   late TextEditingController postalCtrl;
//
//   bool isDefault = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     final data = widget.existingAddress;
//
//     nameCtrl = TextEditingController(text: data?.fullName);
//     phoneCtrl = TextEditingController(text: data?.phoneNumber);
//     addressCtrl = TextEditingController(text: data?.addressLine1);
//     cityCtrl = TextEditingController(text: data?.city);
//     stateCtrl = TextEditingController(text: data?.state);
//     postalCtrl = TextEditingController(text: data?.postalCode);
//     isDefault = data?.isDefaultAddress ?? false;
//   }
//
//   @override
//   void dispose() {
//     nameCtrl.dispose();
//     phoneCtrl.dispose();
//     addressCtrl.dispose();
//     cityCtrl.dispose();
//     stateCtrl.dispose();
//     postalCtrl.dispose();
//     super.dispose();
//   }
//
//   bool get isEdit => widget.existingAddress?.id.isNotEmpty == true;
//
//   bool _hasUnsavedChanges() {
//     final data = widget.existingAddress;
//     return nameCtrl.text != (data?.fullName ?? '') ||
//         phoneCtrl.text != (data?.phoneNumber ?? '') ||
//         addressCtrl.text != (data?.addressLine1 ?? '') ||
//         cityCtrl.text != (data?.city ?? '') ||
//         stateCtrl.text != (data?.state ?? '') ||
//         postalCtrl.text != (data?.postalCode ?? '') ||
//         isDefault != (data?.isDefaultAddress ?? false);
//   }
//
//   void _showDiscardConfirmation() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Discard changes?'),
//         content: const Text(
//           'You have unsaved changes. Are you sure you want to discard them?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Keep Editing'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               Navigator.pop(context);
//             },
//             child: const Text(
//               'Discard',
//               style: TextStyle(color: ThemeColors.red),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: !_hasUnsavedChanges(),
//       onPopInvokedWithResult: (didPop, result) {
//         if (!didPop && _hasUnsavedChanges()) {
//           _showDiscardConfirmation();
//         }
//       },
//       child: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: const SystemUiOverlayStyle(
//           statusBarColor: ThemeColors.white,
//           statusBarIconBrightness: Brightness.dark,
//         ),
//         child: Scaffold(
//           backgroundColor: const Color(0xFFF5F7FB),
//
//           appBar: AppBar(
//             backgroundColor: ThemeColors.white,
//             elevation: 0,
//             foregroundColor: ThemeColors.ink,
//             title: Text(
//               isEdit ? "Edit Address" : "Add Address",
//               style: AppTextStyles.titleLarge.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//
//           body: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Form(
//                     key: _formKey,
//                     autovalidateMode: AutovalidateMode.onUserInteractionIfError,
//                     child: Column(
//                       children: [
//                         /// 📦 ADDRESS CARD (MATCHING PAYMENT SCREEN)
//                         _cardContainer(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               /// HEADER
//                               _gradientHeader(
//                                 title: "Delivery Address",
//                                 icon: Icons.location_on_outlined,
//                               ),
//
//                               /// FIELDS
//                               Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   children: [
//                                     _Field(
//                                       controller: nameCtrl,
//                                       label: "Full Name",
//                                       hint: "Enter full name",
//                                       icon: Icons.person_outline,
//                                       validator: Validators.name,
//                                     ),
//
//                                     const SizedBox(height: 14),
//
//                                     _Field(
//                                       controller: phoneCtrl,
//                                       label: "Phone",
//                                       hint: "10 digit number",
//                                       icon: Icons.phone_android,
//                                       keyboardType: TextInputType.phone,
//                                       maxLength: 10,
//                                       digitsOnly: true,
//                                       validator: (v) {
//                                         final value = v?.trim() ?? '';
//                                         if (value.isEmpty) {
//                                           return 'Phone number is required';
//                                         }
//                                         if (value.length != 10) {
//                                           return 'Enter a valid 10 digit number';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//
//                                     const SizedBox(height: 14),
//
//                                     _Field(
//                                       controller: addressCtrl,
//                                       label: "Address",
//                                       hint: "House / Street / Area",
//                                       icon: Icons.home_outlined,
//                                       maxLines: 2,
//                                       validator: (v) => Validators.required(
//                                         v,
//                                         fieldName: 'Address',
//                                       ),
//                                     ),
//
//                                     const SizedBox(height: 14),
//
//                                     Row(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Expanded(
//                                           flex: 1,
//                                           child: _Field(
//                                             controller: cityCtrl,
//                                             label: "City",
//                                             hint: "City",
//                                             icon: Icons.location_city,
//                                             validator: (v) =>
//                                                 Validators.required(
//                                                   v,
//                                                   fieldName: 'City',
//                                                 ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           flex: 1,
//                                           child: _Field(
//                                             controller: stateCtrl,
//                                             label: "State",
//                                             hint: "State",
//                                             icon: Icons.map_outlined,
//                                             lettersOnly: true,
//                                             validator: (v) {
//                                               final value = v?.trim() ?? '';
//                                               if (value.isEmpty) {
//                                                 return 'State is required';
//                                               }
//                                               if (RegExp(
//                                                 r'[0-9]',
//                                               ).hasMatch(value)) {
//                                                 return 'State cannot contain numbers';
//                                               }
//                                               return null;
//                                             },
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//
//                                     const SizedBox(height: 14),
//
//                                     _Field(
//                                       controller: postalCtrl,
//                                       label: "PIN Code",
//                                       hint: "6 digit code",
//                                       icon: Icons.pin_drop_outlined,
//                                       keyboardType: TextInputType.number,
//                                       maxLength: 6,
//                                       digitsOnly: true,
//                                       validator: (v) {
//                                         final value = v?.trim() ?? '';
//                                         if (value.isEmpty) {
//                                           return 'PIN code is required';
//                                         }
//                                         if (value.length != 6) {
//                                           return 'Enter a valid 6 digit PIN code';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//
//                                     const SizedBox(height: 16),
//
//                                     /// DEFAULT SWITCH
//                                     Row(
//                                       children: [
//                                         const Icon(Icons.star_border),
//                                         const SizedBox(width: 10),
//                                         const Expanded(
//                                           child: Text(
//                                             "Set as default address",
//                                             style: TextStyle(fontSize: 14),
//                                           ),
//                                         ),
//                                         Switch(
//                                           value: isDefault,
//                                           onChanged: (v) =>
//                                               setState(() => isDefault = v),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//
//                         const SizedBox(height: 100),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               /// 🔥 BOTTOM BUTTON (MATCH STYLE)
//               _bottomButton(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// 🔹 CARD STYLE
//   Widget _cardContainer({required Widget child}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: ThemeColors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: ThemeColors.blue.withValues(alpha: 0.08),
//             blurRadius: 24,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
//
//   /// 🔹 GRADIENT HEADER
//   Widget _gradientHeader({required String title, required IconData icon}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
//         ),
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(width: 10),
//           Text(
//             title,
//             style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// 🔹 SUBMIT BUTTON
//   Widget _bottomButton(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: ThemeColors.white,
//         boxShadow: [
//           BoxShadow(
//             color: ThemeColors.ink.withValues(alpha: 0.05),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: GestureDetector(
//           onTap: _submit,
//           child: Container(
//             height: 54,
//             width: double.infinity,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [
//                   Color(0xFF1A1D4E), // same as header
//                   Color(0xFF2B2FA8),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(
//                   color: ThemeColors.blue.withValues(alpha: 0.3),
//                   blurRadius: 12,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             alignment: Alignment.center,
//             child: Text(
//               isEdit ? "Update Address" : "Save Address",
//               style: AppTextStyles.titleMedium.copyWith(
//                 color: ThemeColors.white,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _submit() {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//
//     final address = AddressEntity(
//       id: widget.existingAddress?.id ?? "",
//       fullName: nameCtrl.text.trim(),
//       phoneNumber: phoneCtrl.text.trim(),
//       addressLine1: addressCtrl.text.trim(),
//       addressLine2: null,
//       city: cityCtrl.text.trim(),
//       state: stateCtrl.text.trim(),
//       country: "India",
//       postalCode: postalCtrl.text.trim(),
//       landmark: null,
//       isDefaultAddress: isDefault,
//     );
//
//     if (isEdit) {
//       context.read<AddressCubit>().updateAddressDetails(
//         widget.existingAddress!.id,
//         address,
//       );
//     } else {
//       context.read<AddressCubit>().submitNewAddress(address);
//     }
//
//     Navigator.pop(context, address);
//   }
// }
//
// class _Field extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String hint;
//   final IconData icon;
//   final int maxLines;
//   final int? maxLength;
//   final TextInputType? keyboardType;
//   final bool digitsOnly;
//   final bool lettersOnly;
//   final String? Function(String?)? validator;
//
//   const _Field({
//     required this.controller,
//     required this.label,
//     required this.hint,
//     required this.icon,
//     this.maxLines = 1,
//     this.maxLength,
//     this.keyboardType,
//     this.digitsOnly = false,
//     this.lettersOnly = false,
//     this.validator,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Text(
//         //   label,
//         //   style: AppTextStyles.bodyMedium.copyWith(
//         //     fontWeight: FontWeight.w500,
//         //     color: ThemeColors.ink.withValues(alpha: 0.9),
//         //   ),
//         // ),
//         Text.rich(
//           TextSpan(
//             text: label,
//             style: AppTextStyles.bodyMedium.copyWith(
//             fontWeight: FontWeight.w500,
//             color: ThemeColors.ink.withValues(alpha: 0.9),
//           ),
//             children: const [
//               TextSpan(
//                 text: ' *',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 6),
//
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           maxLength: maxLength,
//           keyboardType: keyboardType,
//           validator: validator,
//
//           inputFormatters: digitsOnly
//               ? [FilteringTextInputFormatter.digitsOnly]
//               : lettersOnly
//               ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
//               : [],
//           decoration: InputDecoration(
//             hintText: hint,
//             prefixIcon: Icon(icon, size: 20),
//
//             filled: true,
//             fillColor: const Color(0xFFF7F9FC),
//
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 14,
//             ),
//
//             hintStyle: AppTextStyles.bodyMedium.copyWith(
//               color: ThemeColors.ink.withValues(alpha: 0.7),
//             ),
//
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: ThemeColors.ink.withValues(alpha: 0.15),
//               ),
//             ),
//
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(
//                 color: ThemeColors.ink.withValues(alpha: 0.6),
//               ),
//             ),
//
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: ThemeColors.blue, width: 1.5),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/address_cubit.dart';
import '../widgets/add_address_metrics.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressEntity? existingAddress;

  const AddEditAddressScreen({super.key, this.existingAddress});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController cityCtrl;
  late TextEditingController stateCtrl;
  late TextEditingController postalCtrl;

  bool isDefault = false;

  @override
  void initState() {
    super.initState();

    final data = widget.existingAddress;

    nameCtrl = TextEditingController(text: data?.fullName);
    phoneCtrl = TextEditingController(text: data?.phoneNumber);
    addressCtrl = TextEditingController(text: data?.addressLine1);
    cityCtrl = TextEditingController(text: data?.city);
    stateCtrl = TextEditingController(text: data?.state);
    postalCtrl = TextEditingController(text: data?.postalCode);
    isDefault = data?.isDefaultAddress ?? false;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    postalCtrl.dispose();
    super.dispose();
  }

  bool get isEdit => widget.existingAddress?.id.isNotEmpty == true;

  bool _hasUnsavedChanges() {
    final data = widget.existingAddress;
    return nameCtrl.text != (data?.fullName ?? '') ||
        phoneCtrl.text != (data?.phoneNumber ?? '') ||
        addressCtrl.text != (data?.addressLine1 ?? '') ||
        cityCtrl.text != (data?.city ?? '') ||
        stateCtrl.text != (data?.state ?? '') ||
        postalCtrl.text != (data?.postalCode ?? '') ||
        isDefault != (data?.isDefaultAddress ?? false);
  }

  Future<void> _showDiscardConfirmation() async {
    final discard = await showAppConfirmDialog(
      context: context,
      title: 'Discard changes?',
      message:
      'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep Editing',
      isDestructive: true,
      icon: Icons.edit_off_outlined,
    );

    if (discard && mounted) Navigator.pop(context);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = AddressEntity(
      id: widget.existingAddress?.id ?? "",
      fullName: nameCtrl.text.trim(),
      phoneNumber: phoneCtrl.text.trim(),
      addressLine1: addressCtrl.text.trim(),
      addressLine2: null,
      city: cityCtrl.text.trim(),
      state: stateCtrl.text.trim(),
      country: "India",
      postalCode: postalCtrl.text.trim(),
      landmark: null,
      isDefaultAddress: isDefault,
    );

    if (isEdit) {
      context.read<AddressCubit>().updateAddressDetails(
        widget.existingAddress!.id,
        address,
      );
    } else {
      context.read<AddressCubit>().submitNewAddress(address);
    }

    Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = AddAddressMetrics.of(context);

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasUnsavedChanges()) {
          _showDiscardConfirmation();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: c.isDark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: c.isDark ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _AddressTopBar(metrics: m, isEdit: isEdit),

                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                      child: Form(
                        key: _formKey,
                        autovalidateMode:
                        AutovalidateMode.onUserInteractionIfError,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            m.pageHPad,
                            m.gapMd,
                            m.pageHPad,
                            m.gapLg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ContactSection(
                                metrics: m,
                                nameCtrl: nameCtrl,
                                phoneCtrl: phoneCtrl,
                              ),

                              SizedBox(height: m.gapMd),

                              _AddressSection(
                                metrics: m,
                                addressCtrl: addressCtrl,
                                cityCtrl: cityCtrl,
                                stateCtrl: stateCtrl,
                                postalCtrl: postalCtrl,
                              ),

                              SizedBox(height: m.gapMd),

                              _DefaultSwitchCard(
                                metrics: m,
                                value: isDefault,
                                onChanged: (v) => setState(() => isDefault = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                _SaveBar(metrics: m, isEdit: isEdit, onSave: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _AddressTopBar extends StatelessWidget {
  final AddAddressMetrics metrics;
  final bool isEdit;

  const _AddressTopBar({required this.metrics, required this.isEdit});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.5,
        m.pageHPad,
        m.pageVPad * 0.5,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: c.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? 'Edit Address' : 'Add New Address',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  'All fields are required',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.subtitleSize,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable section card ──────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final AddAddressMetrics metrics;
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.metrics,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: m.sectionIconBox,
                height: m.sectionIconBox,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: m.sectionIconSize, color: c.brand),
              ),
              SizedBox(width: m.cardPad * 0.7),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.sectionTitleSize,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapLg),

          ...children,
        ],
      ),
    );
  }
}

// ── Contact ────────────────────────────────────────────────────────────────
class _ContactSection extends StatelessWidget {
  final AddAddressMetrics metrics;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  const _ContactSection({
    required this.metrics,
    required this.nameCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return _SectionCard(
      metrics: m,
      icon: Icons.person_outline_rounded,
      title: 'Contact Details',
      children: [
        AddressField(
          metrics: m,
          controller: nameCtrl,
          label: 'Full Name',
          hint: 'Enter full name',
          icon: Icons.person_outline,
          textCapitalization: TextCapitalization.words,
          validator: Validators.name,
        ),

        SizedBox(height: m.gapMd),

        AddressField(
          metrics: m,
          controller: phoneCtrl,
          label: 'Phone Number',
          hint: '10 digit number',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          digitsOnly: true,
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return 'Phone number is required';
            if (value.length != 10) return 'Enter a valid 10 digit number';
            return null;
          },
        ),
      ],
    );
  }
}

// ── Address ────────────────────────────────────────────────────────────────
class _AddressSection extends StatelessWidget {
  final AddAddressMetrics metrics;
  final TextEditingController addressCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController stateCtrl;
  final TextEditingController postalCtrl;

  const _AddressSection({
    required this.metrics,
    required this.addressCtrl,
    required this.cityCtrl,
    required this.stateCtrl,
    required this.postalCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return _SectionCard(
      metrics: m,
      icon: Icons.location_on_outlined,
      title: 'Address',
      children: [
        AddressField(
          metrics: m,
          controller: addressCtrl,
          label: 'Address',
          hint: 'House / Street / Area',
          icon: Icons.home_outlined,
          maxLines: 2,
          textCapitalization: TextCapitalization.words,
          validator: (v) => Validators.required(v, fieldName: 'Address'),
        ),

        SizedBox(height: m.gapMd),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AddressField(
                metrics: m,
                controller: cityCtrl,
                label: 'City',
                hint: 'City',
                icon: Icons.location_city_rounded,
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, fieldName: 'City'),
              ),
            ),
            SizedBox(width: m.gapSm * 1.2),
            Expanded(
              child: AddressField(
                metrics: m,
                controller: stateCtrl,
                label: 'State',
                hint: 'State',
                icon: Icons.map_outlined,
                lettersOnly: true,
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'State is required';
                  if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'State cannot contain numbers';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        SizedBox(height: m.gapMd),

        AddressField(
          metrics: m,
          controller: postalCtrl,
          label: 'PIN Code',
          hint: '6 digit code',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
          digitsOnly: true,
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return 'PIN code is required';
            if (value.length != 6) return 'Enter a valid 6 digit PIN code';
            return null;
          },
        ),
      ],
    );
  }
}

// ── Reusable field ─────────────────────────────────────────────────────────
class AddressField extends StatelessWidget {
  final AddAddressMetrics metrics;
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final bool digitsOnly;
  final bool lettersOnly;
  final String? Function(String?)? validator;

  const AddressField({
    super.key,
    required this.metrics,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.digitsOnly = false,
    this.lettersOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textSecondary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: m.fieldLabelSize,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: c.statusWarning),
              ),
            ],
          ),
        ),

        SizedBox(height: m.gapXs * 1.4),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          validator: validator,
          style: AppTextStyles.bodyMedium.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontSize: m.fieldTextSize,
          ),
          inputFormatters: digitsOnly
              ? [FilteringTextInputFormatter.digitsOnly]
              : lettersOnly
              ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))]
              : [],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: c.textMuted,
              fontFamily: 'Inter',
              fontSize: m.fieldTextSize,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                left: m.cardPad * 0.6,
                right: m.gapSm * 0.8,
              ),
              child: Icon(icon, size: m.fieldIconSize, color: c.textSecondary),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: 0,
              minHeight: m.fieldIconSize,
            ),
            counterText: '',
            errorStyle: AppTextStyles.bodySmall.copyWith(
              color: c.statusWarning,
              fontFamily: 'Inter',
              fontSize: m.errorSize,
            ),
            filled: true,
            fillColor: c.surfaceAlt,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: m.cardPad * 0.6,
              vertical: m.fieldVPad,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.brand, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.statusWarning),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.statusWarning, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Default switch ─────────────────────────────────────────────────────────
class _DefaultSwitchCard extends StatelessWidget {
  final AddAddressMetrics metrics;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _DefaultSwitchCard({
    required this.metrics,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: m.cardPad,
        vertical: m.cardPad * 0.7,
      ),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: m.sectionIconBox * 0.85,
            height: m.sectionIconBox * 0.85,
            decoration: BoxDecoration(
              color: c.brandSoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              value ? Icons.star_rounded : Icons.star_border_rounded,
              size: m.sectionIconSize * 0.9,
              color: c.brand,
            ),
          ),

          SizedBox(width: m.cardPad * 0.7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set as default address',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.switchTitleSize,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.6),
                Text(
                  'Use this address for future orders',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.switchSubSize,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: c.surface,
            activeTrackColor: c.brand,
            inactiveThumbColor: c.surface,
            inactiveTrackColor: c.border,
          ),
        ],
      ),
    );
  }
}

// ── Save bar ───────────────────────────────────────────────────────────────
class _SaveBar extends StatelessWidget {
  final AddAddressMetrics metrics;
  final bool isEdit;
  final VoidCallback onSave;

  const _SaveBar({
    required this.metrics,
    required this.isEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapSm,
        m.pageHPad,
        m.gapSm * 0.5,
      ),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.maxContentWidth),
            child: SizedBox(
              height: m.btnHeight,
              width: double.infinity,
              child: Material(
                color: c.brand,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onSave,
                  child: Center(
                    child: Text(
                      isEdit ? 'UPDATE ADDRESS' : 'SAVE ADDRESS',
                      style: AppTextStyles.buttonText.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.btnFontSize,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}