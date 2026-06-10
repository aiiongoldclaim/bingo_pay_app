import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/helpers/image_picker_helper.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_picker.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_step_indicator.dart';

class KycSelfieScreen extends StatefulWidget {
  const KycSelfieScreen({super.key});

  @override
  State<KycSelfieScreen> createState() => _KycSelfieScreenState();
}

class _KycSelfieScreenState extends State<KycSelfieScreen> {
  String? _imagePath;

  void _submit() {
    if (_imagePath == null) {
      AppSnackbar.showError(context, 'Please take a selfie');
      return;
    }
    context.read<AuthBloc>().add(KycSelfieUploaded(filePath: _imagePath!));
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
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const KycStepIndicator(currentStep: 2),
              const SizedBox(height: 8),
              const Text('Step 3 of 3: Take a Selfie'),
              const SizedBox(height: 24),
              Text(
                'Please take a clear selfie holding your document.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              AppImagePicker(
                label: 'Selfie',
                imagePath: _imagePath,
                onTap: () async {
                  final file = await ImagePickerHelper.pick(
                    context,
                    preferredCameraDevice: CameraDevice.front,
                  );
                  if (file != null && mounted) {
                    setState(() => _imagePath = file.path);
                  }
                },
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is KycSubmitted) {
                    return const _UnderReviewBanner();
                  }
                  return AppButton(
                    label: 'Submit',
                    onPressed: _submit,
                    isLoading: state is KycLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderReviewBanner extends StatelessWidget {
  const _UnderReviewBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.hourglass_top, size: 48),
        const SizedBox(height: 8),
        Text(
          'KYC Under Review',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        const Text('We will notify you once your identity is verified.'),
      ],
    );
  }
}
