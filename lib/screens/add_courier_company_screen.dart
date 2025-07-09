import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddCourierCompanyScreen extends StatefulWidget {
  const AddCourierCompanyScreen({Key? key}) : super(key: key);

  @override
  State<AddCourierCompanyScreen> createState() => _AddCourierCompanyScreenState();
}

class _AddCourierCompanyScreenState extends State<AddCourierCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCourier;
  String? selectedStatus;
  bool isDefault = false;
  bool obscurePassword = true;

  final TextEditingController accountTitleController = TextEditingController();
  final TextEditingController accountNoController = TextEditingController();
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();

  final List<String> couriers = ['TCS', 'Leopards', 'BlueEx', 'CallCourier'];
  final List<String> statuses = ['Active', 'Inactive'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Courier Companies'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedCourier,
                decoration: _inputDecoration('Select Courier'),
                items: couriers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedCourier = val),
                validator: (val) => val == null ? 'Please select a courier' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: accountTitleController,
                decoration: _inputDecoration('Account Title'),
                validator: (val) => val == null || val.isEmpty ? 'Enter account title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: accountNoController,
                decoration: _inputDecoration('Account No'),
                validator: (val) => val == null || val.isEmpty ? 'Enter account no' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: userController,
                decoration: _inputDecoration('User'),
                validator: (val) => val == null || val.isEmpty ? 'Enter user' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: _inputDecoration('Password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => obscurePassword = !obscurePassword),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: apiKeyController,
                decoration: _inputDecoration('API Key'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: _inputDecoration('Select Status'),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedStatus = val),
                validator: (val) => val == null ? 'Please select status' : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Default Courier', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: isDefault,
                    onChanged: (val) => setState(() => isDefault = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                      // Implement save logic
                    }
                  },
                  child: const Text('Save', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32), // Add extra space below the Save button
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navBarItem(Icons.home, 'Home', '/dashboard'),
              _navBarItem(Icons.list_alt, 'Order List', '/order-list'),
              const SizedBox(width: 48), // Space for FAB
              _navBarItem(Icons.bar_chart, 'Reports', '/reports'),
              _navBarItem(Icons.menu, 'Menu', '/menu'),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _navBarItem(IconData icon, String label, String route) {
    return InkWell(
      onTap: () {
        Get.offAllNamed(route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: const Color(0xFF0A2A3A)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF0A2A3A))),
        ],
      ),
    );
  }
} 