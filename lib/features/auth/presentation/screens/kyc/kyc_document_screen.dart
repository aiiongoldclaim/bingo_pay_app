import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/helpers/image_picker_helper.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_picker.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_step_indicator.dart';

class KycDocumentScreen extends StatefulWidget {
  const KycDocumentScreen({super.key});

  @override
  State<KycDocumentScreen> createState() => _KycDocumentScreenState();
}

class _KycDocumentScreenState extends State<KycDocumentScreen> {
  String? _imagePath;
  String _documentType = 'passport';

  static const _documentTypes = [
    ('passport', 'Passport'),
    ('national_id', 'National ID'),
    ('drivers_license', "Driver's License"),
  ];

  void _submit() {
    if (_imagePath == null) {
      AppSnackbar.showError(context, 'Please upload your document');
      return;
    }
    context.read<AuthBloc>().add(
          KycDocumentUploaded(
            filePath: _imagePath!,
            documentType: _documentType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Verification')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
          if (state is KycStepCompleted && state.step == 1) {
            context.push(AppRoutes.kycSelfie);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KycStepIndicator(currentStep: 1),
              const SizedBox(height: 8),
              const Text('Step 2 of 3: Document Upload'),
              const SizedBox(height: 24),
              const Text('Document Type'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _documentTypes
                    .map(
                      (type) => ChoiceChip(
                        label: Text(type.$2),
                        selected: _documentType == type.$1,
                        onSelected: (_) =>
                            setState(() => _documentType = type.$1),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              AppImagePicker(
                label: 'Upload Document',
                imagePath: _imagePath,
                onTap: () async {
                  final file = await ImagePickerHelper.pick(context);
                  if (file != null && mounted) {
                    setState(() => _imagePath = file.path);
                  }
                },
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AppButton(
                  label: 'Continue',
                  onPressed: _submit,
                  isLoading: state is KycLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
