// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sizer/sizer.dart';

// import '../../../../core/di/injection.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/app_theme_colors.dart';

// import '../../../address/domain/entities/address_entity.dart';
// import '../../../address/domain/repositories/address_respository.dart';
// import '../../../address/presentation/cubit/address_cubit.dart';
// import '../../../address/presentation/cubit/address_state.dart';
// import '../../../address/presentation/screens/add_edit_address_screen.dart';

// import '../../../payment/presentation/cubit/payment_cubit.dart';
// import '../../../payment/presentation/cubit/payment_state.dart';
// import '../../../payment/presentation/screens/payment_success_screen.dart';
// import '../../domain/entities/service_entity.dart';
// import '../cubit/services_cubit.dart';
// import '../cubit/services_state.dart';

// class ServiceCheckoutScreen extends StatefulWidget {
//   final String serviceUuid;

//   /// Selected offering UUID from ServiceDetailScreen.
//   final String? offeringUuid;

//   /// Selected booking date.
//   final String? bookingDate;

//   /// Selected booking time.
//   final String? bookingTime;

//   final String?
//   slotUuid; // NEW — must come from wherever the time slot was picked
//   final int participants; // NEW — default 1

//   const ServiceCheckoutScreen({
//     super.key,
//     required this.serviceUuid,
//     this.offeringUuid,
//     this.bookingDate,
//     this.bookingTime,
//     this.slotUuid,

//     this.participants = 1,
//   });

//   @override
//   State<ServiceCheckoutScreen> createState() => _ServiceCheckoutScreenState();
// }

// class _ServiceCheckoutScreenState extends State<ServiceCheckoutScreen> {
//   int _selectedPayment = 0;

//   String? _selectedAddressId;
//   AddressEntity? _selectedAddress;

//   bool _submitted = false;

//   late final AddressCubit _addressCubit;

//   @override
//   void initState() {
//     super.initState();

//     _addressCubit = AddressCubit(getIt<AddressRepository>())
//       ..loadUserAddresses();

//     debugPrint(
//       '========== SERVICE CHECKOUT ==========\n'
//       'Service UUID: ${widget.serviceUuid}\n'
//       'Offering UUID: ${widget.offeringUuid}\n'
//       'Booking Date: ${widget.bookingDate}\n'
//       'Booking Time: ${widget.bookingTime}\n'
//       '======================================',
//     );
//   }

//   @override
//   void dispose() {
//     _addressCubit.close();
//     super.dispose();
//   }

//   void _selectAddress(AddressEntity address) {
//     setState(() {
//       _selectedAddressId = address.id;
//       _selectedAddress = address;
//       _submitted = false;
//     });
//   }

//   void _onAddressDeleted(AddressEntity address) {
//     if (_selectedAddressId != address.id) return;

//     setState(() {
//       _selectedAddressId = null;
//       _selectedAddress = null;
//     });
//   }

//   Future<void> _openAddEditAddress(
//     BuildContext context,
//     AddressEntity? existing,
//   ) async {
//     final result = await Navigator.push<AddressEntity>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => BlocProvider.value(
//           value: _addressCubit,
//           child: AddEditAddressScreen(existingAddress: existing),
//         ),
//       ),
//     );

//     if (!mounted || result == null) return;

//     _selectAddress(result);
//   }

//   Future<void> _deleteAddress(
//     BuildContext context,
//     AddressEntity address,
//   ) async {
//     final c = context.c;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           backgroundColor: c.surface,
//           title: Text(
//             'Delete address?',
//             style: AppTextStyles.titleMedium.copyWith(color: c.textPrimary),
//           ),
//           content: Text(
//             'Remove ${address.fullName.isNotEmpty ? address.fullName : 'this address'} from your saved addresses?',
//             style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext, false),
//               child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext, true),
//               child: Text('Delete', style: TextStyle(color: c.statusWarning)),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmed != true || !mounted) return;

//     await _addressCubit.removeAddress(address.id);

//     if (!mounted) return;

//     final state = _addressCubit.state;

//     if (state is AddressError) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
//       return;
//     }

//     _onAddressDeleted(address);

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Address deleted')));
//   }

//   // void _continueToPay(ServiceEntity service) {
//   //   setState(() => _submitted = true);

//   //   if (_selectedAddress == null) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(content: Text('Please select a service address')),
//   //     );
//   //     return;
//   //   }

//   //   final address = _selectedAddress!;

//   //   OfferingEntity? selectedOffering;

//   //   if (widget.offeringUuid != null && widget.offeringUuid!.trim().isNotEmpty) {
//   //     for (final offering in service.offerings) {
//   //       if (offering.uuid == widget.offeringUuid) {
//   //         selectedOffering = offering;
//   //         break;
//   //       }
//   //     }
//   //   }

//   //   selectedOffering ??= service.offerings.isNotEmpty
//   //       ? service.offerings.first
//   //       : null;

//   //   debugPrint('========== SERVICE CHECKOUT ==========');
//   //   debugPrint('Service UUID: ${widget.serviceUuid}');
//   //   debugPrint('Service ID: ${service.id}');
//   //   debugPrint('Service: ${service.title}');
//   //   debugPrint('Offering UUID: ${selectedOffering?.uuid}');
//   //   debugPrint('Offering Name: ${selectedOffering?.offeringName}');
//   //   debugPrint('Base Price: ${selectedOffering?.basePrice}');
//   //   debugPrint('Sale Price: ${selectedOffering?.salePrice}');
//   //   debugPrint('Currency: ${selectedOffering?.currency}');
//   //   debugPrint('Booking Date: ${widget.bookingDate}');
//   //   debugPrint('Booking Time: ${widget.bookingTime}');
//   //   debugPrint('Address ID: ${address.id}');
//   //   debugPrint('Address Name: ${address.fullName}');
//   //   debugPrint('Phone: ${address.phoneNumber}');
//   //   debugPrint('Address Line 1: ${address.addressLine1}');
//   //   debugPrint('City: ${address.city}');
//   //   debugPrint('State: ${address.state}');
//   //   debugPrint('Postal Code: ${address.postalCode}');
//   //   debugPrint('Payment: $_selectedPayment');
//   //   debugPrint('======================================');

//   //   ScaffoldMessenger.of(
//   //     context,
//   //   ).showSnackBar(const SnackBar(content: Text('Proceeding to payment...')));

//   //   // TODO:
//   //   // Call your service checkout/payment API here.
//   //   // The selected address is available through `address`.
//   //   //
//   //   // addressId: address.id
//   //   // name: address.fullName
//   //   // phone: address.phoneNumber
//   //   // address: address.addressLine1
//   //   // city: address.city
//   //   // state: address.state
//   //   // postal: address.postalCode
//   // }


// Future<void> _continueToPay(ServiceEntity service) async {
//   setState(() => _submitted = true);

//   if (_selectedAddress == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please select a service address')),
//     );
//     return;
//   }

//   final address = _selectedAddress!;

//   OfferingEntity? selectedOffering;
//   if (widget.offeringUuid != null && widget.offeringUuid!.trim().isNotEmpty) {
//     for (final offering in service.offerings) {
//       if (offering.uuid == widget.offeringUuid) {
//         selectedOffering = offering;
//         break;
//       }
//     }
//   }
//   selectedOffering ??= service.offerings.isNotEmpty ? service.offerings.first : null;

//   // final price = _resolveOfferingPrice(selectedOffering, service);
//   final price = service.price;

//   final paymentCubit = PaymentMethodCubit(
//     productPrice: price,
//     productName: service.title,
//     offeringUuid: selectedOffering?.uuid,
//     slotUuid: widget.slotUuid,
//     participants: widget.participants,
//   );

//   paymentCubit.updateDeliveryAddress(
//     name: address.fullName,
//     phone: address.phoneNumber,
//     address: address.addressLine1,
//     city: address.city,
//     postal: address.postalCode,
//     addressId: address.id,
//   );

//   await paymentCubit.makePayment();

//   if (!mounted) return;

//   if (paymentCubit.state.status == PaymentStatus.success) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => BlocProvider.value(
//           value: paymentCubit,
//           child: const PaymentSuccessScreen(),
//         ),
//       ),
//     );
//   } else if (paymentCubit.state.status == PaymentStatus.failure) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(
//         paymentCubit.state.errorMessage ?? 'Payment failed. Please try again.',
//       )),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     if (widget.serviceUuid.trim().isEmpty) {
//       return Scaffold(
//         backgroundColor: c.background,
//         appBar: _CheckoutAppBar(onBack: () => Navigator.pop(context)),
//         body: const Center(child: Text('Invalid service ID')),
//       );
//     }

//     return Scaffold(
//       backgroundColor: c.background,
//       body: SafeArea(
//         bottom: false,
//         child: MultiBlocProvider(
//           providers: [
//             BlocProvider<ServiceDetailCubit>(
//               create: (_) =>
//                   getIt<ServiceDetailCubit>()
//                     ..loadServiceDetail(widget.serviceUuid),
//             ),
//             BlocProvider<AddressCubit>.value(value: _addressCubit),
//           ],
//           child: BlocListener<AddressCubit, AddressState>(
//             listener: (context, addressState) {
//               if (addressState is AddressListLoaded &&
//                   addressState.addresses.isNotEmpty &&
//                   _selectedAddressId == null) {
//                 final defaultAddress = addressState.addresses.firstWhere(
//                   (address) => address.isDefaultAddress,
//                   orElse: () => addressState.addresses.first,
//                 );

//                 _selectAddress(defaultAddress);
//               }
//             },
//             child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
//               builder: (context, state) {
//                 if (state.status == ServiceDetailStatus.loading ||
//                     state.status == ServiceDetailStatus.initial) {
//                   return Column(
//                     children: [
//                       _CheckoutAppBar(onBack: () => Navigator.pop(context)),
//                       const Expanded(
//                         child: Center(child: CircularProgressIndicator()),
//                       ),
//                     ],
//                   );
//                 }

//                 if (state.status == ServiceDetailStatus.error) {
//                   return Column(
//                     children: [
//                       _CheckoutAppBar(onBack: () => Navigator.pop(context)),
//                       Expanded(
//                         child: _CheckoutErrorView(
//                           onRetry: () {
//                             context
//                                 .read<ServiceDetailCubit>()
//                                 .loadServiceDetail(widget.serviceUuid);
//                           },
//                         ),
//                       ),
//                     ],
//                   );
//                 }

//                 if (state.service == null) {
//                   return Column(
//                     children: [
//                       _CheckoutAppBar(onBack: () => Navigator.pop(context)),
//                       const Expanded(
//                         child: Center(child: Text('No service data available')),
//                       ),
//                     ],
//                   );
//                 }

//                 final service = state.service!;

//                 return Column(
//                   children: [
//                     _CheckoutAppBar(onBack: () => Navigator.pop(context)),
//                     Expanded(
//                       child: Center(
//                         child: ConstrainedBox(
//                           constraints: const BoxConstraints(maxWidth: 980),
//                           child: SingleChildScrollView(
//                             physics: const BouncingScrollPhysics(),
//                             padding: EdgeInsets.fromLTRB(4.w, 0.8.h, 4.w, 5.h),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 const _CheckoutProgressHeader(),
//                                 SizedBox(height: 2.h),
//                                 const _CheckoutIntro(),
//                                 SizedBox(height: 2.h),
//                                 _OrderSummaryCard(
//                                   service: service,
//                                   offeringUuid: widget.offeringUuid,
//                                   bookingDate: widget.bookingDate,
//                                   bookingTime: widget.bookingTime,
//                                 ),
//                                 SizedBox(height: 2.2.h),
//                                 const _SectionHeading(
//                                   icon: Icons.location_on_rounded,
//                                   title: 'Service Address',
//                                   subtitle:
//                                       'Where should we provide the service?',
//                                 ),
//                                 SizedBox(height: 1.1.h),
//                                 _AddressSelectionSection(
//                                   selectedAddressId: _selectedAddressId,
//                                   onSelect: _selectAddress,
//                                   onDeleted: _onAddressDeleted,
//                                   onAdd: () =>
//                                       _openAddEditAddress(context, null),
//                                   onEdit: (address) =>
//                                       _openAddEditAddress(context, address),
//                                   onDelete: (address) =>
//                                       _deleteAddress(context, address),
//                                   showError:
//                                       _submitted && _selectedAddress == null,
//                                 ),
//                                 if (_selectedAddress != null) ...[
//                                   SizedBox(height: 2.h),
//                                   _DeliveringToCard(address: _selectedAddress!),
//                                 ],
//                                 SizedBox(height: 2.2.h),
//                                 const _SectionHeading(
//                                   icon: Icons.account_balance_wallet_rounded,
//                                   title: 'Payment',
//                                   subtitle: 'Choose how you want to pay',
//                                 ),
//                                 SizedBox(height: 1.1.h),
//                                 _PaymentMethodCard(
//                                   selectedPayment: _selectedPayment,
//                                   onPaymentSelected: (value) {
//                                     setState(() {
//                                       _selectedPayment = value;
//                                     });
//                                   },
//                                   onContinue: () {
//                                     _continueToPay(service);
//                                   },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================================
// // APP BAR
// // ============================================================================

// class _CheckoutAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final VoidCallback onBack;

//   const _CheckoutAppBar({required this.onBack});

//   @override
//   Size get preferredSize => const Size.fromHeight(72);

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Container(
//       decoration: BoxDecoration(
//         color: c.surface,
//         border: Border(
//           bottom: BorderSide(color: c.border.withValues(alpha: 0.55)),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: c.brand.withValues(alpha: 0.04),
//             blurRadius: 18,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//         child: Row(
//           children: [
//             Material(
//               color: c.background,
//               borderRadius: BorderRadius.circular(13),
//               child: InkWell(
//                 onTap: onBack,
//                 borderRadius: BorderRadius.circular(13),
//                 child: SizedBox(
//                   width: 44,
//                   height: 44,
//                   child: Icon(
//                     Icons.arrow_back_ios_new_rounded,
//                     size: 18,
//                     color: c.textPrimary,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 3.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Checkout',
//                     style: AppTextStyles.titleLarge.copyWith(
//                       color: c.textPrimary,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w800,
//                       fontSize: 19.sp,
//                     ),
//                   ),
//                   SizedBox(height: 0.25.h),
//                   Text(
//                     'Complete your booking',
//                     style: AppTextStyles.bodySmall.copyWith(
//                       color: c.textSecondary,
//                       fontFamily: 'Inter',
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 2.7.w, vertical: 0.8.h),
//               decoration: BoxDecoration(
//                 color: c.brandSoft,
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.lock_outline_rounded, size: 16, color: c.brand),
//                   SizedBox(width: 1.w),
//                   Text(
//                     'Secure',
//                     style: AppTextStyles.labelMedium.copyWith(
//                       color: c.brand,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w700,
//                       fontSize: 14.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ============================================================================
// // PROGRESS
// // ============================================================================

// class _CheckoutProgressHeader extends StatelessWidget {
//   const _CheckoutProgressHeader();

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.7.h),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             c.brand.withValues(alpha: 0.11),
//             c.brandSoft.withValues(alpha: 0.55),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: c.brand.withValues(alpha: 0.13)),
//       ),
//       child: Row(
//         children: [
//           const _ProgressStep(number: '01', title: 'Service', active: true),
//           Expanded(
//             child: Container(
//               height: 1,
//               margin: EdgeInsets.symmetric(horizontal: 2.w),
//               color: c.brand.withValues(alpha: 0.25),
//             ),
//           ),
//           const _ProgressStep(number: '02', title: 'Address', active: true),
//           Expanded(
//             child: Container(
//               height: 1,
//               margin: EdgeInsets.symmetric(horizontal: 2.w),
//               color: c.brand.withValues(alpha: 0.25),
//             ),
//           ),
//           const _ProgressStep(number: '03', title: 'Payment', active: true),
//         ],
//       ),
//     );
//   }
// }

// class _ProgressStep extends StatelessWidget {
//   final String number;
//   final String title;
//   final bool active;

//   const _ProgressStep({
//     required this.number,
//     required this.title,
//     required this.active,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 30,
//           height: 30,
//           decoration: BoxDecoration(
//             color: active ? c.brand : c.brandSoft,
//             shape: BoxShape.circle,
//             boxShadow: active
//                 ? [
//                     BoxShadow(
//                       color: c.brand.withValues(alpha: 0.22),
//                       blurRadius: 10,
//                     ),
//                   ]
//                 : null,
//           ),
//           child: Center(
//             child: Text(
//               number,
//               style: TextStyle(
//                 color: active ? c.surface : c.brand,
//                 fontFamily: 'Inter',
//                 fontSize: 12.5.sp,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 0.7.h),
//         Text(
//           title,
//           style: TextStyle(
//             color: active ? c.textPrimary : c.textSecondary,
//             fontFamily: 'Inter',
//             fontSize: 12.5.sp,
//             fontWeight: active ? FontWeight.w700 : FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ============================================================================
// // INTRO
// // ============================================================================

// class _CheckoutIntro extends StatelessWidget {
//   const _CheckoutIntro();

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Row(
//       children: [
//         Container(
//           width: 42,
//           height: 42,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [c.brand, c.brand.withValues(alpha: 0.72)],
//             ),
//             borderRadius: BorderRadius.circular(13),
//             boxShadow: [
//               BoxShadow(
//                 color: c.brand.withValues(alpha: 0.18),
//                 blurRadius: 14,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//           ),
//           child: Icon(Icons.auto_awesome_rounded, color: c.surface, size: 20),
//         ),
//         SizedBox(width: 3.w),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Almost there',
//                 style: AppTextStyles.titleMedium.copyWith(
//                   color: c.textPrimary,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w800,
//                   fontSize: 14.5.sp,
//                 ),
//               ),
//               SizedBox(height: 0.25.h),
//               Text(
//                 'Review your booking details before payment.',
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: c.textSecondary,
//                   fontFamily: 'Inter',
//                   fontSize: 13.5.sp,
//                   height: 1.35,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ============================================================================
// // SECTION HEADING
// // ============================================================================

// class _SectionHeading extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;

//   const _SectionHeading({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Row(
//       children: [
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: c.brandSoft,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(icon, color: c.brand, size: 20),
//         ),
//         SizedBox(width: 2.7.w),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: AppTextStyles.titleMedium.copyWith(
//                   color: c.textPrimary,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w800,
//                   fontSize: 15.sp,
//                 ),
//               ),
//               SizedBox(height: 0.25.h),
//               Text(
//                 subtitle,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: c.textSecondary,
//                   fontFamily: 'Inter',
//                   fontSize: 12.8.sp,
//                   height: 1.3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ============================================================================
// // ORDER SUMMARY
// // ============================================================================

// class _OrderSummaryCard extends StatelessWidget {
//   final ServiceEntity service;
//   final String? offeringUuid;
//   final String? bookingDate;
//   final String? bookingTime;

//   const _OrderSummaryCard({
//     required this.service,
//     required this.offeringUuid,
//     required this.bookingDate,
//     required this.bookingTime,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     final OfferingEntity? selectedOffering = _findOffering();

//     final String offeringName =
//         selectedOffering?.offeringName.isNotEmpty == true
//         ? selectedOffering!.offeringName
//         : selectedOffering?.title.isNotEmpty == true
//         ? selectedOffering!.title
//         : service.title;

//     final double price = _offeringPrice(selectedOffering);

//     final String currency = selectedOffering?.currency.isNotEmpty == true
//         ? selectedOffering!.currency
//         : 'INR';

//     return Container(
//       decoration: BoxDecoration(
//         color: c.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: c.border.withValues(alpha: 0.75)),
//         boxShadow: [
//           BoxShadow(
//             color: c.brand.withValues(alpha: 0.07),
//             blurRadius: 25,
//             offset: const Offset(0, 10),
//           ),
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.025),
//             blurRadius: 8,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   c.brand.withValues(alpha: 0.09),
//                   c.brandSoft.withValues(alpha: 0.35),
//                 ],
//               ),
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(20),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.receipt_long_rounded, color: c.brand, size: 19),
//                 SizedBox(width: 2.w),
//                 Text(
//                   'Booking Summary',
//                   style: AppTextStyles.titleMedium.copyWith(
//                     color: c.textPrimary,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w800,
//                     fontSize: 14.sp,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 2.5.w,
//                     vertical: 0.55.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: c.surface,
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(color: c.brand.withValues(alpha: 0.14)),
//                   ),
//                   child: Text(
//                     '1 ITEM',
//                     style: TextStyle(
//                       color: c.brand,
//                       fontFamily: 'Inter',
//                       fontSize: 12.5.sp,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: 0.5,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Padding(
//             padding: EdgeInsets.all(3.5.w),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _ServiceImage(service: service),
//                 SizedBox(width: 3.5.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         service.title,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.bodyLarge.copyWith(
//                           color: c.textPrimary,
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w800,
//                           fontSize: 14.sp,
//                           height: 1.25,
//                         ),
//                       ),

//                       SizedBox(height: 0.5.h),

//                       Text(
//                         offeringName,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: AppTextStyles.bodySmall.copyWith(
//                           color: c.textSecondary,
//                           fontFamily: 'Inter',
//                           fontSize: 13.5.sp,
//                           // height: 1.35,
//                         ),
//                       ),

//                       SizedBox(height: 1.h),

//                       Wrap(
//                         spacing: 1.w,
//                         runSpacing: 0.6.h,
//                         children: [
//                           if (bookingDate != null &&
//                               bookingDate!.trim().isNotEmpty)
//                             _InfoPill(
//                               icon: Icons.calendar_today_rounded,
//                               text: bookingDate!,
//                             ),
//                           if (bookingTime != null &&
//                               bookingTime!.trim().isNotEmpty)
//                             _InfoPill(
//                               icon: Icons.schedule_rounded,
//                               text: bookingTime!,
//                             ),
//                         ],
//                       ),

//                       SizedBox(height: 1.h),

//                       Row(
//                         children: [
//                           Icon(
//                             Icons.verified_rounded,
//                             size: 15,
//                             color: c.brand,
//                           ),
//                           SizedBox(width: 1.w),
//                           Text(
//                             'Professional service',
//                             style: TextStyle(
//                               color: c.textSecondary,
//                               fontFamily: 'Inter',
//                               fontSize: 13.sp,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 2.w),
//                 Row(
//                   // crossAxisAlignment:
//                   //     CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       _money(price, currency: currency),
//                       style: AppTextStyles.titleMedium.copyWith(
//                         color: c.brand,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w900,
//                         fontSize: 15.sp,
//                       ),
//                     ),
//                     SizedBox(width: 1.w),
//                     Text(
//                       '× 1',
//                       style: TextStyle(
//                         color: c.textSecondary,
//                         fontFamily: 'Inter',
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           Container(
//             margin: EdgeInsets.symmetric(horizontal: 3.5.w),
//             height: 1,
//             color: c.border.withValues(alpha: 0.7),
//           ),

//           Padding(
//             padding: EdgeInsets.fromLTRB(3.5.w, 1.5.h, 3.5.w, 1.8.h),
//             child: Row(
//               children: [
//                 Text(
//                   'Service total',
//                   style: TextStyle(
//                     color: c.textSecondary,
//                     fontFamily: 'Inter',
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   _money(price, currency: currency),
//                   style: TextStyle(
//                     color: c.textPrimary,
//                     fontFamily: 'Inter',
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   OfferingEntity? _findOffering() {
//     if (service.offerings.isEmpty) {
//       return null;
//     }

//     if (offeringUuid == null || offeringUuid!.trim().isEmpty) {
//       return _getDefaultOffering();
//     }

//     for (final offering in service.offerings) {
//       if (offering.uuid == offeringUuid) {
//         return offering;
//       }
//     }

//     return _getDefaultOffering();
//   }

//   OfferingEntity _getDefaultOffering() {
//     for (final offering in service.offerings) {
//       if (offering.isDefault) {
//         return offering;
//       }
//     }

//     return service.offerings.first;
//   }

//   double _offeringPrice(OfferingEntity? offering) {
//     if (offering == null) {
//       return service.price;
//     }

//     if (offering.salePrice != null && offering.salePrice!.trim().isNotEmpty) {
//       final salePrice = double.tryParse(offering.salePrice!);

//       if (salePrice != null) {
//         return salePrice;
//       }
//     }

//     final basePrice = double.tryParse(offering.basePrice);

//     if (basePrice != null) {
//       return basePrice;
//     }

//     return service.price;
//   }

//   String _money(
//     double value, {
//     // String currency = 'INR',
//     String currency = 'USD',
//   }) {
//     final formatted = value.toStringAsFixed(
//       value.truncateToDouble() == value ? 0 : 2,
//     );

//     switch (currency.toUpperCase()) {
//       case 'INR':
//         return '₹$formatted';
//       case 'USD':
//         return '\$$formatted';
//       case 'EUR':
//         return '€$formatted';
//       case 'GBP':
//         return '£$formatted';
//       default:
//         return '$currency $formatted';
//     }
//   }
// }

// // ============================================================================
// // INFO PILL
// // ============================================================================

// class _InfoPill extends StatelessWidget {
//   final IconData icon;
//   final String text;

//   const _InfoPill({required this.icon, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.3.w, vertical: 0.7.h),
//       decoration: BoxDecoration(
//         color: c.brandSoft.withValues(alpha: 0.7),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: c.brand, size: 13),
//           SizedBox(width: 1.w),
//           Text(
//             text,
//             style: TextStyle(
//               color: c.brand,
//               fontFamily: 'Inter',
//               fontSize: 11.5.sp,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ============================================================================
// // SERVICE IMAGE
// // ============================================================================

// class _ServiceImage extends StatelessWidget {
//   final ServiceEntity service;

//   const _ServiceImage({required this.service});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     final imageUrl = service.imageUrl;

//     return Container(
//       width: 82,
//       height: 82,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(colors: [c.brandSoft, c.background]),
//         boxShadow: [
//           BoxShadow(
//             color: c.brand.withValues(alpha: 0.10),
//             blurRadius: 12,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: imageUrl.trim().isNotEmpty
//             ? Image.network(
//                 imageUrl,
//                 fit: BoxFit.cover,
//                 errorBuilder: (_, __, ___) {
//                   return Icon(
//                     Icons.home_repair_service_outlined,
//                     color: c.brand,
//                     size: 30,
//                   );
//                 },
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) {
//                     return child;
//                   }

//                   return Center(
//                     child: SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: c.brand,
//                       ),
//                     ),
//                   );
//                 },
//               )
//             : Icon(
//                 Icons.home_repair_service_outlined,
//                 color: c.brand,
//                 size: 30,
//               ),
//       ),
//     );
//   }
// }

// // ============================================================================
// // ADDRESS SELECTION
// // ============================================================================

// class _AddressSelectionSection extends StatelessWidget {
//   final String? selectedAddressId;
//   final ValueChanged<AddressEntity> onSelect;
//   final ValueChanged<AddressEntity> onDeleted;
//   final ValueChanged<AddressEntity> onEdit;
//   final ValueChanged<AddressEntity> onDelete;
//   final VoidCallback onAdd;
//   final bool showError;

//   const _AddressSelectionSection({
//     required this.selectedAddressId,
//     required this.onSelect,
//     required this.onDeleted,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onAdd,
//     this.showError = false,
//   });

//   String _formatAddress(AddressEntity address) {
//     final parts = [
//       address.addressLine1,
//       address.city,
//       address.state,
//       address.postalCode,
//     ].where((value) => value.trim().isNotEmpty);

//     return parts.join(', ');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Container(
//       padding: EdgeInsets.all(3.5.w),
//       decoration: BoxDecoration(
//         color: c.surface,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(
//           color: showError ? c.statusWarning : c.border.withValues(alpha: 0.75),
//           width: showError ? 1.2 : 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: c.brand.withValues(alpha: 0.045),
//             blurRadius: 20,
//             offset: const Offset(0, 7),
//           ),
//         ],
//       ),
//       child: BlocBuilder<AddressCubit, AddressState>(
//         builder: (context, state) {
//           if (state is AddressLoading) {
//             return const _AddressLoadingView();
//           }

//           if (state is AddressError) {
//             return _AddressErrorView(
//               message: state.errorMessage.isNotEmpty
//                   ? state.errorMessage
//                   : 'Could not load addresses',
//               onRetry: () {
//                 context.read<AddressCubit>().loadUserAddresses();
//               },
//             );
//           }

//           if (state is AddressListLoaded) {
//             final addresses = state.addresses;

//             if (addresses.isEmpty) {
//               return _EmptyAddressView(onAdd: onAdd);
//             }

//             // Maximum 3 addresses are shown on the Service Checkout screen.
//             final shownAddresses = addresses.take(3).toList();

//             // The user can add another address only while fewer than 3
//             // addresses exist.
//             final canAddMore = addresses.length < 3;

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 ...shownAddresses.map(
//                   (address) => Padding(
//                     padding: EdgeInsets.only(bottom: 1.h),
//                     child: _DynamicAddressCard(
//                       address: address,
//                       isSelected: address.id == selectedAddressId,
//                       formattedAddress: _formatAddress(address),
//                       onTap: () => onSelect(address),
//                       onEdit: () => onEdit(address),
//                       onDelete: () => onDelete(address),
//                     ),
//                   ),
//                 ),
//                 if (canAddMore) _AddNewAddressButton(onTap: onAdd),
//                 if (showError) ...[
//                   SizedBox(height: 1.h),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.info_outline_rounded,
//                         size: 17,
//                         color: c.statusWarning,
//                       ),
//                       SizedBox(width: 1.5.w),
//                       Expanded(
//                         child: Text(
//                           'Please select a service address',
//                           style: TextStyle(
//                             color: c.statusWarning,
//                             fontFamily: 'Inter',
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ],
//             );
//           }

//           return const _AddressLoadingView();
//         },
//       ),
//     );
//   }
// }

// class _DynamicAddressCard extends StatelessWidget {
//   final AddressEntity address;
//   final bool isSelected;
//   final String formattedAddress;
//   final VoidCallback onTap;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _DynamicAddressCard({
//     required this.address,
//     required this.isSelected,
//     required this.formattedAddress,
//     required this.onTap,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeOut,
//       decoration: BoxDecoration(
//         color: isSelected ? c.brandSoft : c.background,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isSelected ? c.brand : c.border,
//           width: isSelected ? 1.5 : 1,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(14),
//           onTap: onTap,
//           child: Padding(
//             padding: EdgeInsets.all(3.w),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(
//                   isSelected
//                       ? Icons.check_circle_rounded
//                       : Icons.circle_outlined,
//                   size: 22,
//                   color: isSelected ? c.brand : c.textSecondary,
//                 ),
//                 SizedBox(width: 2.5.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               address.fullName,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: AppTextStyles.bodyMedium.copyWith(
//                                 color: c.textPrimary,
//                                 fontFamily: 'Inter',
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 14.sp,
//                               ),
//                             ),
//                           ),
//                           if (address.isDefaultAddress)
//                             Container(
//                               margin: EdgeInsets.only(left: 1.5.w),
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 1.8.w,
//                                 vertical: 0.3.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: c.brand.withValues(alpha: 0.12),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 'Default',
//                                 style: TextStyle(
//                                   color: c.brand,
//                                   fontFamily: 'Inter',
//                                   fontSize: 10.5.sp,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 0.5.h),
//                       Text(
//                         address.phoneNumber,
//                         style: TextStyle(
//                           color: c.textSecondary,
//                           fontFamily: 'Inter',
//                           fontSize: 12.5.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       SizedBox(height: 0.5.h),
//                       Text(
//                         formattedAddress,
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: c.textPrimary,
//                           fontFamily: 'Inter',
//                           fontSize: 12.sp,
//                           fontWeight: FontWeight.w600,
//                           height: 1.35,
//                         ),
//                       ),
//                       SizedBox(height: 0.8.h),
//                       Row(
//                         children: [
//                           TextButton.icon(
//                             onPressed: onEdit,
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.zero,
//                               minimumSize: Size.zero,
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             ),
//                             icon: Icon(
//                               Icons.edit_outlined,
//                               size: 15,
//                               color: c.brand,
//                             ),
//                             label: Text(
//                               'Edit',
//                               style: TextStyle(
//                                 color: c.brand,
//                                 fontFamily: 'Inter',
//                                 fontSize: 11.5.sp,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 2.w),
//                           TextButton.icon(
//                             onPressed: onDelete,
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.zero,
//                               minimumSize: Size.zero,
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             ),
//                             icon: Icon(
//                               Icons.delete_outline_rounded,
//                               size: 15,
//                               color: c.statusWarning,
//                             ),
//                             label: Text(
//                               'Delete',
//                               style: TextStyle(
//                                 color: c.statusWarning,
//                                 fontFamily: 'Inter',
//                                 fontSize: 11.5.sp,
//                                 fontWeight: FontWeight.w700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (isSelected) ...[
//                   SizedBox(width: 1.w),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 1.8.w,
//                       vertical: 0.4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: c.brand,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       'SELECTED',
//                       style: TextStyle(
//                         color: c.surface,
//                         fontFamily: 'Inter',
//                         fontSize: 9.5.sp,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _AddNewAddressButton extends StatelessWidget {
//   final VoidCallback onTap;

//   const _AddNewAddressButton({required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(vertical: 1.35.h),
//           decoration: BoxDecoration(
//             color: c.brandSoft.withValues(alpha: 0.35),
//             borderRadius: BorderRadius.circular(11),
//             border: Border.all(color: c.brand.withValues(alpha: 0.18)),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.add_rounded, color: c.brand, size: 19),
//               SizedBox(width: 1.w),
//               Text(
//                 'Add New Address',
//                 style: TextStyle(
//                   color: c.brand,
//                   fontFamily: 'Inter',
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _EmptyAddressView extends StatelessWidget {
//   final VoidCallback onAdd;

//   const _EmptyAddressView({required this.onAdd});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Column(
//       children: [
//         Container(
//           width: 64,
//           height: 64,
//           decoration: BoxDecoration(color: c.brandSoft, shape: BoxShape.circle),
//           child: Icon(Icons.location_off_outlined, size: 30, color: c.brand),
//         ),
//         SizedBox(height: 1.5.h),
//         Text(
//           'No saved addresses yet',
//           style: TextStyle(
//             color: c.textPrimary,
//             fontFamily: 'Inter',
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         SizedBox(height: 0.5.h),
//         Text(
//           'Add a service address to continue',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: c.textSecondary,
//             fontFamily: 'Inter',
//             fontSize: 12.sp,
//           ),
//         ),
//         SizedBox(height: 1.5.h),
//         _AddNewAddressButton(onTap: onAdd),
//       ],
//     );
//   }
// }

// class _AddressLoadingView extends StatelessWidget {
//   const _AddressLoadingView();

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Column(
//       children: [
//         Container(
//           height: 120,
//           decoration: BoxDecoration(
//             color: c.background,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: c.border),
//           ),
//           child: Center(
//             child: CircularProgressIndicator(strokeWidth: 2, color: c.brand),
//           ),
//         ),
//         SizedBox(height: 1.h),
//         Container(
//           height: 100,
//           decoration: BoxDecoration(
//             color: c.background,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: c.border),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _AddressErrorView extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;

//   const _AddressErrorView({required this.message, required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Column(
//       children: [
//         Icon(Icons.location_off_outlined, size: 38, color: c.textSecondary),
//         SizedBox(height: 1.h),
//         Text(
//           message,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: c.textSecondary,
//             fontFamily: 'Inter',
//             fontSize: 12.sp,
//           ),
//         ),
//         SizedBox(height: 1.5.h),
//         OutlinedButton.icon(
//           onPressed: onRetry,
//           icon: const Icon(Icons.refresh_rounded),
//           label: const Text('Retry'),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: c.brand,
//             side: BorderSide(color: c.brand.withValues(alpha: 0.45)),
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ============================================================================
// // DELIVERING TO
// // ============================================================================

// class _DeliveringToCard extends StatelessWidget {
//   final AddressEntity address;

//   const _DeliveringToCard({required this.address});

//   String _formatAddress(AddressEntity address) {
//     final parts = [
//       address.addressLine1,
//       address.city,
//       address.state,
//       address.postalCode,
//     ].where((value) => value.trim().isNotEmpty);

//     return parts.join(', ');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Container(
//       padding: EdgeInsets.all(3.5.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [c.brand.withValues(alpha: 0.07), c.surface],
//         ),
//         borderRadius: BorderRadius.circular(17),
//         border: Border.all(color: c.brand.withValues(alpha: 0.13)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: c.brandSoft,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(Icons.home_rounded, color: c.brand, size: 20),
//           ),
//           SizedBox(width: 2.7.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'Service location',
//                       style: TextStyle(
//                         color: c.textSecondary,
//                         fontFamily: 'Inter',
//                         fontSize: 13.5.sp,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const Spacer(),
//                     Icon(Icons.verified_rounded, color: c.brand, size: 16),
//                   ],
//                 ),
//                 SizedBox(height: 0.45.h),
//                 Text(
//                   address.fullName,
//                   style: TextStyle(
//                     color: c.textPrimary,
//                     fontFamily: 'Inter',
//                     fontSize: 13.5.sp,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 SizedBox(height: 0.4.h),
//                 Text(
//                   address.phoneNumber,
//                   style: TextStyle(
//                     color: c.textPrimary,
//                     fontFamily: 'Inter',
//                     fontSize: 12.8.sp,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 0.35.h),
//                 Text(
//                   _formatAddress(address),
//                   style: TextStyle(
//                     color: c.textSecondary,
//                     fontFamily: 'Inter',
//                     fontSize: 13.5.sp,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ============================================================================
// // PAYMENT
// // ============================================================================

// class _PaymentMethodCard extends StatelessWidget {
//   final int selectedPayment;
//   final ValueChanged<int> onPaymentSelected;
//   final VoidCallback onContinue;

//   const _PaymentMethodCard({
//     required this.selectedPayment,
//     required this.onPaymentSelected,
//     required this.onContinue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Container(
//       padding: EdgeInsets.all(3.5.w),
//       decoration: BoxDecoration(
//         color: c.surface,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: c.border.withValues(alpha: 0.75)),
//         boxShadow: [
//           BoxShadow(
//             color: c.brand.withValues(alpha: 0.06),
//             blurRadius: 24,
//             offset: const Offset(0, 9),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () => onPaymentSelected(0),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               padding: EdgeInsets.all(3.w),
//               decoration: BoxDecoration(
//                 gradient: selectedPayment == 0
//                     ? LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           c.brand.withValues(alpha: 0.12),
//                           c.brandSoft.withValues(alpha: 0.42),
//                         ],
//                       )
//                     : null,
//                 color: selectedPayment == 0 ? null : c.background,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: selectedPayment == 0
//                       ? c.brand.withValues(alpha: 0.55)
//                       : c.border,
//                   width: selectedPayment == 0 ? 1.3 : 1,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [c.brand, c.brand.withValues(alpha: 0.72)],
//                       ),
//                       borderRadius: BorderRadius.circular(14),
//                       boxShadow: [
//                         BoxShadow(
//                           color: c.brand.withValues(alpha: 0.20),
//                           blurRadius: 14,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: Icon(
//                       Icons.account_balance_wallet_rounded,
//                       color: c.surface,
//                       size: 22,
//                     ),
//                   ),

//                   SizedBox(width: 3.w),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 'Pay with BinGold',
//                                 style: TextStyle(
//                                   color: c.textPrimary,
//                                   fontFamily: 'Inter',
//                                   fontSize: 13.8.sp,
//                                   fontWeight: FontWeight.w800,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 1.7.w,
//                                 vertical: 0.4.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: c.brand.withValues(alpha: 0.10),
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               child: Text(
//                                 'BIGOD',
//                                 style: TextStyle(
//                                   color: c.brand,
//                                   fontFamily: 'Inter',
//                                   fontSize: 13.sp,
//                                   fontWeight: FontWeight.w900,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         SizedBox(height: 0.55.h),

//                         Text(
//                           'Pay securely using your BIGOD balance.',
//                           style: TextStyle(
//                             color: c.textSecondary,
//                             fontFamily: 'Inter',
//                             fontSize: 13.sp,
//                             fontWeight: FontWeight.w600,
//                             height: 1.3,
//                           ),
//                         ),

//                         SizedBox(height: 0.8.h),

//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               margin: const EdgeInsets.only(top: 5),
//                               width: 6,
//                               height: 6,
//                               decoration: BoxDecoration(
//                                 color: c.brand,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                             SizedBox(width: 1.3.w),
//                             Expanded(
//                               child: Text(
//                                 'Your BIGOD balance is unavailable right now.',
//                                 style: TextStyle(
//                                   color: c.textSecondary,
//                                   fontFamily: 'Inter',
//                                   fontSize: 12.sp,
//                                   height: 1.3,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(width: 1.w),

//                   Icon(
//                     selectedPayment == 0
//                         ? Icons.radio_button_checked_rounded
//                         : Icons.radio_button_off_rounded,
//                     color: selectedPayment == 0 ? c.brand : c.textSecondary,
//                     size: 22,
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: 2.h),

//           Container(
//             padding: EdgeInsets.all(2.7.w),
//             decoration: BoxDecoration(
//               color: c.background,
//               borderRadius: BorderRadius.circular(13),
//               border: Border.all(color: c.border.withValues(alpha: 0.65)),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.shield_outlined, color: c.brand, size: 20),
//                 SizedBox(width: 2.w),
//                 Expanded(
//                   child: Text(
//                     'Your final payable amount will be confirmed by the server before charging.',
//                     style: TextStyle(
//                       color: c.textSecondary,
//                       fontFamily: 'Inter',
//                       fontSize: 13.sp,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 2.h),

//           Container(
//             width: double.infinity,
//             height: 58,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [c.brand, c.brand.withValues(alpha: 0.82)],
//               ),
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: [
//                 BoxShadow(
//                   color: c.brand.withValues(alpha: 0.25),
//                   blurRadius: 18,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: onContinue,
//                 borderRadius: BorderRadius.circular(15),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Continue to Pay',
//                       style: AppTextStyles.buttonText.copyWith(
//                         color: c.surface,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w800,
//                         fontSize: 14.sp,
//                         letterSpacing: 0.2,
//                       ),
//                     ),
//                     SizedBox(width: 2.w),
//                     Icon(
//                       Icons.arrow_forward_rounded,
//                       color: c.surface,
//                       size: 19,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 1.4.h),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.lock_outline_rounded,
//                 color: c.textSecondary,
//                 size: 13,
//               ),
//               SizedBox(width: 1.w),
//               Text(
//                 'Secure checkout',
//                 style: TextStyle(
//                   color: c.textSecondary,
//                   fontFamily: 'Inter',
//                   fontSize: 13.5.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               SizedBox(width: 2.w),
//               Container(
//                 width: 3,
//                 height: 3,
//                 decoration: BoxDecoration(
//                   color: c.textSecondary,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               SizedBox(width: 2.w),
//               Text(
//                 'Encrypted',
//                 style: TextStyle(
//                   color: c.textSecondary,
//                   fontFamily: 'Inter',
//                   fontSize: 13.5.sp,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ============================================================================
// // ERROR
// // ============================================================================

// class _CheckoutErrorView extends StatelessWidget {
//   final VoidCallback onRetry;

//   const _CheckoutErrorView({required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;

//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(6.w),
//         child: Container(
//           padding: EdgeInsets.all(7.w),
//           decoration: BoxDecoration(
//             color: c.surface,
//             borderRadius: BorderRadius.circular(22),
//             border: Border.all(color: c.border),
//             boxShadow: [
//               BoxShadow(
//                 color: c.brand.withValues(alpha: 0.06),
//                 blurRadius: 25,
//                 offset: const Offset(0, 10),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 72,
//                 height: 72,
//                 decoration: BoxDecoration(
//                   color: c.brandSoft,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(Icons.cloud_off_rounded, size: 34, color: c.brand),
//               ),

//               SizedBox(height: 2.2.h),

//               Text(
//                 'Unable to load checkout',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   color: c.textPrimary,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),

//               SizedBox(height: 1.h),

//               Text(
//                 'We couldn\'t fetch the service details. '
//                 'Please check your connection and try again.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 11.sp,
//                   color: c.textSecondary,
//                   fontFamily: 'Inter',
//                   height: 1.45,
//                 ),
//               ),

//               SizedBox(height: 2.2.h),

//               SizedBox(
//                 height: 48,
//                 child: ElevatedButton.icon(
//                   onPressed: onRetry,
//                   icon: const Icon(Icons.refresh_rounded),
//                   label: const Text('Try Again'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: c.brand,
//                     foregroundColor: c.surface,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(13),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 6.w),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';

import '../../../address/domain/entities/address_entity.dart';
import '../../../address/domain/repositories/address_respository.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../address/presentation/cubit/address_state.dart';
import '../../../address/presentation/screens/add_edit_address_screen.dart';

import '../../../payment/presentation/cubit/payment_cubit.dart';
import '../../../payment/presentation/cubit/payment_state.dart';
import '../../../payment/presentation/screens/payment_success_screen.dart';
import '../../domain/entities/service_entity.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';

class ServiceCheckoutScreen extends StatefulWidget {
  final String serviceUuid;

  /// Selected offering UUID from ServiceDetailScreen.
  final String? offeringUuid;

  /// Selected booking date.
  final String? bookingDate;

  /// Selected booking time.
  final String? bookingTime;

  /// Selected time-slot UUID from wherever the slot was picked.
  final String? slotUuid;

  /// Number of participants for the booking. Defaults to 1.
  final int participants;

  const ServiceCheckoutScreen({
    super.key,
    required this.serviceUuid,
    this.offeringUuid,
    this.bookingDate,
    this.bookingTime,
    this.slotUuid,
    this.participants = 1,
  });

  @override
  State<ServiceCheckoutScreen> createState() => _ServiceCheckoutScreenState();
}

class _ServiceCheckoutScreenState extends State<ServiceCheckoutScreen> {
  int _selectedPayment = 0;

  String? _selectedAddressId;
  AddressEntity? _selectedAddress;

  bool _submitted = false;

  /// True while a payment/booking request is in flight — drives the
  /// spinner + disabled state on the pay button.
  bool _isProcessingPayment = false;

  late final AddressCubit _addressCubit;

  @override
  void initState() {
    super.initState();

    _addressCubit = AddressCubit(getIt<AddressRepository>())
      ..loadUserAddresses();

    debugPrint(
      '========== SERVICE CHECKOUT ==========\n'
      'Service UUID: ${widget.serviceUuid}\n'
      'Offering UUID: ${widget.offeringUuid}\n'
      'Booking Date: ${widget.bookingDate}\n'
      'Booking Time: ${widget.bookingTime}\n'
      '======================================',
    );
  }

  @override
  void dispose() {
    _addressCubit.close();
    super.dispose();
  }

  void _selectAddress(AddressEntity address) {
    setState(() {
      _selectedAddressId = address.id;
      _selectedAddress = address;
      _submitted = false;
    });
  }

  void _onAddressDeleted(AddressEntity address) {
    if (_selectedAddressId != address.id) return;

    setState(() {
      _selectedAddressId = null;
      _selectedAddress = null;
    });
  }

  Future<void> _openAddEditAddress(
    BuildContext context,
    AddressEntity? existing,
  ) async {
    final result = await Navigator.push<AddressEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: _addressCubit,
          child: AddEditAddressScreen(existingAddress: existing),
        ),
      ),
    );

    if (!mounted || result == null) return;

    _selectAddress(result);
  }

  Future<void> _deleteAddress(
    BuildContext context,
    AddressEntity address,
  ) async {
    final c = context.c;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: c.surface,
          title: Text(
            'Delete address?',
            style: AppTextStyles.titleMedium.copyWith(color: c.textPrimary),
          ),
          content: Text(
            'Remove ${address.fullName.isNotEmpty ? address.fullName : 'this address'} from your saved addresses?',
            style: AppTextStyles.bodyMedium.copyWith(color: c.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel', style: TextStyle(color: c.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text('Delete', style: TextStyle(color: c.statusWarning)),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    await _addressCubit.removeAddress(address.id);

    if (!mounted) return;

    final state = _addressCubit.state;

    if (state is AddressError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
      return;
    }

    _onAddressDeleted(address);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Address deleted')));
  }

  Future<void> _continueToPay(ServiceEntity service) async {
    setState(() => _submitted = true);

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service address')),
      );
      return;
    }

    // Don't allow a second tap while one request is already in flight.
    if (_isProcessingPayment) return;

    final address = _selectedAddress!;

    OfferingEntity? selectedOffering;

    if (widget.offeringUuid != null &&
        widget.offeringUuid!.trim().isNotEmpty) {
      for (final offering in service.offerings) {
        if (offering.uuid == widget.offeringUuid) {
          selectedOffering = offering;
          break;
        }
      }
    }

    selectedOffering ??=
        service.offerings.isNotEmpty ? service.offerings.first : null;

    final price = _resolveOfferingPrice(selectedOffering, service);

    debugPrint('========== SERVICE CHECKOUT — PAY ==========');
    debugPrint('Service UUID: ${widget.serviceUuid}');
    debugPrint('Offering UUID: ${selectedOffering?.uuid}');
    debugPrint('Slot UUID: ${widget.slotUuid}');
    debugPrint('Participants: ${widget.participants}');
    debugPrint('Price: $price');
    debugPrint('Address ID: ${address.id}');
    debugPrint('=============================================');

    final paymentCubit = PaymentMethodCubit(
      productPrice: price,
      productName: service.title,
      offeringUuid: selectedOffering?.uuid,
      slotUuid: widget.slotUuid,
      participants: widget.participants,
    );

    paymentCubit.updateDeliveryAddress(
      name: address.fullName,
      phone: address.phoneNumber,
      address: address.addressLine1,
      city: address.city,
      postal: address.postalCode,
      addressId: address.id,
    );

    setState(() => _isProcessingPayment = true);

    try {
      await paymentCubit.makePayment();

      if (!mounted) return;

      if (paymentCubit.state.status == PaymentStatus.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: paymentCubit,
              child: const PaymentSuccessScreen(),
            ),
          ),
        );
        // Screen is being replaced — no need to clear the flag.
        return;
      } else if (paymentCubit.state.status == PaymentStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentCubit.state.errorMessage ??
                  'Payment failed. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  /// Mirrors `_OrderSummaryCard._offeringPrice` — sale price wins if valid,
  /// falling back to base price, then the service's own price.
  double _resolveOfferingPrice(
    OfferingEntity? offering,
    ServiceEntity service,
  ) {
    if (offering == null) {
      return service.price;
    }

    if (offering.salePrice != null && offering.salePrice!.trim().isNotEmpty) {
      final salePrice = double.tryParse(offering.salePrice!);
      if (salePrice != null) {
        return salePrice;
      }
    }

    final basePrice = double.tryParse(offering.basePrice);
    if (basePrice != null) {
      return basePrice;
    }

    return service.price;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    if (widget.serviceUuid.trim().isEmpty) {
      return Scaffold(
        backgroundColor: c.background,
        appBar: _CheckoutAppBar(onBack: () => Navigator.pop(context)),
        body: const Center(child: Text('Invalid service ID')),
      );
    }

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        bottom: false,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<ServiceDetailCubit>(
              create: (_) => getIt<ServiceDetailCubit>()
                ..loadServiceDetail(widget.serviceUuid),
            ),
            BlocProvider<AddressCubit>.value(value: _addressCubit),
          ],
          child: BlocListener<AddressCubit, AddressState>(
            listener: (context, addressState) {
              if (addressState is AddressListLoaded &&
                  addressState.addresses.isNotEmpty &&
                  _selectedAddressId == null) {
                final defaultAddress = addressState.addresses.firstWhere(
                  (address) => address.isDefaultAddress,
                  orElse: () => addressState.addresses.first,
                );

                _selectAddress(defaultAddress);
              }
            },
            child: BlocBuilder<ServiceDetailCubit, ServiceDetailState>(
              builder: (context, state) {
                if (state.status == ServiceDetailStatus.loading ||
                    state.status == ServiceDetailStatus.initial) {
                  return Column(
                    children: [
                      _CheckoutAppBar(onBack: () => Navigator.pop(context)),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (state.status == ServiceDetailStatus.error) {
                  return Column(
                    children: [
                      _CheckoutAppBar(onBack: () => Navigator.pop(context)),
                      Expanded(
                        child: _CheckoutErrorView(
                          onRetry: () {
                            context
                                .read<ServiceDetailCubit>()
                                .loadServiceDetail(widget.serviceUuid);
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (state.service == null) {
                  return Column(
                    children: [
                      _CheckoutAppBar(onBack: () => Navigator.pop(context)),
                      const Expanded(
                        child: Center(
                          child: Text('No service data available'),
                        ),
                      ),
                    ],
                  );
                }

                final service = state.service!;

                return Column(
                  children: [
                    _CheckoutAppBar(onBack: () => Navigator.pop(context)),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 980),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              4.w,
                              0.8.h,
                              4.w,
                              5.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const _CheckoutProgressHeader(),
                                SizedBox(height: 2.h),
                                const _CheckoutIntro(),
                                SizedBox(height: 2.h),
                                _OrderSummaryCard(
                                  service: service,
                                  offeringUuid: widget.offeringUuid,
                                  bookingDate: widget.bookingDate,
                                  bookingTime: widget.bookingTime,
                                ),
                                SizedBox(height: 2.2.h),
                                const _SectionHeading(
                                  icon: Icons.location_on_rounded,
                                  title: 'Service Address',
                                  subtitle:
                                      'Where should we provide the service?',
                                ),
                                SizedBox(height: 1.1.h),
                                _AddressSelectionSection(
                                  selectedAddressId: _selectedAddressId,
                                  onSelect: _selectAddress,
                                  onDeleted: _onAddressDeleted,
                                  onAdd: () =>
                                      _openAddEditAddress(context, null),
                                  onEdit: (address) =>
                                      _openAddEditAddress(context, address),
                                  onDelete: (address) =>
                                      _deleteAddress(context, address),
                                  showError:
                                      _submitted && _selectedAddress == null,
                                ),
                                if (_selectedAddress != null) ...[
                                  SizedBox(height: 2.h),
                                  _DeliveringToCard(
                                    address: _selectedAddress!,
                                  ),
                                ],
                                SizedBox(height: 2.2.h),
                                const _SectionHeading(
                                  icon: Icons.account_balance_wallet_rounded,
                                  title: 'Payment',
                                  subtitle: 'Choose how you want to pay',
                                ),
                                SizedBox(height: 1.1.h),
                                _PaymentMethodCard(
                                  selectedPayment: _selectedPayment,
                                  isProcessing: _isProcessingPayment,
                                  onPaymentSelected: (value) {
                                    setState(() {
                                      _selectedPayment = value;
                                    });
                                  },
                                  onContinue: () {
                                    _continueToPay(service);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// APP BAR
// ============================================================================

class _CheckoutAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;

  const _CheckoutAppBar({required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(
          bottom: BorderSide(color: c.border.withValues(alpha: 0.55)),
        ),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          children: [
            Material(
              color: c.background,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(13),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Checkout',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: c.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 19.sp,
                    ),
                  ),
                  SizedBox(height: 0.25.h),
                  Text(
                    'Complete your booking',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.7.w,
                vertical: 0.8.h,
              ),
              decoration: BoxDecoration(
                color: c.brandSoft,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: c.brand),
                  SizedBox(width: 1.w),
                  Text(
                    'Secure',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: c.brand,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// PROGRESS
// ============================================================================

class _CheckoutProgressHeader extends StatelessWidget {
  const _CheckoutProgressHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.7.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.brand.withValues(alpha: 0.11),
            c.brandSoft.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.brand.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          const _ProgressStep(number: '01', title: 'Service', active: true),
          Expanded(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              color: c.brand.withValues(alpha: 0.25),
            ),
          ),
          const _ProgressStep(number: '02', title: 'Address', active: true),
          Expanded(
            child: Container(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              color: c.brand.withValues(alpha: 0.25),
            ),
          ),
          const _ProgressStep(number: '03', title: 'Payment', active: true),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String number;
  final String title;
  final bool active;

  const _ProgressStep({
    required this.number,
    required this.title,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: active ? c.brand : c.brandSoft,
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: c.brand.withValues(alpha: 0.22),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: active ? c.surface : c.brand,
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(height: 0.7.h),
        Text(
          title,
          style: TextStyle(
            color: active ? c.textPrimary : c.textSecondary,
            fontFamily: 'Inter',
            fontSize: 12.5.sp,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INTRO
// ============================================================================

class _CheckoutIntro extends StatelessWidget {
  const _CheckoutIntro();

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.brand, c.brand.withValues(alpha: 0.72)],
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: c.brand.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(Icons.auto_awesome_rounded, color: c.surface, size: 20),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Almost there',
                style: AppTextStyles.titleMedium.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5.sp,
                ),
              ),
              SizedBox(height: 0.25.h),
              Text(
                'Review your booking details before payment.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 13.5.sp,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SECTION HEADING
// ============================================================================

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.brandSoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: c.brand, size: 20),
        ),
        SizedBox(width: 2.7.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 15.sp,
                ),
              ),
              SizedBox(height: 0.25.h),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 12.8.sp,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ORDER SUMMARY
// ============================================================================

class _OrderSummaryCard extends StatelessWidget {
  final ServiceEntity service;
  final String? offeringUuid;
  final String? bookingDate;
  final String? bookingTime;

  const _OrderSummaryCard({
    required this.service,
    required this.offeringUuid,
    required this.bookingDate,
    required this.bookingTime,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final OfferingEntity? selectedOffering = _findOffering();

    final String offeringName =
        selectedOffering?.offeringName.isNotEmpty == true
        ? selectedOffering!.offeringName
        : selectedOffering?.title.isNotEmpty == true
        ? selectedOffering!.title
        : service.title;

    final double price = _offeringPrice(selectedOffering);

    final String currency = selectedOffering?.currency.isNotEmpty == true
        ? selectedOffering!.currency
        : 'INR';

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: 0.07),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  c.brand.withValues(alpha: 0.09),
                  c.brandSoft.withValues(alpha: 0.35),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded, color: c.brand, size: 19),
                SizedBox(width: 2.w),
                Text(
                  'Booking Summary',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 14.sp,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.5.w,
                    vertical: 0.55.h,
                  ),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: c.brand.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Text(
                    '1 ITEM',
                    style: TextStyle(
                      color: c.brand,
                      fontFamily: 'Inter',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(3.5.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ServiceImage(service: service),
                SizedBox(width: 3.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: c.textPrimary,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                          fontSize: 14.sp,
                          height: 1.25,
                        ),
                      ),

                      SizedBox(height: 0.5.h),

                      Text(
                        offeringName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 13.5.sp,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      Wrap(
                        spacing: 1.w,
                        runSpacing: 0.6.h,
                        children: [
                          if (bookingDate != null &&
                              bookingDate!.trim().isNotEmpty)
                            _InfoPill(
                              icon: Icons.calendar_today_rounded,
                              text: bookingDate!,
                            ),
                          if (bookingTime != null &&
                              bookingTime!.trim().isNotEmpty)
                            _InfoPill(
                              icon: Icons.schedule_rounded,
                              text: bookingTime!,
                            ),
                        ],
                      ),

                      SizedBox(height: 1.h),

                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: c.brand,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Professional service',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Row(
                  children: [
                    Text(
                      _money(price, currency: currency),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 15.sp,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '× 1',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: 3.5.w),
            height: 1,
            color: c.border.withValues(alpha: 0.7),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(3.5.w, 1.5.h, 3.5.w, 1.8.h),
            child: Row(
              children: [
                Text(
                  'Service total',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _money(price, currency: currency),
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OfferingEntity? _findOffering() {
    if (service.offerings.isEmpty) {
      return null;
    }

    if (offeringUuid == null || offeringUuid!.trim().isEmpty) {
      return _getDefaultOffering();
    }

    for (final offering in service.offerings) {
      if (offering.uuid == offeringUuid) {
        return offering;
      }
    }

    return _getDefaultOffering();
  }

  OfferingEntity _getDefaultOffering() {
    for (final offering in service.offerings) {
      if (offering.isDefault) {
        return offering;
      }
    }

    return service.offerings.first;
  }

  double _offeringPrice(OfferingEntity? offering) {
    if (offering == null) {
      return service.price;
    }

    if (offering.salePrice != null && offering.salePrice!.trim().isNotEmpty) {
      final salePrice = double.tryParse(offering.salePrice!);

      if (salePrice != null) {
        return salePrice;
      }
    }

    final basePrice = double.tryParse(offering.basePrice);

    if (basePrice != null) {
      return basePrice;
    }

    return service.price;
  }

  String _money(double value, {String currency = 'USD'}) {
    final formatted = value.toStringAsFixed(
      value.truncateToDouble() == value ? 0 : 2,
    );

    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹$formatted';
      case 'USD':
        return '\$$formatted';
      case 'EUR':
        return '€$formatted';
      case 'GBP':
        return '£$formatted';
      default:
        return '$currency $formatted';
    }
  }
}

// ============================================================================
// INFO PILL
// ============================================================================

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: c.brandSoft.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: c.brand, size: 13),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              color: c.brand,
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SERVICE IMAGE
// ============================================================================

class _ServiceImage extends StatelessWidget {
  final ServiceEntity service;

  const _ServiceImage({required this.service});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    final imageUrl = service.imageUrl;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [c.brandSoft, c.background]),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl.trim().isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.home_repair_service_outlined,
                    color: c.brand,
                    size: 30,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.brand,
                      ),
                    ),
                  );
                },
              )
            : Icon(
                Icons.home_repair_service_outlined,
                color: c.brand,
                size: 30,
              ),
      ),
    );
  }
}

// ============================================================================
// ADDRESS SELECTION
// ============================================================================

class _AddressSelectionSection extends StatelessWidget {
  final String? selectedAddressId;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;
  final ValueChanged<AddressEntity> onEdit;
  final ValueChanged<AddressEntity> onDelete;
  final VoidCallback onAdd;
  final bool showError;

  const _AddressSelectionSection({
    required this.selectedAddressId,
    required this.onSelect,
    required this.onDeleted,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    this.showError = false,
  });

  String _formatAddress(AddressEntity address) {
    final parts = [
      address.addressLine1,
      address.city,
      address.state,
      address.postalCode,
    ].where((value) => value.trim().isNotEmpty);

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: showError
              ? c.statusWarning
              : c.border.withValues(alpha: 0.75),
          width: showError ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading) {
            return const _AddressLoadingView();
          }

          if (state is AddressError) {
            return _AddressErrorView(
              message: state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : 'Could not load addresses',
              onRetry: () {
                context.read<AddressCubit>().loadUserAddresses();
              },
            );
          }

          if (state is AddressListLoaded) {
            final addresses = state.addresses;

            if (addresses.isEmpty) {
              return _EmptyAddressView(onAdd: onAdd);
            }

            // Maximum 3 addresses are shown on the Service Checkout screen.
            final shownAddresses = addresses.take(3).toList();

            // The user can add another address only while fewer than 3
            // addresses exist.
            final canAddMore = addresses.length < 3;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...shownAddresses.map(
                  (address) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: _DynamicAddressCard(
                      address: address,
                      isSelected: address.id == selectedAddressId,
                      formattedAddress: _formatAddress(address),
                      onTap: () => onSelect(address),
                      onEdit: () => onEdit(address),
                      onDelete: () => onDelete(address),
                    ),
                  ),
                ),
                if (canAddMore) _AddNewAddressButton(onTap: onAdd),
                if (showError) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 17,
                        color: c.statusWarning,
                      ),
                      SizedBox(width: 1.5.w),
                      Expanded(
                        child: Text(
                          'Please select a service address',
                          style: TextStyle(
                            color: c.statusWarning,
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          }

          return const _AddressLoadingView();
        },
      ),
    );
  }
}

class _DynamicAddressCard extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final String formattedAddress;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DynamicAddressCard({
    required this.address,
    required this.isSelected,
    required this.formattedAddress,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? c.brandSoft : c.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? c.brand : c.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 22,
                  color: isSelected ? c.brand : c.textSecondary,
                ),
                SizedBox(width: 2.5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: c.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          if (address.isDefaultAddress)
                            Container(
                              margin: EdgeInsets.only(left: 1.5.w),
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.8.w,
                                vertical: 0.3.h,
                              ),
                              decoration: BoxDecoration(
                                color: c.brand.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  color: c.brand,
                                  fontFamily: 'Inter',
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        address.phoneNumber,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontFamily: 'Inter',
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        formattedAddress,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      SizedBox(height: 0.8.h),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: onEdit,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 15,
                              color: c.brand,
                            ),
                            label: Text(
                              'Edit',
                              style: TextStyle(
                                color: c.brand,
                                fontFamily: 'Inter',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          TextButton.icon(
                            onPressed: onDelete,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 15,
                              color: c.statusWarning,
                            ),
                            label: Text(
                              'Delete',
                              style: TextStyle(
                                color: c.statusWarning,
                                fontFamily: 'Inter',
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: 1.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 1.8.w,
                      vertical: 0.4.h,
                    ),
                    decoration: BoxDecoration(
                      color: c.brand,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'SELECTED',
                      style: TextStyle(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddNewAddressButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 1.35.h),
          decoration: BoxDecoration(
            color: c.brandSoft.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: c.brand.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: c.brand, size: 19),
              SizedBox(width: 1.w),
              Text(
                'Add New Address',
                style: TextStyle(
                  color: c.brand,
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAddressView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAddressView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: c.brandSoft,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_off_outlined, size: 30, color: c.brand),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'No saved addresses yet',
          style: TextStyle(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Add a service address to continue',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        _AddNewAddressButton(onTap: onAdd),
      ],
    );
  }
}

class _AddressLoadingView extends StatelessWidget {
  const _AddressLoadingView();

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Column(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: c.brand),
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
        ),
      ],
    );
  }
}

class _AddressErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AddressErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Column(
      children: [
        Icon(Icons.location_off_outlined, size: 38, color: c.textSecondary),
        SizedBox(height: 1.h),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
          style: OutlinedButton.styleFrom(
            foregroundColor: c.brand,
            side: BorderSide(color: c.brand.withValues(alpha: 0.45)),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// DELIVERING TO
// ============================================================================

class _DeliveringToCard extends StatelessWidget {
  final AddressEntity address;

  const _DeliveringToCard({required this.address});

  String _formatAddress(AddressEntity address) {
    final parts = [
      address.addressLine1,
      address.city,
      address.state,
      address.postalCode,
    ].where((value) => value.trim().isNotEmpty);

    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.brand.withValues(alpha: 0.07), c.surface],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: c.brand.withValues(alpha: 0.13)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.brandSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.home_rounded, color: c.brand, size: 20),
          ),
          SizedBox(width: 2.7.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Service location',
                      style: TextStyle(
                        color: c.textSecondary,
                        fontFamily: 'Inter',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.verified_rounded, color: c.brand, size: 16),
                  ],
                ),
                SizedBox(height: 0.45.h),
                Text(
                  address.fullName,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Text(
                  address.phoneNumber,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 12.8.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.35.h),
                Text(
                  _formatAddress(address),
                  style: TextStyle(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    height: 1.4,
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

// ============================================================================
// PAYMENT
// ============================================================================

class _PaymentMethodCard extends StatelessWidget {
  final int selectedPayment;
  final bool isProcessing;
  final ValueChanged<int> onPaymentSelected;
  final VoidCallback onContinue;

  const _PaymentMethodCard({
    required this.selectedPayment,
    this.isProcessing = false,
    required this.onPaymentSelected,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Container(
      padding: EdgeInsets.all(3.5.w),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: c.brand.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: isProcessing ? null : () => onPaymentSelected(0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: selectedPayment == 0
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          c.brand.withValues(alpha: 0.12),
                          c.brandSoft.withValues(alpha: 0.42),
                        ],
                      )
                    : null,
                color: selectedPayment == 0 ? null : c.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedPayment == 0
                      ? c.brand.withValues(alpha: 0.55)
                      : c.border,
                  width: selectedPayment == 0 ? 1.3 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.brand, c.brand.withValues(alpha: 0.72)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: c.brand.withValues(alpha: 0.20),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: c.surface,
                      size: 22,
                    ),
                  ),

                  SizedBox(width: 3.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Pay with BinGold',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontFamily: 'Inter',
                                  fontSize: 13.8.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.7.w,
                                vertical: 0.4.h,
                              ),
                              decoration: BoxDecoration(
                                color: c.brand.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                'BIGOD',
                                style: TextStyle(
                                  color: c.brand,
                                  fontFamily: 'Inter',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 0.55.h),

                        Text(
                          'Pay securely using your BIGOD balance.',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontFamily: 'Inter',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: 0.8.h),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: c.brand,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 1.3.w),
                            Expanded(
                              child: Text(
                                'Your BIGOD balance is unavailable right now.',
                                style: TextStyle(
                                  color: c.textSecondary,
                                  fontFamily: 'Inter',
                                  fontSize: 12.sp,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 1.w),

                  Icon(
                    selectedPayment == 0
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: selectedPayment == 0 ? c.brand : c.textSecondary,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 2.h),

          Container(
            padding: EdgeInsets.all(2.7.w),
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: c.border.withValues(alpha: 0.65)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: c.brand, size: 20),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Your final payable amount will be confirmed by the server before charging.',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Pay button — shows a spinner and disables tap while a payment
          // request is in flight.
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProcessing
                    ? [
                        c.brand.withValues(alpha: 0.65),
                        c.brand.withValues(alpha: 0.55),
                      ]
                    : [c.brand, c.brand.withValues(alpha: 0.82)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: c.brand.withValues(alpha: isProcessing ? 0.12 : 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isProcessing ? null : onContinue,
                borderRadius: BorderRadius.circular(15),
                child: Center(
                  child: isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation(c.surface),
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            Text(
                              'Processing…',
                              style: AppTextStyles.buttonText.copyWith(
                                color: c.surface,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue to Pay',
                              style: AppTextStyles.buttonText.copyWith(
                                color: c.surface,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                                letterSpacing: 0.2,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: c.surface,
                              size: 19,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          SizedBox(height: 1.4.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: c.textSecondary,
                size: 13,
              ),
              SizedBox(width: 1.w),
              Text(
                'Secure checkout',
                style: TextStyle(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: c.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Encrypted',
                style: TextStyle(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ERROR
// ============================================================================

class _CheckoutErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _CheckoutErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: c.border),
            boxShadow: [
              BoxShadow(
                color: c.brand.withValues(alpha: 0.06),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 34,
                  color: c.brand,
                ),
              ),

              SizedBox(height: 2.2.h),

              Text(
                'Unable to load checkout',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                'We couldn\'t fetch the service details. '
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  height: 1.45,
                ),
              ),

              SizedBox(height: 2.2.h),

              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.brand,
                    foregroundColor: c.surface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}