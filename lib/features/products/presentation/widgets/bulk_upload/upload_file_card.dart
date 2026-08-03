import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../bloc/bulk_upload_cubit.dart';
import '../../bloc/bulk_upload_state.dart';
import 'bulk_upload_section_card.dart';

class UploadFileCard extends StatelessWidget {
  const UploadFileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkUploadCubit, BulkUploadState>(
      buildWhen: (prev, curr) =>
          prev.pickedFileName != curr.pickedFileName ||
          prev.pickedFilePath != curr.pickedFilePath ||
          prev.uploading != curr.uploading ||
          prev.uploadProgressPercent != curr.uploadProgressPercent,
      builder: (context, state) {
        return BulkUploadSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '2. Upload the filled template',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.sm),
              InkWell(
                onTap: state.uploading
                    ? null
                    : () => context.read<BulkUploadCubit>().pickFile(),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.border),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMd,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, color: context.colors.textMuted),
                      const SizedBox(width: AppDimensions.sm),
                      Expanded(
                        child: Text(
                          state.pickedFileName ?? 'Tap to choose a .xlsx file',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: state.pickedFileName == null
                                ? context.colors.textMuted
                                : context.colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.uploading) ...[
                const SizedBox(height: AppDimensions.md),
                LinearProgressIndicator(
                  value: state.uploadProgressPercent / 100,
                ),
                const SizedBox(height: AppDimensions.xs),
                Text(
                  'Uploading… ${state.uploadProgressPercent}%',
                  style: AppTextStyles.labelMedium,
                ),
              ],
              const SizedBox(height: AppDimensions.md),
              AppButton(
                label: 'Upload & validate',
                isLoading: state.uploading,
                onPressed: state.pickedFilePath == null || state.uploading
                    ? null
                    : () => context.read<BulkUploadCubit>().upload(),
              ),
            ],
          ),
        );
      },
    );
  }
}
