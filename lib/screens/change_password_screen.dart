import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_nav_bar.dart';

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
  bool obscureOld = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Implement update password logic
                    }
                  },
                  child: const Text('Updated', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 3,
        onTabSelected: (index) {
          if (index == 0) Get.offAllNamed('/dashboard');
          if (index == 1) Get.offAllNamed('/order-list');
          if (index == 2) Get.offAllNamed('/reports');
          if (index == 3) Get.offAllNamed('/menu');
        },
      ),
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
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Enter $label' : null,
    );
  }
} 