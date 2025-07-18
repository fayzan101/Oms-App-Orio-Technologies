import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../utils/custom_snackbar.dart';
import '../utils/Layout/app_bottom_bar.dart';
import 'notification_screen.dart';
import 'package:dio/dio.dart';

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

  List<Map<String, dynamic>> statusOptions = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAcno();
    _fetchStatusOptions();
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

  Future<void> _fetchStatusOptions() async {
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/common/status',
        data: {"status_type": "Customer Service"},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is List) {
          setState(() {
            statusOptions = List<Map<String, dynamic>>.from(data);
            print('API statusOptions:');
            print(statusOptions);
          });
        } else if (data is Map && data['payload'] is List) {
          setState(() {
            statusOptions = List<Map<String, dynamic>>.from(data['payload']);
            print('API statusOptions:');
            print(statusOptions);
          });
        }
      }
    } catch (e) {
      print('Error fetching statusOptions: $e');
    }
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
          statusId: statusOptions.firstWhere(
            (opt) => opt['name'] == selectedStatus,
            orElse: () => {'id': 2},
          )['id'],
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
          statusId: statusOptions.firstWhere(
            (opt) => opt['name'] == selectedStatus,
            orElse: () => {'id': 2},
          )['id'],
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
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
        title: Text(widget.isEdit ? 'Edit Notification' : 'Add Notification'),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              // Replace _StatusDropdown with standard DropdownButtonFormField
              (statusOptions.isEmpty || !statusOptions.every((opt) => opt.containsKey('name')))
                  ? const Text('No status options available or data error', style: TextStyle(color: Colors.red))
                  : DropdownButtonFormField<String>(
                      value: statusOptions.any((opt) => opt['name'] == selectedStatus)
                          ? selectedStatus
                          : null,
                      items: statusOptions
                          .map((opt) => DropdownMenuItem<String>(
                                value: opt['name']?.toString(),
                                child: Text(opt['name']?.toString() ?? ''),
                              ))
                          .toList(),
                      onChanged: statusOptions.isNotEmpty
                          ? (val) => setState(() => selectedStatus = val)
                          : null,
                      decoration: InputDecoration(
                        hintText: statusOptions.isNotEmpty ? 'Select Status' : 'No status available',
                        hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF6B6B6B)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.blue, width: 1.5),
                        ),
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF222222)),
                      style: const TextStyle(fontSize: 15, color: Colors.black),
                      validator: (val) => val == null ? 'Please select status' : null,
                    ),
              const SizedBox(height: 16),
              // Subject field: only show if WhatsApp or Email is enabled
              if (whatsapp || email) ...[
                TextFormField(
                  controller: subjectController,
                  decoration: _inputDecoration('Subject'),
                  validator: (val) {
                    if (!(whatsapp || email)) return null;
                    return val == null || val.isEmpty ? 'Enter subject' : null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: messageController,
                maxLines: 4,
                decoration: _inputDecoration('Your Message').copyWith(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  alignLabelWithHint: true,
                ),
                textAlignVertical: TextAlignVertical.top,
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
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
              bottomNavigationBar: const AppBottomBar(selectedIndex: 3),
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

class _StatusDropdown extends StatefulWidget {
  final String? value;
  final List<Map<String, dynamic>> options;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  const _StatusDropdown({Key? key, this.value, required this.options, required this.onChanged, this.validator}) : super(key: key);

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  // Removed search state and search bar
  @override
  Widget build(BuildContext context) {
    // No filtering, just show all options
    final filtered = widget.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Status', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        // Removed search TextFormField here
        // const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: widget.value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: Color(0xFFF7F8FA),
          ),
          items: filtered.map((opt) => DropdownMenuItem(
            value: opt['status_name']?.toString(),
            child: Text(opt['status_name']?.toString() ?? ''),
          )).toList(),
          onChanged: widget.onChanged,
          validator: widget.validator,
        ),
      ],
    );
  }
} 