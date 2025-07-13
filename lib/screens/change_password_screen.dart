import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../utils/custom_snackbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool _isLoading = false;
  String _userId = '';
  String _acno = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('user_id') ?? '';
      _acno = prefs.getString('acno') ?? '';
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that new password and confirm password match
    if (newPasswordController.text != confirmPasswordController.text) {
      customSnackBar('Error', 'New password and confirm password do not match');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.changePassword(
        userId: _userId,
        acno: _acno,
        oldPassword: oldPasswordController.text,
        newPassword: newPasswordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (success) {
        customSnackBar('Success', 'Password updated successfully');
        
        // Clear the form
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        
        // Navigate back after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Get.back();
        });
      } else {
        customSnackBar('Error', _authService.errorMessage.value.isNotEmpty 
            ? _authService.errorMessage.value 
            : 'Failed to change password. Please try again.');
      }
    } catch (e) {
      customSnackBar('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: const Text('Change Password'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E5EA),
            height: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _passwordField('Old Password', oldPasswordController, obscureOld, () => setState(() => obscureOld = !obscureOld)),
              const SizedBox(height: 16),
              _passwordField('New Password', newPasswordController, obscureNew, () => setState(() => obscureNew = !obscureNew)),
              const SizedBox(height: 16),
              _passwordField('Confirm Password', confirmPasswordController, obscureConfirm, () => setState(() => obscureConfirm = !obscureConfirm)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Update Password', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {},
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: const AppBottomBar(selectedIndex: 3),
    );
  }

  Widget _passwordField(String label, TextEditingController controller, bool obscure, VoidCallback toggle) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
          onPressed: toggle,
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Enter $label';
        }
        if (label == 'New Password' && val.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
} 