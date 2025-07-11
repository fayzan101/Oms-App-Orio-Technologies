import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart' as dash;
import 'report.dart' as report;
import 'menu.dart' as menu;
import 'create_order.dart' as create_order;
import 'create_cn_screen.dart';
import '../network/order_service.dart';
import 'filter_screen.dart';
import 'search_screen.dart';
import 'quick_edit_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import 'calendar_screen.dart';
import '../widgets/custom_date_selector.dart';

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

  // Search and date filter state
  String? _searchQuery;
  List<dynamic> _filteredOrders = [];
  final TextEditingController _searchController = TextEditingController();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchReportSummary();
    fetchOrders(reset: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoading && hasMore) {
        fetchOrders();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applySearch();
    });
  }

  void _applySearch() {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredOrders = orders.where((order) {
        return order.values.any((v) => v != null && v.toString().toLowerCase().contains(_searchQuery!.toLowerCase()));
      }).toList();
    } else {
      _filteredOrders = orders;
    }
  }

  Future<void> fetchReportSummary() async {
    try {
      final summary = await OrderService.fetchReportSummary(
        acno: 'OR-00009',
        startDate: _startDate.toIso8601String().split('T')[0],
        endDate: _endDate.toIso8601String().split('T')[0],
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

  Future<void> fetchOrders({bool reset = false}) async {
    if (reset) {
      setState(() {
        orders = [];
        startLimit = 1;
        endLimit = 20;
        hasMore = true;
      });
    }
    setState(() => isLoading = true);
    try {
      final data = await OrderService.fetchOrders(
        startLimit: startLimit,
        endLimit: endLimit,
        startDate: _startDate.toIso8601String().split('T')[0],
        endDate: _endDate.toIso8601String().split('T')[0],
      );
      final List<dynamic> newOrders = data['data'] ?? [];
      setState(() {
        orders.addAll(newOrders);
        startLimit = endLimit + 1;
        endLimit += 20;
        hasMore = newOrders.isNotEmpty;
        _applySearch();
      });
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDeleteOrderDialog(BuildContext context, VoidCallback onConfirm) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Icon(Icons.delete_outline, size: 56, color: Color(0xFF007AFF)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Are you Sure',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SF Pro Display',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'You want to delete this order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'SF Pro Display',
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF111827),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('No', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w600)),
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
                _trackingDetailRow('Status', 'Shipped'),
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
        shadowColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
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
          if (_searchQuery != null && _searchQuery!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = null;
                  _applySearch();
                });
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
            onPressed: () async {
              final picked = await showDialog<DateTimeRange>(
                context: context,
                barrierDismissible: true,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(24),
                    child: CustomDateSelector(
                      initialStartDate: _startDate,
                      initialEndDate: _endDate,
                    ),
                  ),
                ),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = picked.end;
                });
                await fetchReportSummary();
                await fetchOrders(reset: true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by any field',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ),
            // --- End Search Bar ---
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
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateCnScreen()),
                    );
                  },
                  child: const Text('Create CN', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF007AFF), decoration: TextDecoration.underline)),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const _BulkTrackingBottomSheet(),
                    );
                  },
                  child: const Text('Bulk Tracking', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF007AFF), decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Orders List
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredOrders.length : orders.length) + (isLoading ? 1 : 0),
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final list = (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredOrders : orders);
                  if (i >= list.length) {
                    return Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final order = list[i];
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
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Action', style: TextStyle(fontWeight: FontWeight.w700)),
                                      const SizedBox(width: 32),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              _showDeleteOrderDialog(context, () {
                                                setState(() {
                                                  orders.removeAt(i);
                                                });
                                              });
                                            },
                                            child: Row(
                                              children: const [
                                                Icon(Icons.delete_outline, color: Color(0xFF007AFF)),
                                                SizedBox(width: 4),
                                                Text('Delete', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (_) => const QuickEditScreen()),
                                              );
                                            },
                                            child: Row(
                                              children: const [
                                                Icon(Icons.edit, color: Color(0xFF007AFF)),
                                                SizedBox(width: 4),
                                                Text('Quick Edit', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
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
      bottomNavigationBar: const AppBottomBar(currentTab: 1),
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

class _BulkTrackingBottomSheet extends StatelessWidget {
  const _BulkTrackingBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  'Bulk Tracking',
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
            _trackingDetailRow('Status', 'Shipped'),
            _trackingDetailRow('CN#', '5024657241'),
            _trackingDetailRow('Date', '2023-07-25'),
            _trackingDetailRow('Customer', 'Asad Ahmed Khan'),
            _trackingDetailRow('COD', '4200'),
          ],
        ),
      ),
    );
  }

  Widget _trackingDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
} 