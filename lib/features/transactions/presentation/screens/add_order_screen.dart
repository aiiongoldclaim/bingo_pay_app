import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../data/datasources/order_remote_datasource.dart';
import '../models/order_mock_data.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _OrderItemRow {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  PaymentType _payment = PaymentType.cod;
  final List<_OrderItemRow> _items = [_OrderItemRow()];
  bool _isSubmitting = false;

  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItemRow() => setState(() => _items.add(_OrderItemRow()));

  void _removeItemRow(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  double get _totalAmount {
    var total = 0.0;
    for (final item in _items) {
      final qty = int.tryParse(item.quantityController.text.trim()) ?? 0;
      final price = double.tryParse(item.priceController.text.trim()) ?? 0;
      total += qty * price;
    }
    return total;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    final items = _items
        .map(
          (item) => OrderItem(
            productName: item.nameController.text.trim(),
            quantity: int.tryParse(item.quantityController.text.trim()) ?? 0,
            price: double.tryParse(item.priceController.text.trim()) ?? 0,
          ),
        )
        .toList();

    final payload = {
      'customer_name': _customerNameController.text.trim(),
      'customer_phone': _customerPhoneController.text.trim(),
      'payment_type': _payment == PaymentType.paid ? 'paid' : 'cod',
      'status': OrderStatus.pending.name,
      'total_amount': _totalAmount,
      'items': items.map((e) => e.toApi()).toList(),
    };

    setState(() => _isSubmitting = true);
    try {
      await getIt<OrderRemoteDataSource>().addOrder(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order added')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add order: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2A6B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.md),
          children: [
            const _FieldLabel('Customer name', required: true),
            TextFormField(
              controller: _customerNameController,
              decoration: const InputDecoration(hintText: 'e.g. Rashi Khurana'),
              validator: Validators.name,
            ),
            const SizedBox(height: AppDimensions.lg),
            const _FieldLabel('Customer phone', required: true),
            TextFormField(
              controller: _customerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '10-digit mobile number'),
              validator: Validators.phone,
            ),
            const SizedBox(height: AppDimensions.lg),
            const _FieldLabel('Payment', required: true),
            _PaymentSegmentedControl(value: _payment, onChanged: (v) => setState(() => _payment = v)),
            const SizedBox(height: AppDimensions.lg),
            Row(
              children: [
                const Expanded(child: _FieldLabel('Items', required: true)),
                TextButton.icon(
                  onPressed: _addItemRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add item'),
                ),
              ],
            ),
            for (var i = 0; i < _items.length; i++)
              _ItemRowFields(
                row: _items[i],
                onRemove: _items.length > 1 ? () => _removeItemRow(i) : null,
                onChanged: () => setState(() {}),
              ),
            const SizedBox(height: AppDimensions.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total amount', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _currency.format(_totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size.fromHeight(48)),
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Add order'),
          ),
        ),
      ),
    );
  }
}

class _PaymentSegmentedControl extends StatelessWidget {
  final PaymentType value;
  final ValueChanged<PaymentType> onChanged;

  const _PaymentSegmentedControl({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Row(
        children: [
          for (final payment in PaymentType.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(payment),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: payment == value ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  ),
                  child: Text(
                    payment == PaymentType.cod ? 'COD' : 'Paid',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: payment == value ? Colors.white : Colors.grey[600],
                      fontWeight: payment == value ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ItemRowFields extends StatelessWidget {
  final _OrderItemRow row;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _ItemRowFields({required this.row, required this.onRemove, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.nameController,
                  decoration: const InputDecoration(hintText: 'Product name'),
                  validator: (v) => Validators.required(v, fieldName: 'Product name'),
                ),
              ),
              if (onRemove != null)
                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onRemove),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: row.quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Qty'),
                  onChanged: (_) => onChanged(),
                  validator: (v) {
                    final qty = int.tryParse(v?.trim() ?? '');
                    if (qty == null || qty <= 0) return 'Invalid qty';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: TextFormField(
                  controller: row.priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(prefixText: '₹ ', hintText: 'Price'),
                  onChanged: (_) => onChanged(),
                  validator: (v) {
                    final price = double.tryParse(v?.trim() ?? '');
                    if (price == null || price <= 0) return 'Invalid price';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _FieldLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: required ? const [TextSpan(text: ' *', style: TextStyle(color: AppColors.error))] : null,
        ),
      ),
    );
  }
}
