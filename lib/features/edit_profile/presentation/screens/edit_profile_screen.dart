import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';
import '../widgets/edit_profile_matrics.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    context.read<EditProfileCubit>().load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _pickPhoto() {
    final cubit = context.read<EditProfileCubit>();

    showAppActionsSheet(
      context: context,
      title: 'Change Photo',
      actions: [
        SheetAction(
          label: 'Take Photo',
          icon: Icons.photo_camera_outlined,
          onTap: () => cubit.pickImage(fromCamera: true),
        ),
        SheetAction(
          label: 'Choose from Gallery',
          icon: Icons.photo_library_outlined,
          onTap: () => cubit.pickImage(),
        ),
      ],
    );
  }

  /// Inline edit ke liye bottom sheet — image jaisa pencil tap
  Future<void> _editField({
    required String title,
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) async {
    final temp = TextEditingController(text: controller.text);

    await showAppSheet<void>(
      context: context,
      builder: (sheetContext) {
        final m = EditProfileMetrics.of(sheetContext);

        return AppSheetShell(
          title: title,
          footer: AppSheetButton(
            label: 'DONE',
            onTap: () {
              setState(() => controller.text = temp.text.trim());
              Navigator.pop(sheetContext);
            },
          ),
          child: _SheetField(
            metrics: m,
            label: label,
            hint: hint,
            controller: temp,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
          ),
        );
      },
    );

    temp.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (prev, curr) =>
      prev.status != curr.status || prev.message != curr.message,
      listener: (context, state) {
        if (!_seeded && state.profile != null) {
          _nameCtrl.text = state.profile!.fullName;
          _phoneCtrl.text = state.profile!.phoneNumber;
          _seeded = true;
        }

        final msg = state.message;
        if (msg == null) return;

        if (state.status == EditProfileStatus.success) {
          AppSnackbar.showSuccess(context, msg);
          if (context.canPop()) context.pop();
        } else if (state.status == EditProfileStatus.failure) {
          AppSnackbar.showError(context, msg);
        }
      },
      builder: (context, state) {
        final m = EditProfileMetrics.of(context);
        final cubit = context.read<EditProfileCubit>();

        final avatar = _AvatarBlock(
          metrics: m,
          state: state,
          onChangePhoto: _pickPhoto,
        );

        final fields = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _EmailCard(metrics: m, email: state.profile?.email ?? ''),

            SizedBox(height: m.gapMd),

            _InfoTile(
              metrics: m,
              icon: Icons.person_outline_rounded,
              label: 'FULL NAME',
              value: _nameCtrl.text,
              placeholder: 'Add your name',
              error: state.nameError,
              onEdit: () => _editField(
                title: 'Full Name',
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
              ),
            ),

            SizedBox(height: m.gapMd),

            _InfoTile(
              metrics: m,
              icon: Icons.phone_outlined,
              label: 'PHONE NUMBER',
              value: _phoneCtrl.text,
              placeholder: 'Add your phone number',
              error: state.phoneError,
              onEdit: () => _editField(
                title: 'Phone Number',
                label: 'Phone Number',
                hint: 'Enter your phone number',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
                  LengthLimitingTextInputFormatter(18),
                ],
              ),
            ),
          ],
        );

        final saveBar = _SaveBar(
          metrics: m,
          isSaving: state.status == EditProfileStatus.saving,
          onSave: () => cubit.save(
            fullName: _nameCtrl.text,
            phoneNumber: _phoneCtrl.text,
          ),
        );

        return Scaffold(
          backgroundColor: c.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _EditTopBar(metrics: m),

                Expanded(
                  child:
                  state.status == EditProfileStatus.loading &&
                      state.profile == null
                      ? Center(child: CircularProgressIndicator(color: c.brand))
                      : Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: m.maxContentWidth,
                      ),
                      child: m.isLandscape
                          ? Padding(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapMd,
                          m.pageHPad,
                          0,
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: m.avatarPaneWidth,
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  bottom: m.gapLg,
                                ),
                                child: avatar,
                              ),
                            ),
                            SizedBox(width: m.gapLg),
                            Expanded(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.only(
                                  bottom: m.gapLg,
                                ),
                                child: fields,
                              ),
                            ),
                          ],
                        ),
                      )
                          : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapLg,
                          m.pageHPad,
                          m.gapLg,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            avatar,
                            SizedBox(height: m.gapLg),
                            fields,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                saveBar,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────
class _EditTopBar extends StatelessWidget {
  final EditProfileMetrics metrics;

  const _EditTopBar({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Row(
      children: [
        IconButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.account),
          splashRadius: m.backIconSize * 1.2,
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            size: m.backIconSize,
            color: c.brand,
          ),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Profile',
                style: AppTextStyles.titleLarge.copyWith(
                  color: c.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: m.titleSize,
                  height: 1.2,
                ),
              ),
              SizedBox(height: m.gapXs * 0.6),
              Text(
                'Manage your personal information',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: c.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: m.avatarHintSize,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Avatar ─────────────────────────────────────────────────────────────────
class _AvatarBlock extends StatelessWidget {
  final EditProfileMetrics metrics;
  final EditProfileState state;
  final VoidCallback onChangePhoto;

  const _AvatarBlock({
    required this.metrics,
    required this.state,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final profile = state.profile;
    final picked = state.pickedImage;
    final url = profile?.profileImageUrl;

    Widget avatarChild() {
      if (picked != null) {
        return ClipOval(
          child: Image.file(
            picked,
            width: m.avatarSize,
            height: m.avatarSize,
            fit: BoxFit.cover,
          ),
        );
      }
      if (url != null && url.isNotEmpty) {
        return ClipOval(
          child: Image.network(
            url,
            width: m.avatarSize,
            height: m.avatarSize,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _Initials(metrics: m, profile: profile),
          ),
        );
      }
      return _Initials(metrics: m, profile: profile);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: m.avatarSize + m.cameraBadgeSize * 0.6,
          height: m.avatarSize + m.cameraBadgeSize * 0.3,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: m.avatarSize,
                height: m.avatarSize,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: c.brand.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: avatarChild(),
              ),
              Positioned(
                right: 0,
                bottom: m.avatarSize * 0.06,
                child: Material(
                  color: c.brand,
                  shape: CircleBorder(
                    side: BorderSide(color: c.background, width: 3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onChangePhoto,
                    child: SizedBox(
                      width: m.cameraBadgeSize,
                      height: m.cameraBadgeSize,
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: m.cameraIconSize,
                        color: c.surface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: m.gapMd),

        InkWell(
          onTap: onChangePhoto,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(m.gapXs * 1.2),
            child: Text(
              'Change Profile Photo',
              style: AppTextStyles.titleMedium.copyWith(
                color: c.brand,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.avatarNameSize,
              ),
            ),
          ),
        ),

        SizedBox(height: m.gapXs * 0.6),

        Text(
          'Max size 2MB',
          style: AppTextStyles.bodySmall.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontSize: m.avatarHintSize,
          ),
        ),
      ],
    );
  }
}

class _Initials extends StatelessWidget {
  final EditProfileMetrics metrics;
  final dynamic profile;

  const _Initials({required this.metrics, required this.profile});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Text(
      profile?.initials ?? '?',
      style: AppTextStyles.titleLarge.copyWith(
        color: c.brand,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: metrics.avatarInitialSize,
      ),
    );
  }
}

// ── Email (read-only) ──────────────────────────────────────────────────────
class _EmailCard extends StatelessWidget {
  final EditProfileMetrics metrics;
  final String email;

  const _EmailCard({required this.metrics, required this.email});

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.brandSoft,
        borderRadius: BorderRadius.circular(m.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: m.fieldHeight * 0.85,
                height: m.fieldHeight * 0.85,
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.7),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: m.fieldIconSize,
                  color: c.brand,
                ),
              ),

              SizedBox(width: m.cardPad * 0.7),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EMAIL ADDRESS',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: c.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.fieldLabelSize,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    Text(
                      email.isEmpty ? '-' : email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: c.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: m.fieldTextSize,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: m.gapSm),

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: m.gapSm * 1.1,
                  vertical: m.gapXs * 1.4,
                ),
                decoration: BoxDecoration(
                  color: c.surface.withValues(alpha: c.isDark ? 0.10 : 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Not editable',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: m.errorSize,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: m.gapMd),

          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: m.errorSize + 4,
                color: c.textMuted,
              ),
              SizedBox(width: m.gapSm * 0.8),
              Expanded(
                child: Text(
                  'Your email address cannot be changed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: c.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: m.errorSize,
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

// ── Editable info tile ─────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final EditProfileMetrics metrics;
  final IconData icon;
  final String label;
  final String value;
  final String placeholder;
  final String? error;
  final VoidCallback onEdit;

  const _InfoTile({
    required this.metrics,
    required this.icon,
    required this.label,
    required this.value,
    required this.placeholder,
    required this.error,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasError = error != null;
    final isEmpty = value.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: c.surface,
          borderRadius: BorderRadius.circular(m.cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onEdit,
            child: Container(
              padding: EdgeInsets.all(m.cardPad * 0.85),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(m.cardRadius),
                border: Border.all(
                  color: hasError ? c.statusWarning : c.border,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: m.fieldHeight * 0.85,
                    height: m.fieldHeight * 0.85,
                    decoration: BoxDecoration(
                      color: c.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: m.fieldIconSize, color: c.brand),
                  ),

                  SizedBox(width: m.cardPad * 0.7),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: c.brand,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.fieldLabelSize,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(height: m.gapXs),
                        Text(
                          isEmpty ? placeholder : value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isEmpty ? c.textMuted : c.textPrimary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: m.fieldTextSize,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: m.gapSm),

                  Icon(
                    Icons.edit_outlined,
                    size: m.fieldIconSize,
                    color: c.brand,
                  ),
                ],
              ),
            ),
          ),
        ),

        if (hasError) ...[
          SizedBox(height: m.gapXs),
          Padding(
            padding: EdgeInsets.only(left: m.cardPad * 0.6),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: m.errorSize + 2,
                  color: c.statusWarning,
                ),
                SizedBox(width: m.gapXs),
                Flexible(
                  child: Text(
                    error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: c.statusWarning,
                      fontFamily: 'Inter',
                      fontSize: m.errorSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Sheet field ────────────────────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final EditProfileMetrics metrics;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _SheetField({
    required this.metrics,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: c.textSecondary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: m.fieldLabelSize,
          ),
        ),

        SizedBox(height: m.gapXs * 1.4),

        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: AppTextStyles.bodyMedium.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontSize: m.fieldTextSize,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: c.textMuted,
              fontFamily: 'Inter',
              fontSize: m.fieldTextSize,
            ),
            filled: true,
            fillColor: c.surfaceAlt,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: m.cardPad * 0.7,
              vertical: m.gapMd,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(m.fieldRadius),
              borderSide: BorderSide(color: c.brand, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Save bar ───────────────────────────────────────────────────────────────
class _SaveBar extends StatelessWidget {
  final EditProfileMetrics metrics;
  final bool isSaving;
  final VoidCallback onSave;

  const _SaveBar({
    required this.metrics,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapSm,
        m.pageHPad,
        m.gapSm * 0.5,
      ),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(top: BorderSide(color: c.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.maxContentWidth),
            child: SizedBox(
              height: m.btnHeight,
              width: double.infinity,
              child: Material(
                color: c.brand,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: isSaving ? null : onSave,
                  child: Center(
                    child: isSaving
                        ? SizedBox(
                      width: m.btnFontSize + 4,
                      height: m.btnFontSize + 4,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(c.surface),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_outlined,
                          size: m.btnFontSize + 5,
                          color: c.surface,
                        ),
                        SizedBox(width: m.gapSm),
                        Text(
                          'Save Changes',
                          style: AppTextStyles.buttonText.copyWith(
                            color: c.surface,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: m.btnFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}