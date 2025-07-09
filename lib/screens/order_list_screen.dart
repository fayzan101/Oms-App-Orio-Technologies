import 'package:flutter/material.dart';
import 'dashboard_screen.dart' as dash;
import 'report.dart' as report;
import 'menu.dart' as menu;
import 'create_order.dart' as create_order;
import '../network/order_service.dart';
import 'filter_screen.dart';
import '../widgets/custom_nav_bar.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({Key? key}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<dynamic> orders = [];
  int startLimit = 1;
  int endLimit = 20;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final Set<int> expanded = {};

  // Report summary state
  int totalOrders = 0;
  int fulfilledOrders = 0;
  int deliveredOrders = 0;
  int returnedOrders = 0;

  @override
  void initState() {
    super.initState();
    fetchReportSummary();
    fetchOrders();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoading && hasMore) {
        fetchOrders();
      }
    });
  }

  Future<void> fetchReportSummary() async {
    try {
      final summary = await OrderService.fetchReportSummary(
        acno: 'OR-00009',
        startDate: '2025-01-01',
        endDate: '2025-03-21',
      );
      setState(() {
        totalOrders = int.tryParse(summary['orders']?['total']?.toString() ?? '0') ?? 0;
        fulfilledOrders = int.tryParse(summary['booked_orders']?['total']?.toString() ?? '0') ?? 0;
        deliveredOrders = int.tryParse(summary['delivered_orders']?['total']?.toString() ?? '0') ?? 0;
        returnedOrders = int.tryParse(summary['returned_orders']?['total']?.toString() ?? '0') ?? 0;
      });
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final data = await OrderService.fetchOrders(
        startLimit: startLimit,
        endLimit: endLimit,
      );
      final List<dynamic> newOrders = data['data'] ?? [];
      setState(() {
        orders.addAll(newOrders);
        startLimit = endLimit + 1;
        endLimit += 20;
        hasMore = newOrders.isNotEmpty;
      });
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          'Orders',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
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
            onPressed: () {},
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
                  _SummaryColumn(label: 'Total', value: totalOrders.toString()),
                  _SummaryColumn(label: 'Fulfilled', value: fulfilledOrders.toString()),
                  _SummaryColumn(label: 'Delivered', value: deliveredOrders.toString()),
                  _SummaryColumn(label: 'Returns', value: returnedOrders.toString()),
                ],
              ),
            ),
            // Select All and Actions
            Row(
              children: [
                Checkbox(
                  value: false, // selectAll is removed, so this will always be false
                  onChanged: (val) {
                    // This functionality is removed
                  },
                  activeColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const Text('Select All', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15)),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Create CN', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF007AFF), decoration: TextDecoration.underline)),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {},
                  child: const Text('Bulk Tracking', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF007AFF), decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Orders List
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: orders.length + (isLoading ? 1 : 0),
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i >= orders.length) {
                    return Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ));
                  }
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
                            title: Text('Order ID:  ${order['id'] ?? ''}'),
                            trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Consignee:  ${order['consignee_name'] ?? ''}'),
                                  Text('Address:  ${order['consignee_address'] ?? ''}'),
                                  Text('Status:  ${order['status'] ?? ''}'),
                                  Text('Amount:  ${order['order_amount'] ?? ''}'),
                                  Text('Consignee Email:  ${order['consignee_email'] ?? ''}'),
                                  Text('Consignee Contact:  ${order['consignee_contact'] ?? ''}'),
                                  Text('Order Ref:  ${order['order_ref'] ?? ''}'),
                                  Text('Store Name:  ${order['store_name'] ?? ''}'),
                                  Text('Courier Name:  ${order['courier_name'] ?? ''}'),
                                  Text('Remarks:  ${order['remarks'] ?? ''}'),
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
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 1,
        onTabSelected: (index) {
          if (index == 0) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => dash.DashboardScreen()), (route) => false);
          if (index == 1) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => OrderListScreen()), (route) => false);
          if (index == 2) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => report.ReportsScreen()), (route) => false);
          if (index == 3) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => menu.MenuScreen()), (route) => false);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => create_order.CreateOrderScreen()),
            (route) => false,
          );
        },
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