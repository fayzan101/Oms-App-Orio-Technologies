import 'package:flutter/material.dart';
import '../utils/Layout/app_bottom_bar.dart';

class DashboardNotificationScreen extends StatelessWidget {
  DashboardNotificationScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> notificationsByDate = const [
    {
      'date': '1-Mar-2025',
      'items': [
        {
          'message': 'Cutt-off time for pickups in Ramadan is 4.00 pm.',
          'time': '06:30 PM',
        },
      ],
    },
    {
      'date': '26-Feb-2025',
      'items': [
        {
          'message': 'Great news! Orio is now delivering in more than 600+ cities ',
          'link': 'Download List',
          'time': '10:00 AM',
        },
      ],
    },
    {
      'date': '22-Feb-2025',
      'items': [
        {
          'message': 'Overnight delivery services in Sawad and One day + delivery services in Badin now available, start Booking Now.',
          'time': '02:30 PM',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          itemCount: notificationsByDate.length,
          itemBuilder: (context, i) {
            final group = notificationsByDate[i];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    group['date'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'SF Pro Display',
                      color: Colors.black,
                    ),
                  ),
                ),
                ...List.generate((group['items'] as List).length, (j) {
                  final item = group['items'][j];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(text: item['message']),
                              if (item['link'] != null)
                                TextSpan(
                                  text: item['link'],
                                  style: const TextStyle(
                                    color: Color(0xFF007AFF),
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['time'],
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A253B),
        child: const Icon(Icons.edit, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const AppBottomBar(currentTab: 0),
    );
  }
} 