// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubit/address_cubit.dart';
// import '../cubit/address_state.dart';
// import 'add_edit_address_screen.dart';
//
// class AddressListScreen extends StatefulWidget {
//   const AddressListScreen({super.key});
//
//   @override
//   State<AddressListScreen> createState() => _AddressListScreenState();
// }
//
// class _AddressListScreenState extends State<AddressListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<AddressCubit>().loadUserAddresses();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Addresses")),
//
//       body: BlocBuilder<AddressCubit, AddressState>(
//         builder: (context, state) {
//           if (state is AddressLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (state is AddressListLoaded) {
//             final addresses = state.addresses;
//
//             if (addresses.isEmpty) {
//               return const Center(child: Text("No addresses found"));
//             }
//
//             return ListView.builder(
//               itemCount: addresses.length,
//               itemBuilder: (_, index) {
//                 final address = addresses[index];
//
//                 return Card(
//                   margin: const EdgeInsets.all(10),
//                   child: ListTile(
//                     title: Text(address.fullName),
//                     subtitle: Text(
//                       "${address.addressLine1}, ${address.city}, ${address.state}",
//                     ),
//
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         /// ✏️ Edit
//                         IconButton(
//                           icon: const Icon(Icons.edit),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => BlocProvider.value(
//                                   value: context.read<AddressCubit>(),
//                                   child: AddEditAddressScreen(
//                                     existingAddress: address,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//
//                         /// 🗑 Delete
//                         IconButton(
//                           icon: const Icon(Icons.delete),
//                           onPressed: () {
//                             context.read<AddressCubit>().removeAddress(
//                               address.id,
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//
//           if (state is AddressError) {
//             return Center(child: Text(state.errorMessage));
//           }
//
//           return const SizedBox();
//         },
//       ),
//
//       /// ➕ Add New Address
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => BlocProvider.value(
//                 value: context.read<AddressCubit>(),
//                 child: const AddEditAddressScreen(),
//               ),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import '../widgets/address_metrics.dart';
import '../widgets/address_tile.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  /// Jo address abhi selected hai (Review screen se aata hai)
  final String? selectedAddressId;

  const AddressListScreen({super.key, this.selectedAddressId});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedAddressId;
    context.read<AddressCubit>().loadUserAddresses();
  }

  Future<void> _openAddEdit(AddressEntity? existing) async {
    final cubit = context.read<AddressCubit>();
    final result = await Navigator.push<AddressEntity>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddEditAddressScreen(existingAddress: existing),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() => _selectedId = result.id);
    }
  }

  Future<void> _deleteAddress(AddressEntity address) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete address?',
      message:
      'Remove ${address.fullName.isNotEmpty ? address.fullName : 'this address'} from your saved addresses?',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );

    if (!confirmed || !mounted) return;

    final cubit = context.read<AddressCubit>();
    await cubit.removeAddress(address.id);

    if (!mounted) return;

    final state = cubit.state;
    if (state is AddressError) {
      AppSnackbar.showError(context, state.errorMessage);
      return;
    }

    if (_selectedId == address.id) setState(() => _selectedId = null);
    AppSnackbar.showSuccess(context, 'Address deleted');
  }

  void _confirmSelection(List<AddressEntity> addresses) {
    final selected = addresses.where((a) => a.id == _selectedId).firstOrNull;
    if (selected == null) {
      AppSnackbar.showError(context, 'Please select a delivery address');
      return;
    }
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<AddressCubit, AddressState>(
          builder: (context, state) {
            final m = AddressMetrics.of(context);

            final addresses = state is AddressListLoaded
                ? state.addresses
                : <AddressEntity>[];

            return Column(
              children: [
                _AddressTopBar(
                  metrics: m,
                  count: state is AddressListLoaded ? addresses.length : null,
                ),

                Expanded(
                  child: state is AddressLoading
                      ? Center(
                    child: CircularProgressIndicator(color: colors.brand),
                  )
                      : state is AddressError
                      ? _MessageView(
                    metrics: m,
                    icon: Icons.wifi_off_rounded,
                    title: 'Could not load addresses',
                    subtitle: state.errorMessage.isNotEmpty
                        ? state.errorMessage
                        : 'Please try again.',
                    actionLabel: 'RETRY',
                    onAction: () =>
                        context.read<AddressCubit>().loadUserAddresses(),
                  )
                      : addresses.isEmpty
                      ? _MessageView(
                    metrics: m,
                    icon: Icons.location_off_outlined,
                    title: 'No saved addresses',
                    subtitle:
                    'Add a delivery address to continue checkout.',
                    actionLabel: 'ADD NEW ADDRESS',
                    onAction: () => _openAddEdit(null),
                  )
                      : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: m.maxContentWidth,
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapMd,
                          m.pageHPad,
                          m.gapLg,
                        ),
                        itemCount: addresses.length + 1,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: m.gapMd),
                        itemBuilder: (context, index) {
                          if (index == addresses.length) {
                            return AddressAddNewButton(
                              onTap: () => _openAddEdit(null),
                            );
                          }

                          final address = addresses[index];
                          return AddressTile(
                            address: address,
                            isSelected: address.id == _selectedId,
                            onSelect: () =>
                                setState(() => _selectedId = address.id),
                            onEdit: () => _openAddEdit(address),
                            onDelete: () => _deleteAddress(address),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                if (addresses.isNotEmpty)
                  _DeliverBar(
                    metrics: m,
                    isEnabled: _selectedId != null,
                    onDeliver: () => _confirmSelection(addresses),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _AddressTopBar extends StatelessWidget {
  final AddressMetrics metrics;
  final int? count;

  const _AddressTopBar({required this.metrics, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
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
            onPressed: () => Navigator.pop(context),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Delivery Address',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.titleSize,
                    height: 1.2,
                  ),
                ),
                if (count != null) ...[
                  SizedBox(height: m.gapXs * 0.6),
                  Text(
                    '$count saved address${count == 1 ? '' : 'es'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontSize: m.subtitleSize,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── Deliver bar ────────────────────────────────────────────────────────────
class _DeliverBar extends StatelessWidget {
  final AddressMetrics metrics;
  final bool isEnabled;
  final VoidCallback onDeliver;

  const _DeliverBar({
    required this.metrics,
    required this.isEnabled,
    required this.onDeliver,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapSm,
        m.pageHPad,
        m.gapSm * 0.5,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.maxContentWidth),
            child: SizedBox(
              height: m.addBtnHeight,
              width: double.infinity,
              child: Material(
                color: isEnabled ? colors.brand : colors.border,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: isEnabled ? onDeliver : null,
                  child: Center(
                    child: Text(
                      'DELIVER HERE',
                      style: AppTextStyles.buttonText.copyWith(
                        color: isEnabled ? colors.surface : colors.textMuted,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.addBtnFontSize,
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

// ── Error / empty ──────────────────────────────────────────────────────────
class _MessageView extends StatelessWidget {
  final AddressMetrics metrics;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageView({
    required this.metrics,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: m.emptyIllustration,
              height: m.emptyIllustration,
              decoration: BoxDecoration(
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: m.emptyIllustration * 0.42,
                color: colors.brand,
              ),
            ),

            SizedBox(height: m.gapLg),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.emptyTitleSize,
              ),
            ),

            SizedBox(height: m.gapSm),

            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.emptySubSize,
                height: 1.45,
              ),
            ),

            SizedBox(height: m.gapLg),

            SizedBox(
              width: m.isTablet ? 280 : null,
              height: m.addBtnHeight,
              child: Material(
                color: colors.brand,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onAction,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
                    child: Center(
                      child: Text(
                        actionLabel,
                        style: AppTextStyles.buttonText.copyWith(
                          color: colors.surface,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: m.addBtnFontSize,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}