import 'package:flutter/material.dart';

/// Singleton to preserve login form state (email/password) across navigation.
///
/// Lifecycle:
/// 1. LoginScreen.initState() → registerControllers()
/// 2. User navigates away or back
/// 3. OTPScreen (or other screens) can call clearForm() to reset the form
/// 4. LoginScreen.dispose() → unregisterControllers()
///
/// Race condition handling:
/// clearForm() may be called during navigation while dispose() is running.
/// Both methods are designed to handle this safely by checking controller state.
class LoginFormManager {
  static final LoginFormManager _instance = LoginFormManager._internal();

  factory LoginFormManager() {
    return _instance;
  }

  LoginFormManager._internal();

  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  FocusNode? _emailFocusNode;
  FocusNode? _passwordFocusNode;

  /// Register controllers from the login screen.
  /// Called in LoginScreen.initState().
  void registerControllers(
    TextEditingController emailController,
    TextEditingController passwordController,
    FocusNode emailFocusNode,
    FocusNode passwordFocusNode,
  ) {
    _emailController = emailController;
    _passwordController = passwordController;
    _emailFocusNode = emailFocusNode;
    _passwordFocusNode = passwordFocusNode;
  }

  void clearForm() {
    try {
      // Safe to clear - wrapped in try-catch to handle race conditions where
      // controllers might be disposed during rapid navigation.
      // This can happen when clearForm() is called from OTP screen's _backToLogin()
      // while Login screen's dispose() is simultaneously running.
      _emailController?.clear();
      _passwordController?.clear();
      _emailFocusNode?.unfocus();
      _passwordFocusNode?.unfocus();
    } catch (e) {
      // Silently ignore any errors that might occur if controllers were disposed
      // during navigation between screens
    }
  }

  /// Unregister controllers from the login screen.
  /// Called in LoginScreen.dispose() to release references before controller disposal.
  /// This is safe to call even if controllers have already been disposed.
  void unregisterControllers() {
    _emailController = null;
    _passwordController = null;
    _emailFocusNode = null;
    _passwordFocusNode = null;
  }
}
