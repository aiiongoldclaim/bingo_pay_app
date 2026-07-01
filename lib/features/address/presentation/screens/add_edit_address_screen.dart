// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../domain/entities/address_entity.dart';
// import '../cubit/address_cubit.dart';

// class AddEditAddressScreen extends StatefulWidget {
//   final AddressEntity? existingAddress;

//   const AddEditAddressScreen({super.key, this.existingAddress});

//   @override
//   State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
// }

// class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
//   final _formKey = GlobalKey<FormState>();

//   late TextEditingController nameController;
//   late TextEditingController phoneController;
//   late TextEditingController line1Controller;
//   late TextEditingController cityController;
//   late TextEditingController stateController;
//   late TextEditingController countryController;
//   late TextEditingController postalController;

//   bool isDefault = false;

//   @override
//   void initState() {
//     super.initState();

//     final data = widget.existingAddress;

//     nameController = TextEditingController(text: data?.fullName);
//     phoneController = TextEditingController(text: data?.phoneNumber);
//     line1Controller = TextEditingController(text: data?.addressLine1);
//     cityController = TextEditingController(text: data?.city);
//     stateController = TextEditingController(text: data?.state);
//     countryController = TextEditingController(text: data?.country);
//     postalController = TextEditingController(text: data?.postalCode);
//     isDefault = data?.isDefaultAddress ?? false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.existingAddress?.id.isNotEmpty == true;

//     return Scaffold(
//       appBar: AppBar(title: Text(isEdit ? "Edit Address" : "Add Address")),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: nameController,
//                 decoration: const InputDecoration(labelText: "Full Name"),
//               ),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: const InputDecoration(labelText: "Phone"),
//               ),
//               TextFormField(
//                 controller: line1Controller,
//                 decoration: const InputDecoration(labelText: "Address Line 1"),
//               ),
//               TextFormField(
//                 controller: cityController,
//                 decoration: const InputDecoration(labelText: "City"),
//               ),
//               TextFormField(
//                 controller: stateController,
//                 decoration: const InputDecoration(
//                   labelText: "State Code (DL, MH...)",
//                 ),
//               ),
//               TextFormField(
//                 controller: countryController,
//                 decoration: const InputDecoration(labelText: "Country"),
//               ),
//               TextFormField(
//                 controller: postalController,
//                 decoration: const InputDecoration(labelText: "Postal Code"),
//               ),

//               SwitchListTile(
//                 value: isDefault,
//                 onChanged: (val) => setState(() => isDefault = val),
//                 title: const Text("Set as Default"),
//               ),

//               const SizedBox(height: 20),

//               ElevatedButton(
//                 onPressed: () {
//                   final address = AddressEntity(
//                     id: widget.existingAddress?.id ?? "",
//                     fullName: nameController.text,
//                     phoneNumber: phoneController.text,
//                     addressLine1: line1Controller.text,
//                     addressLine2: null,
//                     city: cityController.text,
//                     state: stateController.text,
//                     country: countryController.text,
//                     postalCode: postalController.text,
//                     landmark: null,
//                     isDefaultAddress: isDefault,
//                   );

//                   if (isEdit) {
//                     context.read<AddressCubit>().updateAddressDetails(
//                       widget.existingAddress!.id,
//                       address,
//                     );
//                   } else {
//                     context.read<AddressCubit>().submitNewAddress(address);
//                   }

//                   Navigator.pop(context, address);
//                 },
//                 child: Text(isEdit ? "Update Address" : "Save Address"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/address_cubit.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressEntity? existingAddress;

  const AddEditAddressScreen({super.key, this.existingAddress});

  @override
  State<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ThemeColors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),

        appBar: AppBar(
          backgroundColor: ThemeColors.white,
          elevation: 0,
          foregroundColor: ThemeColors.ink,
          title: Text(
            isEdit ? "Edit Address" : "Add Address",
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    /// 📦 ADDRESS CARD (MATCHING PAYMENT SCREEN)
                    _cardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          /// HEADER
                          _gradientHeader(
                            title: "Delivery Address",
                            icon: Icons.location_on_outlined,
                          ),

                          /// FIELDS
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [

                                _Field(
                                  controller: nameCtrl,
                                  label: "Full Name",
                                  hint: "Enter full name",
                                  icon: Icons.person_outline,
                                ),

                                const SizedBox(height: 14),

                                _Field(
                                  controller: phoneCtrl,
                                  label: "Phone",
                                  hint: "10 digit number",
                                  icon: Icons.phone_android,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  digitsOnly: true,
                                ),

                                const SizedBox(height: 14),

                                _Field(
                                  controller: addressCtrl,
                                  label: "Address",
                                  hint: "House / Street / Area",
                                  icon: Icons.home_outlined,
                                  maxLines: 2,
                                ),

                                const SizedBox(height: 14),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _Field(
                                        controller: cityCtrl,
                                        label: "City",
                                        hint: "City",
                                        icon: Icons.location_city,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _Field(
                                        controller: stateCtrl,
                                        label: "State",
                                        hint: "MH, DL...",
                                        icon: Icons.map_outlined,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                _Field(
                                  controller: postalCtrl,
                                  label: "PIN Code",
                                  hint: "6 digit code",
                                  icon: Icons.pin_drop_outlined,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  digitsOnly: true,
                                ),

                                const SizedBox(height: 16),

                                /// DEFAULT SWITCH
                                Row(
                                  children: [
                                    const Icon(Icons.star_border),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        "Set as default address",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Switch(
                                      value: isDefault,
                                      onChanged: (v) =>
                                          setState(() => isDefault = v),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            /// 🔥 BOTTOM BUTTON (MATCH STYLE)
            _bottomButton(context),
          ],
        ),
      ),
    );
  }

  /// 🔹 CARD STYLE
  Widget _cardContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.blue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  /// 🔹 GRADIENT HEADER
  Widget _gradientHeader({required String title, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1D4E), Color(0xFF2B2FA8)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 SUBMIT BUTTON
Widget _bottomButton(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ThemeColors.white,
      boxShadow: [
        BoxShadow(
          color: ThemeColors.ink.withValues(alpha: 0.05),
          blurRadius: 10,
        )
      ],
    ),
    child: SafeArea(
      child: GestureDetector(
        onTap: _submit,
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A1D4E), // same as header
                Color(0xFF2B2FA8),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.blue.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            isEdit ? "Update Address" : "Save Address",
            style: AppTextStyles.titleMedium.copyWith(
              color: ThemeColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    ),
  );
}

  void _submit() {
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
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool digitsOnly;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.digitsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: ThemeColors.ink.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          inputFormatters: digitsOnly
              ? [FilteringTextInputFormatter.digitsOnly]
              : [],
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),

            filled: true,
            fillColor: const Color(0xFFF7F9FC),

            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeColors.ink.withValues(alpha: 0.15),
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeColors.ink.withValues(alpha: 0.15),
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: ThemeColors.blue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}