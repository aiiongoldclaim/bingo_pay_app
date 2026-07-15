import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class ProductShareService {
  static const String _baseWebUrl = 'https://bingosg.com/products';

  /// Share a product using the native share dialog
  /// [productId] - The unique identifier of the product
  /// [productName] - The name of the product to display in the share message
  /// [productPrice] - The price of the product
  static Future<void> shareProduct({
    required String productId,
    required String productName,
    required String productPrice,
  }) async {
    try {
      if (productId.isEmpty || productName.isEmpty || productPrice.isEmpty) {
        developer.log('Invalid product data for sharing', name: 'ProductShareService');
        return;
      }

      final webLink = _generateWebLink(productId);
      final message = _generateShareMessage(
        productName,
        productPrice,
        webLink,
      );

      debugPrint('Sharing product: $productName with link: $webLink');

      if (Platform.isIOS) {
        // iOS: Share complete formatted message without subject
        // to ensure emojis and formatting are preserved
        await Share.share(message);
      } else {
        // Android: Use subject parameter
        await Share.share(
          message,
          subject: 'Check out this product: $productName',
        );
      }

      debugPrint('Share dialog opened successfully');
    } catch (e) {
      developer.log('Error sharing product: $e', name: 'ProductShareService', error: e);
      debugPrint('Share error: $e');
    }
  }

  /// Generate a web URL for the product
  static String _generateWebLink(String productId) {
    return '$_baseWebUrl/$productId';
  }

  /// Generate a formatted share message with emoji and details
  static String _generateShareMessage(
    String productName,
    String productPrice,
    String productLink,
  ) {
    return 'Check out this amazing product on BingoSG!\n\n'
        '📦 $productName\n'
        '💰 Price: $productPrice\n\n'
        'View here: $productLink';
  }
}
