import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/edit_profile_cubit.dart';
import '../cubit/edit_profile_state.dart';
import '../widgets/edit_profile_matrics.dart';
import '../widgets/edit_profile_shimmer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _seeded = false;
  bool _editingName = false;
  bool _editingPhone = false;

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
    context.read<EditProfileCubit>().pickImage();
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.c;

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
              controller: _nameCtrl,
              placeholder: 'Add your name',
              error: state.nameError,
              isEditing: _editingName,
              onToggleEdit: () => setState(() => _editingName = !_editingName),
              textCapitalization: TextCapitalization.words,
            ),

            SizedBox(height: m.gapMd),

            _InfoTile(
              metrics: m,
              icon: Icons.phone_outlined,
              label: 'PHONE NUMBER',
              controller: _phoneCtrl,
              placeholder: 'Add your phone number',
              error: state.phoneError,
              isEditing: _editingPhone,
              onToggleEdit: () =>
                  setState(() => _editingPhone = !_editingPhone),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]')),
                LengthLimitingTextInputFormatter(18),
              ],
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
          backgroundColor: colors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _EditTopBar(metrics: m),

                Expanded(
                  child:
                  state.status == EditProfileStatus.loading &&
                      state.profile == null
                      ? EditProfileShimmer(metrics: m)
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
                      ) : SingleChildScrollView(
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
                        SizedBox(height: m.gapMd),
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
    final colors = context.c;
    final m = metrics;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          m.pageHPad * 0.5,
          m.pageVPad,
          m.pageHPad,
          m.pageVPad,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go(AppRoutes.profile),
              splashRadius: m.backIconSize * 1.2,
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                size: m.backIconSize,
                color: colors.textPrimary,
              ),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: colors.textPrimary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: m.titleSize,
                      letterSpacing: -0.3,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: m.gapXs * 0.6),
                  Text(
                    'Manage your personal information',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: m.avatarHintSize,
                      height: 1.2,
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
    final colors = context.c;
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
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.brand.withValues(alpha: 0.25),
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
                  color: colors.brand,
                  shape: CircleBorder(
                    side: BorderSide(color: colors.background, width: 3),
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
                        color: colors.surface,
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
                color: colors.brand,
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
            color: colors.textSecondary,
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
    final colors = context.c;
    final initials = profile?.initials;

    if (initials == null || initials == '?' || initials.toString().isEmpty) {
      return Icon(
        Icons.person_rounded,
        size: metrics.avatarSize * 0.5,
        color: colors.brand,
      );
    }

    return Text(
      initials,
      style: AppTextStyles.titleLarge.copyWith(
        color: colors.brand,
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
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.all(m.cardPad),
      decoration: BoxDecoration(
        color: colors.brandSoft,
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
                  color: colors.surface.withValues(alpha: colors.isDark ? 0.10 : 0.7),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: m.fieldIconSize,
                  color: colors.brand,
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
                        color: colors.brand,
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
                        color: colors.textPrimary,
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
                  color: colors.surface.withValues(alpha: colors.isDark ? 0.10 : 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Not editable',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.textSecondary,
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
                color: colors.textMuted,
              ),
              SizedBox(width: m.gapSm * 0.8),
              Expanded(
                child: Text(
                  'Your email address cannot be changed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
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

// ── Editable info tile — edits inline, no sheet/screen navigation ──────────
class _InfoTile extends StatelessWidget {
  final EditProfileMetrics metrics;
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final String? error;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _InfoTile({
    required this.metrics,
    required this.icon,
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.error,
    required this.isEditing,
    required this.onToggleEdit,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = metrics;
    final hasError = error != null;
    final isEmpty = controller.text.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(m.cardPad * 0.85),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(m.cardRadius),
            border: Border.all(
              color: hasError
                  ? colors.statusWarning
                  : (isEditing ? colors.brand : colors.border),
              width: hasError || isEditing ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: m.fieldHeight * 0.85,
                height: m.fieldHeight * 0.85,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: m.fieldIconSize, color: colors.brand),
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
                        color: colors.brand,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: m.fieldLabelSize,
                        letterSpacing: 0.6,
                      ),
                    ),
                    SizedBox(height: m.gapXs),
                    isEditing
                        ? TextField(
                            controller: controller,
                            autofocus: true,
                            keyboardType: keyboardType,
                            textCapitalization: textCapitalization,
                            inputFormatters: inputFormatters,
                            onSubmitted: (_) => onToggleEdit(),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: colors.textPrimary,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: m.fieldTextSize,
                              height: 1.3,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: placeholder,
                              hintStyle: AppTextStyles.titleMedium.copyWith(
                                color: colors.textMuted,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: m.fieldTextSize,
                              ),
                            ),
                          )
                        : Text(
                            isEmpty ? placeholder : controller.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: isEmpty ? colors.textMuted : colors.textPrimary,
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

              IconButton(
                onPressed: onToggleEdit,
                splashRadius: m.fieldIconSize,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_outlined,
                  size: m.fieldIconSize,
                  color: colors.brand,
                ),
              ),
            ],
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
                  color: colors.statusWarning,
                ),
                SizedBox(width: m.gapXs),
                Flexible(
                  child: Text(
                    error!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.statusWarning,
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
    final colors = context.c;
    final m = metrics;

    return Container(
      padding: EdgeInsets.fromLTRB(
        m.pageHPad,
        m.gapSm,
        m.pageHPad,
        m.gapSm * 0.5,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: m.maxContentWidth),
            child: AppButton(
              label: 'Save Changes',
              prefixIcon: Icons.save_outlined,
              isLoading: isSaving,
              onPressed: isSaving ? null : onSave,
              height: m.btnHeight,
              fontSize: m.btnFontSize,
            ),
          ),
        ),
      ),
    );
  }
}