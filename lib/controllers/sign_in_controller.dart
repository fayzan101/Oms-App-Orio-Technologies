import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/custom_snackbar.dart';

class SignInController extends GetxController {
  var obscurePassword = true.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = Get.find<AuthService>();

  // Error states for input fields
  final emailError = false.obs;
  final passwordError = false.obs;

  // Remember Me state
  final rememberMe = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remember_email') ?? '';
    final savedPassword = prefs.getString('remember_password') ?? '';
    final savedRemember = prefs.getBool('remember_me') ?? false;
    if (savedRemember) {
      emailController.text = savedEmail;
      passwordController.text = savedPassword;
      rememberMe.value = true;
    }
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
      print('Validation failed: emailValid=\u001b[32m$emailValid\u001b[0m, emailEmpty=\u001b[32m${email.isEmpty}\u001b[0m, passwordEmpty=\u001b[32m${password.isEmpty}\u001b[0m');
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

    // Save or clear credentials based on Remember Me
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe.value) {
      await prefs.setString('remember_email', email);
      await prefs.setString('remember_password', password);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('remember_email');
      await prefs.remove('remember_password');
      await prefs.setBool('remember_me', false);
    }

    print('🔐 Attempting login...');
    final success = await authService.login(email, password);
    print('🔐 Login success: $success');

    if (success) {
      print('🔐 Login successful, navigating to dashboard...');
      Get.offAllNamed('/dashboard');
      Future.delayed(const Duration(milliseconds: 300), () {
        customSnackBar('Success', 'Login successful!');
      });
    } else {
      emailError.value = true;
      passwordError.value = true;
      print('Login failed');
      
      // If login fails and "Remember Me" was enabled, clear the saved credentials
      if (rememberMe.value) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('remember_email');
        await prefs.remove('remember_password');
        await prefs.setBool('remember_me', false);
        rememberMe.value = false;
      }
      
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