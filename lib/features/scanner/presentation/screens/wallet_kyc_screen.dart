import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/helpers/image_picker_helper.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../address/data/datasources/address_remote_datasources.dart';
import '../../../address/data/models/address_model.dart';
import '../../data/tvs_qr_datasource.dart';
import '../widgets/review_payment_metrics.dart';
import '../widgets/review_payment_section_label.dart';

const _photoKinds = {
  'FRONT': (
    short: 'Front',
    label: 'Front of document',
    hint: 'All four corners visible',
    icon: Icons.badge_outlined,
  ),
  'BACK': (
    short: 'Back',
    label: 'Back of document',
    hint: 'Flip it over, same framing',
    icon: Icons.flip_outlined,
  ),
  'SELFIE': (
    short: 'Selfie',
    label: 'Selfie with document',
    hint: 'Your face and the document, both clear',
    icon: Icons.face_outlined,
  ),
};

const _docIcons = {
  'AADHAAR': Icons.fingerprint_rounded,
  'PAN': Icons.credit_card_rounded,
  'PASSPORT': Icons.menu_book_rounded,
};

// Address choice meaning "type a different address".
const _typedAddress = '';

// TVS Wallet identity verification, as on the web (/customer/tvs-wallet/verify):
// pick documents, enter details and home address, upload photos. An admin
// reviews it, and approval activates the wallet.
class WalletKycScreen extends StatefulWidget {
  const WalletKycScreen({super.key});

  @override
  State<WalletKycScreen> createState() => _WalletKycScreenState();
}

class _WalletKycScreenState extends State<WalletKycScreen> {
  final _api = getIt<TvsQrDataSource>();

  List<dynamic>? _reqs;
  Map<String, dynamic>? _status;
  String? _loadError;
  String _country = '';
  final Set<String> _picked = {};
  final Map<String, TextEditingController> _numbers = {};
  final _name = TextEditingController();
  List<AddressModel> _addresses = const [];
  String _addressId = _typedAddress;
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();
  // Photos by "<CODE>.FRONT" / "<CODE>.BACK", and one "SELFIE".
  final Map<String, XFile> _files = {};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadAddresses();
  }

  @override
  void dispose() {
    for (final c in [
      ..._numbers.values,
      _name,
      _line1,
      _line2,
      _city,
      _state,
      _postal,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await Future.wait([_api.kycRequirements(), _api.kycStatus()]);
      if (!mounted) return;
      setState(() {
        _reqs = r[0] as List<dynamic>;
        _status = r[1] as Map<String, dynamic>;
        if (_country.isEmpty && _reqs!.isNotEmpty) {
          _country = '${_reqs!.first['country']}';
        }
        _loadError = null;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = ErrorHandler.mapObjectToFailure(e).message);
      }
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final list = await getIt<AddressRemoteDataSource>().getAllAddresses();
      if (!mounted || list.isEmpty) return;
      final first = list.firstWhere(
        (a) => a.isDefault,
        orElse: () => list.first,
      );
      setState(() {
        _addresses = list;
        // Start from the default saved address unless they began typing one.
        if (_line1.text.isEmpty) _addressId = first.id;
      });
    } catch (_) {} // typing the address still works
  }

  Map<String, dynamic>? get _countryReq => _reqs
      ?.cast<Map<String, dynamic>>()
      .where((r) => r['country'] == _country)
      .firstOrNull;

  List<Map<String, dynamic>> get _docs =>
      ((_countryReq?['documents'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> get _rule =>
      _countryReq?['rule'] as Map<String, dynamic>? ??
      const {'required': [], 'pick': 1};

  List<String> get _required =>
      ((_rule['required'] as List?) ?? const []).cast<String>();

  // The rule is a minimum: required documents plus `pick` of the others.
  int get _minDocs =>
      _required.length + ((_rule['pick'] as num?)?.toInt() ?? 0);

  List<Map<String, dynamic>> get _chosen => _docs
      .where(
        (d) => _required.contains(d['code']) || _picked.contains(d['code']),
      )
      .toList();

  static List<String> _filesOf(Map<String, dynamic> doc) =>
      ((doc['files'] as List?) ?? const []).cast<String>();

  // (key, kind, document) for every photo the chosen documents need.
  List<(String, String, Map<String, dynamic>?)> get _slots {
    final chosen = _chosen;
    return [
      for (final d in chosen)
        for (final kind in _filesOf(d))
          if (kind != 'SELFIE') ('${d['code']}.$kind', kind, d),
      if (chosen.any((d) => _filesOf(d).contains('SELFIE')))
        ('SELFIE', 'SELFIE', null),
    ];
  }

  TextEditingController _numberFor(String code) =>
      _numbers.putIfAbsent(code, TextEditingController.new);

  bool get _addressMissing =>
      _addressId == _typedAddress &&
      (_line1.text.trim().isEmpty ||
          _city.text.trim().isEmpty ||
          _state.text.trim().isEmpty ||
          !RegExp(r'^[A-Za-z0-9 -]{3,12}$').hasMatch(_postal.text.trim()));

  List<String> get _missing {
    final toPick = _minDocs - _chosen.length;
    return [
      if (toPick > 0) 'choose $toPick more document${toPick > 1 ? 's' : ''}',
      if (_name.text.trim().length < 2) 'enter your full name',
      if (_chosen.any((d) => _numberFor('${d['code']}').text.trim().length < 4))
        'enter the document number',
      if (_slots.any((s) => _files[s.$1] == null)) 'upload the photos',
      if (_addressMissing) 'enter your home address',
    ];
  }

  Future<void> _pickPhoto(String key) async {
    final file = await ImagePickerHelper.pick(
      context,
      maxWidth: 2000, // stays readable and under the API's 5 MB limit
      preferredCameraDevice: key == 'SELFIE'
          ? CameraDevice.front
          : CameraDevice.rear,
    );
    if (file != null && mounted) setState(() => _files[key] = file);
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      final form = FormData.fromMap({
        'country': _country,
        'fullName': _name.text.trim(),
        'address': jsonEncode(
          _addressId != _typedAddress
              ? {'addressId': _addressId}
              : {
                  'line1': _line1.text.trim(),
                  'line2': _line2.text.trim(),
                  'city': _city.text.trim(),
                  'state': _state.text.trim(),
                  'postalCode': _postal.text.trim(),
                },
        ),
        'documents': jsonEncode([
          for (final d in _chosen)
            {
              'type': d['code'],
              'number': _numberFor('${d['code']}').text.trim(),
            },
        ]),
      });
      for (final (key, kind, doc) in _slots) {
        final file = _files[key]!;
        // dio sets the part's type from the name (.jpg/.png), which the API checks.
        form.files.add(
          MapEntry(
            kind == 'SELFIE'
                ? 'selfie'
                : '${doc!['code']}.${kind.toLowerCase()}',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
      await _api.submitKyc(form);
      if (!mounted) return;
      AppSnackbar.showSuccess(context, "Sent for review. We'll let you know.");
      setState(() {
        _files.clear();
        _picked.clear();
      });
      await _load();
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context,
          ErrorHandler.mapObjectToFailure(e).message,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = ReviewPaymentMetrics.of(context);
    final canSubmit = _reqs != null && _status?['canSubmit'] == true;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const CustomAppBar(title: 'Verify your identity'),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _body(m, colors)),
            if (canSubmit) _submitBar(m, colors),
          ],
        ),
      ),
    );
  }

  Widget _body(ReviewPaymentMetrics m, AppThemeColors colors) {
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(m.pageHPad * 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              TextButton(
                onPressed: () {
                  setState(() => _loadError = null);
                  _load();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
    final status = _status;
    if (_reqs == null || status == null) return const AppLoader();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: m.maxContentWidth),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            m.pageHPad,
            m.gapMd,
            m.pageHPad,
            m.gapLg,
          ),
          children: [
            _hero(status, m, colors),
            if (status['canSubmit'] == true) ..._form(m, colors),
            if (status['status'] == 'APPROVED') ...[
              SizedBox(height: m.gapLg),
              AppButton(
                label: 'Back to Scan & Pay',
                onPressed: () => context.pop(),
                height: m.payHeight,
                fontSize: m.payFontSize,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Status card: what happens next, and progress while filling the form ──
  Widget _hero(
    Map<String, dynamic> status,
    ReviewPaymentMetrics m,
    AppThemeColors colors,
  ) {
    final latest = status['latest'] as Map<String, dynamic>?;
    final (icon, accent, title, body) = switch (status['status']) {
      'APPROVED' => (
        Icons.verified_rounded,
        colors.statusSuccess,
        "You're verified${status['legalName'] != null ? ', ${status['legalName']}' : ''}",
        'Your TVS Wallet is active. You can pay shops with TVS Coins.',
      ),
      'PENDING' => (
        Icons.schedule_rounded,
        colors.statusWarning,
        "We're reviewing your documents",
        'This usually takes a few hours. Scan & Pay unlocks once you are approved.',
      ),
      'REVOKED' => (
        Icons.block_rounded,
        colors.error,
        'Verification withdrawn',
        'Your wallet is on hold. Please contact support.',
      ),
      _ when ['REJECTED', 'RESUBMIT_REQUESTED'].contains(latest?['status']) => (
        Icons.error_outline_rounded,
        colors.error,
        latest!['status'] == 'RESUBMIT_REQUESTED'
            ? 'Please upload again'
            : "We couldn't verify that document",
        [
          if (latest['reason'] != null) 'Reason: ${latest['reason']}',
          status['canSubmit'] == true
              ? 'Fix it below and send again. ${status['attemptsLeft']} attempt(s) left.'
              : 'Please contact support to finish verification.',
        ].join('\n'),
      ),
      _ => (
        Icons.shield_outlined,
        colors.brand,
        'Activate your TVS Wallet',
        'Takes about two minutes. We review it and activate your wallet.',
      ),
    };

    final pending = status['status'] == 'PENDING' && latest != null;
    final docs = ((latest?['documents'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    final sent = DateTime.tryParse('${latest?['submittedAt']}')?.toLocal();

    return Container(
      padding: EdgeInsets.all(m.cardPad * 0.85),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: colors.isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: m.bannerIconBox,
                height: m.bannerIconBox,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: m.bannerIconSize, color: accent),
              ),
              SizedBox(width: m.cardPad * 0.7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: _text(
                        colors.textPrimary,
                        m.bannerTitleSize + 1,
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: m.gapXs * 0.6),
                    Text(
                      body,
                      style: _text(colors.textSecondary, m.bannerSubSize + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pending) ...[
            Divider(height: m.gapLg, color: accent.withValues(alpha: 0.25)),
            for (final d in docs)
              _infoRow('${d['label']}', '${d['number']}', m, colors),
            if (sent != null)
              _infoRow(
                'Sent',
                DateFormat('d MMM yyyy, h:mm a').format(sent),
                m,
                colors,
              ),
          ],
          if (status['canSubmit'] == true) ...[
            SizedBox(height: m.gapMd),
            _steps(m, colors),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    ReviewPaymentMetrics m,
    AppThemeColors colors,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: m.gapXs * 0.5),
      child: Row(
        children: [
          Text(label, style: _text(colors.textSecondary, m.methodSubSize + 2)),
          const Spacer(),
          Text(
            value,
            style: _text(
              colors.textPrimary,
              m.methodSubSize + 2,
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Document → details → photos, ticked off as each part is complete.
  Widget _steps(ReviewPaymentMetrics m, AppThemeColors colors) {
    final missing = _missing;
    final slots = _slots;
    final steps = [
      ('Document', _chosen.length >= _minDocs && _chosen.isNotEmpty),
      (
        'Details',
        !missing.any(
          (x) =>
              x.contains('name') ||
              x.contains('number') ||
              x.contains('address'),
        ),
      ),
      ('Photos', slots.isNotEmpty && slots.every((s) => _files[s.$1] != null)),
    ];
    return Row(
      children: [
        for (final (i, (label, done)) in steps.indexed) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                margin: EdgeInsets.symmetric(horizontal: m.gapXs),
                color: done ? colors.brand : colors.border,
              ),
            ),
          Container(
            width: m.methodIconBox * 0.55,
            height: m.methodIconBox * 0.55,
            decoration: BoxDecoration(
              color: done ? colors.brand : colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: done ? colors.brand : colors.border),
            ),
            alignment: Alignment.center,
            child: done
                ? Icon(
                    Icons.check_rounded,
                    size: m.methodIconSize * 0.7,
                    color: colors.onBrand,
                  )
                : Text(
                    '${i + 1}',
                    style: _text(
                      colors.textSecondary,
                      m.helperSize,
                      FontWeight.w700,
                    ),
                  ),
          ),
          SizedBox(width: m.gapXs),
          Text(
            label,
            style: _text(
              done ? colors.brand : colors.textSecondary,
              m.helperSize + 1,
              FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _form(ReviewPaymentMetrics m, AppThemeColors colors) {
    final reqs = _reqs!;
    final docs = _docs;
    final chosen = _chosen;
    final chosenCodes = {for (final d in chosen) d['code']};
    final slots = _slots;
    void refresh(String _) => setState(() {});

    return [
      _section(
        'CHOOSE YOUR DOCUMENT',
        'Required: ${_countryReq?['ruleText'] ?? 'any one document'}',
        m,
        colors,
      ),
      if (reqs.length > 1) ...[
        DropdownButtonFormField<String>(
          initialValue: _country,
          decoration: const InputDecoration(labelText: 'Country'),
          items: [
            for (final r in reqs)
              DropdownMenuItem(
                value: '${r['country']}',
                child: Text('${r['name']}'),
              ),
          ],
          onChanged: (c) => setState(() {
            _country = c!;
            _picked.clear();
            _files.clear();
          }),
        ),
        SizedBox(height: m.gapSm),
      ],
      for (var i = 0; i < docs.length; i += 3) ...[
        if (i > 0) SizedBox(height: m.gapSm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = i; j < i + 3; j++) ...[
                if (j > i) SizedBox(width: m.gapSm),
                Expanded(
                  child: j < docs.length
                      ? _docTile(
                          docs[j],
                          chosenCodes.contains(docs[j]['code']),
                          m,
                          colors,
                        )
                      : const SizedBox(),
                ),
              ],
            ],
          ),
        ),
      ],

      _section('YOUR DETAILS', 'Exactly as printed on the document', m, colors),
      _input(
        icon: Icons.person_outline_rounded,
        hint: 'Full name',
        controller: _name,
        onChanged: refresh,
        caps: TextCapitalization.words,
        m: m,
        colors: colors,
      ),
      for (final d in chosen) ...[
        SizedBox(height: m.gapSm),
        _input(
          icon: _docIcons[d['code']] ?? Icons.badge_outlined,
          hint: '${d['label']} number',
          controller: _numberFor('${d['code']}'),
          onChanged: refresh,
          caps: TextCapitalization.characters,
          m: m,
          colors: colors,
        ),
      ],

      _section(
        'HOME ADDRESS',
        'Where you live. Checked with your document.',
        m,
        colors,
      ),
      for (final a in _addresses) ...[
        _choiceTile(
          icon: Icons.home_outlined,
          title: [
            a.addressLine1,
            a.addressLine2,
          ].where((s) => s != null && s.isNotEmpty).join(', '),
          subtitle: '${a.city}, ${a.state}, ${a.postalCode}',
          selected: _addressId == a.id,
          onTap: () => setState(() => _addressId = a.id),
          m: m,
          colors: colors,
        ),
        SizedBox(height: m.gapSm),
      ],
      if (_addresses.isNotEmpty)
        _choiceTile(
          icon: Icons.add_location_alt_outlined,
          title: 'Use a different address',
          subtitle: 'Type your home address',
          selected: _addressId == _typedAddress,
          onTap: () => setState(() => _addressId = _typedAddress),
          m: m,
          colors: colors,
        ),
      if (_addressId == _typedAddress) ...[
        if (_addresses.isNotEmpty) SizedBox(height: m.gapSm),
        _input(
          icon: Icons.home_outlined,
          hint: 'House, street',
          controller: _line1,
          onChanged: refresh,
          m: m,
          colors: colors,
        ),
        SizedBox(height: m.gapSm),
        _input(
          icon: Icons.apartment_outlined,
          hint: 'Area, landmark (optional)',
          controller: _line2,
          onChanged: refresh,
          m: m,
          colors: colors,
        ),
        SizedBox(height: m.gapSm),
        Row(
          children: [
            Expanded(
              child: _input(
                icon: Icons.location_city_outlined,
                hint: 'City',
                controller: _city,
                onChanged: refresh,
                m: m,
                colors: colors,
              ),
            ),
            SizedBox(width: m.gapSm),
            Expanded(
              child: _input(
                icon: Icons.map_outlined,
                hint: 'State',
                controller: _state,
                onChanged: refresh,
                m: m,
                colors: colors,
              ),
            ),
          ],
        ),
        SizedBox(height: m.gapSm),
        _input(
          icon: Icons.markunread_mailbox_outlined,
          hint: 'Postal code',
          controller: _postal,
          onChanged: refresh,
          m: m,
          colors: colors,
        ),
      ],

      _section(
        'UPLOAD PHOTOS',
        slots.isEmpty
            ? 'Choose a document first'
            : 'Good light, the whole document in frame, no glare',
        m,
        colors,
      ),
      for (var i = 0; i < slots.length; i += 2) ...[
        if (i > 0) SizedBox(height: m.gapSm),
        // A photo left alone in its row (usually the selfie) spans the width.
        if (i + 1 == slots.length)
          _photoTile(slots[i], chosen.length > 1, 2.4, m, colors)
        else
          Row(
            children: [
              Expanded(
                child: _photoTile(slots[i], chosen.length > 1, 1.1, m, colors),
              ),
              SizedBox(width: m.gapSm),
              Expanded(
                child: _photoTile(
                  slots[i + 1],
                  chosen.length > 1,
                  1.1,
                  m,
                  colors,
                ),
              ),
            ],
          ),
      ],

      SizedBox(height: m.gapLg),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: m.methodIconSize * 0.75,
            color: colors.textMuted,
          ),
          SizedBox(width: m.gapSm),
          Expanded(
            child: Text(
              'Your documents are stored privately and seen only by our review team. They are never shared with shops.',
              style: _text(colors.textMuted, m.helperSize + 1),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _section(
    String label,
    String subtitle,
    ReviewPaymentMetrics m,
    AppThemeColors colors,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: m.gapLg, bottom: m.gapSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewPaymentSectionLabel(metrics: m, label: label),
          SizedBox(height: m.gapXs * 0.6),
          Text(subtitle, style: _text(colors.textMuted, m.helperSize + 1)),
        ],
      ),
    );
  }

  Widget _docTile(
    Map<String, dynamic> d,
    bool on,
    ReviewPaymentMetrics m,
    AppThemeColors colors,
  ) {
    final code = '${d['code']}';
    final locked = _required.contains(code);
    final radius = BorderRadius.circular(m.cardRadius * 0.8);
    return Semantics(
      selected: on,
      child: Material(
        color: on ? colors.brandSoft : colors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: locked
              ? null
              : () => setState(
                  () => on ? _picked.remove(code) : _picked.add(code),
                ),
          child: Container(
            padding: EdgeInsets.all(m.cardPad * 0.6),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: on ? colors.brand : colors.border,
                width: on ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: m.methodIconBox * 0.8,
                      height: m.methodIconBox * 0.8,
                      decoration: BoxDecoration(
                        color: on ? colors.brand : colors.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _docIcons[code] ?? Icons.badge_outlined,
                        size: m.methodIconSize * 0.8,
                        color: on ? colors.onBrand : colors.brand,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      on ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: m.methodIconSize * 0.8,
                      color: on ? colors.brand : colors.border,
                    ),
                  ],
                ),
                SizedBox(height: m.gapSm),
                Text(
                  '${d['label']}',
                  style: _text(
                    colors.textPrimary,
                    m.methodTitleSize + 1,
                    FontWeight.w700,
                  ),
                ),
                SizedBox(height: m.gapXs * 0.5),
                Text(
                  _filesOf(
                    d,
                  ).map((f) => _photoKinds[f]?.short ?? f).join(' · '),
                  style: _text(colors.textSecondary, m.helperSize),
                ),
                if (locked) ...[
                  SizedBox(height: m.gapXs),
                  Text(
                    'Required',
                    style: _text(colors.brand, m.helperSize, FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required ReviewPaymentMetrics m,
    required AppThemeColors colors,
    TextCapitalization caps = TextCapitalization.sentences,
  }) {
    final style = _text(colors.textPrimary, m.methodTitleSize + 1);
    return Container(
      height: m.noteBoxHeight,
      padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.7),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(m.cardRadius * 0.8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: m.methodIconSize * 0.85,
            color: colors.textSecondary,
          ),
          SizedBox(width: m.gapSm),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textCapitalization: caps,
              style: style,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: style.copyWith(color: colors.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    required ReviewPaymentMetrics m,
    required AppThemeColors colors,
  }) {
    final radius = BorderRadius.circular(m.cardRadius * 0.8);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? colors.brandSoft : colors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(m.cardPad * 0.7),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? colors.brand : colors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: m.methodIconBox * 0.8,
                  height: m.methodIconBox * 0.8,
                  decoration: BoxDecoration(
                    color: selected ? colors.brand : colors.brandSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: m.methodIconSize * 0.8,
                    color: selected ? colors.onBrand : colors.brand,
                  ),
                ),
                SizedBox(width: m.cardPad * 0.6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: _text(
                          colors.textPrimary,
                          m.methodTitleSize + 1,
                          FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: m.gapXs * 0.5),
                      Text(
                        subtitle,
                        style: _text(colors.textSecondary, m.methodSubSize + 2),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? colors.brand : colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _photoTile(
    (String, String, Map<String, dynamic>?) slot,
    bool manyDocs,
    double aspectRatio,
    ReviewPaymentMetrics m,
    AppThemeColors colors,
  ) {
    final (key, kind, doc) = slot;
    final file = _files[key];
    final info = _photoKinds[kind];
    final label = manyDocs && doc != null
        ? '${doc['label']} · ${info?.short ?? kind}'
        : info?.label ?? kind;
    final radius = BorderRadius.circular(m.cardRadius * 0.8);

    return Semantics(
      button: true,
      label: '$label, ${file == null ? 'not added' : 'added'}',
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Material(
          color: file == null ? colors.surface : colors.brandSoft,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _pickPhoto(key),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: file == null ? colors.border : colors.brand,
                  width: file == null ? 1 : 1.5,
                ),
              ),
              child: file == null
                  ? Padding(
                      padding: EdgeInsets.all(m.cardPad * 0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: m.methodIconBox,
                            height: m.methodIconBox,
                            decoration: BoxDecoration(
                              color: colors.brandSoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              info?.icon ?? Icons.add_a_photo_outlined,
                              color: colors.brand,
                              size: m.methodIconSize,
                            ),
                          ),
                          SizedBox(height: m.gapSm),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            style: _text(
                              colors.textPrimary,
                              m.methodSubSize + 2,
                              FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: m.gapXs * 0.5),
                          Text(
                            info?.hint ?? '',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _text(colors.textMuted, m.helperSize),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(file.path), fit: BoxFit.cover),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: m.gapSm,
                              vertical: m.gapXs,
                            ),
                            color: colors.scrim.withValues(alpha: 0.6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _text(
                                      Colors.white,
                                      m.helperSize,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Change',
                                  style: _text(
                                    Colors.white,
                                    m.helperSize,
                                    FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: m.gapXs,
                          right: m.gapXs,
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: colors.statusSuccess,
                            size: m.methodIconSize,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _submitBar(ReviewPaymentMetrics m, AppThemeColors colors) {
    final missing = _missing;
    final ready = missing.isEmpty;
    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapSm,
        m.pageHPad,
        m.gapSm * 0.5,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  ready
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: m.helperSize + 4,
                  color: ready ? colors.statusSuccess : colors.textSecondary,
                ),
                SizedBox(width: m.gapXs),
                Expanded(
                  child: Text(
                    ready
                        ? 'All set. Send it for review.'
                        : 'To continue, ${missing.join(', ')}.',
                    style: _text(
                      ready ? colors.statusSuccess : colors.textSecondary,
                      m.helperSize + 1,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: m.gapSm),
            AppButton(
              label: 'Submit for review',
              prefixIcon: Icons.shield_outlined,
              isLoading: _busy,
              onPressed: ready && !_busy ? _submit : null,
              height: m.payHeight,
              fontSize: m.payFontSize,
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _text(
    Color color,
    double size, [
    FontWeight weight = FontWeight.w400,
  ]) => AppTextStyles.bodyMedium.copyWith(
    color: color,
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: weight,
    height: 1.3,
  );
}
