import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../data/models/bulk_import_result_model.dart';
import '../../bloc/bulk_upload_cubit.dart';
import '../../bloc/bulk_upload_state.dart';
import 'bulk_upload_section_card.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkUploadCubit, BulkUploadState>(
      buildWhen: (prev, curr) => prev.result != curr.result,
      builder: (context, state) {
        final result = state.result;
        if (result == null) return const SizedBox.shrink();

        return BulkUploadSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '3. Results',
                style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
              ),
              const SizedBox(height: AppDimensions.md),
              if (result.hasErrors)
                ..._buildErrorState(context, result)
              else
                ..._buildSuccessState(result),
              const SizedBox(height: AppDimensions.md),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Upload another file',
                      variant: AppButtonVariant.outlined,
                      onPressed: () =>
                          context.read<BulkUploadCubit>().reset(),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: AppButton(
                      label: 'View products',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSuccessState(BulkImportResultModel result) {
    return [
      Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.successTint,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                '${result.totalRows} product(s) queued for import. '
                "You'll get an email when it's done — check My Products afterward.",
                style: const TextStyle(color: AppColors.success, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildErrorState(
    BuildContext context,
    BulkImportResultModel result,
  ) {
    return [
      Row(
        children: [
          Expanded(
            child: _StatTile(label: 'Total rows', value: '${result.totalRows}'),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _StatTile(
              label: 'Valid',
              value: '${result.validCount ?? 0}',
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _StatTile(
              label: 'Invalid',
              value: '${result.invalidCount ?? result.invalidRows.length}',
              color: AppColors.error,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppDimensions.md),
      Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.errorTint,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Text(
          '${result.invalidRows.length} row(s) need fixing — no products '
          'were imported yet. Fix the errors below and re-upload.',
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),
      ),
      const SizedBox(height: AppDimensions.md),
      for (final row in result.invalidRows) _InvalidRowTile(row: row),
    ];
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatTile({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color ?? context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InvalidRowTile extends StatefulWidget {
  final BulkInvalidRow row;

  const _InvalidRowTile({required this.row});

  @override
  State<_InvalidRowTile> createState() => _InvalidRowTileState();
}

class _InvalidRowTileState extends State<_InvalidRowTile> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.errorTint),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm,
              ),
              child: Row(
                children: [
                  Icon(_open ? Icons.expand_less : Icons.expand_more, size: 18),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    'Row ${widget.row.rowNumber}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.xs),
                  Text(
                    '(${widget.row.errors.length} '
                    '${widget.row.errors.length == 1 ? 'error' : 'errors'})',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.md,
                0,
                AppDimensions.md,
                AppDimensions.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final err in widget.row.errors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${err.field}: ${err.message}',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
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
