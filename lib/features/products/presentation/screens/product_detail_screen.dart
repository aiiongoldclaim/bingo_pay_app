import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../models/product_detail_data.dart';

class ProductDetailScreen extends StatefulWidget {
  final String uuid;

  const ProductDetailScreen({super.key, required this.uuid});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductDetail> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture = _fetch();
  }

  Future<ProductDetail> _fetch() async {
    final ds = getIt<ProductRemoteDataSource>();
    final detailFuture = ds.getProductDetail(widget.uuid);
    final mediaFuture = ds.getProductMedia(widget.uuid).catchError((_) => <Map<String, dynamic>>[]);
    final specsFuture = ds.getProductSpecifications(widget.uuid).catchError((_) => <Map<String, dynamic>>[]);

    final json = await detailFuture;
    final mediaList = await mediaFuture;
    final specsList = await specsFuture;

    if (mediaList.isNotEmpty) json['media'] = mediaList;
    if (specsList.isNotEmpty) json['specifications'] = specsList;
    return ProductDetail.fromApi(json);
  }

  Future<void> _openEdit() async {
    await context.push(AppRoutes.vendorProductEditPath(widget.uuid));
    setState(() => _productFuture = _fetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A6B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          FutureBuilder<ProductDetail>(
            future: _productFuture,
            builder: (_, snap) => snap.hasData
                ? IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: _openEdit,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: FutureBuilder<ProductDetail>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: '${snapshot.error}',
              onRetry: () => setState(() => _productFuture = _fetch()),
            );
          }
          return _Body(product: snapshot.data!, onEdit: _openEdit);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Body extends StatefulWidget {
  final ProductDetail product;
  final VoidCallback onEdit;

  const _Body({required this.product, required this.onEdit});

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _pageController = PageController();
  int _currentImage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  ProductDetail get p => widget.product;

  @override
  Widget build(BuildContext context) {
    final allImages = p.media.map((m) => m.url).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image carousel ────────────────────────────────────────────────
          _ImageCarousel(
            images: allImages,
            controller: _pageController,
            currentIndex: _currentImage,
            onPageChanged: (i) => setState(() => _currentImage = i),
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status + featured ──────────────────────────────────────
                Row(
                  children: [
                    _StatusBadge(rawStatus: p.rawStatus),
                    if (p.isFeatured) ...[
                      const SizedBox(width: 8),
                      _Badge(label: 'Featured', bg: const Color(0xFFFFF3CD), fg: const Color(0xFF7D5A00)),
                    ],
                    const Spacer(),
                    if (p.createdAt != null)
                      Text(
                        DateFormat('d MMM y').format(p.createdAt!),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Title ─────────────────────────────────────────────────
                Text(
                  p.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.25),
                ),
                const SizedBox(height: 6),

                // ── Brand · Category ──────────────────────────────────────
                if (p.brand != null || p.category != null)
                  Text(
                    [
                      if (p.brand?.name.isNotEmpty == true) p.brand!.name,
                      if (p.category?.name.isNotEmpty == true) p.category!.name,
                    ].join('  ·  '),
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),

                const SizedBox(height: AppDimensions.md),
                const Divider(height: 1),
                const SizedBox(height: AppDimensions.md),

                // ── Quick metrics ─────────────────────────────────────────
                _MetricsRow(product: p),

                // ── Variants ──────────────────────────────────────────────
                if (p.variants.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _SectionTitle('Variants'),
                  const SizedBox(height: AppDimensions.sm),
                  ...p.variants.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                        child: _VariantCard(variant: v),
                      )),
                ],

                // ── Short description ──────────────────────────────────────
                if (p.shortDescription?.isNotEmpty == true) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _SectionTitle('Short description'),
                  const SizedBox(height: AppDimensions.sm),
                  _InfoCard(
                    child: Text(
                      p.shortDescription!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
                    ),
                  ),
                ],

                // ── Full description ──────────────────────────────────────
                if (p.description?.isNotEmpty == true) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _SectionTitle('Description'),
                  const SizedBox(height: AppDimensions.sm),
                  _ExpandableDescription(text: p.description!),
                ],

                // ── Specifications ────────────────────────────────────────
                if (p.specifications.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _SectionTitle('Specifications'),
                  const SizedBox(height: AppDimensions.sm),
                  _InfoCard(child: _SpecTable(specs: p.specifications)),
                ],

                // ── Gallery thumbnails ────────────────────────────────────
                if (allImages.length > 1) ...[
                  const SizedBox(height: AppDimensions.lg),
                  _SectionTitle('Gallery  (${allImages.length} images)'),
                  const SizedBox(height: AppDimensions.sm),
                  _GalleryRow(images: allImages, currentIndex: _currentImage, onTap: (i) {
                    _pageController.animateToPage(i,
                        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }),
                ],

                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Image carousel
// ---------------------------------------------------------------------------

class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ImageCarousel({
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 260,
          child: images.isEmpty
              ? Container(
                  color: AppColors.infoTint,
                  child: const Center(
                    child: Icon(Icons.image_outlined, color: AppColors.primary, size: 56),
                  ),
                )
              : PageView.builder(
                  controller: controller,
                  itemCount: images.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (_, i) => Image.network(
                    images[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.infoTint,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined, color: AppColors.primary, size: 48),
                      ),
                    ),
                  ),
                ),
        ),
        // Dots
        if (images.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == currentIndex ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == currentIndex ? AppColors.primary : Colors.white.withAlpha(180),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Metrics row
// ---------------------------------------------------------------------------

class _MetricsRow extends StatelessWidget {
  final ProductDetail product;
  const _MetricsRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final totalStock = product.variants.fold<int>(
      0,
      (sum, v) => sum + (int.tryParse((v['stock'] ?? v['stockQuantity'])?.toString() ?? '') ?? 0),
    );

    return Row(
      children: [
        _MetricTile(
          icon: Icons.layers_outlined,
          value: '${product.variants.length}',
          label: 'Variants',
        ),
        const SizedBox(width: AppDimensions.sm),
        _MetricTile(
          icon: Icons.inventory_2_outlined,
          value: '$totalStock',
          label: 'In Stock',
        ),
        const SizedBox(width: AppDimensions.sm),
        _MetricTile(
          icon: Icons.photo_library_outlined,
          value: '${product.media.length}',
          label: 'Images',
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Variant card
// ---------------------------------------------------------------------------

class _VariantCard extends StatelessWidget {
  final Map<String, dynamic> variant;
  const _VariantCard({required this.variant});

  @override
  Widget build(BuildContext context) {
    final title = variant['title']?.toString() ?? 'Default';
    final basePrice = double.tryParse(variant['basePrice']?.toString() ?? '');
    final salePrice = double.tryParse(variant['salePrice']?.toString() ?? '');
    final stock = int.tryParse((variant['stock'] ?? variant['stockQuantity'])?.toString() ?? '') ?? 0;
    final sku = variant['sku']?.toString() ?? '';
    final isDefault = variant['isDefault'] == true;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: isDefault ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      _Badge(label: 'Default', bg: AppColors.primary.withAlpha(20), fg: AppColors.primary),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (salePrice != null) ...[
                      Text(
                        '₹${salePrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      if (basePrice != null && basePrice > salePrice) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${basePrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${(((basePrice - salePrice) / basePrice) * 100).round()}% off',
                          style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ] else if (basePrice != null)
                      Text(
                        '₹${basePrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                  ],
                ),
                if (sku.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('SKU: $sku', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stock > 0 ? AppColors.successTint : const Color(0xFFFFEDED),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                ),
                child: Text(
                  stock > 0 ? '$stock in stock' : 'Out of stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: stock > 0 ? const Color(0xFF4C7A2D) : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spec table
// ---------------------------------------------------------------------------

class _SpecTable extends StatelessWidget {
  final List<Map<String, dynamic>> specs;
  const _SpecTable({required this.specs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < specs.length; i++) ...[
          if (i > 0) const Divider(height: 1, thickness: 0.5),
          _SpecRow(spec: specs[i]),
        ],
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  final Map<String, dynamic> spec;
  const _SpecRow({required this.spec});

  @override
  Widget build(BuildContext context) {
    final attrName = (spec['categoryAttribute'] as Map?)?['name']?.toString()
        ?? spec['name']?.toString()
        ?? '';
    final value = spec['value']?.toString() ?? '';
    if (attrName.isEmpty && value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(attrName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gallery row
// ---------------------------------------------------------------------------

class _GalleryRow extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GalleryRow({required this.images, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            width: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: i == currentIndex ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd - 2),
              child: Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.infoTint),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expandable description
// ---------------------------------------------------------------------------

class _ExpandableDescription extends StatefulWidget {
  final String text;
  const _ExpandableDescription({required this.text});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const maxLines = 4;
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : maxLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
          ),
          if (widget.text.length > 200) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? 'Show less' : 'Read more',
                style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final String rawStatus;
  const _StatusBadge({required this.rawStatus});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (rawStatus.toUpperCase()) {
      'ACTIVE' => (AppColors.successTint, const Color(0xFF4C7A2D), 'Active'),
      'DRAFT' => (const Color(0xFFEDEEF0), const Color(0xFF666666), 'Draft'),
      'PENDING_ADMIN_APPROVAL' => (const Color(0xFFFFF3CD), const Color(0xFF7D5A00), 'Pending Review'),
      'ARCHIVED' => (const Color(0xFFEDEEF0), const Color(0xFF666666), 'Archived'),
      'REJECTED' => (const Color(0xFFFFEDED), AppColors.error, 'Rejected'),
      _ => (const Color(0xFFEDEEF0), const Color(0xFF666666), rawStatus.isNotEmpty ? rawStatus : 'Draft'),
    };

    return _Badge(label: label, bg: bg, fg: fg);
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700));
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load product', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: AppDimensions.md),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
