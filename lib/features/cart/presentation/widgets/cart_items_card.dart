import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'cart_metrics.dart';

class CartItemsCard extends StatefulWidget {
  final List<CartItemEntity> items;
  final Set<int> deselectedIds;
  final Set<int> pendingItemIds;
  final void Function(CartItemEntity item) onToggleSelect;
  final void Function(CartItemEntity item) onMoveToWishlist;
  final void Function(CartItemEntity item) onIncrease;
  final void Function(CartItemEntity item) onDecrease;
  final void Function(CartItemEntity item) onDelete;

  const CartItemsCard({
    super.key,
    required this.items,
    this.deselectedIds = const {},
    this.pendingItemIds = const {},
    required this.onToggleSelect,
    required this.onMoveToWishlist,
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
    final m = CartMetrics.of(context);
    final isLast = index >= _items.length - 1;

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: animation,
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : m.gapMd),
          child: CartItemTile(
            item: item,
            metrics: m,
            isSelected: !widget.deselectedIds.contains(item.id),
            isPending: widget.pendingItemIds.contains(item.id),
            onToggleSelect: () => widget.onToggleSelect(item),
            onMoveToWishlist: () => widget.onMoveToWishlist(item),
            onIncrease: () => widget.onIncrease(item),
            // qty 1 par decrease -> item remove
            onDecrease: () => item.quantity <= 1
                ? widget.onDelete(item)
                : widget.onDecrease(item),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) =>
          _buildTile(_items[index], animation, index: index),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItemEntity item;
  final CartMetrics metrics;
  final bool isSelected;
  final bool isPending;
  final VoidCallback onToggleSelect;
  final VoidCallback onMoveToWishlist;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemTile({
    super.key,
    required this.item,
    required this.metrics,
    this.isSelected = true,
    this.isPending = false,
    required this.onToggleSelect,
    required this.onMoveToWishlist,
    required this.onIncrease,
    required this.onDecrease,
  });

  String? get _sizeLabel {
    for (final a in item.variant.attributes) {
      if (a.attribute.toLowerCase().contains('size')) return a.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isPending ? 0.5 : (isSelected ? 1 : 0.6),
      child: Container(
        padding: EdgeInsets.all(m.cardPad),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          border: Border.all(color: colors.border, width: 1),
          boxShadow: colors.isDark
              ? null
              : [
                  BoxShadow(
                    color: colors.textPrimary.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          // Checkbox vertically center
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SelectBox(
              isSelected: isSelected,
              metrics: m,
              onTap: onToggleSelect,
            ),

            SizedBox(width: m.cardPad * 0.7),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(item: item, metrics: m),

                  SizedBox(width: m.cardPad * 0.8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Brand + name + meta  |  price ────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.vendor.shopName.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: colors.textPrimary,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      fontSize: m.brandSize,
                                      letterSpacing: 0.2,
                                      height: 1.25,
                                    ),
                                  ),
                                  SizedBox(height: m.gapXs),
                                  Text(
                                    item.product.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: colors.textSecondary,
                                      fontFamily: 'Inter',
                                      fontSize: m.titleSize,
                                      height: 1.3,
                                    ),
                                  ),
                                  SizedBox(height: m.gapSm),
                                  _MetaRow(
                                    item: item,
                                    size: _sizeLabel,
                                    metrics: m,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(width: m.gapSm),

                            Text(
                              '\$${item.unitPrice.toStringAsFixed(2)}',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: colors.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                fontSize: m.priceSize,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: m.gapMd * 0.8),

                        // ── Move to Wishlist  |  qty stepper (same row) ──
                        Row(
                          children: [
                            Flexible(
                              child: _OutlineAction(
                                icon: Icons.favorite_border_rounded,
                                label: AppStrings.moveToWishlist,
                                metrics: m,
                                onTap: isPending ? null : onMoveToWishlist,
                              ),
                            ),
                            SizedBox(width: m.gapSm),
                            _QtyStepper(
                              quantity: item.quantity,
                              metrics: m,
                              isPending: isPending,
                              onIncrease: onIncrease,
                              onDecrease: onDecrease,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectBox extends StatelessWidget {
  final bool isSelected;
  final CartMetrics metrics;
  final VoidCallback onTap;

  const _SelectBox({
    required this.isSelected,
    required this.metrics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: m.checkboxSize,
        height: m.checkboxSize,
        decoration: BoxDecoration(
          color: isSelected ? colors.brand : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? colors.brand : colors.border,
            width: 1.5,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check_rounded,
                size: m.checkboxSize * 0.72,
                color: colors.surface,
              )
            : null,
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final CartItemEntity item;
  final CartMetrics metrics;

  const _Thumbnail({required this.item, required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final thumbnail = item.product.thumbnail;

    final fallback = Icon(
      Icons.shopping_bag_outlined,
      color: colors.brand,
      size: m.thumbSize * 0.36,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(m.thumbRadius),
      child: Container(
        width: m.thumbSize,
        height: m.thumbSize * 1.15,
        color: colors.surfaceAlt,
        alignment: Alignment.center,
        child: thumbnail != null
            ? Image.network(
                thumbnail,
                fit: BoxFit.cover,
                width: m.thumbSize,
                height: m.thumbSize * 1.15,
                errorBuilder: (ctx, e, st) => fallback,
              )
            : fallback,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final CartItemEntity item;
  final String? size;
  final CartMetrics metrics;

  const _MetaRow({
    required this.item,
    required this.size,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      children: [
        if (size != null) ...[
          _Meta(label: 'Size:', value: size!, metrics: m),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: m.gapSm * 0.8),
            child: Text(
              '|',
              style: TextStyle(color: colors.border, fontSize: m.metaSize),
            ),
          ),
        ],
        _Meta(label: 'Qty:', value: '${item.quantity}', metrics: m),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  final String label;
  final String value;
  final CartMetrics metrics;

  const _Meta({
    required this.label,
    required this.value,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.metaSize,
          ),
        ),
        SizedBox(width: m.gapSm * 0.4),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: m.metaSize,
          ),
        ),
      ],
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final CartMetrics metrics;
  final VoidCallback? onTap;

  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.metrics,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: m.actionHeight,
          padding: EdgeInsets.symmetric(horizontal: m.gapSm * 1.1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: m.actionIconSize, color: colors.textSecondary),
              SizedBox(width: m.gapSm * 0.5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: m.actionFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final CartMetrics metrics;
  final bool isPending;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _QtyStepper({
    required this.quantity,
    required this.metrics,
    required this.isPending,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    // qty 1 par minus ka matlab "remove" — icon delete dikhata hai
    final isRemoveMode = quantity <= 1;

    return Container(
      height: m.qtyBoxHeight,
      width: m.qtyBoxWidth,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QtyButton(
            icon: isRemoveMode ? Icons.delete_outline_rounded : Icons.remove,
            metrics: m,
            color: isRemoveMode ? colors.statusWarning : null,
            onTap: isPending ? null : onDecrease,
          ),
          Text(
            '$quantity',
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.qtyFontSize,
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            metrics: m,
            onTap: isPending ? null : onIncrease,
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final CartMetrics metrics;
  final Color? color;
  final VoidCallback? onTap;

  const _QtyButton({
    required this.icon,
    required this.metrics,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: m.qtyBoxHeight,
        height: m.qtyBoxHeight,
        child: Icon(
          icon,
          size: m.qtyIconSize,
          color: onTap == null ? colors.textMuted : (color ?? colors.textPrimary),
        ),
      ),
    );
  }
}
