import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/helpers/dialog_helper.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_dimensions.dart';
import '../../../../../core/utils/upload_service.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/app_image_picker.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../core/widgets/glass/glass_card.dart';
import '../../../../../core/widgets/glass/glass_scaffold.dart';
import '../../../domain/usecases/submit_vendor_kyc_usecase.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/auth_event.dart';
import '../../bloc/auth_state.dart';
import '../../widgets/kyc_document_upload_sheet.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final List<KycDocumentUploadResult> _documents = [];
  int? _deletingIndex;

  Future<void> _addDocument() async {
    final takenTypes = _documents.map((d) => d.documentType).toSet();
    if (takenTypes.length == KycDocumentType.values.length) {
      AppSnackbar.showError(context, 'All document types are already added');
      return;
    }
    final result =
        await showKycDocumentUploadSheet(context, excludedTypes: takenTypes);
    if (result != null && mounted) {
      setState(() => _documents.add(result));
    }
  }

  Future<void> _deleteDocument(int index) async {
    setState(() => _deletingIndex = index);
    try {
      await getIt<UploadService>().deleteFile(_documents[index].publicId);
      if (!mounted) return;
      setState(() {
        _documents.removeAt(index);
        _deletingIndex = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _deletingIndex = null);
      AppSnackbar.showError(context, 'Failed to delete document');
    }
  }

  void _submit() {
    if (_documents.isEmpty) {
      AppSnackbar.showError(context, 'Please upload at least one document');
      return;
    }
    context.read<AuthBloc>().add(
          KycDocumentsSubmitted(
            documents: _documents
                .map((doc) => KycDocumentSubmission(
                      documentType: doc.documentType.value,
                      documentUrl: doc.documentUrl,
                      publicId: doc.publicId,
                    ))
                .toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Identity Verification',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackbar.showError(context, state.failure.message);
          }
          if (state is KycSubmitted) {
            DialogHelper.showSuccess(
              context: context,
              title: 'Document Submitted',
              message:
                  "Your document has been submitted for verification. We'll notify you once it's reviewed.",
              actionLabel: 'Go to Login',
              // Log out explicitly rather than just navigating: a vendor
              // whose resubmission comes back with an immediate final
              // verification outcome (e.g. rejected again) is still
              // "authenticated" per RouteGuard, which would otherwise bounce
              // a bare `context.go(login)` straight back to this KYC screen.
              onAction: () => context.read<AuthBloc>().add(const LogoutRequested()),
              barrierDismissible: false,
            );
          }
          if (state is AuthUnauthenticated) {
            context.go(AppRoutes.login);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      'Upload a government-issued document to verify your identity.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    AppImagePicker(
                      label: 'Upload Document',
                      onTap: _addDocument,
                    ),
                    const SizedBox(height: 16),
                    const _UploadGuidelinesCard(),
                    if (_documents.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Added Documents',
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: AppDimensions.sm),
                      ...List.generate(_documents.length, (index) {
                        final doc = _documents[index];
                        return _AddedDocumentTile(
                          document: doc,
                          isDeleting: _deletingIndex == index,
                          onDelete: () => _deleteDocument(index),
                        );
                      }),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) => AppButton(
                  label: 'Submit',
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

class _UploadGuidelinesCard extends StatelessWidget {
  const _UploadGuidelinesCard();

  static const _tips = [
    'Use the original colored document — no photocopy or screenshot',
    'Photo should be clear and focused, without blur or glare',
    'All four corners of the document must be visible',
    'Name, number and dates should be clearly readable',
    'Document must be valid (not expired)',
    'Accepted: JPG, PNG or PDF · max 5 MB',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: colors.infoTint,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: colors.infoFg.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined, size: 18, color: colors.infoFg),
              const SizedBox(width: 6),
              Text(
                'Tips for a clear upload',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.infoFg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          for (final tip in _tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ',
                      style: TextStyle(fontSize: 12, color: colors.textSecondary)),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.textPrimary,
                      ),
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

class _AddedDocumentTile extends StatelessWidget {
  final KycDocumentUploadResult document;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _AddedDocumentTile({
    required this.document,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      radius: AppDimensions.radiusXl,
      child: Row(
        children: [
          Icon(
            document.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.documentType.label, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  document.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          if (isDeleting)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
