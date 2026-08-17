import 'package:flutter/material.dart';
import 'auth_metrics.dart';

class AuthLandscapeShell extends StatelessWidget {
  const AuthLandscapeShell({
    super.key,
    required this.m,
    required this.topBar,
    required this.left,
    required this.image,
    required this.form,
    this.footer,
  });

  final AuthMetrics m;
  final Widget topBar;
  final Widget left;
  final Widget image;
  final Widget form;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: m.pagePadH,
          vertical: m.pagePadV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// LEFT
                  Expanded(
                    flex: 4,
                    child: AuthFitPane(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          topBar,
                          SizedBox(height: m.blockGap * 1.4),
                          left,
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: m.paneGap * 0.5),

                  /// CENTER
                  Expanded(flex: 5, child: Center(child: image)),

                  /// DIVIDER
                  AuthPaneDivider(m: m),

                  /// RIGHT
                  SizedBox(
                    width: m.formMaxWidth,
                    child: AuthAutoScrollPane(child: form),
                  ),
                ],
              ),
            ),
            if (footer != null) ...[
              SizedBox(height: m.fieldGap * 0.6),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class AuthFitPane extends StatelessWidget {
  const AuthFitPane({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.minScale = 0.88,
  });

  final Widget child;
  final Alignment alignment;
  final double minScale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (!c.hasBoundedHeight) return child;
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: c.maxHeight / minScale),
              child: SizedBox(width: c.maxWidth, child: child),
            ),
          ),
        );
      },
    );
  }
}

class AuthAutoScrollPane extends StatelessWidget {
  const AuthAutoScrollPane({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

class AuthPaneDivider extends StatelessWidget {
  const AuthPaneDivider({super.key, required this.m});

  final AuthMetrics m;

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).dividerColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: m.paneGap),
      child: SizedBox(
        width: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                line.withValues(alpha: 0),
                line.withValues(alpha: 0.55),
                line.withValues(alpha: 0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
