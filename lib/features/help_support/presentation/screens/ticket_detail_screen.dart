import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../cubit/support_ticket_cubit.dart';
import '../cubit/support_ticket_state.dart';

class TicketDetailScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupportTicketCubit>().loadTicketDetail(widget.ticketId);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              onRetry: () => context
                  .read<SupportTicketCubit>()
                  .loadTicketDetail(widget.ticketId),
            ),
            Expanded(
              child: BlocBuilder<SupportTicketCubit, SupportTicketState>(
                builder: (context, state) {
                  if (state is SupportTicketError) {
                    return _ErrorView(
                      message: state.errorMessage,
                      onRetry: () => context
                          .read<SupportTicketCubit>()
                          .loadTicketDetail(widget.ticketId),
                    );
                  }

                  if (state is SupportTicketDetailLoaded) {
                    return _TicketBody(ticket: state.ticket);
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            _ReplyComposer(ticketId: widget.ticketId),
          ],
        ),
      ),
    );
  }
}

class _ReplyComposer extends StatefulWidget {
  final String ticketId;

  const _ReplyComposer({required this.ticketId});

  @override
  State<_ReplyComposer> createState() => _ReplyComposerState();
}

class _ReplyComposerState extends State<_ReplyComposer> {
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
    final error = await context.read<SupportTicketCubit>().sendReply(
          ticketId: widget.ticketId,
          body: text,
        );
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
        padding: EdgeInsets.fromLTRB(4.w, 1.2.h, 4.w, 1.2.h),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(top: BorderSide(color: colors.border, width: 1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
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
                  fontSize: 16.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a reply...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textMuted,
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
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

class _TopBar extends StatelessWidget {
  final VoidCallback onRetry;

  const _TopBar({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.c;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/help'),
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              size: 22.sp,
              color: colors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              'Ticket Details',
              style: AppTextStyles.headlineMedium.copyWith(
                color: colors.textPrimary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: 20.sp,
              ),
            ),
          ),
          IconButton(
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh_rounded,
              size: 24.sp,
              color: colors.textSecondary,
            ),
          ),
        ],
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
            Icon(Icons.error_outline_rounded, size: 46.sp, color: colors.error),
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

class _TicketBody extends StatefulWidget {
  final SupportTicketEntity ticket;

  const _TicketBody({required this.ticket});

  @override
  State<_TicketBody> createState() => _TicketBodyState();
}

class _TicketBodyState extends State<_TicketBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _statusColor(BuildContext context) {
    final colors = context.c;
    switch (widget.ticket.status.toUpperCase()) {
      case 'RESOLVED':
        return AppColors.success;
      case 'CLOSED':
        return colors.textMuted;
      case 'PENDING':
        return AppColors.warning;
      default:
        return colors.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = widget.ticket;
    final colors = context.c;
    final statusColor = _statusColor(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final query = _query.trim().toLowerCase();
    final filteredMessages = query.isEmpty
        ? ticket.messages
        : ticket.messages
            .where((m) =>
                m.body.toLowerCase().contains(query) ||
                m.author.fullName.toLowerCase().contains(query))
            .toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.ref,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 19.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.status,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: statusColor,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.2.h),
              Text(
                ticket.subject,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 17.sp,
                ),
              ),
              if (ticket.description != null &&
                  ticket.description!.isNotEmpty) ...[
                SizedBox(height: 0.8.h),
                Text(
                  ticket.description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                    fontFamily: 'Inter',
                    fontSize: 15.sp,
                    height: 1.4,
                  ),
                ),
              ],
              SizedBox(height: 1.6.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  _Tag(label: ticket.category, colors: colors),
                  _Tag(label: ticket.priority, colors: colors),
                ],
              ),
              SizedBox(height: 1.6.h),
              Text(
                'Raised on ${dateFormat.format(ticket.createdAt.toLocal())}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textMuted,
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.4.h),

        Text(
          'Conversation',
          style: AppTextStyles.titleMedium.copyWith(
            color: colors.textPrimary,
            fontFamily: 'CormorantGaramond',
            fontWeight: FontWeight.w700,
            fontSize: 19.sp,
          ),
        ),
        SizedBox(height: 1.4.h),

        if (ticket.messages.isNotEmpty) ...[
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontFamily: 'Inter',
              fontSize: 15.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Search conversation...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: colors.textMuted,
                fontFamily: 'Inter',
                fontSize: 15.sp,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 22.sp,
                color: colors.textMuted,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20.sp,
                        color: colors.textMuted,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: colors.surface,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.4.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.brand, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: 1.6.h),
        ],

        if (ticket.messages.isEmpty)
          Text(
            'No messages yet.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontSize: 15.sp,
            ),
          )
        else if (filteredMessages.isEmpty)
          Text(
            'No messages match your search.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
              fontFamily: 'Inter',
              fontSize: 15.sp,
            ),
          )
        else
          ...filteredMessages.map(
            (message) => Padding(
              padding: EdgeInsets.only(bottom: 1.4.h),
              child: _MessageBubble(
                message: message,
                dateFormat: dateFormat,
                highlightQuery: query,
              ),
            ),
          ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final AppThemeColors colors;

  const _Tag({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
      decoration: BoxDecoration(
        color: colors.brandSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: colors.brand,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

Widget _highlightedText(
  String text,
  String query,
  TextStyle style,
  Color highlightColor,
) {
  if (query.isEmpty) return Text(text, style: style);

  final lowerText = text.toLowerCase();
  final spans = <TextSpan>[];
  var start = 0;
  var index = lowerText.indexOf(query);

  while (index != -1) {
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index)));
    }
    spans.add(
      TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: highlightColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    start = index + query.length;
    index = lowerText.indexOf(query, start);
  }

  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start)));
  }

  return RichText(text: TextSpan(style: style, children: spans));
}

class _MessageBubble extends StatelessWidget {
  final SupportTicketMessageEntity message;
  final DateFormat dateFormat;
  final String highlightQuery;

  const _MessageBubble({
    required this.message,
    required this.dateFormat,
    this.highlightQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.c;
    final isSupport = message.fromSupport;

    return Align(
      alignment: isSupport ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 82.w),
        child: Container(
          padding: EdgeInsets.all(3.4.w),
          decoration: BoxDecoration(
            color: isSupport ? colors.surface : colors.brandSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSupport ? 'Support Team' : message.author.fullName,
                style: AppTextStyles.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 0.6.h),
              _highlightedText(
                message.body,
                highlightQuery,
                AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  height: 1.4,
                ),
                colors.brand.withValues(alpha: 0.35),
              ),
              SizedBox(height: 0.6.h),
              Text(
                dateFormat.format(message.createdAt.toLocal()),
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textMuted,
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
