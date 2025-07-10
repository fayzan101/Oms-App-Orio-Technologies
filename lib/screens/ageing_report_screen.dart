import 'package:flutter/material.dart';
import '../network/order_service.dart';
import 'filter_screen.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;
import 'search_screen.dart';
import 'package:get/get.dart';
import 'calendar_screen.dart';

class AgeingReportScreen extends StatefulWidget {
  const AgeingReportScreen({Key? key}) : super(key: key);

  @override
  State<AgeingReportScreen> createState() => _AgeingReportScreenState();
}

class _AgeingReportScreenState extends State<AgeingReportScreen> {
  // Summary data (mock for now, can be updated if API provides summary)
  int booked = 0;
  int arrival = 0;
  int inTransit = 0;
  int failed = 0;

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  final Set<int> expanded = {};

  @override
  void initState() {
    super.initState();
    fetchAgeingReport();
  }

  Future<void> fetchAgeingReport() async {
    setState(() => isLoading = true);
    try {
      final data = await OrderService.fetchAgeingReport(
        acno: 'OR-00009',
        startLimit: 1,
        endLimit: 50000,
        startDate: '2024-02-20',
        endDate: '2025-03-21',
        ageingType: 'order',
      );
      setState(() {
        orders = data;
        // Optionally, calculate summary values from data if needed
        booked = data.length; // Example: count as booked
        // arrival, inTransit, failed can be calculated if API provides such info
      });
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => isLoading = false);
    }
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
          'Ageing Report',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 18,
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
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FilterScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: () {
              Get.to(() => const CalendarScreen());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryColumn(label: 'Booked', value: booked.toString()),
                  _SummaryColumn(label: 'Arrival', value: arrival.toString()),
                  _SummaryColumn(label: 'In Transit', value: inTransit.toString()),
                  _SummaryColumn(label: 'Failed', value: failed.toString()),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Orders List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                      ? const Center(child: Text('No data found'))
                      : ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (context, i) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final order = orders[i];
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
                                      title: Text('Order ID:   ${order['id'] ?? ''}'),
                                      trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                    ),
                                    if (isExpanded)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Consignee:   ${order['consignee_name'] ?? ''}'),
                                            Text('Address:   ${order['city_name'] ?? ''}'),
                                            Text('Status:   ${order['status_name'] ?? ''}'),
                                            Text('Amount:   ${order['order_amount'] ?? ''}'),
                                            Text('Consignee Contact:   ${order['consignee_contact'] ?? ''}'),
                                            Text('Order Ref:   ${order['order_ref'] ?? ''}'),
                                            Text('Store Name:   ${order['store_name'] ?? ''}'),
                                            Text('Courier Name:   ${order['courier_name'] ?? ''}'),
                                            Text('Order Date:   ${order['order_date'] ?? ''}'),
                                            Text('Remarks:   ${order['account_title'] ?? ''}'),
                                            // Add more fields as needed
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

class _SummaryColumn extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w400, fontSize: 13, color: Color(0xFF8E8E93))),
      ],
    );
  }
} 