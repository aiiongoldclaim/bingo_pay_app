import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../bloc/bulk_upload_cubit.dart';
import '../bloc/bulk_upload_state.dart';
import '../widgets/bulk_upload/category_template_card.dart';
import '../widgets/bulk_upload/result_card.dart';
import '../widgets/bulk_upload/upload_file_card.dart';

class BulkUploadScreen extends StatelessWidget {
  const BulkUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BulkUploadCubit()..loadCategories(),
      child: const _BulkUploadView(),
    );
  }
}

class _BulkUploadView extends StatelessWidget {
  const _BulkUploadView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<BulkUploadCubit, BulkUploadState>(
      listenWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppSnackbar.showError(context, state.errorMessage!);
          context.read<BulkUploadCubit>().clearError();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Bulk Upload Products',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            children: [
              BlocBuilder<BulkUploadCubit, BulkUploadState>(
                buildWhen: (prev, curr) => prev.currentStep != curr.currentStep,
                builder: (context, state) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.md),
                  child: StepIndicator(
                    currentStep: state.currentStep,
                    totalSteps: 3,
                    stepLabels: const ['Category', 'Upload', 'Results'],
                  ),
                ),
              ),
              const CategoryTemplateCard(),
              const UploadFileCard(),
              const ResultCard(),
            ],
          ),
        ),
      ),
    );
  }
}
