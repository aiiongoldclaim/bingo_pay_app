import 'dart:async';

import 'package:flutter/material.dart';

/// Jab [isBlocking] true ho, andar ka poora subtree touch-proof ho jaata hai.
/// UI dikhne mein bilkul same rehta hai — koi dim, overlay ya color change nahi.
class AppInteractionBlocker extends StatefulWidget {
  final bool isBlocking;
  final Widget child;
  final bool blockBackButton;
  final bool dismissKeyboard;

  /// Itne time baad blocking khud release ho jayegi (stuck-state safety)
  final Duration maxBlockDuration;

  const AppInteractionBlocker({
    super.key,
    required this.isBlocking,
    required this.child,
    this.blockBackButton = true,
    this.dismissKeyboard = true,
    this.maxBlockDuration = const Duration(seconds: 30),
  });

  @override
  State<AppInteractionBlocker> createState() => _AppInteractionBlockerState();
}

class _AppInteractionBlockerState extends State<AppInteractionBlocker> {
  Timer? _timer;
  bool _timedOut = false;

  bool get _blocking => widget.isBlocking && !_timedOut;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant AppInteractionBlocker old) {
    super.didUpdateWidget(old);
    if (old.isBlocking != widget.isBlocking) {
      _timedOut = false;
      _sync();
    }
  }

  void _sync() {
    _timer?.cancel();
    if (widget.isBlocking) {
      _timer = Timer(widget.maxBlockDuration, () {
        if (mounted) setState(() => _timedOut = true);
      });
      if (widget.dismissKeyboard) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) FocusScope.of(context).unfocus();
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = AbsorbPointer(absorbing: _blocking, child: widget.child);
    if (widget.blockBackButton) {
      content = PopScope(canPop: !_blocking, child: content);
    }
    return content;
  }
}