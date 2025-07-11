import 'package:flutter/material.dart';
import '../network/order_service.dart';
import 'filter_screen.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;
import 'search_screen.dart';
import 'package:get/get.dart';
import 'calendar_screen.dart';
import '../widgets/custom_date_selector.dart';
import 'ageing_report_filter_screen.dart';
import '../utils/custom_snackbar.dart';

class AgeingReportScreen extends StatefulWidget {
  const AgeingReportScreen({Key? key}) : super(key: key);

  @override
  State<AgeingReportScreen> createState() => _AgeingReportScreenState();
}

class _AgeingReportScreenState extends State<AgeingReportScreen> {
  // Summary data (from API)
  int booked = 0;
  int arrival = 0;
  int inTransit = 0;
  int failed = 0;

  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;
  final Set<int> expanded = {};
  // Search state
  String? _searchQuery;
  List<Map<String, dynamic>> _filteredOrders = [];
  final TextEditingController _searchController = TextEditingController();

  // Date range state
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  final String acno = 'OR-00009'; // TODO: Replace with user/session value if available

  // Filter state
  String? filterAgeing;
  String? filterPlatform;
  String? filterCourier;
  String? filterCity;

  @override
  void initState() {
    super.initState();
    fetchAllData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applySearch();
    });
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchSummary(),
      fetchAgeingReport(),
    ]);
  }

  Future<void> fetchSummary() async {
    try {
      final summary = await OrderService.fetchReportSummary(
        acno: acno,
        startDate: _formatDate(startDate),
        endDate: _formatDate(endDate),
        module: 'ageing_report',
      );
      setState(() {
        booked = int.tryParse(summary['booked_orders_count'] ?? '0') ?? 0;
        arrival = int.tryParse(summary['arrival_orders_count'] ?? '0') ?? 0;
        inTransit = int.tryParse(summary['intransit_orders_count'] ?? '0') ?? 0;
        failed = int.tryParse(summary['failed_orders_count'] ?? '0') ?? 0;
      });
    } catch (e) {
      // Optionally show error
    }
  }

  Future<void> fetchAgeingReport() async {
    setState(() => isLoading = true);
    try {
      // First, fetch data without server-side filters to get all data for client-side filtering
      final data = await OrderService.fetchAgeingReport(
        acno: acno,
        startLimit: 1,
        endLimit: 50000,
        startDate: _formatDate(startDate),
        endDate: _formatDate(endDate),
        ageingType: 'order',
        // Remove server-side filters to avoid conflicts with client-side filtering
        // filterCourierId: filterCourier,
        // filterStatusId: filterAgeing,
        // filterDestinationCity: filterCity,
      );
      
      // Apply client-side filtering
      List<Map<String, dynamic>> filteredData = data;
      
      // Apply ageing filter
      if (filterAgeing != null) {
        filteredData = filteredData.where((order) {
          final noOfDays = int.tryParse(order['no_of_days']?.toString() ?? '0') ?? 0;
          switch (filterAgeing!.toLowerCase()) {
            case '0-3 days':
              return noOfDays >= 0 && noOfDays <= 3;
            case '4-7 days':
              return noOfDays >= 4 && noOfDays <= 7;
            case '8-15 days':
              return noOfDays >= 8 && noOfDays <= 15;
            case '16+ days':
              return noOfDays >= 16;
            default:
              return true;
          }
        }).toList();
      }
      
      // Apply platform filter
      if (filterPlatform != null) {
        filteredData = filteredData.where((order) => 
          (order['store_name']?.toString().toLowerCase().contains(filterPlatform!.toLowerCase()) ?? false) ||
          (order['web_order_id']?.toString().toLowerCase().contains(filterPlatform!.toLowerCase()) ?? false)
        ).toList();
      }
      
      // Apply courier filter
      if (filterCourier != null) {
        filteredData = filteredData.where((order) => 
          order['courier_name']?.toString().toLowerCase() == filterCourier!.toLowerCase()
        ).toList();
      }
      
      // Apply city filter
      if (filterCity != null) {
        filteredData = filteredData.where((order) => 
          order['city_name']?.toString().toLowerCase() == filterCity!.toLowerCase()
        ).toList();
      }
      
      setState(() {
        orders = filteredData;
        _applySearch();
      });
    } catch (e) {
      // Optionally show error
      print('Error fetching ageing report: $e');
    } finally {
      setState(() => isLoading = false);
    }
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

  String _formatDate(DateTime date) {
    return " ${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _openDateSelector() async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          child: CustomDateSelector(
            initialStartDate: startDate,
            initialEndDate: endDate,
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      fetchAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AgeingReportFilterScreen(
                    onApply: (filters) {
                      setState(() {
                        filterAgeing = filters['ageing'];
                        filterPlatform = filters['platform'];
                        filterCourier = filters['courier'];
                        filterCity = filters['city'];
                      });
                      // Debug logging
                      print('Applied filters: ageing=$filterAgeing, platform=$filterPlatform, courier=$filterCourier, city=$filterCity');
                      fetchAllData();
                      // Show custom snackbar
                      customSnackBar('Success', 'Filters applied successfully');
                    },
                                            onReset: () {
                          setState(() {
                            filterAgeing = null;
                            filterPlatform = null;
                            filterCourier = null;
                            filterCity = null;
                          });
                          fetchAllData();
                          // Show custom snackbar
                          customSnackBar('Success', 'Filters reset successfully');
                        },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: _openDateSelector,
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
                  : (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredOrders : orders).isEmpty
                      ? const Center(child: Text('No data found'))
                      : ListView.separated(
                          itemCount: (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredOrders : orders).length,
                          separatorBuilder: (context, i) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final order = (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredOrders : orders)[i];
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
                                            _infoRow('Order ID', order['id']),
                                            _infoRow('Name', order['consignee_name']),
                                            _infoRow('Contact', order['consignee_contact']),
                                            _infoRow('Date', order['order_date']),
                                            _infoRow('Booking Date', order['booking_date']),
                                            _infoRow('City', order['city_name']),
                                            _infoRow('Web Order ID', order['web_order_id']),
                                            _infoRow('Store', order['store_name']),
                                            _infoRow('Payment Type', order['payment_type']),
                                            _infoRow('COD Amount', order['cod_amount']),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const Text('Courier: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                                if (order['courier_logo'] != null && order['courier_logo'].toString().isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                    child: Image.network(order['courier_logo'], height: 20, errorBuilder: (context, error, stackTrace) => Text(order['courier_name'] ?? '')),
                                                  )
                                                else
                                                  Text(order['courier_name'] ?? ''),
                                              ],
                                            ),
                                            _infoRow('Account', order['account_title']),
                                            _infoRow('CN', order['cn']),
                                            _infoRow('No of Days', order['no_of_days']),
                                            _infoRow('Status', order['status_name']),
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
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF0A253B),
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.edit, color: Colors.white, size: 28),
            )
          : null,
    );
  }

  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? '')),
        ],
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