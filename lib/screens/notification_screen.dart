import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({Key? key}) : super(key: key);

  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationService.getNotifications('OR-00009'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found.'));
          }
          final notifications = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Notifications: ${notifications.length.toString().padLeft(2, '0')}',
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
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
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
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Notification'),
                                        content: const Text('Are you sure you want to delete this notification?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(ctx).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Implement delete logic
                                              Navigator.of(ctx).pop();
                                            },
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2A3A),
        onPressed: () {
          Get.toNamed('/add-notification');
        },
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
} 