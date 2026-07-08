import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportEmail = 'support@bingosg.com';

  static const List<_Faq> _faqs = [
    _Faq(
      question: 'How do I reset my password?',
      answer:
          'Go to the login screen and tap "Forgot Password". Enter your '
          'registered email and follow the instructions sent to you to '
          'reset your password.',
    ),
    _Faq(
      question: 'How can I track my order?',
      answer:
          'Open the Account tab and select "Transactions" to view the '
          'status of all your recent orders and payments.',
    ),
    _Faq(
      question: 'How do I add or update my payment method?',
      answer:
          'Payment methods can be managed from the Account section under '
          '"Payment Methods". You can add, remove, or set a default option.',
    ),
    _Faq(
      question: 'What should I do if a payment fails?',
      answer:
          'If a payment fails, any deducted amount is automatically refunded '
          'within 3-5 business days. If you don\'t see a refund, please '
          'contact our support team with your transaction details.',
    ),
    _Faq(
      question: 'How do I contact customer support?',
      answer:
          'You can reach us anytime at support@bingosg.com and our team '
          'will get back to you as soon as possible.',
    ),
  ];

  void _copyEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _supportEmail));
    AppSnackbar.showSuccess(context, 'Email address copied');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.background,
      appBar: AppBar(
        backgroundColor: ThemeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          _ContactCard(email: _supportEmail, onTapEmail: () => _copyEmail(context)),
          SizedBox(height: 3.h),
          Text('Frequently Asked Questions', style: AppTextStyles.titleMedium),
          SizedBox(height: 1.h),
          ..._faqs.map((faq) => _FaqTile(faq: faq)),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String email;
  final VoidCallback onTapEmail;

  const _ContactCard({required this.email, required this.onTapEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.ink.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Need help?', style: AppTextStyles.titleMedium),
          SizedBox(height: 0.5.h),
          Text(
            'Reach out to our support team and we\'ll get back to you as soon as possible.',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 2.h),
          InkWell(
            onTap: onTapEmail,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            child: Row(
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: ThemeColors.blueSoft,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.mail_outline_rounded,
                    color: ThemeColors.blue,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email us',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(email, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.copy_rounded, color: ThemeColors.inkDim, size: 18.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Faq {
  final String question;
  final String answer;

  const _Faq({required this.question, required this.answer});
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;

  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: ThemeColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.ink.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 4.w),
          childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
          expandedAlignment: Alignment.topLeft,
          iconColor: ThemeColors.blue,
          collapsedIconColor: ThemeColors.inkDim,
          title: Text(
            faq.question,
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          children: [
            Text(faq.answer, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
