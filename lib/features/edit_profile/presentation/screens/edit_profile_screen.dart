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

  @override
  Widget build(BuildContext context) {
    final c = context.c;

    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (prev, curr) =>
      prev.status != curr.status || prev.message != curr.message,
      listener: (context, state) {
        // Profile aane par controllers ek hi baar seed karo
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

        final form = _FormBlock(
          metrics: m,
          state: state,
          nameCtrl: _nameCtrl,
          phoneCtrl: _phoneCtrl,
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
                  child: state.status == EditProfileStatus.loading &&
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
                                child: form,
                              ),
                            ),
                          ],
                        ),
                      )
                          : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          m.pageHPad,
                          m.gapMd,
                          m.pageHPad,
                          m.gapLg,
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            avatar,
                            SizedBox(height: m.gapLg),
                            form,
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

    return Padding(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad * 0.4,
        m.pageVPad * 0.5,
        m.pageHPad,
        m.pageVPad * 0.5,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.account),
            splashRadius: m.backIconSize * 1.2,
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: m.backIconSize,
              color: c.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Edit Profile',
              style: AppTextStyles.titleLarge.copyWith(
                color: c.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: m.titleSize,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
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
            errorBuilder: (_, __, ___) => _Initials(metrics: m, profile: profile),
          ),
        );
      }
      return _Initials(metrics: m, profile: profile);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: m.avatarSize + m.cameraBadgeSize * 0.4,
          height: m.avatarSize + m.cameraBadgeSize * 0.3,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: m.avatarSize,
                height: m.avatarSize,
                decoration: BoxDecoration(
                  color: c.brand,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 3),
                ),
                alignment: Alignment.center,
                child: avatarChild(),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: c.brand,
                  shape: CircleBorder(
                    side: BorderSide(color: c.background, width: 2.5),
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

        Text(
          profile?.fullName ?? '',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleMedium.copyWith(
            color: c.textPrimary,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: m.avatarNameSize,
          ),
        ),

        SizedBox(height: m.gapXs),

        InkWell(
          onTap: onChangePhoto,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: EdgeInsets.all(m.gapXs * 1.4),
            child: Text(
              'Change Photo',
              style: AppTextStyles.labelMedium.copyWith(
                color: c.brand,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: m.avatarHintSize,
              ),
            ),
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
        color: c.surface,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        fontSize: metrics.avatarInitialSize,
      ),
    );
  }
}

// ── Form ───────────────────────────────────────────────────────────────────
class _FormBlock extends StatelessWidget {
  final EditProfileMetrics metrics;
  final EditProfileState state;
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;

  const _FormBlock({
    required this.metrics,
    required this.state,
    required this.nameCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(m.cardRadius),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Personal Details',
            style: AppTextStyles.titleMedium.copyWith(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: m.sectionTitleSize,
            ),
          ),

          SizedBox(height: m.gapLg),

          _Field(
            metrics: m,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline_rounded,
            controller: nameCtrl,
            error: state.nameError,
            textCapitalization: TextCapitalization.words,
          ),

          SizedBox(height: m.gapMd),

          // Email — read only
          _Field(
            metrics: m,
            label: 'Email Address',
            hint: '',
            icon: Icons.mail_outline_rounded,
            initialText: state.profile?.email ?? '',
            readOnly: true,
            helper: 'Email cannot be changed',
          ),

          SizedBox(height: m.gapMd),

          _Field(
            metrics: m,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone_outlined,
            controller: phoneCtrl,
            error: state.phoneError,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
              LengthLimitingTextInputFormatter(18),
            ],
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final EditProfileMetrics metrics;
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final String? initialText;
  final String? error;
  final String? helper;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.metrics,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.initialText,
    this.error,
    this.helper,
    this.readOnly = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final m = metrics;
    final hasError = error != null;

    final borderColor = hasError
        ? c.statusWarning
        : readOnly
        ? c.border
        : c.border;

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

        Container(
          height: m.fieldHeight,
          padding: EdgeInsets.symmetric(horizontal: m.cardPad * 0.7),
          decoration: BoxDecoration(
            color: readOnly ? c.surfaceAlt : c.surface,
            borderRadius: BorderRadius.circular(m.fieldRadius),
            border: Border.all(
              color: borderColor,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: m.fieldIconSize,
                color: readOnly ? c.textMuted : c.textSecondary,
              ),
              SizedBox(width: m.gapSm),
              Expanded(
                child: readOnly
                    ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    initialText ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: c.textMuted,
                      fontFamily: 'Inter',
                      fontSize: m.fieldTextSize,
                    ),
                  ),
                )
                    : TextField(
                  controller: controller,
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
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (readOnly)
                Icon(
                  Icons.lock_outline_rounded,
                  size: m.fieldIconSize * 0.85,
                  color: c.textMuted,
                ),
            ],
          ),
        ),

        if (hasError) ...[
          SizedBox(height: m.gapXs),
          Row(
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
        ] else if (helper != null) ...[
          SizedBox(height: m.gapXs),
          Text(
            helper!,
            style: AppTextStyles.bodySmall.copyWith(
              color: c.textMuted,
              fontFamily: 'Inter',
              fontSize: m.errorSize,
            ),
          ),
        ],
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
                        : Text(
                      'SAVE CHANGES',
                      style: AppTextStyles.buttonText.copyWith(
                        color: c.surface,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.btnFontSize,
                        letterSpacing: 0.4,
                      ),
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