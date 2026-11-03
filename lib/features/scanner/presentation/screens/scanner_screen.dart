import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';
import 'package:zxing2/qrcode.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../tvs_wallet/data/pending_invite.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  bool _isScanned = false;
  final ImagePicker _picker = ImagePicker();

  // Decoded in Dart (zxing2): mobile_scanner's analyzeImage doesn't run on
  // the iOS Simulator.
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200, // keeps decoding fast; a QR stays readable
    );
    if (image == null) return;

    String? token;
    try {
      final decoded = img.decodeImage(await image.readAsBytes())!;
      final source = RGBLuminanceSource(
        decoded.width,
        decoded.height,
        decoded
            .convert(numChannels: 4)
            .getBytes(order: img.ChannelOrder.abgr)
            .buffer
            .asInt32List(),
      );
      token = QRCodeReader().decode(BinaryBitmap(HybridBinarizer(source))).text;
    } catch (_) {}

    if (!mounted) return;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code found in that image')),
      );
      return;
    }
    _open(token);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final token = capture.barcodes.first.rawValue;
    if (token != null) _open(token);
  }

  void _open(String raw) {
    final token = raw.trim();
    if (_isScanned || token.isEmpty) return;

    _isScanned = true;

    // An invite QR is the invite link (<site>/join?ref=CODE): it joins with
    // channel QR. A website checkout QR is a link carrying a BIGOD payment
    // token (<pay-url>?token=<hex>). A member's QR (tvs:u:<uuid>) is for
    // sending them TVS Coins. Anything else is a shop's token; the review
    // screen asks the API who it is.
    final uri = Uri.tryParse(token);
    final invite = uri == null ? null : PendingInvite.parse(uri);
    final payToken = uri?.queryParameters['token'] ?? '';
    final member = token.startsWith('tvs:u:');
    final opened = invite != null
        ? context.push(
            Uri(
              path: AppRoutes.join,
              queryParameters: {'ref': invite.code, 'ch': 'QR'},
            ).toString(),
          )
        : payToken.isNotEmpty
        ? context.push(AppRoutes.bigodScanPay, extra: payToken)
        : context.push(
            member ? AppRoutes.tvsSend : AppRoutes.reviewPayment,
            extra: member ? token : {'token': token},
          );
    opened.then((_) => _isScanned = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: ThemeColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70.w,
                  height: 35.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: ThemeColors.primaryPurple,
                      width: 3,
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: IconButton(
                        onPressed: () => controller.toggleTorch(),
                        icon: Icon(
                          Icons.flash_on_rounded,
                          color: ThemeColors.white,
                          size: AppSizes.iconLg,
                        ),
                      ),
                    ),

                    SizedBox(width: 6.w),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: IconButton(
                        onPressed: _pickFromGallery,
                        icon: Icon(
                          Icons.photo_library_rounded,
                          color: ThemeColors.white,
                          size: AppSizes.iconLg,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
