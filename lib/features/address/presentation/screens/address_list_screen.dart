import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import '../widgets/address_metrics.dart';
import '../widgets/address_tile.dart';
import '../widgets/manage_address_list.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  final String? selectedAddressId;

  final bool isSelectionMode;

  const AddressListScreen({
    super.key,
    this.selectedAddressId,
    this.isSelectionMode = true,
  });

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
    final selectionMode = widget.isSelectionMode;

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppRoutes.buyerSettings);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: CustomAppBar(
          title: selectionMode ? 'Select Delivery Address' : 'My Addresses',
          onBack: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.buyerSettings),
        ),
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
                  Expanded(

                    child:
                        !selectionMode &&
                            (state is AddressLoading ||
                                state is AddressSubmitting)
                        ? ManageAddressListShimmer(metrics: m)
                        : state is AddressLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colors.brand,
                            ),
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
                            onAction: () => context
                                .read<AddressCubit>()
                                .loadUserAddresses(),
                          )
                        : addresses.isEmpty
                        ? _MessageView(
                            metrics: m,
                            icon: Icons.location_off_outlined,
                            title: 'No saved addresses',
                            subtitle: selectionMode
                                ? 'Add a delivery address to continue checkout.'
                                : 'Save an address for faster checkout.',
                            actionLabel: 'ADD NEW ADDRESS',
                            onAction: () => _openAddEdit(null),
                          )
                        : !selectionMode
                        ? ManageAddressList(
                            metrics: m,
                            addresses: addresses,
                            onAdd: () => _openAddEdit(null),
                            onEdit: _openAddEdit,
                            onDelete: _deleteAddress,
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
                                    onSelect: () => setState(
                                      () => _selectedId = address.id,
                                    ),
                                    onEdit: () => _openAddEdit(address),
                                    onDelete: () => _deleteAddress(address),
                                  );
                                },
                              ),
                            ),
                          ),
                  ),

                  if (selectionMode && addresses.isNotEmpty)
                    AppBottomActionBar(
                      primaryLabel: 'DELIVER HERE',
                      onPrimaryPressed: _selectedId != null
                          ? () => _confirmSelection(addresses)
                          : null,
                    ),
                ],
              );
            },
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
