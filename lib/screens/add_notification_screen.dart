import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../utils/custom_snackbar.dart';
import '../utils/Layout/app_bottom_bar.dart';
import 'notification_screen.dart';

class AddNotificationScreen extends StatefulWidget {
  final bool isEdit;
  final NotificationModel? notification;

  const AddNotificationScreen({
    Key? key,
    this.isEdit = false,
    this.notification,
  }) : super(key: key);

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = Get.find<AuthService>();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  
  String? selectedStatus;
  bool email = false;
  bool whatsapp = false;
  bool sms = false;
  bool isActive = true;
  bool isLoading = false;
  String? _currentAcno;

  final List<String> statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
  final Map<String, int> statusIdMap = {
    'Pending': 1,
    'Processing': 2,
    'Shipped': 3,
    'Delivered': 4,
    'Cancelled': 5,
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAcno();
    if (widget.isEdit && widget.notification != null) {
      _loadNotificationData();
    }
  }

  Future<void> _loadCurrentUserAcno() async {
    final user = _authService.currentUser.value;
    if (user != null) {
      setState(() {
        _currentAcno = user.acno;
      });
    }
  }

  void _loadNotificationData() {
    final notification = widget.notification!;
    subjectController.text = notification.subject;
    messageController.text = notification.message;
    selectedStatus = notification.statusName;
    email = notification.isEmail == 'Y';
    whatsapp = notification.isWhatsapp == 'Y';
    sms = notification.isSms == 'Y';
    isActive = notification.status == 'Y';
  }

  Future<void> _saveNotification() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (selectedStatus == null) {
      customSnackBar('Error', 'Please select a status');
      return;
    }

    if (_currentAcno == null) {
      customSnackBar('Error', 'User account not found');
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
          acno: _currentAcno!,
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
          acno: _currentAcno!,
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
        customSnackBar('Success', widget.isEdit ? 'Notification updated successfully!' : 'Notification created successfully!');
        
        // Navigate back to notification screen
        Get.off(() => const NotificationScreen());
      } else {
        customSnackBar('Error', widget.isEdit ? 'Failed to update notification' : 'Failed to create notification');
      }
    } catch (e) {
      customSnackBar('Error', widget.isEdit 
        ? 'Failed to update notification: ${e.toString()}'
        : 'Failed to create notification: ${e.toString()}');
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
      bottomNavigationBar: const AppBottomBar(currentTab: 3),
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