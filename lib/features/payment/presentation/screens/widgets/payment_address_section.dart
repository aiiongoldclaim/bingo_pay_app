import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../../../../address/domain/entities/address_entity.dart';
import '../../../../address/presentation/cubit/address_cubit.dart';
import '../../../../address/presentation/cubit/address_state.dart';
import '../../../../address/presentation/widgets/address_tile.dart';
import '../payment_flow_args.dart';
import 'payment_metrics.dart';

// ── Address Selection Section ──────────────────────────────────────────────
class PaymentAddressSection extends StatelessWidget {
  final PaymentMetrics metrics;
  final String? selectedAddressId;
  final ValueChanged<AddressEntity> onSelect;
  final ValueChanged<AddressEntity> onDeleted;
  final bool showError;

  const PaymentAddressSection({
    super.key,
    required this.metrics,
    required this.selectedAddressId,
    required this.onSelect,
    required this.onDeleted,
    this.showError = false,
  });

  Future<void> _openAddEdit(
    BuildContext context,
    AddressEntity? existing,
  ) async {
    final cubit = context.read<AddressCubit>();
    final result = await context.push<AddressEntity>(
      AppRoutes.addEditAddress,
      extra: AddEditAddressArgs(cubit: cubit, existingAddress: existing),
    );

    if (result != null) {
      onSelect(result);
    }
  }

  Future<void> _deleteAddress(
    BuildContext context,
    AddressEntity address,
  ) async {
    final colors = context.c;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          'Delete address?',
          style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          'Remove ${address.fullName.isNotEmpty ? address.fullName : 'this address'} from your saved addresses?',
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: TextStyle(color: colors.statusWarning)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final cubit = context.read<AddressCubit>();
    await cubit.removeAddress(address.id);

    if (!context.mounted) return;

    final state = cubit.state;
    if (state is AddressError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
      return;
    }

    onDeleted(address);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Address deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(
          color: showError ? colors.statusWarning : colors.border,
          width: 1,
        ),
        boxShadow: colors.isDark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: m.walletIconBox * 0.8,
                height: m.walletIconBox * 0.8,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: m.walletIconSize * 0.8,
                  color: colors.brand,
                ),
              ),
              SizedBox(width: m.gapSm),
              Expanded(
                child: Text(
                  'Delivery Address',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: m.sectionTitleSize,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          BlocBuilder<AddressCubit, AddressState>(
            builder: (context, state) {
              if (state is AddressLoading) {
                return _AddressSkeletonLoader(metrics: m);
              }

              if (state is AddressError) {
                return _AddressErrorRetry(
                  metrics: m,
                  message: state.errorMessage.isNotEmpty
                      ? state.errorMessage
                      : 'Could not load addresses',
                  onRetry: () =>
                      context.read<AddressCubit>().loadUserAddresses(),
                );
              }

              if (state is AddressListLoaded) {
                final addresses = state.addresses;

                if (addresses.isEmpty) {
                  return EmptyAddressWidget(
                    metrics: m,
                    onAddPressed: () => _openAddEdit(context, null),
                  );
                }

                final shown = addresses.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...shown.map(
                      (addr) => Padding(
                        padding: EdgeInsets.only(bottom: m.gapSm),
                        child: AddressTile(
                          address: addr,
                          isSelected: addr.id == selectedAddressId,
                          onSelect: () => onSelect(addr),
                          onEdit: () => _openAddEdit(context, addr),
                          onDelete: () => _deleteAddress(context, addr),
                        ),
                      ),
                    ),
                    if (shown.length < 3)
                      AddressAddNewButton(
                        onTap: () => _openAddEdit(context, null),
                      ),
                    if (showError) ...[
                      SizedBox(height: m.gapSm),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: m.addrChipSize + 2,
                            color: colors.statusWarning,
                          ),
                          SizedBox(width: m.gapXs),
                          Text(
                            'Please select a delivery address',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.statusWarning,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: m.addrChipSize + 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              }

              return _AddressSkeletonLoader(metrics: m);
            },
          ),
        ],
      ),
    );
  }
}

// ── Empty Address ──────────────────────────────────────────────────────────
class EmptyAddressWidget extends StatelessWidget {
  final PaymentMetrics metrics;
  final VoidCallback onAddPressed;

  const EmptyAddressWidget({
    super.key,
    required this.metrics,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Column(
      children: [
        Container(
          width: m.walletIconBox * 1.4,
          height: m.walletIconBox * 1.4,
          decoration: BoxDecoration(color: colors.brandSoft, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_off_outlined,
            size: m.walletIconSize * 1.2,
            color: colors.brand,
          ),
        ),
        SizedBox(height: m.gapMd),
        Text(
          'No saved addresses yet',
          style: AppTextStyles.labelLarge.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: m.addrNameSize,
          ),
        ),
        SizedBox(height: m.gapXs),
        Text(
          'Add a delivery address to continue',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.addrBodySize,
          ),
        ),
        SizedBox(height: m.gapMd),
        AddressAddNewButton(onTap: onAddPressed),
      ],
    );
  }
}

// ── Skeleton ───────────────────────────────────────────────────────────────
class _AddressSkeletonLoader extends StatefulWidget {
  final PaymentMetrics metrics;

  const _AddressSkeletonLoader({required this.metrics});

  @override
  State<_AddressSkeletonLoader> createState() => _AddressSkeletonLoaderState();
}

class _AddressSkeletonLoaderState extends State<_AddressSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.4,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = widget.metrics;

    return FadeTransition(
      opacity: _opacity,
      child: Column(
        children: List.generate(
          2,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: m.gapSm),
            child: Container(
              height: m.walletIconBox * 1.7,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(m.addrRadius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error / Retry ──────────────────────────────────────────────────────────
class _AddressErrorRetry extends StatelessWidget {
  final PaymentMetrics metrics;
  final String message;
  final VoidCallback onRetry;

  const _AddressErrorRetry({
    required this.metrics,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Column(
      children: [
        Icon(
          Icons.wifi_off_rounded,
          size: m.walletIconSize * 1.3,
          color: colors.textMuted,
        ),
        SizedBox(height: m.gapSm),
        Text(
          message.isNotEmpty ? message : 'Could not load addresses',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.addrBodySize,
          ),
        ),
        SizedBox(height: m.gapMd),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: Icon(Icons.refresh, size: m.addrBodySize + 3),
          label: Text(
            'Retry',
            style: AppTextStyles.labelMedium.copyWith(
              fontFamily: 'Inter',
              fontSize: m.addrBodySize,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.brand,
            side: BorderSide(color: colors.brand.withValues(alpha: 0.45)),
          ),
        ),
      ],
    );
  }
}
