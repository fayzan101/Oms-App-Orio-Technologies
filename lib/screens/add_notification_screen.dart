import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../widgets/custom_nav_bar.dart';
import 'notification_screen.dart';

class AddNotificationScreen extends StatefulWidget {
  final bool isEdit;
  final NotificationModel? notification;
  const AddNotificationScreen({Key? key, this.isEdit = false, this.notification}) : super(key: key);

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final NotificationService _notificationService = NotificationService();
  String? selectedStatus;
  final TextEditingController messageController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  bool whatsapp = true;
  bool email = true;
  bool sms = true;
  bool isActive = true;
  bool isLoading = false;

  final List<String> statuses = ['Confirmed', 'New', 'Processing', 'Delivered', 'Cancelled'];
  
  // Map status names to status IDs
  final Map<String, int> statusIdMap = {
    'Confirmed': 1,
    'New': 2,
    'Processing': 3,
    'Delivered': 4,
    'Cancelled': 5,
  };

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.notification != null) {
      selectedStatus = widget.notification!.statusName;
      messageController.text = widget.notification!.message;
      subjectController.text = widget.notification!.subject;
      whatsapp = widget.notification!.isWhatsapp == 'Y';
      email = widget.notification!.isEmail == 'Y';
      sms = widget.notification!.isSms == 'Y';
      isActive = widget.notification!.status == 'Y';
    } else {
      messageController.text = 'Your Message, Thanks {{CUSTOMER_NAME}} for placing the order. Your order amount is {{ORDER_AMOUNT}}.';
      subjectController.text = 'Order Notification';
    }
  }

  Future<void> _saveNotification() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedStatus == null) {
      Get.snackbar(
        'Error',
        'Please select a status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      bool success;
      
      if (widget.isEdit && widget.notification != null) {
        // Edit existing notification
        success = await _notificationService.editNotification(
          id: int.tryParse(widget.notification!.id) ?? 0,
          acno: 'OR-00009',
          message: messageController.text.trim(),
          statusId: statusIdMap[selectedStatus!] ?? 2,
          subject: subjectController.text.trim(),
          isEmail: email ? 'Y' : 'N',
          isWhatsapp: whatsapp ? 'Y' : 'N',
          isSms: sms ? 'Y' : 'N',
          status: isActive ? 'Y' : 'N',
        );
      } else {
        // Create new notification
        success = await _notificationService.createNotification(
          acno: 'OR-00009',
          message: messageController.text.trim(),
          statusId: statusIdMap[selectedStatus!] ?? 2,
          subject: subjectController.text.trim(),
          isEmail: email ? 'Y' : 'N',
          isWhatsapp: whatsapp ? 'Y' : 'N',
          isSms: sms ? 'Y' : 'N',
          status: isActive ? 'Y' : 'N',
        );
      }

      if (success) {
        Get.snackbar(
          'Success',
          widget.isEdit ? 'Notification updated successfully!' : 'Notification created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Navigate back to notification screen
        Get.off(() => NotificationScreen());
      } else {
        Get.snackbar(
          'Error',
          widget.isEdit ? 'Failed to update notification' : 'Failed to create notification',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        widget.isEdit 
          ? 'Failed to update notification: ${e.toString()}'
          : 'Failed to create notification: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
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
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
                controller: subjectController,
                decoration: _inputDecoration('Subject'),
                validator: (val) => val == null || val.isEmpty ? 'Enter subject' : null,
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
                  onPressed: isLoading ? null : _saveNotification,
                  child: isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(widget.isEdit ? 'Update' : 'Save', style: const TextStyle(fontSize: 18, color: Colors.white)),
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
      resizeToAvoidBottomInset: false,
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