import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/service_entity.dart';
import '../cubit/services_cubit.dart';
import '../cubit/services_state.dart';
import '../widgets/all_services_shimmer.dart';
import '../widgets/service_card.dart';

enum _ServiceSort { relevant, priceLow, priceHigh, rating }

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({super.key});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  late ScrollController _scrollController;
  late ServicesCubit _servicesCubit;
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedRating;
  _ServiceSort _sort = _ServiceSort.relevant;

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategory != null ||
      _selectedRating != null;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _servicesCubit = getIt<ServicesCubit>();
    _servicesCubit.loadAllServices();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _servicesCubit.loadMoreServices();
    }
  }

  List<String> _categories(List<ServiceEntity> services) {
    final names = services
        .map((s) => s.categoryName)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    names.sort();
    return names;
  }

  List<ServiceEntity> _visibleServices(List<ServiceEntity> services) {
    var result = services;

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (s) =>
                s.title.toLowerCase().contains(query) ||
                s.vendorName.toLowerCase().contains(query) ||
                s.categoryName.toLowerCase().contains(query),
          )
          .toList();
    }

    if (_selectedCategory != null) {
      result = result.where((s) => s.categoryName == _selectedCategory).toList();
    }

    if (_selectedRating != null) {
      final minRating = _selectedRating == '4★ & up' ? 4.0 : 3.0;
      result = result.where((s) => s.averageRating >= minRating).toList();
    }

    if (_sort != _ServiceSort.relevant) {
      result = List.of(result);
      switch (_sort) {
        case _ServiceSort.priceLow:
          result.sort((a, b) => a.price.compareTo(b.price));
        case _ServiceSort.priceHigh:
          result.sort((a, b) => b.price.compareTo(a.price));
        case _ServiceSort.rating:
          result.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        case _ServiceSort.relevant:
          break;
      }
    }

    return result;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _selectedRating = null;
      _sort = _ServiceSort.relevant;
    });
  }

  void _showSortSheet() {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _SortSheet(
        selected: _sort,
        onSelect: (option) {
          Navigator.pop(sheetContext);
          setState(() => _sort = option);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocProvider<ServicesCubit>.value(
      value: _servicesCubit,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: const CustomAppBar(title: 'All Services'),
        body: BlocBuilder<ServicesCubit, ServicesState>(
          builder: (context, state) {
            if (state.status == ServicesStatus.loading) {
              return const AllServicesShimmer();
            }

            if (state.status == ServicesStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 15.w,
                      color: colors.textMuted,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Failed to load services',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      state.errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    AppButton(
                      onPressed: () {
                        _servicesCubit.loadAllServices();
                      },
                      label: 'Retry',
                    ),
                  ],
                ),
              );
            }

            if (state.services.isEmpty) {
              return Center(
                child: Text(
                  'No services available',
                  style: TextStyle(fontSize: 16.sp, color: colors.textPrimary),
                ),
              );
            }

            final categories = _categories(state.services);
            final visible = _visibleServices(state.services);

            return Column(
              children: [
                _ServiceSearchBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onClear: () => setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                ),
                _ServiceFilterRow(
                  categories: categories,
                  selectedCategory: _selectedCategory,
                  onCategoryTap: (c) => setState(
                    () => _selectedCategory =
                        _selectedCategory == c ? null : c,
                  ),
                  selectedRating: _selectedRating,
                  onRatingTap: (r) => setState(
                    () => _selectedRating = _selectedRating == r ? null : r,
                  ),
                  sort: _sort,
                  onSortTap: _showSortSheet,
                ),
                Expanded(
                  child: visible.isEmpty
                      ? _NoMatchesView(onClearFilters: _clearFilters)
                      : GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(4.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: visible.length +
                              (!_hasActiveFilters && state.hasMorePages
                                  ? 1
                                  : 0),
                          itemBuilder: (context, index) {
                            if (index >= visible.length) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: colors.brand,
                                ),
                              );
                            }

                            final service = visible[index];

                            return ServiceCard(
                              service: service,
                              onTap: () {
                                context.push(
                                  AppRoutes.serviceDetailPath(service.uuid),
                                  extra: service,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────
class _ServiceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _ServiceSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.2.h),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            hintText: 'Search services, vendors, categories',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: colors.textMuted,
              fontFamily: 'Inter',
            ),
            prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded, color: colors.textSecondary),
                    onPressed: onClear,
                  ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 1.4.h),
          ),
        ),
      ),
    );
  }
}

// ── Filter / sort chip row ─────────────────────────────────────────────────
class _ServiceFilterRow extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;
  final String? selectedRating;
  final ValueChanged<String> onRatingTap;
  final _ServiceSort sort;
  final VoidCallback onSortTap;

  static const _ratingFilters = ['4★ & up', '3★ & up'];

  const _ServiceFilterRow({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.selectedRating,
    required this.onRatingTap,
    required this.sort,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 4.w, right: 4.w, bottom: 1.2.h),
      child: Row(
        children: [
          _ChipButton(
            label: sort == _ServiceSort.relevant ? 'Sort' : _sortLabel(sort),
            icon: Icons.swap_vert_rounded,
            isActive: sort != _ServiceSort.relevant,
            onTap: onSortTap,
          ),
          SizedBox(width: 2.w),
          for (final category in categories) ...[
            _ChipButton(
              label: category,
              isActive: selectedCategory == category,
              onTap: () => onCategoryTap(category),
            ),
            SizedBox(width: 2.w),
          ],
          for (final rating in _ratingFilters) ...[
            _ChipButton(
              label: rating,
              isActive: selectedRating == rating,
              onTap: () => onRatingTap(rating),
            ),
            SizedBox(width: 2.w),
          ],
        ],
      ),
    );
  }

  String _sortLabel(_ServiceSort sort) {
    switch (sort) {
      case _ServiceSort.priceLow:
        return 'Price: Low to High';
      case _ServiceSort.priceHigh:
        return 'Price: High to Low';
      case _ServiceSort.rating:
        return 'Highest Rated';
      case _ServiceSort.relevant:
        return 'Sort';
    }
  }
}

class _ChipButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ChipButton({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
        decoration: BoxDecoration(
          color: isActive ? colors.brandSoft : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? colors.brand : colors.border,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14.sp,
                color: isActive ? colors.brand : colors.textSecondary,
              ),
              SizedBox(width: 1.2.w),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? colors.brand : colors.textSecondary,
                fontFamily: 'Inter',
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sort bottom sheet ───────────────────────────────────────────────────────
class _SortSheet extends StatelessWidget {
  final _ServiceSort selected;
  final ValueChanged<_ServiceSort> onSelect;

  const _SortSheet({required this.selected, required this.onSelect});

  static const _options = [
    (_ServiceSort.relevant, 'Most Relevant'),
    (_ServiceSort.priceLow, 'Price: Low to High'),
    (_ServiceSort.priceHigh, 'Price: High to Low'),
    (_ServiceSort.rating, 'Highest Rated'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: AppTextStyles.titleLarge.copyWith(color: colors.textPrimary),
            ),
            SizedBox(height: 1.h),
            ..._options.map(
              (option) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  option.$2,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selected == option.$1
                        ? colors.brand
                        : colors.textPrimary,
                    fontWeight: selected == option.$1
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
                trailing: selected == option.$1
                    ? Icon(Icons.check, color: colors.brand)
                    : null,
                onTap: () => onSelect(option.$1),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      ),
    );
  }
}

// ── No matches (search/filter yielded nothing) ──────────────────────────────
class _NoMatchesView extends StatelessWidget {
  final VoidCallback onClearFilters;

  const _NoMatchesView({required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 15.w,
              color: colors.textMuted,
            ),
            SizedBox(height: 2.h),
            Text(
              'No services match',
              style: TextStyle(fontSize: 16.sp, color: colors.textPrimary),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Try a different search term or clear your filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: colors.textSecondary),
            ),
            SizedBox(height: 2.h),
            AppButton(onPressed: onClearFilters, label: 'Clear Filters'),
          ],
        ),
      ),
    );
  }
}
