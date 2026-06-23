import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/theme_colors.dart';
import '../../data/models/cart_model.dart';
import '../widgets/cart_bottom_bar.dart';
import '../widgets/cart_header.dart';
import '../widgets/cart_items_card.dart';
import '../widgets/coin_redemption_card.dart';
import '../widgets/coupen_card.dart';
import '../widgets/delivery_banner.dart';
import '../widgets/price_details.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const CartHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const FreeDeliveryBanner(),
                    SizedBox(height: 16),

                    CartItemsCard(
                      items: [
                        CartItemModel(
                          brand: 'SONARA',
                          name: 'Aurora Pro Wireless Headphones',
                          price: '₹18,990',
                          icon: Icons.headphones,
                        ),
                        CartItemModel(
                          brand: 'STRIDE',
                          name: 'Velvet Runner Knit Sneakers',
                          price: '₹6,490',
                          icon: Icons.hiking,
                        ),
                        CartItemModel(
                          brand: 'GLOW',
                          name: 'Nimbus Smart Desk Lamp',
                          price: '₹3,490',
                          icon: Icons.light,
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    const CouponCard(),

                    SizedBox(height: 16),

                    const CoinRedemptionCard(),

                    SizedBox(height: 16),

                    const PriceDetailsCard(),
                  ],
                ),
              ),
            ),

            const CartBottomBar(),
          ],
        ),
      ),
    );
  }
}
