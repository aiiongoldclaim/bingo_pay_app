import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../cubit/support_ticket_cubit.dart';
import '../cubit/support_ticket_state.dart';

class RaiseTicketSheet extends StatefulWidget {
  const RaiseTicketSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showAppSheet<void>(
      context: context,
      builder: (_) => const RaiseTicketSheet(),
    );
  }

  @override
  State<RaiseTicketSheet> createState() => _RaiseTicketSheetState();
}

class _RaiseTicketSheetState extends State<RaiseTicketSheet> {
  static const _categories = [
    ('ORDER', 'An Order'),
    ('BOOKING', 'A Booking'),
    ('PAYMENT', 'A Payment'),
    ('REFUND', 'A Refund'),
    ('ACCOUNT', 'My Account'),
    ('TECHNICAL', 'Something is broken'),
    ('OTHER', 'Something else'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _categoryFieldKey = GlobalKey();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _relatedRefController = TextEditingController();
  String _category = _categories.first.$1;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _relatedRefController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final relatedRef = _relatedRefController.text.trim();
    context.read<SupportTicketCubit>().raiseTicket(
          category: _category,
          subject: _subjectController.text.trim(),
          description: _descriptionController.text.trim(),
          relatedRef: relatedRef.isEmpty ? null : relatedRef,
        );
  }

  Future<void> _pickCategory(bool isSubmitting) async {
    if (isSubmitting) return;

    final buttonBox =
        _categoryFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (buttonBox == null || overlayBox == null) return;

    final topLeft = buttonBox.localToGlobal(
      Offset(0, buttonBox.size.height + 6),
      ancestor: overlayBox,
    );
    final bottomRight = buttonBox.localToGlobal(
      buttonBox.size.bottomRight(Offset.zero),
      ancestor: overlayBox,
    );

    final colors = context.c;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(topLeft, bottomRight),
        Offset.zero & overlayBox.size,
      ),
      constraints: BoxConstraints(minWidth: buttonBox.size.width),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      items: _categories.map((c) {
        final isSelected = c.$1 == _category;
        return PopupMenuItem<String>(
          value: c.$1,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  c.$2,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_rounded, size: 20.sp, color: colors.brand),
            ],
          ),
        );
      }).toList(),
    );

    if (selected == null) return;
    setState(() => _category = selected);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = SheetMetrics.of(context);
    final fieldLabelSize = 16.sp;
    final fieldTextSize = 16.sp;

    return BlocConsumer<SupportTicketCubit, SupportTicketState>(
      listener: (context, state) {
        final cubit = context.read<SupportTicketCubit>();

        if (state is SupportTicketSubmitted) {
          final ticketUuid = state.ticket.uuid;
          final router = GoRouter.of(context);
          Navigator.pop(context);
          cubit.reset();
          router.push(AppRoutes.ticketDetailPath(ticketUuid));
        } else if (state is SupportTicketError) {
          AppSnackbar.showError(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is SupportTicketSubmitting;
        final categoryLabel = _categories
            .firstWhere((c) => c.$1 == _category, orElse: () => _categories.first)
            .$2;

        return AppSheetShell(
          footer: AppSheetButton(
            label: 'Submit',
            isLoading: isSubmitting,
            onTap: isSubmitting ? null : _submit,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Raise an issue',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: colors.textPrimary,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: m.titleSize,
                              height: 1.25,
                            ),
                          ),
                          SizedBox(height: m.gapXs * 0.6),
                          Text(
                            "We'll get back to you as soon as we can.",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: colors.textSecondary,
                              fontFamily: 'Inter',
                              fontSize: m.captionSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: m.gapSm),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(m.gapXs),
                        child: Icon(
                          Icons.close_rounded,
                          size: m.titleSize + 4,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: m.gapLg),
                Text(
                  'What is this about?',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: fieldLabelSize,
                  ),
                ),
                SizedBox(height: m.gapXs * 1.4),
                Material(
                  key: _categoryFieldKey,
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(m.fieldRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _pickCategory(isSubmitting),
                    child: Container(
                      height: m.fieldHeight,
                      padding: EdgeInsets.symmetric(
                        horizontal: m.gapMd * 0.9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(m.fieldRadius),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              categoryLabel,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: fieldTextSize,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: fieldLabelSize + 8,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: m.gapMd),
                AppTextField(
                  label: 'Subject',
                  hint: 'Briefly describe your issue',
                  controller: _subjectController,
                  enabled: !isSubmitting,
                  isRequired: true,
                  labelFontSize: fieldLabelSize,
                  hintFontSize: fieldTextSize,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Subject is required'
                      : null,
                ),
                SizedBox(height: m.gapMd),
                AppTextField(
                  label: 'Order / Booking Reference (Optional)',
                  hint: 'e.g. BP-10023 or ORD-1234567',
                  controller: _relatedRefController,
                  enabled: !isSubmitting,
                  labelFontSize: fieldLabelSize,
                  hintFontSize: fieldTextSize,
                ),
                SizedBox(height: m.gapMd),
                AppTextField(
                  label: 'Description',
                  hint: 'Tell us more about the issue (min. 15 characters)',
                  controller: _descriptionController,
                  enabled: !isSubmitting,
                  isRequired: true,
                  maxLines: 4,
                  labelFontSize: fieldLabelSize,
                  hintFontSize: fieldTextSize,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Description is required';
                    if (value.length < 15) {
                      return 'Description must be at least 15 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
