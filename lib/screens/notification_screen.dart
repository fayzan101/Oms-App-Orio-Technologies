import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../utils/custom_snackbar.dart';
import '../utils/Layout/app_bottom_bar.dart';
import 'add_notification_screen.dart';
import 'search_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = Get.find<AuthService>();
  String? _currentAcno;
  final TextEditingController _searchController = TextEditingController();
  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAcno();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUserAcno() async {
    final user = _authService.currentUser.value;
    if (user != null) {
      setState(() {
        _currentAcno = user.acno;
      });
      _fetchNotifications(user.acno);
    }
  }

  void _fetchNotifications(String acno) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final notifications = await _notificationService.getNotifications(acno: acno);
      setState(() {
        _allNotifications = notifications;
        _filteredNotifications = notifications;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotifications = _allNotifications.where((notification) {
        return notification.message.toLowerCase().contains(query) ||
               notification.subject.toLowerCase().contains(query) ||
               notification.statusName.toLowerCase().contains(query) ||
               notification.courierName.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentAcno == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Notifications: ${_filteredNotifications.length.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w500)),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed('/add-notification');
                            },
                            child: const Text(
                              'Add Notification',
                              style: TextStyle(
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by message, subject, status, or courier',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filteredNotifications.isEmpty
                          ? const Center(child: Text('No notifications found.'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              itemCount: _filteredNotifications.length,
                              itemBuilder: (context, index) {
                                final notification = _filteredNotifications[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _infoRow('ID', notification.id),
                                        _infoRow('Order Status', notification.statusName),
                                        _infoRow('Message', notification.message),
                                        _infoRow('Subject', notification.subject),
                                        _infoRow('Activate', notification.status == 'Y' ? 'Active' : 'Inactive'),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Text('Actions', style: TextStyle(fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 16),
                                            IconButton(
                                              icon: const Icon(Icons.edit, color: Color(0xFF007AFF)),
                                              onPressed: () {
                                                Get.toNamed('/edit-notification', arguments: notification);
                                              },
                                            ),
                                            const Text('Edit', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Color(0xFF007AFF)),
                                              onPressed: () {
                                                _showDeleteConfirmation(context, () {
                                                  _deleteNotification(notification);
                                                });
                                              },
                                            ),
                                            const Text('Delete', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF0A2A3A),
              onPressed: () {
                Get.toNamed('/add-notification');
              },
              child: const Icon(Icons.edit, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const AppBottomBar(currentTab: 3),
    );
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      final success = await _notificationService.deleteNotification(
        int.tryParse(notification.id) ?? 0,
        _currentAcno ?? '',
      );

      if (success) {
        customSnackBar('Success', 'Notification deleted successfully!');
        
        // Refresh the screen to show updated list
        setState(() {});
      } else {
        customSnackBar('Error', 'Failed to delete notification');
      }
    } catch (e) {
      customSnackBar('Error', 'Failed to delete notification: ${e.toString()}');
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110, // fixed width for label for alignment
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.left),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.normal), textAlign: TextAlign.left)),
        ],
      ),
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

  void _showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FF),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: const Icon(Icons.delete_outline, color: Color(0xFF007AFF), size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Are you Sure',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You want to delete this notification',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F2F7),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('No', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteSuccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F0FF),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: const Icon(Icons.check, color: Color(0xFF007AFF), size: 64),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Success!',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have successfully deleted notification',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Ok', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 