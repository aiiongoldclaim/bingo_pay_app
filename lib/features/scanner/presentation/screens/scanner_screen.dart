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


import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
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

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied && mounted) {
      await openAppSettings();
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

    final BarcodeCapture? capture = await controller.analyzeImage(image.path);

    if (capture == null || capture.barcodes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No QR code found")));
      return;
    }

    _onDetect(capture);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
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

      await context.push(
        AppRoutes.reviewPayment,
        extra: {'merchantEmail': merchantEmail},
      );

      _isScanned = false;
    } catch (e) {
      _isScanned = false;

      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("Invalid QR Code")));
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
 