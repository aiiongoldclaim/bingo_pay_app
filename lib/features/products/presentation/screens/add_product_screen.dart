import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/models/category_form_model.dart';
import '../../data/models/category_model.dart';
import '../models/product_form_data.dart';
import '../widgets/add_product/info_step.dart';
import '../widgets/add_product/media_step.dart';
import '../widgets/add_product/pricing_stock_step.dart';
import '../widgets/add_product/publish_step.dart';
import '../widgets/add_product/specifications_step.dart';

const List<String> _allStepLabels = [
  'Info',
  'Spec',
  'Variant',
  'Media',
  'Publish',
];

class AddProductScreen extends StatefulWidget {
  final String? productId;

  const AddProductScreen({super.key, this.productId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int _step = 0;
  bool _isSubmitting = false;
  bool _isStepSaving = false;
  bool _submittingReview = false;
  bool _isLoadingInitial = false;
  final _draft = ProductDraft();
  CategoryFormData? _formData;
  String? _productId;

  bool get _hasSpecStep => _formData?.hasSpecifications == true;

  List<int> get _activeStepIndices =>
      _hasSpecStep ? [0, 1, 2, 3, 4] : [0, 2, 3, 4];

  List<String> get _activeStepLabels =>
      _activeStepIndices.map((i) => _allStepLabels[i]).toList();

  int get _displayStep {
    final idx = _activeStepIndices.indexOf(_step);
    return idx < 0 ? 0 : idx;
  }

  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  final _nameController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _fullDescriptionController = TextEditingController();

  final _videoLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productId = widget.productId;
    if (widget.productId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _isLoadingInitial = true);
    try {
      final ds = getIt<ProductRemoteDataSource>();
      final data = await ds.getProductDetail(widget.productId!);
      if (!mounted) return;

      _nameController.text = data['title']?.toString() ?? '';
      _shortDescriptionController.text =
          data['shortDescription']?.toString() ?? '';
      _fullDescriptionController.text = data['description']?.toString() ?? '';
      final brandJson = data['brand'] as Map<String, dynamic>?;
      if (brandJson != null) {
        _draft.brand = brandJson['name']?.toString();
        _draft.brandUuid = brandJson['uuid']?.toString();
      }

      final categoryJson = data['category'] as Map<String, dynamic>?;
      if (categoryJson != null) {
        final catUuid = categoryJson['uuid']?.toString();
        final catName = categoryJson['name']?.toString() ?? '';
        final tree = await ds.getCategoryTree();
        final isRoot = tree.any((c) => c.uuid == catUuid);
        if (isRoot) {
          _draft.categoryUuid = catUuid;
          _draft.category = catName;
        } else {
          CategoryModel? parent;
          for (final root in tree) {
            if (root.children.any((c) => c.uuid == catUuid)) {
              parent = root;
              break;
            }
          }
          if (parent != null) {
            _draft.categoryUuid = parent.uuid;
            _draft.category = parent.name;
          }
          _draft.subCategoryUuid = catUuid;
          _draft.subCategory = catName;
        }
      }

      _draft.featured = data['isFeatured'] == true;

      final media = (data['media'] as List? ?? [])
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
      final sorted = [...media]
        ..sort(
          (a, b) => (b['isPrimary'] == true ? 1 : 0).compareTo(
            a['isPrimary'] == true ? 1 : 0,
          ),
        );
      for (final m in sorted) {
        final url = m['url']?.toString();
        if (url == null || url.isEmpty) continue;
        _draft.imagePaths.add(url);
        final id = m['id']?.toString();
        if (id != null) _draft.imageMediaIds[url] = id;
      }

      try {
        final variants = await ds.getProductVariants(widget.productId!);
        for (final v in variants) {
          final stock = v['stock'] ?? v['stockQuantity'];
          final attributeValues = <String, String>{};
          final attrs = v['attributes'];
          if (attrs is List) {
            for (final a in attrs) {
              if (a is! Map) continue;
              final attrUuid = a['attributeUuid']?.toString();
              final value = a['optionId'] ?? a['value'];
              if (attrUuid != null && value != null) {
                attributeValues[attrUuid] = value.toString();
              }
            }
          }
          _draft.variants.add(
            VariantDraft(
              uuid: v['uuid']?.toString(),
              title: v['title']?.toString() ?? '',
              basePrice: double.tryParse(v['basePrice']?.toString() ?? ''),
              salePrice: double.tryParse(v['salePrice']?.toString() ?? ''),
              costPrice: double.tryParse(v['costPrice']?.toString() ?? ''),
              sku: v['sku']?.toString() ?? '',
              barcode: v['barcode']?.toString() ?? '',
              stock: stock != null ? (stock as num).toInt() : 0,
              isDefault: v['isDefault'] == true,
              attributeValues: attributeValues,
            ),
          );
        }
      } catch (_) {
        // variants not yet created
      }

      // Load category form + existing specs in parallel
      final categoryUuid = _draft.subCategoryUuid ?? _draft.categoryUuid;
      if (categoryUuid != null) {
        try {
          final results = await Future.wait([
            ds.getCategoryForm(categoryUuid),
            ds.getProductSpecifications(widget.productId!),
          ]);
          final form = results[0] as CategoryFormData;
          final specs = results[1] as List<Map<String, dynamic>>;
          for (final spec in specs) {
            final catAttrId = spec['categoryAttributeId']?.toString();
            final value = spec['value']?.toString() ?? '';
            if (catAttrId != null && value.isNotEmpty) {
              final attr = form.specificationAttributes
                  .where((a) => a.id == catAttrId)
                  .firstOrNull;
              if (attr != null) _draft.specifications[attr.uuid] = value;
            }
          }
          if (mounted) setState(() => _formData = form);
        } catch (_) {
          // non-fatal — proceed without spec step
        }
      }

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load product: ${friendlyErrorMessage(e)}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _shortDescriptionController,
      _fullDescriptionController,
      _videoLinkController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDraftChanged() => setState(() {});

  Future<void> _loadCategoryForm() async {
    final categoryUuid = _draft.subCategoryUuid ?? _draft.categoryUuid;
    if (categoryUuid == null) return;
    try {
      final form = await getIt<ProductRemoteDataSource>().getCategoryForm(
        categoryUuid,
      );
      if (mounted) setState(() => _formData = form);
    } catch (_) {
      // non-fatal — proceed without spec step
    }
  }

  Future<void> _next() async {
    if (_isStepSaving) return;
    if (_formKeys[_step].currentState?.validate() == false) return;

    final active = _activeStepIndices;
    final pos = active.indexOf(_step);
    if (pos >= active.length - 1) return;

    if (_step == 2 && _draft.variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one variant to continue')),
      );
      return;
    }

    setState(() => _isStepSaving = true);
    try {
      if (_step == 0) {
        // Load form data when leaving Info step so Spec/Variant steps know their fields
        await _loadCategoryForm();
        if (!mounted) return;
        if (_productId != null) {
          await _patchStep(0);
        } else {
          await _createProduct();
        }
      } else if (_step == 1 && _productId != null) {
        await _saveSpecifications();
      } else if (_productId != null) {
        await _patchStep(_step);
      }

      if (!mounted) return;
      // Recompute — _loadCategoryForm() above may have just changed _hasSpecStep.
      final updatedActive = _activeStepIndices;
      final updatedPos = updatedActive.indexOf(_step);
      if (updatedPos < 0 || updatedPos >= updatedActive.length - 1) return;
      setState(() => _step = updatedActive[updatedPos + 1]);
    } finally {
      if (mounted) setState(() => _isStepSaving = false);
    }
  }

  Future<void> _createProduct() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'title': _nameController.text.trim(),
        'shortDescription': _shortDescriptionController.text.trim(),
        'description': _fullDescriptionController.text.trim(),
        'categoryUuid': _draft.subCategoryUuid ?? _draft.categoryUuid,
        if (_draft.brandUuid != null) 'brandUuid': _draft.brandUuid,
      };
      final result = await getIt<ProductRemoteDataSource>().createProduct(
        payload,
      );
      _productId = result['uuid']?.toString();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to create product: ${friendlyErrorMessage(e)}',
            ),
          ),
        );
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _saveSpecifications() async {
    if (_draft.specifications.isEmpty) return;
    try {
      await getIt<ProductRemoteDataSource>().saveSpecifications(
        _productId!,
        _draft.specifications,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save specifications: ${friendlyErrorMessage(e)}',
            ),
          ),
        );
      }
      rethrow;
    }
  }

  Future<({String url, String id})?> _onFirstImageAdded(
    String imagePath,
  ) async {
    if (_productId == null) return null;
    try {
      final result = await getIt<ProductRemoteDataSource>().uploadThumbnail(
        _productId!,
        imagePath,
        altText: _nameController.text.trim(),
      );
      final url = result['url']?.toString();
      final id = result['id']?.toString();
      if (url == null || id == null) return null;
      return (url: url, id: id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload thumbnail: ${friendlyErrorMessage(e)}',
            ),
          ),
        );
      }
      return null;
    }
  }

  Future<List<({String url, String id})>> _onGalleryImagesAdded(
    List<String> imagePaths,
  ) async {
    if (_productId == null) return [];
    try {
      final items = await getIt<ProductRemoteDataSource>().uploadGalleryWithIds(
        _productId!,
        imagePaths,
      );
      return items
          .map((item) {
            final url = item['url']?.toString();
            final id = item['id']?.toString();
            if (url == null || id == null) return null;
            return (url: url, id: id);
          })
          .whereType<({String url, String id})>()
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload images: ${friendlyErrorMessage(e)}',
            ),
          ),
        );
      }
      return [];
    }
  }

  Future<void> _onImageDeleted(String mediaId) async {
    await getIt<ProductRemoteDataSource>().deleteMedia(mediaId);
  }

  Future<({String url, String id})?> _onReplaceFirstImage(
    String imagePath,
  ) async {
    if (_productId == null) return null;
    try {
      final result = await getIt<ProductRemoteDataSource>().replaceThumbnail(
        _productId!,
        imagePath,
      );
      final url = result['url']?.toString();
      final id = result['id']?.toString();
      if (url == null || id == null) return null;
      return (url: url, id: id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to replace thumbnail: ${friendlyErrorMessage(e)}',
            ),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _onVariantSaved(VariantDraft variant) async {
    if (_productId == null) return;
    final ds = getIt<ProductRemoteDataSource>();
    if (variant.uuid != null) {
      await ds.updateVariant(_productId!, variant.uuid!, variant.toPayload());
    } else {
      final result = await ds.createVariant(_productId!, variant.toPayload());
      variant.uuid = result['uuid']?.toString();
    }
  }

  Future<void> _patchStep(int step) async {
    if (_isSubmitting) return;
    if (step == 1) return; // variants are saved individually on sheet Save
    setState(() => _isSubmitting = true);
    try {
      final payload = _buildStepPayload(step);
      if (payload.isNotEmpty) {
        await getIt<ProductRemoteDataSource>().updateProduct(
          _productId!,
          payload,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${friendlyErrorMessage(e)}')),
        );
      }
      rethrow;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Map<String, dynamic> _buildStepPayload(int step) {
    return switch (step) {
      0 => {
        'title': _nameController.text.trim(),
        if (_shortDescriptionController.text.trim().isNotEmpty)
          'shortDescription': _shortDescriptionController.text.trim(),
        if (_fullDescriptionController.text.trim().isNotEmpty)
          'description': _fullDescriptionController.text.trim(),
        if (_draft.subCategoryUuid != null || _draft.categoryUuid != null)
          'categoryUuid': _draft.subCategoryUuid ?? _draft.categoryUuid,
        if (_draft.brandUuid != null) 'brandUuid': _draft.brandUuid,
      },
      _ => {},
    };
  }

  void _previous() {
    final active = _activeStepIndices;
    final pos = active.indexOf(_step);
    if (pos > 0) setState(() => _step = active[pos - 1]);
  }

  Future<void> _submit({required bool submitForReview}) async {
    if (_formKeys[_step].currentState?.validate() == false) return;
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _submittingReview = submitForReview;
    });

    try {
      if (submitForReview && _productId != null) {
        await getIt<ProductRemoteDataSource>().submitProduct(_productId!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            submitForReview ? 'Product submitted for review' : 'Saved as draft',
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save product: ${friendlyErrorMessage(e)}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.productId != null ? 'Edit Product' : 'Add Product',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    AppDimensions.md,
                    AppDimensions.md,
                    AppDimensions.sm,
                  ),
                  child: StepIndicator(
                    currentStep: _displayStep,
                    totalSteps: _activeStepIndices.length,
                    stepLabels: _activeStepLabels,
                    onStepTapped: (i) =>
                        setState(() => _step = _activeStepIndices[i]),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    child: _buildStep(),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => InfoStep(
        formKey: _formKeys[0],
        nameController: _nameController,
        shortDescriptionController: _shortDescriptionController,
        fullDescriptionController: _fullDescriptionController,
        draft: _draft,
        onDraftChanged: _onDraftChanged,
      ),
      1 => SpecificationsStep(
        formKey: _formKeys[1],
        draft: _draft,
        attributes: _formData?.specificationAttributes ?? [],
      ),
      2 => PricingStockStep(
        formKey: _formKeys[2],
        draft: _draft,
        onDraftChanged: _onDraftChanged,
        variantAttributes: _formData?.variantAttributes ?? [],
        onVariantSaved: _productId != null ? _onVariantSaved : null,
      ),
      3 => MediaStep(
        formKey: _formKeys[3],
        videoLinkController: _videoLinkController,
        draft: _draft,
        onDraftChanged: _onDraftChanged,
        onFirstImageAdded: _productId != null ? _onFirstImageAdded : null,
        onGalleryImagesAdded: _productId != null ? _onGalleryImagesAdded : null,
        onImageDeleted: _productId != null ? _onImageDeleted : null,
        onReplaceFirstImage: _productId != null ? _onReplaceFirstImage : null,
      ),
      _ => PublishStep(
        formKey: _formKeys[4],
        productName: _nameController.text,
        shortDescription: _shortDescriptionController.text,
        draft: _draft,
      ),
    };
  }

  Widget _buildBottomBar() {
    final isLastStep = _displayStep == _activeStepIndices.length - 1;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isLastStep) ...[
            Expanded(
              child: AppButton(
                label: 'Save as draft',
                variant: AppButtonVariant.outlined,
                isLoading: _isSubmitting && !_submittingReview,
                onPressed: _isSubmitting
                    ? null
                    : () => _submit(submitForReview: false),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
          ] else if (_displayStep > 0) ...[
            Expanded(
              child: AppButton(
                label: 'Previous',
                variant: AppButtonVariant.outlined,
                onPressed: _isStepSaving ? null : _previous,
              ),
            ),
            const SizedBox(width: AppDimensions.md),
          ],
          Expanded(
            child: AppButton(
              label: isLastStep ? 'Submit' : 'Next',
              isLoading: isLastStep
                  ? _isSubmitting && _submittingReview
                  : _isStepSaving,
              onPressed: _isSubmitting
                  ? null
                  : isLastStep
                  ? () => _submit(submitForReview: true)
                  : _next,
            ),
          ),
        ],
      ),
    );
  }
}
