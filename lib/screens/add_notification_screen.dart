import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedStatus;
  final TextEditingController messageController = TextEditingController(text: 'Your Message, Thanks {{CUSTOMER_NAME}} for placing the order. Your order amount is {{ORDER_AMOUNT}}.');
  bool whatsapp = true;
  bool email = true;
  bool sms = true;
  bool isActive = true;

  final List<String> statuses = ['Confirmed', 'New', 'Processing', 'Delivered', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: _inputDecoration('Select Status'),
                items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedStatus = val),
                validator: (val) => val == null ? 'Please select status' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: messageController,
                maxLines: 4,
                decoration: _inputDecoration('Your Message'),
                validator: (val) => val == null || val.isEmpty ? 'Enter message' : null,
              ),
              const SizedBox(height: 24),
              const Text('Choose Notification to Send to your Customer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              _toggleRow('WhatsApp Notification', whatsapp, (val) => setState(() => whatsapp = val)),
              _toggleRow('Email Notification', email, (val) => setState(() => email = val)),
              _toggleRow('SMS Notification', sms, (val) => setState(() => sms = val)),
              const SizedBox(height: 24),
              const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Inactive/Active', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: isActive,
                    onChanged: (val) => setState(() => isActive = val),
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
              const SizedBox(height: 32),
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

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Switch(value: value, onChanged: onChanged),
      ],
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