import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../data/models/category_model.dart';
import '../../bloc/bulk_upload_cubit.dart';
import '../../bloc/bulk_upload_state.dart';
import '../add_product/category_picker_sheet.dart';
import 'bulk_upload_section_card.dart';

class CategoryTemplateCard extends StatelessWidget {
  const CategoryTemplateCard({super.key});

  /// Drills down through the category tree — same pattern
  /// [AddProductScreen] uses — until a leaf (no children) is picked, since
  /// only leaf categories carry a full bulk-import template.
  Future<void> _pickCategory(BuildContext context) async {
    final cubit = context.read<BulkUploadCubit>();
    var options = cubit.state.rootCategories;
    CategoryModel? picked;
    while (true) {
      if (!context.mounted) return;
      final choice = await showCategoryPicker(
        context,
        options: options,
        selectedId: picked?.uuid,
        title: 'Select category',
      );
      if (choice == null) return;
      if (choice.children.isEmpty) {
        picked = choice;
        break;
      }
      options = choice.children;
    }
    cubit.selectCategory(picked);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkUploadCubit, BulkUploadState>(
      buildWhen: (prev, curr) =>
          prev.rootCategories != curr.rootCategories ||
          prev.loadingCategories != curr.loadingCategories ||
          prev.categoriesError != curr.categoriesError ||
          prev.selectedCategory != curr.selectedCategory ||
          prev.downloadingTemplate != curr.downloadingTemplate,
      builder: (context, state) {
        return BulkUploadSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Choose a category & get the template',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.sm),
              if (state.loadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (state.categoriesError != null) ...[
                Text(
                  state.categoriesError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
                const SizedBox(height: AppDimensions.sm),
                OutlinedButton(
                  onPressed: () =>
                      context.read<BulkUploadCubit>().loadCategories(),
                  child: const Text('Retry'),
                ),
              ] else ...[
                InkWell(
                  onTap: () => _pickCategory(context),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colors.border),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.selectedCategory?.name ??
                                'Select a category',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: state.selectedCategory == null
                                  ? context.colors.textMuted
                                  : context.colors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                AppButton(
                  label: 'Download template',
                  isLoading: state.downloadingTemplate,
                  onPressed: state.selectedCategory == null
                      ? null
                      : () =>
                            context.read<BulkUploadCubit>().downloadTemplate(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
