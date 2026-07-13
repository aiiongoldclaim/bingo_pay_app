// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:sizer/sizer.dart';

// import '../../../../core/constants/app_sizes.dart';
// import '../../../../core/helpers/email_qr_code.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/theme_colors.dart';

// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});

//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }

// class _ScannerScreenState extends State<ScannerScreen> {
//   final MobileScannerController controller = MobileScannerController();

//   bool _isScanned = false;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickFromGallery() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

//     if (image == null) return;

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Selected: ${image.name}')));

//     // TODO:
//     // Process QR from image if needed
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   void _onDetect(BarcodeCapture capture) {
//     if (_isScanned) return;

//     final barcode = capture.barcodes.first;

//     if (barcode.rawValue == null) return;

//     _isScanned = true;

//     try {
//       final encryptedQr = barcode.rawValue!;

//       print("Encrypted QR : $encryptedQr");

//       final merchantEmail = EmailQrCodec.decrypt(encryptedQr);

//       print("Merchant Email : $merchantEmail");
//       print('Key Length = ${"BingoPayVendorQrEncryptionKey32!".length}');

//       context.push(
//         AppRoutes.reviewPayment,
//         extra: {'merchantEmail': merchantEmail},
//       );
//     } catch (e) {
//       _isScanned = false;

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Invalid QR Code")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,

//       body: Stack(
//         children: [
//           /// Camera Preview
//           MobileScanner(controller: controller, onDetect: _onDetect),

//           /// Top Bar
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Row(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//                     ),
//                     child: IconButton(
//                       onPressed: () => context.pop(),
//                       icon: const Icon(
//                         Icons.arrow_back_ios_new_rounded,
//                         color: ThemeColors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           /// Scan Area
//           /// Scan Area
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 70.w,
//                   height: 35.h,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(AppSizes.radiusLg),
//                     border: Border.all(color: ThemeColors.blue, width: 3),
//                   ),
//                 ),

//                 SizedBox(height: 3.h),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//                       ),
//                       child: IconButton(
//                         onPressed: () => controller.toggleTorch(),
//                         icon: Icon(
//                           Icons.flash_on_rounded,
//                           color: ThemeColors.white,
//                           size: AppSizes.iconLg,
//                         ),
//                       ),
//                     ),

//                     SizedBox(width: 6.w),

//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.black54,
//                         borderRadius: BorderRadius.circular(AppSizes.radiusMd),
//                       ),
//                       child: IconButton(
//                         onPressed: _pickFromGallery,
//                         icon: Icon(
//                           Icons.photo_library_rounded,
//                           color: ThemeColors.white,
//                           size: AppSizes.iconLg,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:zxing2/qrcode.dart' as zx;

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/helpers/email_qr_code.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // autoStart is disabled deliberately: mobile_scanner's own internal camera
  // start would otherwise race with our explicit permission_handler request
  // below — both end up calling the same native AVCaptureDevice permission
  // API on iOS at the same time. If mobile_scanner's attempt loses that race
  // (e.g. on a fresh install where permission isn't decided yet), it never
  // retries and the preview stays dead. Starting the controller ourselves,
  // only after permission is confirmed granted, avoids the race entirely.
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
  );

  bool _isScanned = false;
  final ImagePicker _picker = ImagePicker();

  bool _permissionChecked = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;

    setState(() {
      _permissionChecked = true;
      _permissionGranted = status.isGranted;
    });

    if (status.isGranted) {
      await controller.start();
    }
  }

  Future<void> _pickFromGallery() async {
    _isScanned = false;

    // On Android request storage/photos permission; iOS 14+ uses PHPickerViewController
    // which manages its own access without a prior permission prompt.
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      if (!status.isGranted && !status.isLimited) return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    String? rawValue;
    try {
      final capture = await controller.analyzeImage(image.path);
      if (capture != null && capture.barcodes.isNotEmpty) {
        rawValue = capture.barcodes.first.rawValue;
      }
    } on UnsupportedError {
      // mobile_scanner's Vision-based analyzeImage is hard-unsupported on
      // the iOS Simulator (Apple GPU limitation) — it throws instead of
      // returning null there. Fall back to a pure-Dart decode so gallery
      // scanning still works while developing/testing on the simulator.
      rawValue = await _decodeQrWithZxing(image.path);
    } on MobileScannerBarcodeException {
      rawValue = null;
    } catch (_) {
      rawValue = null;
    }

    if (rawValue == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No QR code found')));
      return;
    }

    await _processScannedValue(rawValue);
  }

  // Pure-Dart QR decode (no platform channel / native Vision API involved),
  // used only when mobile_scanner's native analyzeImage is unavailable.
  Future<String?> _decodeQrWithZxing(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final pixels = decoded
          .convert(numChannels: 4)
          .getBytes(order: img.ChannelOrder.abgr)
          .buffer
          .asInt32List();

      final source = zx.RGBLuminanceSource(
        decoded.width,
        decoded.height,
        pixels,
      );
      final bitmap = zx.BinaryBitmap(zx.GlobalHistogramBinarizer(source));

      final result = zx.QRCodeReader().decode(bitmap);
      return result.text;
    } on zx.ReaderException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (capture.barcodes.isEmpty) return;
    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null) return;
    await _processScannedValue(rawValue);
  }

  // Shared by both the live camera detector and gallery-based scanning
  // (native analyzeImage or the zxing2 fallback) — either path ends up
  // with just the raw decoded QR string.
  Future<void> _processScannedValue(String encryptedQr) async {
    if (_isScanned) return;
    _isScanned = true;

    try {
      final merchantEmail = EmailQrCodec.decrypt(encryptedQr);

      await context.push(
        AppRoutes.reviewPayment,
        extra: {'merchantEmail': merchantEmail},
      );

      _isScanned = false;
    } catch (_) {
      if (!mounted) return;

      AppSnackbar.showError(
        context,
        "Invalid QR code. Please scan a valid Bingo Vender's payment QR.",
      );

      // Guard against instant re-triggering while the error snackbar is up
      // (e.g. the live camera keeps decoding the same bad QR frame-by-frame).
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _isScanned = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          /// Camera Preview — only mounted once permission is confirmed
          /// granted, so mobile_scanner's own start never races our request.
          if (_permissionGranted)
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) =>
                  _ScannerMessage(message: error.errorCode.message),
            )
          else if (_permissionChecked)
            _PermissionDeniedView(onRetry: _requestCameraPermission)
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          /// Top Bar — back button + gallery upload. Gallery-based QR
          /// scanning (analyzeImage) never touches the live camera session,
          /// so it stays available regardless of camera permission state.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: ThemeColors.white,
                      ),
                    ),
                  ),
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
            ),
          ),

          /// Scan Area — the live viewfinder frame + torch toggle only make
          /// sense once the camera is actually running.
          if (_permissionGranted)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70.w,
                    height: 35.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(color: ThemeColors.blue, width: 3),
                    ),
                  ),

                  SizedBox(height: 3.h),

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
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onRetry;

  const _PermissionDeniedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_rounded,
              color: ThemeColors.white,
              size: 48,
            ),
            SizedBox(height: 2.h),
            const Text(
              'Camera access is needed to scan QR codes.\n'
              'You can still upload a QR from your gallery using '
              'the icon at the top.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ThemeColors.white, fontSize: 14),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () async {
                final status = await Permission.camera.status;
                if (status.isPermanentlyDenied) {
                  await openAppSettings();
                } else {
                  onRetry();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.blue,
                foregroundColor: ThemeColors.white,
              ),
              child: const Text('Grant Camera Access'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerMessage extends StatelessWidget {
  final String message;

  const _ScannerMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: ThemeColors.white, fontSize: 14),
        ),
      ),
    );
  }
}
