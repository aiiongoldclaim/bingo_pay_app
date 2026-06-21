import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/email_qr_sheet.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/models/vendor_profile_model.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late Future<VendorProfileModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = getIt<ProfileRemoteDataSource>().getProfile();
  }

  void _retry() {
    setState(() {
      _profileFuture = getIt<ProfileRemoteDataSource>().getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<VendorProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load profile.'),
                    const SizedBox(height: AppDimensions.sm),
                    ElevatedButton(onPressed: _retry, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          return _ProfileBody(profile: snapshot.data!);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final VendorProfileModel profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final vendor = profile.vendor;
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.md),
      children: [
        _SectionCard(
          title: 'Shop',
          children: [
            _InfoRow(label: 'Shop name', value: vendor.shopName),
            _InfoRow(label: 'Business name', value: vendor.businessName),
            if (vendor.merchantCode != null)
              _InfoRow(label: 'Merchant code', value: vendor.merchantCode!),
            _InfoRow(label: 'Status', value: vendor.status),
            _InfoRow(label: 'KYC status', value: vendor.kycStatus),
            const SizedBox(height: AppDimensions.sm),
            OutlinedButton.icon(
              onPressed: () => showEmailQrSheet(context, email: vendor.email),
              icon: const Icon(Icons.qr_code),
              label: const Text('My QR code'),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        _SectionCard(
          title: 'Contact',
          children: [
            _InfoRow(label: 'Email', value: vendor.email),
            _InfoRow(label: 'Phone', value: vendor.phone),
            if (vendor.supportEmail != null)
              _InfoRow(label: 'Support email', value: vendor.supportEmail!),
            if (vendor.supportPhone != null)
              _InfoRow(label: 'Support phone', value: vendor.supportPhone!),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        _SectionCard(
          title: 'Wallet addresses',
          children: profile.walletAddresses.entries
              .map((e) => _InfoRow(label: e.key.toUpperCase(), value: e.value))
              .toList(),
        ),
        const SizedBox(height: AppDimensions.md),
        _SectionCard(
          title: 'Balances',
          children: profile.balances
              .map((b) => _InfoRow(
                    label: b.fullName,
                    value: b.totalBalance.toString(),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppDimensions.sm),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
