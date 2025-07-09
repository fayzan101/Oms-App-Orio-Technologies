import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../widgets/custom_nav_bar.dart';

class AddNotificationScreen extends StatefulWidget {
  final bool isEdit;
  final NotificationModel? notification;
  const AddNotificationScreen({Key? key, this.isEdit = false, this.notification}) : super(key: key);

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedStatus;
  final TextEditingController messageController = TextEditingController();
  bool whatsapp = true;
  bool email = true;
  bool sms = true;
  bool isActive = true;

  final List<String> statuses = ['Confirmed', 'New', 'Processing', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.notification != null) {
      selectedStatus = widget.notification!.statusName;
      messageController.text = widget.notification!.message;
      whatsapp = widget.notification!.isWhatsapp == 'Y';
      email = widget.notification!.isEmail == 'Y';
      sms = widget.notification!.isSms == 'Y';
      isActive = widget.notification!.status == 'Y';
    } else {
      messageController.text = 'Your Message, Thanks {{CUSTOMER_NAME}} for placing the order. Your order amount is {{ORDER_AMOUNT}}.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(widget.isEdit ? 'Edit Notification' : 'Add Notification'),
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
                  child: Text(widget.isEdit ? 'Update' : 'Save', style: const TextStyle(fontSize: 18, color: Colors.white)),
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
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 3, // or the appropriate index for this screen
        onTabSelected: (index) {
          if (index == 0) Get.offAllNamed('/dashboard');
          if (index == 1) Get.offAllNamed('/order-list');
          if (index == 2) Get.offAllNamed('/reports');
          if (index == 3) Get.offAllNamed('/menu');
        },
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