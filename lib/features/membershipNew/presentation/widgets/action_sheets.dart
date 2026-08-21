import 'package:flutter/material.dart';
import 'package:bingo_pay/core/theme/app_theme_colors.dart';
import 'package:bingo_pay/core/theme/theme_colors.dart';

import 'membership_metrices.dart';

/// Cancel / Resume ke confirmation sheets.
/// `true` return karta hai jab user confirm kare.
class MembershipActionSheets {
  const MembershipActionSheets._();

  static Future<bool> confirmCancel(
      BuildContext context, {
        required MembershipMetrics metrics,
        required String planName,
        required String validTill,
      }) => _confirm(
    context,
    metrics: metrics,
    icon: Icons.pause_circle_outline_rounded,
    danger: true,
    title: 'Cancel membership?',
    body:
    'Your $planName benefits will stay active till $validTill. After that you go back to the free plan. Your listings stay safe.',
    confirmLabel: 'Yes, cancel',
    dismissLabel: 'Keep membership',
  );

  static Future<bool> confirmResume(
      BuildContext context, {
        required MembershipMetrics metrics,
        required String planName,
      }) => _confirm(
    context,
    metrics: metrics,
    icon: Icons.play_circle_outline_rounded,
    danger: false,
    title: 'Resume membership?',
    body:
    '$planName will be reactivated for the remaining period. Nothing further to pay.',
    confirmLabel: 'Resume now',
    dismissLabel: 'Not now',
  );

  static Future<bool> _confirm(
      BuildContext context, {
        required MembershipMetrics metrics,
        required IconData icon,
        required bool danger,
        required String title,
        required String body,
        required String confirmLabel,
        required String dismissLabel,
      }) async {
    final m = metrics;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      // sheet bg hamesha scaffold bg — cardColor dark me almost transparent hai
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(m.radiusLg)),
      ),
      builder: (sheetContext) {
        final c = sheetContext.c;
        final accent = danger ? c.statusWarning : c.statusSuccess;
        final accentSoft = danger ? c.statusWarningSoft : c.statusSuccessSoft;

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              m.hPad,
              m.cardPad,
              m.hPad,
              m.sectionGap * 0.7,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: m.maxContentWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: m.iconBox,
                        height: m.progressHeight * 0.6,
                        decoration: BoxDecoration(
                          color: c.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    SizedBox(height: m.sectionGap * 0.7),
                    Center(
                      child: Container(
                        width: m.iconCircle * 1.2,
                        height: m.iconCircle * 1.2,
                        decoration: BoxDecoration(
                          color: accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: m.iconCircle * 0.6,
                          color: accent,
                        ),
                      ),
                    ),
                    SizedBox(height: m.rowGap),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: m.sectionTitleSize,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    SizedBox(height: m.rowGap * 0.5),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: m.labelSize,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                        color: c.textSecondary,
                      ),
                    ),
                    SizedBox(height: m.sectionGap * 0.8),
                    SizedBox(
                      height: m.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: danger ? accent : c.brand,
                          foregroundColor: ThemeColors.white,
                          elevation: 0,
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(m.radiusMd),
                          ),
                        ),
                        child: Text(
                          confirmLabel,
                          style: TextStyle(
                            fontSize: m.sectionTitleSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: m.rowGap * 0.6),
                    SizedBox(
                      height: m.buttonHeight,
                      child: TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: c.textSecondary,
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(m.radiusMd),
                          ),
                        ),
                        child: Text(
                          dismissLabel,
                          style: TextStyle(
                            fontSize: m.labelSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    return result ?? false;
  }
}