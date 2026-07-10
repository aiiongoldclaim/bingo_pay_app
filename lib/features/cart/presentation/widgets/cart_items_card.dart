import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemsCard extends StatefulWidget {
  final List<CartItemEntity> items;
  final Set<int> pendingItemIds;
  final void Function(CartItemEntity item) onIncrease;
  final void Function(CartItemEntity item) onDecrease;
  final void Function(CartItemEntity item) onDelete;

  const CartItemsCard({
    super.key,
    required this.items,
    this.pendingItemIds = const {},
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  State<CartItemsCard> createState() => _CartItemsCardState();
}

class _CartItemsCardState extends State<CartItemsCard> {
  final _listKey = GlobalKey<AnimatedListState>();
  late final List<CartItemEntity> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
  }

  @override
  void didUpdateWidget(covariant CartItemsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItems(widget.items);
  }

  void _syncItems(List<CartItemEntity> newItems) {
    for (var i = _items.length - 1; i >= 0; i--) {
      final id = _items[i].id;
      if (newItems.any((e) => e.id == id)) continue;
      final removed = _items.removeAt(i);
      _listKey.currentState?.removeItem(
        i,
        (context, animation) => _buildTile(removed, animation, index: i),
        duration: const Duration(milliseconds: 280),
      );
    }

    for (var i = 0; i < newItems.length; i++) {
      final existingIndex = _items.indexWhere((e) => e.id == newItems[i].id);
      if (existingIndex == -1) {
        _items.insert(i, newItems[i]);
        _listKey.currentState?.insertItem(
          i,
          duration: const Duration(milliseconds: 280),
        );
      } else {
        _items[existingIndex] = newItems[i];
      }
    }
  }

  Widget _buildTile(
    CartItemEntity item,
    Animation<double> animation, {
    required int index,
  }) {
    final isLast = index >= _items.length - 1;
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: animation,
        child: Column(
          children: [
            CartItemTile(
              item: item,
              isPending: widget.pendingItemIds.contains(item.id),
              onIncrease: () => widget.onIncrease(item),
              onDecrease: () => widget.onDecrease(item),
              onDelete: () => widget.onDelete(item),
            ),
            if (!isLast) Divider(height: 3.h, color: ThemeColors.line),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1D4E).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AnimatedList(
        key: _listKey,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        initialItemCount: _items.length,
        itemBuilder: (context, index, animation) =>
            _buildTile(_items[index], animation, index: index),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final bool isPending;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  const CartItemTile({
    super.key,
    required this.item,
    this.isPending = false,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnail = item.product.thumbnail;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isPending ? 0.5 : 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Image / Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 20.w,
              height: 20.w,
              color: ThemeColors.surface2,
              child: thumbnail != null
                  ? Image.network(
                      thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, e, st) => Icon(
                        Icons.shopping_bag_outlined,
                        color: ThemeColors.blue,
                        size: 10.w,
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      color: ThemeColors.blue,
                      size: 10.w,
                    ),
            ),
          ),

          SizedBox(width: 3.w),

          /// Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.vendor.shopName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: ThemeColors.inkDim,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: isPending ? null : onDelete,
                      child: Icon(
                        Icons.delete_outline,
                        size: 18.sp,
                        color: ThemeColors.inkDim,
                      ),
                    ),
                  ],
                ),

                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 0.5.h),

                Row(
                  children: [
                    Text(
                      '\$${item.unitPrice.toStringAsFixed(0)}',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.sp,
                      ),
                    ),
                    const Spacer(),
                    // Quantity controls
                    Container(
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D4E),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: isPending
                          ? SizedBox(
                              width: 18.w,
                              child: const Center(
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: onDecrease,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.w),
                                  child: Text(
                                    '${item.quantity}',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: onIncrease,
                                ),
                              ],
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: Icon(icon, size: 16.sp, color: Colors.white),
      ),
    );
  }
}
