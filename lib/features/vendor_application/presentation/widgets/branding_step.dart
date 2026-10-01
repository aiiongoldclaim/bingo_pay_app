import 'package:flutter/material.dart';

import '../../../../core/helpers/image_picker_helper.dart';
import '../../../setting/features/widgets/settings_metrics.dart';
import 'vendor_application_widgets.dart';

class BrandingStep extends StatelessWidget {
  final SettingsMetrics metrics;
  final String? logoPath;
  final String? bannerPath;
  final ValueChanged<String?> onLogoChanged;
  final ValueChanged<String?> onBannerChanged;


  const BrandingStep({
    super.key,
    required this.metrics,
    required this.logoPath,
    required this.bannerPath,
    required this.onLogoChanged,
    required this.onBannerChanged,
  });

  Future<void> _pick(
    BuildContext context,
    ValueChanged<String?> onPicked,
  ) async {
    final file = await ImagePickerHelper.pick(context);
    if (file != null) onPicked(file.path);
  }

  @override
  Widget build(BuildContext context) {
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VendorStepHeader(
          metrics: m,
          title: 'Branding & Store Identity',
          subtitle:"Upload your store logo and banner image"
        ),
        SizedBox(height: m.gapLg),

        VendorSectionCard(
          metrics: m,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VendorFieldLabel(metrics: m, label: 'Shop Logo'),
              SizedBox(height: m.gapSm),
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: m.isTablet
                      ? 180
                      : MediaQuery.sizeOf(context).width * 0.38,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: VendorImageUploadBox(
                      metrics: m,
                      imagePath: logoPath,
                      placeholderIcon: Icons.add_photo_alternate_outlined,
                      placeholderText: 'Upload logo',
                      onPick: () => _pick(context, onLogoChanged),
                      onRemove: () => onLogoChanged(null),
                    ),
                  ),
                ),
              ),

              SizedBox(height: m.gapLg),

              VendorFieldLabel(metrics: m, label: 'Shop Banner'),
              SizedBox(height: m.gapSm),
              AspectRatio(
                aspectRatio: 3,
                child: VendorImageUploadBox(
                  metrics: m,
                  imagePath: bannerPath,
                  placeholderIcon: Icons.panorama_outlined,
                  placeholderText: 'Upload banner',
                  onPick: () => _pick(context, onBannerChanged),
                  onRemove: () => onBannerChanged(null),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

