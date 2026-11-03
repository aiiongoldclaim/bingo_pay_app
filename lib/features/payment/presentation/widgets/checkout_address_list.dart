import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../../address/presentation/cubit/address_state.dart';
import '../screens/payment_flow_args.dart';
import 'checkout_ui.dart';

// The saved addresses to deliver to: pick one, edit or delete it, add a new
// one, or see them all when there are more than fit here.
class CheckoutAddressList extends StatelessWidget {
  static const _shown = 3;

  final String? selectedId;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;

  const CheckoutAddressList({
    super.key,
    required this.selectedId,
    required this.onSelect,
    required this.onDeleted,
  });

  Future<void> _addOrEdit(BuildContext context, AddressEntity? existing) async {
    final cubit = context.read<AddressCubit>();
    final result = await context.push<AddressEntity>(
      AppRoutes.addEditAddress,
      extra: AddEditAddressArgs(cubit: cubit, existingAddress: existing),
    );
    if (result != null) onSelect(result);
  }

  Future<void> _seeAll(BuildContext context) async {
    final picked = await context.push<AddressEntity>(
      AppRoutes.addressList,
      extra: selectedId,
    );
    if (picked != null) onSelect(picked);
  }

  Future<void> _delete(BuildContext context, AddressEntity address) async {
    final cubit = context.read<AddressCubit>();
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete address?',
      message:
          'Remove ${address.fullName.isNotEmpty ? address.fullName : 'this address'} from your saved addresses?',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
      confirmColor: context.colors.error,
    );
    if (!confirmed || !context.mounted) return;

    await cubit.removeAddress(address.id);
    if (!context.mounted) return;
    final state = cubit.state;
    if (state is AddressError) {
      AppSnackbar.showError(context, state.errorMessage);
      return;
    }
    onDeleted(address);
    AppSnackbar.showSuccess(context, 'Address deleted');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        if (state is AddressError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    state.errorMessage.isNotEmpty
                        ? state.errorMessage
                        : 'Could not load your addresses.',
                    style: checkoutText(colors.textSecondary, size: 13),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<AddressCubit>().loadUserAddresses(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is! AddressListLoaded) return const _AddressShimmer();

        final addresses = state.addresses;
        if (addresses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 32,
                  color: colors.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  'No saved addresses yet',
                  style: checkoutText(
                    colors.textPrimary,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add where your order should go.',
                  style: checkoutText(colors.textSecondary, size: 13),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _addOrEdit(context, null),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add address'),
                ),
              ],
            ),
          );
        }

        // The selected address stays visible even when it is not in the first few.
        final shown = addresses.take(_shown).toList();
        final selected = addresses.where((a) => a.id == selectedId);
        if (selected.isNotEmpty && !shown.contains(selected.first)) {
          shown[shown.length - 1] = selected.first;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final a in shown) ...[
              _AddressRow(
                address: a,
                selected: a.id == selectedId,
                onTap: () => onSelect(a),
                onEdit: () => _addOrEdit(context, a),
                onDelete: () => _delete(context, a),
              ),
              Divider(height: 1, thickness: 1, color: colors.border),
            ],
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _addOrEdit(context, null),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add new address'),
                ),
                const Spacer(),
                if (addresses.length > _shown)
                  TextButton(
                    onPressed: () => _seeAll(context),
                    child: Text('See all (${addresses.length})'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _AddressRow extends StatelessWidget {
  final AddressEntity address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressRow({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = address;
    final line = [
      a.addressLine1,
      if ((a.addressLine2 ?? '').isNotEmpty) a.addressLine2,
      a.city,
      a.postalCode,
    ].join(', ');

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected
            ? colors.brandSoft.withValues(alpha: 0.5)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: selected ? colors.brand : colors.textMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              a.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: checkoutText(
                                colors.textPrimary,
                                size: 15,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (a.isDefaultAddress) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: colors.brandSoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Default',
                                style: checkoutText(
                                  colors.brand,
                                  size: 10,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        line,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: checkoutText(colors.textSecondary, size: 13),
                      ),
                      Text(
                        a.phoneNumber,
                        style: checkoutText(colors.textMuted, size: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressShimmer extends StatelessWidget {
  const _AddressShimmer();

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: [
          for (var i = 0; i < 2; i++)
            const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(
                    width: 22,
                    height: 22,
                    borderRadius: BorderRadius.all(Radius.circular(11)),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 140, height: 14),
                        SizedBox(height: 8),
                        ShimmerBox(height: 12),
                        SizedBox(height: 6),
                        ShimmerBox(width: 90, height: 11),
                      ],
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
