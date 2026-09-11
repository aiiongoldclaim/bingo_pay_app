import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'booking_details_metrics.dart';

class BookingCancelDialog extends StatefulWidget {
  const BookingCancelDialog({super.key});

  @override
  State<BookingCancelDialog> createState() =>
      _BookingCancelDialogState();
}

class _BookingCancelDialogState
    extends State<BookingCancelDialog> {
  late final TextEditingController _reasonController;
  late final FocusNode _reasonFocusNode;

  String? _errorText;

  @override
  void initState() {
    super.initState();

    _reasonController = TextEditingController();
    _reasonFocusNode = FocusNode();

    _reasonController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorText != null &&
        _reasonController.text.trim().isNotEmpty) {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  void dispose() {
    _reasonController.removeListener(_clearError);
    _reasonController.dispose();
    _reasonFocusNode.dispose();

    super.dispose();
  }

  void _submit() {
    final reason = _reasonController.text.trim();

    if (reason.isEmpty) {
      setState(() {
        _errorText =
            AppStrings.cancellationReasonRequired;
      });

      _reasonFocusNode.requestFocus();
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop(reason);
  }

  void _close() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final m = BookingDetailsMetrics.of(context);

    return AlertDialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(m.dialogRadius),
      ),
      title: Text(
        AppStrings.cancelBookingQuestion,
        style: TextStyle(
          color: colors.textPrimary,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.cancellationReasonPrompt,
              style: TextStyle(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: m.dialogBodySize,
              ),
            ),
            SizedBox(height: m.cancelFieldGapH),
            TextField(
              controller: _reasonController,
              focusNode: _reasonFocusNode,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: AppStrings.cancellationReasonHint,
                errorText: _errorText,
                filled: true,
                fillColor: colors.background,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: colors.border,
                  ),
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: colors.border,
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: colors.brand,
                  ),
                ),
                errorBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: colors.brand,
                  ),
                ),
                focusedErrorBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(m.cancelFieldRadius),
                  borderSide: BorderSide(
                    color: colors.brand,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _close,
          child: Text(
            AppStrings.keepBooking,
            style: TextStyle(
              color: colors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: colors.brand,
          ),
          child: const Text(
            AppStrings.cancelBookingCta,
          ),
        ),
      ],
    );
  }
}
