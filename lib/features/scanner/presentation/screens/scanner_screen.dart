import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/helpers/email_qr_code.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController controller = MobileScannerController();

  bool _isScanned = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Selected: ${image.name}')));

    // TODO:
    // Process QR from image if needed
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final barcode = capture.barcodes.first;

    if (barcode.rawValue == null) return;

    _isScanned = true;

    try {
      final encryptedQr = barcode.rawValue!;

      print("Encrypted QR : $encryptedQr");

      final merchantEmail = EmailQrCodec.decrypt(encryptedQr);

      print("Merchant Email : $merchantEmail");
      print('Key Length = ${"BingoPayVendorQrEncryptionKey32!".length}');

      context.push(
        AppRoutes.reviewPayment,
        extra: {'merchantEmail': merchantEmail},
      );
    } catch (e) {
      _isScanned = false;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid QR Code")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          /// Camera Preview
          MobileScanner(controller: controller, onDetect: _onDetect),

          /// Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
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
                ],
              ),
            ),
          ),

          /// Scan Area
          /// Scan Area
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

// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:zxing2/qrcode.dart' as zx;
//
// import '../../../../core/helpers/email_qr_code.dart';
// import '../../../../core/router/app_routes.dart';
// import '../../../../core/widgets/app_snackbar.dart';
//
// // class ScannerScreen extends StatefulWidget {
// //   const ScannerScreen({super.key});
// //
// //   @override
// //   State<ScannerScreen> createState() => _ScannerScreenState();
// // }
// //
// // class _ScannerScreenState extends State<ScannerScreen> {
// //   final MobileScannerController controller = MobileScannerController(
// //     autoStart: false,
// //   );
// //
// //   bool _isScanned = false;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   bool _permissionChecked = false;
// //   bool _permissionGranted = false;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _requestCameraPermission();
// //   }
// //
// //   Future<void> _requestCameraPermission() async {
// //     final status = await Permission.camera.request();
// //     if (!mounted) return;
// //
// //     setState(() {
// //       _permissionChecked = true;
// //       _permissionGranted = status.isGranted;
// //     });
// //
// //     if (status.isGranted) {
// //       await controller.start();
// //     }
// //   }
// //
// //   Future<void> _pickFromGallery() async {
// //     _isScanned = false;
// //
// //     // On Android request storage/photos permission; iOS 14+ uses PHPickerViewController
// //     // which manages its own access without a prior permission prompt.
// //     if (Platform.isAndroid) {
// //       final status = await Permission.photos.request();
// //       if (!status.isGranted && !status.isLimited) return;
// //     }
// //
// //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
// //
// //     if (image == null) return;
// //
// //     String? rawValue;
// //     try {
// //       final capture = await controller.analyzeImage(image.path);
// //       if (capture != null && capture.barcodes.isNotEmpty) {
// //         rawValue = capture.barcodes.first.rawValue;
// //       }
// //     } on UnsupportedError {
// //       // mobile_scanner's Vision-based analyzeImage is hard-unsupported on
// //       // the iOS Simulator (Apple GPU limitation) — it throws instead of
// //       // returning null there. Fall back to a pure-Dart decode so gallery
// //       // scanning still works while developing/testing on the simulator.
// //       rawValue = await _decodeQrWithZxing(image.path);
// //     } on MobileScannerBarcodeException {
// //       rawValue = null;
// //     } catch (_) {
// //       rawValue = null;
// //     }
// //
// //     if (rawValue == null) {
// //       if (!mounted) return;
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text('No QR code found')));
// //       return;
// //     }
// //
// //     await _processScannedValue(rawValue);
// //   }
// //
// //   // Pure-Dart QR decode (no platform channel / native Vision API involved),
// //   // used only when mobile_scanner's native analyzeImage is unavailable.
// //   Future<String?> _decodeQrWithZxing(String path) async {
// //     try {
// //       final bytes = await File(path).readAsBytes();
// //       final decoded = img.decodeImage(bytes);
// //       if (decoded == null) return null;
// //
// //       final pixels = decoded
// //           .convert(numChannels: 4)
// //           .getBytes(order: img.ChannelOrder.abgr)
// //           .buffer
// //           .asInt32List();
// //
// //       final source = zx.RGBLuminanceSource(
// //         decoded.width,
// //         decoded.height,
// //         pixels,
// //       );
// //       final bitmap = zx.BinaryBitmap(zx.GlobalHistogramBinarizer(source));
// //
// //       final result = zx.QRCodeReader().decode(bitmap);
// //       return result.text;
// //     } on zx.ReaderException {
// //       return null;
// //     } catch (_) {
// //       return null;
// //     }
// //   }
// //
// //   @override
// //   void dispose() {
// //     controller.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _onDetect(BarcodeCapture capture) async {
// //     if (capture.barcodes.isEmpty) return;
// //     final rawValue = capture.barcodes.first.rawValue;
// //     if (rawValue == null) return;
// //     await _processScannedValue(rawValue);
// //   }
// //
// //   // Shared by both the live camera detector and gallery-based scanning
// //   // (native analyzeImage or the zxing2 fallback) — either path ends up
// //   // with just the raw decoded QR string.
// //   Future<void> _processScannedValue(String encryptedQr) async {
// //     if (_isScanned) return;
// //     _isScanned = true;
// //
// //     try {
// //       final merchantEmail = EmailQrCodec.decrypt(encryptedQr);
// //
// //       await context.push(
// //         AppRoutes.reviewPayment,
// //         extra: {'merchantEmail': merchantEmail},
// //       );
// //
// //       _isScanned = false;
// //     } catch (_) {
// //       if (!mounted) return;
// //
// //       AppSnackbar.showError(
// //         context,
// //         "Invalid QR code. Please scan a valid Bingo Vender's payment QR.",
// //       );
// //
// //       // Guard against instant re-triggering while the error snackbar is up
// //       // (e.g. the live camera keeps decoding the same bad QR frame-by-frame).
// //       await Future.delayed(const Duration(seconds: 2));
// //       if (mounted) _isScanned = false;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //
// //       body: Stack(
// //         children: [
// //           /// Camera Preview — only mounted once permission is confirmed
// //           /// granted, so mobile_scanner's own start never races our request.
// //           if (_permissionGranted)
// //             MobileScanner(
// //               controller: controller,
// //               onDetect: _onDetect,
// //               errorBuilder: (context, error) =>
// //                   _ScannerMessage(message: error.errorCode.message),
// //             )
// //           else if (_permissionChecked)
// //             _PermissionDeniedView(onRetry: _requestCameraPermission)
// //           else
// //             const Center(child: CircularProgressIndicator(color: Colors.white)),
// //
// //           /// Top Bar — back button + gallery upload. Gallery-based QR
// //           /// scanning (analyzeImage) never touches the live camera session,
// //           /// so it stays available regardless of camera permission state.
// //           SafeArea(
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.black54,
// //                       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
// //                     ),
// //                     child: IconButton(
// //                       onPressed: () => context.pop(),
// //                       icon: const Icon(
// //                         Icons.arrow_back_ios_new_rounded,
// //                         color: ThemeColors.white,
// //                       ),
// //                     ),
// //                   ),
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.black54,
// //                       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
// //                     ),
// //                     child: IconButton(
// //                       onPressed: _pickFromGallery,
// //                       icon: Icon(
// //                         Icons.photo_library_rounded,
// //                         color: ThemeColors.white,
// //                         size: AppSizes.iconLg,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //
// //           /// Scan Area — the live viewfinder frame + torch toggle only make
// //           /// sense once the camera is actually running.
// //           if (_permissionGranted)
// //             Center(
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Container(
// //                     width: 70.w,
// //                     height: 35.h,
// //                     decoration: BoxDecoration(
// //                       borderRadius: BorderRadius.circular(AppSizes.radiusLg),
// //                       border: Border.all(color: ThemeColors.blue, width: 3),
// //                     ),
// //                   ),
// //
// //                   SizedBox(height: 3.h),
// //
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.black54,
// //                       borderRadius: BorderRadius.circular(AppSizes.radiusMd),
// //                     ),
// //                     child: IconButton(
// //                       onPressed: () => controller.toggleTorch(),
// //                       icon: Icon(
// //                         Icons.flash_on_rounded,
// //                         color: ThemeColors.white,
// //                         size: AppSizes.iconLg,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _PermissionDeniedView extends StatelessWidget {
// //   final VoidCallback onRetry;
// //
// //   const _PermissionDeniedView({required this.onRetry});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Padding(
// //         padding: EdgeInsets.symmetric(horizontal: 8.w),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Icon(
// //               Icons.no_photography_rounded,
// //               color: ThemeColors.white,
// //               size: 48,
// //             ),
// //             SizedBox(height: 2.h),
// //             const Text(
// //               'Camera access is needed to scan QR codes.\n'
// //               'You can still upload a QR from your gallery using '
// //               'the icon at the top.',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(color: ThemeColors.white, fontSize: 14),
// //             ),
// //             SizedBox(height: 2.h),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 final status = await Permission.camera.status;
// //                 if (status.isPermanentlyDenied) {
// //                   await openAppSettings();
// //                 } else {
// //                   onRetry();
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: ThemeColors.blue,
// //                 foregroundColor: ThemeColors.white,
// //               ),
// //               child: const Text('Grant Camera Access'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _ScannerMessage extends StatelessWidget {
// //   final String message;
// //
// //   const _ScannerMessage({required this.message});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Center(
// //       child: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 24),
// //         child: Text(
// //           message,
// //           textAlign: TextAlign.center,
// //           style: const TextStyle(color: ThemeColors.white, fontSize: 14),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// import '../../../../core/theme/app_text_styles.dart';
// import '../../../../core/theme/app_theme_colors.dart';
//
// import '../widgets/scanner_metrics.dart';
//
// class ScannerScreen extends StatefulWidget {
//   const ScannerScreen({super.key});
//
//   @override
//   State<ScannerScreen> createState() => _ScannerScreenState();
// }
//
// class _ScannerScreenState extends State<ScannerScreen> {
//   final MobileScannerController controller = MobileScannerController(
//     autoStart: false,
//   );
//
//   bool _isScanned = false;
//   final ImagePicker _picker = ImagePicker();
//
//   bool _permissionChecked = false;
//   bool _permissionGranted = false;
//
//   /// UI-only: torch button ka visual state
//   bool _torchOn = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestCameraPermission();
//   }
//
//   Future<void> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     if (!mounted) return;
//
//     setState(() {
//       _permissionChecked = true;
//       _permissionGranted = status.isGranted;
//     });
//
//     if (status.isGranted) {
//       await controller.start();
//     }
//   }
//
//   Future<void> _pickFromGallery() async {
//     _isScanned = false;
//
//     // On Android request storage/photos permission; iOS 14+ uses PHPickerViewController
//     // which manages its own access without a prior permission prompt.
//     if (Platform.isAndroid) {
//       final status = await Permission.photos.request();
//       if (!status.isGranted && !status.isLimited) return;
//     }
//
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//
//     if (image == null) return;
//
//     String? rawValue;
//     try {
//       final capture = await controller.analyzeImage(image.path);
//       if (capture != null && capture.barcodes.isNotEmpty) {
//         rawValue = capture.barcodes.first.rawValue;
//       }
//     } on UnsupportedError {
//       // mobile_scanner's Vision-based analyzeImage is hard-unsupported on
//       // the iOS Simulator (Apple GPU limitation) — it throws instead of
//       // returning null there. Fall back to a pure-Dart decode so gallery
//       // scanning still works while developing/testing on the simulator.
//       rawValue = await _decodeQrWithZxing(image.path);
//     } on MobileScannerBarcodeException {
//       rawValue = null;
//     } catch (_) {
//       rawValue = null;
//     }
//
//     if (rawValue == null) {
//       if (!mounted) return;
//       AppSnackbar.showError(context, 'No QR code found');
//       return;
//     }
//
//     await _processScannedValue(rawValue);
//   }
//
//   // Pure-Dart QR decode (no platform channel / native Vision API involved),
//   // used only when mobile_scanner's native analyzeImage is unavailable.
//   Future<String?> _decodeQrWithZxing(String path) async {
//     try {
//       final bytes = await File(path).readAsBytes();
//       final decoded = img.decodeImage(bytes);
//       if (decoded == null) return null;
//
//       final pixels = decoded
//           .convert(numChannels: 4)
//           .getBytes(order: img.ChannelOrder.abgr)
//           .buffer
//           .asInt32List();
//
//       final source = zx.RGBLuminanceSource(
//         decoded.width,
//         decoded.height,
//         pixels,
//       );
//       final bitmap = zx.BinaryBitmap(zx.GlobalHistogramBinarizer(source));
//
//       final result = zx.QRCodeReader().decode(bitmap);
//       return result.text;
//     } on zx.ReaderException {
//       return null;
//     } catch (_) {
//       return null;
//     }
//   }
//
//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _onDetect(BarcodeCapture capture) async {
//     if (capture.barcodes.isEmpty) return;
//     final rawValue = capture.barcodes.first.rawValue;
//     if (rawValue == null) return;
//     await _processScannedValue(rawValue);
//   }
//
//   // Shared by both the live camera detector and gallery-based scanning
//   // (native analyzeImage or the zxing2 fallback) — either path ends up
//   // with just the raw decoded QR string.
//   Future<void> _processScannedValue(String encryptedQr) async {
//     if (_isScanned) return;
//     _isScanned = true;
//
//     try {
//       final merchantEmail = EmailQrCodec.decrypt(encryptedQr);
//
//       await context.push(
//         AppRoutes.reviewPayment,
//         extra: {'merchantEmail': merchantEmail},
//       );
//
//       _isScanned = false;
//     } catch (_) {
//       if (!mounted) return;
//
//       AppSnackbar.showError(
//         context,
//         "Invalid QR code. Please scan a valid Bingo Vender's payment QR.",
//       );
//
//       // Guard against instant re-triggering while the error snackbar is up
//       // (e.g. the live camera keeps decoding the same bad QR frame-by-frame).
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) _isScanned = false;
//     }
//   }
//
//   void _toggleTorch() {
//     controller.toggleTorch();
//     setState(() => _torchOn = !_torchOn);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//
//     return Scaffold(
//       backgroundColor: c.background,
//       body: SafeArea(
//         bottom: false,
//         child: Builder(
//           builder: (context) {
//             final m = ScannerMetrics.of(context);
//
//             final banner = _SecureBanner(metrics: m);
//
//             final camera = _CameraArea(
//               metrics: m,
//               permissionGranted: _permissionGranted,
//               permissionChecked: _permissionChecked,
//               controller: controller,
//               torchOn: _torchOn,
//               onDetect: _onDetect,
//               onToggleTorch: _toggleTorch,
//               onGallery: _pickFromGallery,
//               onRetryPermission: _requestCameraPermission,
//             );
//
//             final help = _HowToScanCard(metrics: m);
//
//             final actions = _ScannerActionBar(
//               metrics: m,
//               torchOn: _torchOn,
//               onFlash: _permissionGranted ? _toggleTorch : null,
//               onScan: _permissionGranted ? null : _requestCameraPermission,
//               onMyQr: () {},
//             );
//
//             return Column(
//               children: [
//                 _ScannerTopBar(metrics: m),
//
//                 Expanded(
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(maxWidth: m.maxContentWidth),
//                       child: m.isLandscape
//                           ? _LandscapeBody(
//                         metrics: m,
//                         banner: banner,
//                         camera: camera,
//                         help: help,
//                         actions: actions,
//                       )
//                           : _PortraitBody(
//                         metrics: m,
//                         banner: banner,
//                         camera: camera,
//                         help: help,
//                         actions: actions,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// // ── Top bar ────────────────────────────────────────────────────────────────
// class _ScannerTopBar extends StatelessWidget {
//   final ScannerMetrics metrics;
//
//   const _ScannerTopBar({required this.metrics});
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return Padding(
//       padding: EdgeInsets.fromLTRB(
//         m.pageHPad * 0.4,
//         m.pageVPad * 0.5,
//         m.pageHPad,
//         m.pageVPad * 0.5,
//       ),
//       child: Row(
//         children: [
//           IconButton(
//             onPressed: () => context.canPop()
//                 ? context.pop()
//                 : context.go(AppRoutes.home),
//             splashRadius: m.backIconSize * 1.2,
//             icon: Icon(
//               Icons.arrow_back_ios_rounded,
//               size: m.backIconSize,
//               color: c.textPrimary,
//             ),
//           ),
//
//           Expanded(
//             child: Center(
//               child: Text(
//                 'Scan & Pay',
//                 style: AppTextStyles.titleLarge.copyWith(
//                   color: c.textPrimary,
//                   fontFamily: 'Inter',
//                   fontWeight: FontWeight.w700,
//                   fontSize: m.titleSize,
//                   height: 1.2,
//                 ),
//               ),
//             ),
//           ),
//
//           Material(
//             color: c.brandSoft,
//             borderRadius: BorderRadius.circular(m.chipHeight),
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: () => context.push(AppRoutes.buyerTransactions),
//               child: Container(
//                 height: m.chipHeight,
//                 padding: EdgeInsets.symmetric(horizontal: m.chipHPad * 0.7),
//                 alignment: Alignment.center,
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.history_rounded,
//                       size: m.chipFontSize + 4,
//                       color: c.brand,
//                     ),
//                     SizedBox(width: m.gapXs * 1.4),
//                     Text(
//                       'History',
//                       style: AppTextStyles.labelMedium.copyWith(
//                         color: c.brand,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w600,
//                         fontSize: m.chipFontSize,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Portrait ───────────────────────────────────────────────────────────────
// class _PortraitBody extends StatelessWidget {
//   final ScannerMetrics metrics;
//   final Widget banner;
//   final Widget camera;
//   final Widget help;
//   final Widget actions;
//
//   const _PortraitBody({
//     required this.metrics,
//     required this.banner,
//     required this.camera,
//     required this.help,
//     required this.actions,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final m = metrics;
//
//     return Column(
//       children: [
//         Expanded(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.fromLTRB(
//               m.pageHPad,
//               m.gapSm,
//               m.pageHPad,
//               m.gapMd,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 banner,
//                 SizedBox(height: m.gapMd),
//                 camera,
//                 SizedBox(height: m.gapMd),
//                 help,
//               ],
//             ),
//           ),
//         ),
//         actions,
//       ],
//     );
//   }
// }
//
// // ── Landscape: camera left, info right ─────────────────────────────────────
// class _LandscapeBody extends StatelessWidget {
//   final ScannerMetrics metrics;
//   final Widget banner;
//   final Widget camera;
//   final Widget help;
//   final Widget actions;
//
//   const _LandscapeBody({
//     required this.metrics,
//     required this.banner,
//     required this.camera,
//     required this.help,
//     required this.actions,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final m = metrics;
//
//     return Padding(
//       padding: EdgeInsets.fromLTRB(m.pageHPad, m.gapSm, m.pageHPad, 0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 6,
//             child: SingleChildScrollView(
//               padding: EdgeInsets.only(bottom: m.gapMd),
//               child: camera,
//             ),
//           ),
//
//           SizedBox(width: m.gapLg),
//
//           Expanded(
//             flex: 5,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         banner,
//                         SizedBox(height: m.gapMd),
//                         help,
//                       ],
//                     ),
//                   ),
//                 ),
//                 actions,
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Secure payments banner ─────────────────────────────────────────────────
// class _SecureBanner extends StatelessWidget {
//   final ScannerMetrics metrics;
//
//   const _SecureBanner({required this.metrics});
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return Container(
//       padding: EdgeInsets.all(m.bannerPad),
//       decoration: BoxDecoration(
//         color: c.brandSoft,
//         borderRadius: BorderRadius.circular(m.bannerRadius),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: m.bannerIconBox,
//             height: m.bannerIconBox,
//             decoration: BoxDecoration(
//               color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.7),
//               shape: BoxShape.circle,
//             ),
//             alignment: Alignment.center,
//             child: Icon(
//               Icons.lock_outline_rounded,
//               size: m.bannerIconSize,
//               color: c.brand,
//             ),
//           ),
//
//           SizedBox(width: m.bannerPad * 0.8),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Secure Payments',
//                   style: AppTextStyles.labelLarge.copyWith(
//                     color: c.brand,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w700,
//                     fontSize: m.bannerTitleSize,
//                     height: 1.3,
//                   ),
//                 ),
//                 SizedBox(height: m.gapXs * 0.6),
//                 Text(
//                   'Your payments are 100% safe and secure',
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: c.textSecondary,
//                     fontFamily: 'Inter',
//                     fontSize: m.bannerSubSize,
//                     height: 1.35,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Camera area ────────────────────────────────────────────────────────────
// class _CameraArea extends StatelessWidget {
//   final ScannerMetrics metrics;
//   final bool permissionGranted;
//   final bool permissionChecked;
//   final MobileScannerController controller;
//   final bool torchOn;
//   final Future<void> Function(BarcodeCapture) onDetect;
//   final VoidCallback onToggleTorch;
//   final VoidCallback onGallery;
//   final VoidCallback onRetryPermission;
//
//   const _CameraArea({
//     required this.metrics,
//     required this.permissionGranted,
//     required this.permissionChecked,
//     required this.controller,
//     required this.torchOn,
//     required this.onDetect,
//     required this.onToggleTorch,
//     required this.onGallery,
//     required this.onRetryPermission,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(m.cameraRadius),
//       child: Container(
//         height: m.cameraHeight,
//         color: Colors.black,
//         child: Stack(
//           children: [
//             // Camera / permission states
//             if (permissionGranted)
//               Positioned.fill(
//                 child: MobileScanner(
//                   controller: controller,
//                   onDetect: onDetect,
//                   errorBuilder: (context, error) =>
//                       _ScannerMessage(message: error.errorCode.message),
//                 ),
//               )
//             else if (permissionChecked)
//               Positioned.fill(
//                 child: _PermissionDeniedView(
//                   metrics: m,
//                   onRetry: onRetryPermission,
//                 ),
//               )
//             else
//               Positioned.fill(
//                 child: Center(
//                   child: CircularProgressIndicator(color: c.surface),
//                 ),
//               ),
//
//             // Frame + hint
//             if (permissionGranted)
//               Positioned.fill(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Position the QR code within the frame',
//                       textAlign: TextAlign.center,
//                       style: AppTextStyles.labelMedium.copyWith(
//                         color: Colors.white,
//                         fontFamily: 'Inter',
//                         fontWeight: FontWeight.w600,
//                         fontSize: m.hintFontSize,
//                       ),
//                     ),
//                     SizedBox(height: m.gapMd),
//                     SizedBox(
//                       width: m.frameSize,
//                       height: m.frameSize,
//                       child: CustomPaint(
//                         painter: _ScanFramePainter(
//                           corner: m.frameCorner,
//                           stroke: m.frameStroke,
//                           color: Colors.white,
//                           accent: c.brand,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//             // Torch (top-left)
//             if (permissionGranted)
//               Positioned(
//                 top: m.gapMd,
//                 left: m.gapMd,
//                 child: Material(
//                   color: Colors.black.withValues(alpha: 0.45),
//                   shape: const CircleBorder(),
//                   clipBehavior: Clip.antiAlias,
//                   child: InkWell(
//                     onTap: onToggleTorch,
//                     child: SizedBox(
//                       width: m.overlayBtnSize,
//                       height: m.overlayBtnSize,
//                       child: Icon(
//                         torchOn
//                             ? Icons.flash_on_rounded
//                             : Icons.flash_off_rounded,
//                         size: m.overlayIconSize,
//                         color: torchOn ? c.brand : Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//             // Scan from Gallery (top-right)
//             Positioned(
//               top: m.gapMd,
//               right: m.gapMd,
//               child: Material(
//                 color: Colors.black.withValues(alpha: 0.55),
//                 borderRadius: BorderRadius.circular(m.pillHeight),
//                 clipBehavior: Clip.antiAlias,
//                 child: InkWell(
//                   onTap: onGallery,
//                   child: Container(
//                     height: m.pillHeight,
//                     padding: EdgeInsets.symmetric(horizontal: m.gapMd * 0.9),
//                     alignment: Alignment.center,
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.photo_library_outlined,
//                           size: m.pillFontSize + 5,
//                           color: Colors.white,
//                         ),
//                         SizedBox(width: m.gapXs * 1.4),
//                         Text(
//                           'Scan from Gallery',
//                           style: AppTextStyles.labelMedium.copyWith(
//                             color: Colors.white,
//                             fontFamily: 'Inter',
//                             fontWeight: FontWeight.w600,
//                             fontSize: m.pillFontSize,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// Rounded corner brackets — image jaise 4 corners
// class _ScanFramePainter extends CustomPainter {
//   final double corner;
//   final double stroke;
//   final Color color;
//   final Color accent;
//
//   _ScanFramePainter({
//     required this.corner,
//     required this.stroke,
//     required this.color,
//     required this.accent,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = stroke
//       ..strokeCap = StrokeCap.round
//       ..style = PaintingStyle.stroke;
//
//     final r = corner * 0.5;
//
//     // Top-left
//     canvas.drawPath(
//       Path()
//         ..moveTo(0, corner)
//         ..lineTo(0, r)
//         ..quadraticBezierTo(0, 0, r, 0)
//         ..lineTo(corner, 0),
//       paint,
//     );
//
//     // Top-right
//     canvas.drawPath(
//       Path()
//         ..moveTo(size.width - corner, 0)
//         ..lineTo(size.width - r, 0)
//         ..quadraticBezierTo(size.width, 0, size.width, r)
//         ..lineTo(size.width, corner),
//       paint,
//     );
//
//     // Bottom-right
//     canvas.drawPath(
//       Path()
//         ..moveTo(size.width, size.height - corner)
//         ..lineTo(size.width, size.height - r)
//         ..quadraticBezierTo(
//           size.width,
//           size.height,
//           size.width - r,
//           size.height,
//         )
//         ..lineTo(size.width - corner, size.height),
//       paint,
//     );
//
//     // Bottom-left
//     canvas.drawPath(
//       Path()
//         ..moveTo(corner, size.height)
//         ..lineTo(r, size.height)
//         ..quadraticBezierTo(0, size.height, 0, size.height - r)
//         ..lineTo(0, size.height - corner),
//       paint,
//     );
//
//     // Scan line (middle)
//     canvas.drawLine(
//       Offset(0, size.height / 2),
//       Offset(size.width, size.height / 2),
//       Paint()
//         ..color = accent
//         ..strokeWidth = 2,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant _ScanFramePainter oldDelegate) =>
//       oldDelegate.corner != corner ||
//           oldDelegate.stroke != stroke ||
//           oldDelegate.color != color ||
//           oldDelegate.accent != accent;
// }
//
// // ── How to scan ────────────────────────────────────────────────────────────
// class _HowToScanCard extends StatelessWidget {
//   final ScannerMetrics metrics;
//
//   const _HowToScanCard({required this.metrics});
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return Container(
//       padding: EdgeInsets.all(m.helpPad),
//       decoration: BoxDecoration(
//         color: c.surface,
//         borderRadius: BorderRadius.circular(m.helpRadius),
//         border: Border.all(color: c.border, width: 1),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: m.helpIconBox,
//             height: m.helpIconBox,
//             decoration: BoxDecoration(
//               color: c.brandSoft,
//               shape: BoxShape.circle,
//             ),
//             alignment: Alignment.center,
//             child: Icon(
//               Icons.qr_code_2_rounded,
//               size: m.helpIconSize,
//               color: c.brand,
//             ),
//           ),
//
//           SizedBox(width: m.helpPad * 0.8),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'How to scan?',
//                   style: AppTextStyles.labelLarge.copyWith(
//                     color: c.brand,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w700,
//                     fontSize: m.helpTitleSize,
//                     height: 1.3,
//                   ),
//                 ),
//                 SizedBox(height: m.gapXs),
//                 Text(
//                   'Place the QR code inside the frame.\n'
//                       'It will be scanned automatically.',
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: c.textSecondary,
//                     fontFamily: 'Inter',
//                     fontSize: m.helpBodySize,
//                     height: 1.45,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Bottom action bar ──────────────────────────────────────────────────────
// class _ScannerActionBar extends StatelessWidget {
//   final ScannerMetrics metrics;
//   final bool torchOn;
//   final VoidCallback? onFlash;
//   final VoidCallback? onScan;
//   final VoidCallback onMyQr;
//
//   const _ScannerActionBar({
//     required this.metrics,
//     required this.torchOn,
//     required this.onFlash,
//     required this.onScan,
//     required this.onMyQr,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     Widget sideBtn({
//       required IconData icon,
//       required String label,
//       required VoidCallback? onTap,
//       bool active = false,
//     }) => Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         SizedBox(
//           width: m.actionBtnSize,
//           height: m.actionBtnSize,
//           child: Material(
//             color: active ? c.brandSoft : c.surface,
//             borderRadius: BorderRadius.circular(14),
//             clipBehavior: Clip.antiAlias,
//             child: InkWell(
//               onTap: onTap,
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(14),
//                   border: Border.all(color: c.border, width: 1),
//                 ),
//                 alignment: Alignment.center,
//                 child: Icon(
//                   icon,
//                   size: m.actionIconSize,
//                   color: onTap == null ? c.textMuted : c.brand,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: m.gapSm * 0.7),
//         Text(
//           label,
//           style: AppTextStyles.labelMedium.copyWith(
//             color: c.textSecondary,
//             fontFamily: 'Inter',
//             fontWeight: FontWeight.w500,
//             fontSize: m.actionLabelSize,
//           ),
//         ),
//       ],
//     );
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         m.pageHPad,
//         m.gapMd,
//         m.pageHPad,
//         m.gapSm * 0.5,
//       ),
//       decoration: BoxDecoration(
//         color: c.background,
//         border: Border(top: BorderSide(color: c.border, width: 1)),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             sideBtn(
//               icon: torchOn ? Icons.flash_on_rounded : Icons.flashlight_on_outlined,
//               label: 'Flash',
//               onTap: onFlash,
//               active: torchOn,
//             ),
//
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 SizedBox(
//                   width: m.scanBtnSize,
//                   height: m.scanBtnSize,
//                   child: Material(
//                     color: c.brand,
//                     shape: const CircleBorder(),
//                     clipBehavior: Clip.antiAlias,
//                     child: InkWell(
//                       onTap: onScan,
//                       child: Icon(
//                         Icons.qr_code_scanner_rounded,
//                         size: m.scanIconSize,
//                         color: c.surface,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: m.gapSm * 0.7),
//                 Text(
//                   'Scan',
//                   style: AppTextStyles.labelMedium.copyWith(
//                     color: c.brand,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w700,
//                     fontSize: m.actionLabelSize,
//                   ),
//                 ),
//               ],
//             ),
//
//             sideBtn(
//               icon: Icons.center_focus_strong_rounded,
//               label: 'My QR',
//               onTap: onMyQr,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ── Permission denied ──────────────────────────────────────────────────────
// class _PermissionDeniedView extends StatelessWidget {
//   final ScannerMetrics metrics;
//   final VoidCallback onRetry;
//
//   const _PermissionDeniedView({required this.metrics, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     final c = context.c;
//     final m = metrics;
//
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: m.pageHPad),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: m.helpIconBox * 1.4,
//               height: m.helpIconBox * 1.4,
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.12),
//                 shape: BoxShape.circle,
//               ),
//               alignment: Alignment.center,
//               child: Icon(
//                 Icons.no_photography_rounded,
//                 color: Colors.white,
//                 size: m.helpIconSize * 1.3,
//               ),
//             ),
//
//             SizedBox(height: m.gapMd),
//
//             Text(
//               'Camera access is needed to scan QR codes.\n'
//                   'You can still upload a QR from your gallery using '
//                   'the button at the top.',
//               textAlign: TextAlign.center,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: Colors.white,
//                 fontFamily: 'Inter',
//                 fontSize: m.helpBodySize,
//                 height: 1.45,
//               ),
//             ),
//
//             SizedBox(height: m.gapLg),
//
//             SizedBox(
//               height: m.pillHeight,
//               child: Material(
//                 color: c.brand,
//                 borderRadius: BorderRadius.circular(12),
//                 clipBehavior: Clip.antiAlias,
//                 child: InkWell(
//                   onTap: () async {
//                     final status = await Permission.camera.status;
//                     if (status.isPermanentlyDenied) {
//                       await openAppSettings();
//                     } else {
//                       onRetry();
//                     }
//                   },
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: m.gapLg),
//                     child: Center(
//                       child: Text(
//                         'Grant Camera Access',
//                         style: AppTextStyles.buttonText.copyWith(
//                           color: c.surface,
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w700,
//                           fontSize: m.pillFontSize,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ScannerMessage extends StatelessWidget {
//   final String message;
//
//   const _ScannerMessage({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Text(
//           message,
//           textAlign: TextAlign.center,
//           style: AppTextStyles.bodyMedium.copyWith(
//             color: Colors.white,
//             fontFamily: 'Inter',
//             fontSize: 14,
//           ),
//         ),
//       ),
//     );
//   }
// }