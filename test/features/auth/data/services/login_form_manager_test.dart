import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bingo_pay/features/auth/data/services/login_form_manager.dart';

void main() {
  group('LoginFormManager - Lifecycle and Race Conditions', () {
    test('should register and unregister controllers safely', () {
      final manager = LoginFormManager();

      final emailController = TextEditingController();
      final passwordController = TextEditingController();
      final emailFocus = FocusNode();
      final passwordFocus = FocusNode();

      // Register controllers
      manager.registerControllers(
        emailController,
        passwordController,
        emailFocus,
        passwordFocus,
      );

      // Unregister should clear references
      manager.unregisterControllers();

      // Verify references are cleared (no exceptions when clearing form now)
      expect(
        () => manager.clearForm(),
        returnsNormally,
      );

      // Cleanup
      emailController.dispose();
      passwordController.dispose();
      emailFocus.dispose();
      passwordFocus.dispose();
    });

    test('should clear form when controllers are valid', () {
      final manager = LoginFormManager();

      final emailController = TextEditingController(text: 'test@example.com');
      final passwordController = TextEditingController(text: 'password123');
      final emailFocus = FocusNode();
      final passwordFocus = FocusNode();

      manager.registerControllers(
        emailController,
        passwordController,
        emailFocus,
        passwordFocus,
      );

      // Clear form should work normally
      manager.clearForm();

      expect(emailController.text, isEmpty);
      expect(passwordController.text, isEmpty);

      // Cleanup
      emailController.dispose();
      passwordController.dispose();
      emailFocus.dispose();
      passwordFocus.dispose();
      manager.unregisterControllers();
    });

    test('should not throw when clearing form after controller disposal', () {
      final manager = LoginFormManager();

      final emailController = TextEditingController();
      final passwordController = TextEditingController();
      final emailFocus = FocusNode();
      final passwordFocus = FocusNode();

      manager.registerControllers(
        emailController,
        passwordController,
        emailFocus,
        passwordFocus,
      );

      // Dispose controllers (simulating the login screen's dispose)
      emailController.dispose();
      passwordController.dispose();
      emailFocus.dispose();
      passwordFocus.dispose();

      // clearForm() should NOT throw even after disposal
      expect(
        () => manager.clearForm(),
        returnsNormally,
      );

      // Unregister should also work safely
      expect(
        () => manager.unregisterControllers(),
        returnsNormally,
      );
    });

    test('should handle rapid navigation: OTP back to Login scenario', () {
      final manager = LoginFormManager();

      // Login screen registers controllers
      final emailController = TextEditingController(text: 'user@test.com');
      final passwordController = TextEditingController(text: 'pass123');
      final emailFocus = FocusNode();
      final passwordFocus = FocusNode();

      manager.registerControllers(
        emailController,
        passwordController,
        emailFocus,
        passwordFocus,
      );

      // User navigates to OTP screen
      // OTP screen calls clearForm() during navigation back
      expect(
        () => manager.clearForm(),
        returnsNormally,
      );

      // At the same time, Login screen's dispose runs and disposes controllers
      emailController.dispose();
      passwordController.dispose();
      emailFocus.dispose();
      passwordFocus.dispose();

      // OTP screen might call clearForm() again during rapid back-navigation
      // This should not crash even with disposed controllers
      expect(
        () => manager.clearForm(),
        returnsNormally,
      );

      // Login screen's dispose completes by unregistering
      expect(
        () => manager.unregisterControllers(),
        returnsNormally,
      );
    });

    test('should preserve form state until explicitly cleared', () {
      final manager = LoginFormManager();

      final emailController = TextEditingController(text: 'preserved@test.com');
      final passwordController = TextEditingController(text: 'savedpass');
      final emailFocus = FocusNode();
      final passwordFocus = FocusNode();

      manager.registerControllers(
        emailController,
        passwordController,
        emailFocus,
        passwordFocus,
      );

      // Form values should be preserved
      expect(emailController.text, 'preserved@test.com');
      expect(passwordController.text, 'savedpass');

      // After clearForm(), they should be cleared
      manager.clearForm();
      expect(emailController.text, isEmpty);
      expect(passwordController.text, isEmpty);

      // Cleanup
      emailController.dispose();
      passwordController.dispose();
      emailFocus.dispose();
      passwordFocus.dispose();
      manager.unregisterControllers();
    });

    test('should handle Login → OTP → Back → Login complete flow', () {
      final manager = LoginFormManager();

      // Step 1: Login screen initializes
      final emailController1 = TextEditingController();
      final passwordController1 = TextEditingController();
      final emailFocus1 = FocusNode();
      final passwordFocus1 = FocusNode();

      manager.registerControllers(
        emailController1,
        passwordController1,
        emailFocus1,
        passwordFocus1,
      );

      // Step 2: User navigates to OTP
      // OTP screen may call clearForm() before navigation completes
      expect(() => manager.clearForm(), returnsNormally);

      // Step 3: User navigates back to Login
      // Previous Login screen's dispose runs
      expect(() => manager.unregisterControllers(), returnsNormally);
      emailController1.dispose();
      passwordController1.dispose();
      emailFocus1.dispose();
      passwordFocus1.dispose();

      // Step 4: New Login screen instance starts
      final emailController2 = TextEditingController();
      final passwordController2 = TextEditingController();
      final emailFocus2 = FocusNode();
      final passwordFocus2 = FocusNode();

      manager.registerControllers(
        emailController2,
        passwordController2,
        emailFocus2,
        passwordFocus2,
      );

      // Should have new controller references now
      expect(emailController2.text, isEmpty);
      expect(passwordController2.text, isEmpty);

      // Cleanup
      emailController2.dispose();
      passwordController2.dispose();
      emailFocus2.dispose();
      passwordFocus2.dispose();
      manager.unregisterControllers();
    });

    test('should handle clearForm() on already-disposed focus nodes', () {
      final manager = LoginFormManager();

      final emailController = TextEditingController();
      final passwordController = TextEditingController();
      final emailFocus = FocusNode();
      final passwordFocus = FocusNode();

      manager.registerControllers(
        emailController,
        passwordController,
        emailFocus,
        passwordFocus,
      );

      // Dispose only the focus nodes
      emailFocus.dispose();
      passwordFocus.dispose();

      // clearForm() should still work without throwing
      expect(() => manager.clearForm(), returnsNormally);

      // Cleanup
      emailController.dispose();
      passwordController.dispose();
      manager.unregisterControllers();
    });
  });
}
