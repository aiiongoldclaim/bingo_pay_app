import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../setting/features/widgets/settings_metrics.dart';
import '../../../setting/features/widgets/settings_widgets.dart';
import '../widgets/branding_step.dart';
import '../widgets/business_info_step.dart';
import '../widgets/identity_step.dart';
import '../widgets/vendor_application_widgets.dart';

class VendorApplicationScreen extends StatefulWidget {
  const VendorApplicationScreen({super.key});

  @override
  State<VendorApplicationScreen> createState() =>
      _VendorApplicationScreenState();
}

class _VendorApplicationScreenState extends State<VendorApplicationScreen> {
  final _businessFormKey = GlobalKey<FormState>();
  final _businessInfo = BusinessInfoControllers();
  final _scrollController = ScrollController();

  String? _logoPath;
  String? _bannerPath;

  final List<VendorDocument> _documents = [];

  int _currentStep = 0;

  bool get _isLastStep => _currentStep == vendorApplicationSteps.length - 1;

  @override
  void dispose() {
    _businessInfo.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    FocusScope.of(context).unfocus();
    setState(() => _currentStep = index);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  // No field is mandatory, so Next always moves forward.
  void _onNext() {
    if (_isLastStep) return; // Submit will be wired with the API.
    _goToStep(_currentStep + 1);
  }

  void _onBack() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  Widget _buildStep(SettingsMetrics m) {
    switch (_currentStep) {
      case 0:
        return BusinessInfoStep(
          metrics: m,
          controllers: _businessInfo,
          formKey: _businessFormKey,
        );
      case 1:
        return BrandingStep(
          metrics: m,
          logoPath: _logoPath,
          bannerPath: _bannerPath,
          onLogoChanged: (path) => setState(() => _logoPath = path),
          onBannerChanged: (path) => setState(() => _bannerPath = path),
        );
      case 2:
        return IdentityStep(
          metrics: m,
          documents: _documents,
          onDocumentAdded: (doc) {
            setState(() {
              _documents
                ..removeWhere((d) => d.type == doc.type)
                ..add(doc);
            });
            AppSnackbar.showSuccess(context, '${doc.label} added');
          },
          onDocumentRemoved: (doc) =>
              setState(() => _documents.remove(doc)),
        );
      default:
        return VendorStepPlaceholder(
          metrics: m,
          stepName: vendorApplicationSteps[_currentStep],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToStep(_currentStep - 1);
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Builder(
            builder: (context) {
              final m = SettingsMetrics.of(context);

              return Column(
                children: [
                  SettingsTopBar(
                    metrics: m,
                    title: 'Vendor Application',
                    subtitle:
                        'Step ${_currentStep + 1} of ${vendorApplicationSteps.length}',
                    onBack: _onBack,
                  ),

                  VendorStepTabs(
                    metrics: m,
                    currentIndex: _currentStep,
                    onStepTap: _goToStep,
                  ),

                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: m.maxContentWidth),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: EdgeInsets.fromLTRB(
                            m.pageHPad,
                            m.gapLg,
                            m.pageHPad,
                            m.gapLg,
                          ),
                          // Full width so short steps stay left-aligned
                          // instead of being centred.
                          child: SizedBox(
                            width: double.infinity,
                            child: _buildStep(m),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    padding: EdgeInsets.fromLTRB(
                      m.pageHPad,
                      m.gapSm,
                      m.pageHPad,
                      m.gapMd,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      border: Border(top: BorderSide(color: colors.border)),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: m.maxContentWidth),
                        child: Row(
                          children: [
                            if (_currentStep > 0) ...[
                              Expanded(
                                child: AppButton(
                                  label: 'Back',
                                  variant: AppButtonVariant.outlined,
                                  onPressed: _onBack,
                                ),
                              ),
                              SizedBox(width: m.gapMd),
                            ],
                            Expanded(
                              child: AppButton(
                                label: _isLastStep ? 'Submit' : 'Next',
                                suffixIcon: _isLastStep
                                    ? null
                                    : Icons.arrow_forward_rounded,
                                onPressed: _onNext,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
