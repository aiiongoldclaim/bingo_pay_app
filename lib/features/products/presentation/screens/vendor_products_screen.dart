import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_responsive.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/vendor_product_model.dart';
import '../bloc/vendor_products_cubit.dart';
import '../bloc/vendor_products_state.dart';

class VendorProductsScreen extends StatelessWidget {
  const VendorProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorProductsCubit()..loadProducts(),
      child: const _VendorProductsView(),
    );
  }
}

class _VendorProductsView extends StatelessWidget {
  const _VendorProductsView();

  static const _filters = ['All', 'Published', 'Unpublished'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(context),
      body: BlocBuilder<VendorProductsCubit, VendorProductsState>(
        builder: (context, state) {
          if (state is VendorProductsInitial || state is VendorProductsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is VendorProductsError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.r.w(6)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: context.r.sp(40), color: AppColors.textSecondary),
                    SizedBox(height: context.r.h(2)),
                    Text(state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                    SizedBox(height: context.r.h(2)),
                    OutlinedButton(
                      onPressed: () =>
                          context.read<VendorProductsCubit>().loadProducts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is VendorProductsLoaded) {
            return _buildBody(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final r = context.r;
    return AppBar(
      backgroundColor: AppColors.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: Container(
        margin: EdgeInsets.only(left: r.w(3)),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: r.sp(18), color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      title: Text(
        'My Products',
        style: AppTextStyles.headlineMedium.copyWith(
          fontSize: r.sp(20),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, VendorProductsLoaded state) {
    final r = context.r;
    return Column(
      children: [
        _FilterTabs(
          filters: _filters,
          activeFilter: state.activeFilter,
          all: state.all,
          onSelected: (f) =>
              context.read<VendorProductsCubit>().filterProducts(f),
        ),
        Expanded(
          child: state.filtered.isEmpty
              ? _buildEmpty(context)
              : ListView.separated(
                  padding: EdgeInsets.symmetric(
                      horizontal: r.w(4), vertical: r.h(1.5)),
                  itemCount: state.filtered.length,
                  separatorBuilder: (ctx, i) => SizedBox(height: r.h(2)),
                  itemBuilder: (_, index) =>
                      _ProductListTile(product: state.filtered[index]),
                ),
        ),
        SizedBox(height: context.r.h(2)),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final r = context.r;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: r.sp(40), color: AppColors.textSecondary),
          SizedBox(height: r.h(2)),
          Text(
            'No products found',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
              fontSize: r.sp(15),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final List<String> filters;
  final String activeFilter;
  final List<VendorProductModel> all;
  final void Function(String) onSelected;

  const _FilterTabs({
    required this.filters,
    required this.activeFilter,
    required this.all,
    required this.onSelected,
  });

  int _countFor(String filter) {
    return switch (filter) {
      'Published' => all.where((p) => p.isPublished).length,
      'Unpublished' => all.where((p) => !p.isPublished).length,
      _ => all.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: r.w(4), vertical: r.h(1.5)),
      child: Row(
        children: filters.map((f) {
          final isActive = f == activeFilter;
          return Padding(
            padding: EdgeInsets.only(right: r.w(2)),
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    EdgeInsets.symmetric(horizontal: r.w(4), vertical: r.h(0.8)),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  '$f (${_countFor(f)})',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: r.sp(13),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductListTile extends StatelessWidget {
  final VendorProductModel product;

  const _ProductListTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final r = context.r;
    final imageUrl = product.primaryImageUrl;
    final isPublished = product.isPublished;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(r.w(3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: r.w(22),
                height: r.w(22),
                color: AppColors.backgroundLight,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const _ImageFallback(),
                        loadingBuilder: (ctx, child, p) =>
                            p == null ? child : const _ImageFallback(),
                      )
                    : const _ImageFallback(),
              ),
            ),

            SizedBox(width: r.w(3)),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: r.w(2), vertical: r.h(0.3)),
                      decoration: BoxDecoration(
                        color: AppColors.infoTint,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category!.name,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: r.sp(11),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: r.h(0.5)),
                  ],

                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: r.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (product.shortDescription.isNotEmpty) ...[
                    SizedBox(height: r.h(0.3)),
                    Text(
                      product.shortDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: r.sp(12),
                      ),
                    ),
                  ],

                  SizedBox(height: r.h(1)),

                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: r.w(2.5), vertical: r.h(0.4)),
                    decoration: BoxDecoration(
                      color: isPublished
                          ? AppColors.successTint
                          : AppColors.warningTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPublished ? 'Published' : 'Unpublished',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isPublished
                            ? AppColors.success
                            : AppColors.warning,
                        fontSize: r.sp(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: r.sp(20)),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 22,
        color: AppColors.textSecondary,
      ),
    );
  }
}
