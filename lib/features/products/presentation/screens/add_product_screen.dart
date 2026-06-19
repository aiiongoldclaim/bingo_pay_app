import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/slugify.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../models/product_form_data.dart';
import '../models/product_mock_data.dart';
import '../widgets/add_product/info_step.dart';
import '../widgets/add_product/media_step.dart';
import '../widgets/add_product/pricing_step.dart';
import '../widgets/add_product/publish_step.dart';
import '../widgets/add_product/stock_step.dart';

const List<String> _stepLabels = ['Info', 'Pricing', 'Stock', 'Media', 'Publish'];

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int _step = 0;
  final _draft = ProductDraft();

  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());

  final _nameController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _fullDescriptionController = TextEditingController();
  final _brandController = TextEditingController();

  final _mrpController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();

  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _lowStockThresholdController = TextEditingController(text: '10');

  final _videoLinkController = TextEditingController();

  final _scheduledPublishController = TextEditingController(text: 'Publish immediately');
  final _hsnCodeController = TextEditingController();
  final _countryOfOriginController = TextEditingController(text: 'India');
  final _shippingWeightController = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _nameController,
      _shortDescriptionController,
      _fullDescriptionController,
      _brandController,
      _mrpController,
      _sellingPriceController,
      _costPriceController,
      _skuController,
      _barcodeController,
      _lowStockThresholdController,
      _videoLinkController,
      _scheduledPublishController,
      _hsnCodeController,
      _countryOfOriginController,
      _shippingWeightController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onDraftChanged() => setState(() {});

  String _suggestSku(String name) {
    final slug = slugify(name);
    final firstWord = slug.split('-').firstOrNull ?? 'SKU';
    final prefix = (firstWord.length >= 3 ? firstWord.substring(0, 3) : firstWord.padRight(3, 'x')).toUpperCase();
    final suffix = 1000 + Random().nextInt(9000);
    return '$prefix-$suffix';
  }

  void _next() {
    if (!_formKeys[_step].currentState!.validate()) return;
    if (_step >= 4) return;
    final nextStep = _step + 1;
    if (nextStep == 2 && _skuController.text.trim().isEmpty && _nameController.text.trim().isNotEmpty) {
      _skuController.text = _suggestSku(_nameController.text);
    }
    setState(() => _step = nextStep);
  }

  void _previous() {
    if (_step > 0) setState(() => _step--);
  }

  void _submit({required ProductStatus status}) {
    if (!_formKeys[_step].currentState!.validate()) return;

    final mrp = double.tryParse(_mrpController.text.trim());
    final sellingPrice = double.tryParse(_sellingPriceController.text.trim());
    final discountPercent = (mrp != null && sellingPrice != null && sellingPrice < mrp && mrp > 0)
        ? (((mrp - sellingPrice) / mrp) * 100).round()
        : null;

    final lowStockThreshold = int.tryParse(_lowStockThresholdController.text.trim()) ?? 10;
    final stock = !_draft.trackInventory
        ? const StockInfo.inStock()
        : _draft.stockQty <= 0
        ? const StockInfo.outOfStock()
        : _draft.stockQty <= lowStockThreshold
        ? StockInfo.lowStock(_draft.stockQty)
        : const StockInfo.inStock();

    final product = Product(
      name: _nameController.text.trim(),
      sku: _skuController.text.trim(),
      category: _draft.category ?? '',
      price: sellingPrice,
      discountPercent: discountPercent,
      status: status,
      stock: stock,
    );

    ProductRepository.instance.addProduct(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status == ProductStatus.draft ? 'Saved as draft' : 'Product published')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A6B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimensions.md, AppDimensions.md, AppDimensions.md, AppDimensions.sm),
            child: StepIndicator(
              currentStep: _step,
              totalSteps: 5,
              stepLabels: _stepLabels,
              onStepTapped: (step) => setState(() => _step = step),
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
        brandController: _brandController,
        draft: _draft,
        onDraftChanged: _onDraftChanged,
      ),
      1 => PricingStep(
        formKey: _formKeys[1],
        mrpController: _mrpController,
        sellingPriceController: _sellingPriceController,
        costPriceController: _costPriceController,
        draft: _draft,
        onDraftChanged: _onDraftChanged,
      ),
      2 => StockStep(
        formKey: _formKeys[2],
        skuController: _skuController,
        barcodeController: _barcodeController,
        lowStockThresholdController: _lowStockThresholdController,
        draft: _draft,
        onDraftChanged: _onDraftChanged,
      ),
      3 => MediaStep(
        formKey: _formKeys[3],
        videoLinkController: _videoLinkController,
        draft: _draft,
        onDraftChanged: _onDraftChanged,
      ),
      _ => PublishStep(
        formKey: _formKeys[4],
        scheduledPublishController: _scheduledPublishController,
        hsnCodeController: _hsnCodeController,
        countryOfOriginController: _countryOfOriginController,
        shippingWeightController: _shippingWeightController,
        draft: _draft,
        onDraftChanged: _onDraftChanged,
      ),
    };
  }

  Widget _buildBottomBar() {
    final isLastStep = _step == 4;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLastStep ? () => _submit(status: ProductStatus.draft) : (_step > 0 ? _previous : null),
              child: Text(isLastStep ? 'Save as draft' : 'Previous'),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: isLastStep ? () => _submit(status: ProductStatus.active) : _next,
              child: Text(isLastStep ? 'Publish' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}
