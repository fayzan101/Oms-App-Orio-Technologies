import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class SignInController extends GetxController {
  var obscurePassword = true.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = Get.find<AuthService>();

  // Error states for input fields
  final emailError = false.obs;
  final passwordError = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> signIn() async {
    // Dismiss keyboard
    Get.focusScope?.unfocus();
    emailError.value = false;
    passwordError.value = false;

    final email = emailController.text.trim();
    final password = passwordController.text;

    // Simple email validation
    final emailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(email);
    if (email.isEmpty || password.isEmpty || !emailValid) {
      emailError.value = true;
      passwordError.value = true;
      print('Validation failed: emailValid=[32m$emailValid[0m, emailEmpty=[32m${email.isEmpty}[0m, passwordEmpty=[32m${password.isEmpty}[0m');
      Get.snackbar(
        'Invalid',
        'Invalid email or password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    print('Attempting login...');
    final success = await authService.login(email, password);
    print('Login success: $success');

    if (success) {
      print('Navigating to dashboard...');
      Get.offAllNamed('/dashboard');
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Success',
          'Login successful!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      });
    } else {
      emailError.value = true;
      passwordError.value = true;
      print('Login failed');
      Get.snackbar(
        'Invalid',
        'Invalid email or password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }
} 