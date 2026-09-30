import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_bottom_sheets.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/chat_session_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

const String _welcomeMessage =
    'Hello \u{1F44B} Welcome to Support. How can we help you today?';

class ChatSessionScreen extends StatefulWidget {
  const ChatSessionScreen({super.key});

  @override
  State<ChatSessionScreen> createState() => _ChatSessionScreenState();
}

class _ChatSessionScreenState extends State<ChatSessionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().checkCurrentSession();
  }

  Future<void> _confirmClose(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'End Chat?',
      message:
          'This will close the conversation. You can always start a new chat later.',
      confirmLabel: 'End Chat',
      isDestructive: true,
      icon: Icons.close_rounded,
    );
    if (!confirmed || !context.mounted) return;

    final error = await context.read<ChatCubit>().closeSession();
    if (!context.mounted) return;
    if (error != null) AppSnackbar.showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            final canEndChat = state is ChatSessionLoaded &&
                state.session.status.toUpperCase() != 'CLOSED';

            return Column(
              children: [
                _ChatAppBar(
                  canEndChat: canEndChat,
                  onEndChat: () => _confirmClose(context),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (state is ChatSessionError) {
                        return _ErrorView(
                          message: state.errorMessage,
                          onRetry: () => context
                              .read<ChatCubit>()
                              .checkCurrentSession(),
                        );
                      }

                      if (state is ChatContactInfoRequired) {
                        return const _ContactInfoForm();
                      }

                      if (state is ChatSessionLoaded) {
                        return _SessionBody(state: state);
                      }

                      return const _ChatLoadingShimmer();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  final bool canEndChat;
  final VoidCallback onEndChat;

  const _ChatAppBar({
    required this.canEndChat,
    required this.onEndChat,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.6.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.canPop()
                ? context.pop()
                : context.go(AppRoutes.help),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 20.sp,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Support Chat',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (canEndChat)
            TextButton(
              onPressed: onEndChat,
              child: Text(
                'End Chat',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colors.error,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 15.sp,
                ),
              ),
            )
          else
            SizedBox(width: 3.w),
        ],
      ),
    );
  }
}

class _ContactInfoForm extends StatefulWidget {
  const _ContactInfoForm();

  @override
  State<_ContactInfoForm> createState() => _ContactInfoFormState();
}

class _ContactInfoFormState extends State<_ContactInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ChatCubit>().startSession(
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 4.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: colors.brandSoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.support_agent_rounded,
                size: 11.w,
                color: colors.brand,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Start a Support Chat',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'We couldn’t fetch your saved contact details — '
              'please confirm them below so our team can reach you.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 15.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),
            AppTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              isRequired: true,
              validator: Validators.email,
              labelFontSize: 15.sp,
              hintFontSize: 15.sp,
            ),
            SizedBox(height: 2.h),
            AppTextField(
              label: 'Phone Number',
              hint: 'Digits only',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              isRequired: true,
              validator: Validators.phone,
              labelFontSize: 15.sp,
              hintFontSize: 15.sp,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              height: 6.5.h,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  textStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
                child: const Text('Start Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatLoadingShimmer extends StatelessWidget {
  const _ChatLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    const widths = [58.0, 42.0, 65.0, 48.0, 70.0, 40.0];
    const aligned = [false, true, false, true, false, true];

    return AppShimmer(
      backgroundColor: colors.background,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
        itemCount: widths.length,
        itemBuilder: (context, index) {
          final isMine = aligned[index];

          return Padding(
            padding: EdgeInsets.only(bottom: 1.6.h),
            child: Align(
              alignment: isMine
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: widths[index].w,
                height: 5.4.h,
                decoration: BoxDecoration(
                  color: colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 44.sp, color: colors.error),
            SizedBox(height: 1.6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
                fontFamily: 'Inter',
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 1.6.h),
            SizedBox(
              height: 6.h,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  textStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ChatMessageEntity _welcomeMessageFor(ChatSessionEntity session) {
  return ChatMessageEntity(
    uuid: 'welcome',
    senderType: 'SUPPORT',
    body: _welcomeMessage,
    isRead: true,
    createdAt: session.createdAt,
    sender: ChatContactEntity(
      uuid: 'support',
      fullName: 'Support',
      email: '',
    ),
  );
}

class _SessionBody extends StatelessWidget {
  final ChatSessionLoaded state;

  const _SessionBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final isClosed = session.status.toUpperCase() == 'CLOSED';
    final messages = [_welcomeMessageFor(session), ...state.messages];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[messages.length - 1 - index];
              return Padding(
                padding: EdgeInsets.only(bottom: 1.4.h),
                child: _MessageBubble(message: message),
              );
            },
          ),
        ),
        if (isClosed)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.8.h),
            child: Text(
              'This conversation has ended. Start a new chat any time from Help & Support.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: context.c.textMuted,
                fontFamily: 'Inter',
                fontSize: 14.sp,
              ),
            ),
          )
        else
          _MessageComposer(sessionUuid: session.uuid),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final isMine = message.senderType.toUpperCase() == 'USER';
    final timeFormat = DateFormat('hh:mm a');

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 80.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
          decoration: BoxDecoration(
            color: isMine ? colors.brand : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isMine ? null : Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.body,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMine ? colors.surface : colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 15.sp,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                timeFormat.format(message.createdAt.toLocal()),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isMine
                      ? colors.surface.withValues(alpha: 0.75)
                      : colors.textMuted,
                  fontFamily: 'Inter',
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatefulWidget {
  final String sessionUuid;

  const _MessageComposer({required this.sessionUuid});

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final error = await context.read<ChatCubit>().sendMessage(text);
    if (!mounted) return;

    setState(() => _isSending = false);
    if (error != null) {
      AppSnackbar.showError(context, error);
    } else {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(4.w, 1.4.h, 4.w, 1.4.h),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(top: BorderSide(color: colors.border, width: 1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                enabled: !_isSending,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 15.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: 15.sp,
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: colors.brand, width: 1.5),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Material(
              color: colors.brand,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _isSending ? null : _send,
                child: SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: _isSending
                      ? Padding(
                          padding: EdgeInsets.all(2.8.w),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(colors.surface),
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: colors.surface,
                          size: 21.sp,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
