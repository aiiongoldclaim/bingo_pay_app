import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../scanner/data/tvs_qr_datasource.dart';
import '../../data/pending_invite.dart';
import '../widgets/tvs_ui.dart';

// Landing for invite links and QR codes: /join?ref=CODE (&ch=QR). Shows who
// the invite is from. Signed in, the code is added straight away; signed out,
// it is kept and added once they sign up or log in.
class TvsJoinScreen extends StatefulWidget {
  final Uri uri;

  const TvsJoinScreen({super.key, required this.uri});

  @override
  State<TvsJoinScreen> createState() => _TvsJoinScreenState();
}

class _TvsJoinScreenState extends State<TvsJoinScreen> {
  late final _invite = PendingInvite.parse(widget.uri);
  Future<Map<String, dynamic>>? _info;
  bool _adding = false;
  bool _added = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final invite = _invite;
    if (invite == null) return;
    // Saved first, so it survives a sign-up that takes a while.
    PendingInvite().save(invite).then((_) {
      if (mounted && context.read<AuthBloc>().state is AuthAuthenticated) {
        _add();
      }
    });
    _info = getIt<TvsQrDataSource>().describeInvite(invite.code);
  }

  Future<void> _add() async {
    if (_adding || _added) return;
    setState(() {
      _adding = true;
      _error = null;
    });
    final error = await PendingInvite().add();
    if (!mounted) return;
    setState(() {
      _adding = false;
      _added = error == null;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final invite = _invite;

    return BlocListener<AuthBloc, AuthState>(
      // Opened before sign-in finished (a link that started the app).
      listenWhen: (previous, current) =>
          current is AuthAuthenticated && previous is! AuthAuthenticated,
      listener: (_, _) {
        if (invite != null) _add();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: CustomAppBar(
          title: 'Invite',
          showBackButton: false,
          actionIcon1: Icons.close_rounded,
          onAction1: () => context.go(AppRoutes.home),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 32,
                backgroundColor: colors.brandSoft,
                child: Icon(Icons.redeem_rounded, size: 30, color: colors.brand),
              ),
            ),
            const SizedBox(height: 16),
            if (invite == null)
              _text(context, 'This invite link is incomplete', null)
            else
              FutureBuilder<Map<String, dynamic>>(
                future: _info,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final info = snap.data;
                  if (info?['valid'] != true) {
                    return _text(
                      context,
                      'This invite isn’t valid',
                      'It may have ended. You can still join and earn rewards.',
                    );
                  }
                  return _text(
                    context,
                    info!['type'] == 'FRIEND'
                        ? '${info['name']} invited you'
                        : 'Join through ${info['name']}',
                    'Get rewards in your TVS Wallet when you join with code '
                        '${info['code']}.',
                  );
                },
              ),
            const SizedBox(height: 24),
            if (invite != null)
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, auth) {
                  if (auth is AuthAuthenticated) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_adding)
                          const Center(child: CircularProgressIndicator())
                        else if (_added || _error != null)
                          Text(
                            _added ? 'Invite code added' : _error!,
                            textAlign: TextAlign.center,
                            style: tvsText(
                              _added ? colors.statusSuccess : colors.error,
                              weight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Continue',
                          onPressed: () => context.go(AppRoutes.home),
                        ),
                      ],
                    );
                  }
                  if (auth is AuthInitial || auth is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Your code is added once you sign up or log in.',
                        textAlign: TextAlign.center,
                        style: tvsText(colors.textSecondary, size: 13),
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Sign up',
                        onPressed: () => context.go(AppRoutes.register),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Log in',
                        variant: AppButtonVariant.outlined,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _text(BuildContext context, String title, String? message) {
    final colors = context.colors;
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: tvsText(colors.textPrimary, size: 20, weight: FontWeight.w700),
        ),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: tvsText(colors.textSecondary),
          ),
        ],
      ],
    );
  }
}
