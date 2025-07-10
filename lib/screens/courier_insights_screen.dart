import 'package:flutter/material.dart';
import '../network/order_service.dart';
import 'filter_screen.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;
import 'search_screen.dart';
import 'package:get/get.dart';
import 'calendar_screen.dart';

class CourierInsightsScreen extends StatefulWidget {
  const CourierInsightsScreen({Key? key}) : super(key: key);

  @override
  State<CourierInsightsScreen> createState() => _CourierInsightsScreenState();
}

class _CourierInsightsScreenState extends State<CourierInsightsScreen> {
  int totalReports = 0;
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;
  final Set<int> expanded = {};

  @override
  void initState() {
    super.initState();
    fetchCourierInsights();
  }

  Future<void> fetchCourierInsights() async {
    setState(() => isLoading = true);
    try {
      final data = await OrderService.fetchCourierInsights(
        acno: 'OR-00009',
        startLimit: 1,
        endLimit: 50000,
        startDate: '2024-02-20',
        endDate: '2025-03-21',
      );
      setState(() {
        reports = data;
        totalReports = data.length;
      });
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showTrackingDialog(BuildContext context) {
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tracking',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        fontFamily: 'SF Pro Display',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _trackingDetailRow('Status', 'Booked'),
                _trackingDetailRow('CN#', '5024657241'),
                _trackingDetailRow('Date', '2023-07-25'),
                _trackingDetailRow('Customer', 'Asad Ahmed Khan'),
                _trackingDetailRow('COD', '4200'),
                _trackingDetailRow('From To', 'Lahore   Karachi'),
                const SizedBox(height: 12),
                const Text(
                  'Courier Shipping Label: 5024657241',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'SF Pro Display'),
                ),
                const SizedBox(height: 4),
                const Text(
                  'August 8th, 2023 12:09:00 - Order information received pending at Shippers end.',
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13, fontFamily: 'SF Pro Display', color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _trackingDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SF Pro Display',
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'SF Pro Display',
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Courier Insights',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FilterScreen()),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
              onPressed: () {
                Get.to(() => const CalendarScreen());
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Total Courier Insights Reports: $totalReports',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reports.isEmpty
                      ? const Center(child: Text('No data found'))
                      : ListView.separated(
                          itemCount: reports.length,
                          separatorBuilder: (context, i) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final report = reports[i];
                            final isExpanded = expanded.contains(i);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    expanded.remove(i);
                                  } else {
                                    expanded.add(i);
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: const Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(report['id']?.toString() ?? ''),
                                      trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                    ),
                                    if (isExpanded)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Consignee:   ${report['consignee_name'] ?? ''}'),
                                            Text('Origin City:   ${report['origin_city'] ?? ''}'),
                                            Text('Destination City:   ${report['destination_city'] ?? ''}'),
                                            Text('Status:   ${report['status_name'] ?? ''}'),
                                            Text('Amount:   ${report['order_amount'] ?? ''}'),
                                            Text('Consignee Contact:   ${report['contact'] ?? ''}'),
                                            Text('Order Ref:   ${report['order_ref'] ?? ''}'),
                                            Text('Store Name:   ${report['account_title'] ?? ''}'),
                                            Text('Courier Name:   ${report['courier_name'] ?? ''}'),
                                            Text('Order Date:   ${report['created_date'] ?? ''}'),
                                            Text('Remarks:   ${report['tags_name'] ?? ''}'),
                                            // Add more fields as needed
                                            const SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Action:', style: TextStyle(fontWeight: FontWeight.w700)),
                                                const SizedBox(width: 32),
                                                GestureDetector(
                                                  onTap: () {
                                                    _showTrackingDialog(context);
                                                  },
                                                  child: Row(
                                                    children: const [
                                                      Icon(Icons.place_outlined, color: Color(0xFF007AFF)),
                                                      SizedBox(width: 4),
                                                      Text('Tracking', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
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
      ),
      bottomNavigationBar: dash.CustomBottomNavBar(
        selectedIndex: 2,
        onHomeTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => dash.DashboardScreen()),
            (route) => false,
          );
        },
        onMenuTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => menu.MenuScreen()),
            (route) => false,
          );
        },
        onReportsTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => report.ReportsScreen()),
            (route) => false,
          );
        },
        onOrderListTap: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A253B),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
      ),
    );
  }
} 