import 'package:flutter/widgets.dart';

/// Clears text-field focus on every navigation.
///
/// Without this, a focused TextField (e.g. a search bar) keeps its focus
/// state across a push/pop — Flutter restores it when the covering route is
/// popped, silently reopening the keyboard on a screen the user never
/// tapped back into.
class UnfocusNavigatorObserver extends NavigatorObserver {
  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _unfocus();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _unfocus();
}
