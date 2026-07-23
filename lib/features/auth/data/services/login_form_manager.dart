import 'package:flutter/material.dart';

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
    _emailController?.clear();
    _passwordController?.clear();
    _emailFocusNode?.unfocus();
    _passwordFocusNode?.unfocus();
  }

  void unregisterControllers() {
    _emailController = null;
    _passwordController = null;
    _emailFocusNode = null;
    _passwordFocusNode = null;
  }
}
