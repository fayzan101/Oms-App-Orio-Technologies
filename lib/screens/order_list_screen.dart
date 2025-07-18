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
import 'bulk_tracking_screen.dart';
import '../widgets/custom_date_selector.dart';
import '../services/auth_service.dart';
import '../utils/custom_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/courier_logo_widget.dart';
import 'package:google_fonts/google_fonts.dart';


class OrderListScreen extends StatefulWidget {
  final String? snackbarMessage;
  const OrderListScreen({Key? key, this.snackbarMessage}) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<dynamic> orders = [];
  int startLimit = 1;
  int endLimit = 15;
  final int pageSize = 15;
  bool isLoading = false;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final Set<int> expanded = {};
  final AuthService _authService = Get.find<AuthService>();

  // Selection state
  bool selectAll = false;
  final Set<int> selectedOrders = {};

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
  bool _datesLoaded = false;
  // Filter state
  Map<String, dynamic>? _activeFilters;
  String? _selectedOrderStatus; // 'Booked', 'Unbooked', or null for All

  @override
  void initState() {
    super.initState();
    _loadSavedDateRange();
    _scrollController.addListener(() {
      if (mounted && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoading && hasMore) {
        fetchOrders();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.snackbarMessage != null && widget.snackbarMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        customSnackBar('Success', widget.snackbarMessage!);
      });
    }
  }

  Future<void> _loadUserDataAndFetchData() async {
    // Load user data if not already loaded
    if (_authService.currentUser.value == null) {
      await _authService.loadUserData();
    }
    await fetchReportSummary();
    await fetchOrders(reset: true);
  }

  Future<void> _loadSavedDateRange() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString('order_list_start_date');
    final endStr = prefs.getString('order_list_end_date');
    if (startStr != null && endStr != null) {
      setState(() {
        _startDate = DateTime.parse(startStr);
        _endDate = DateTime.parse(endStr);
      });
    }
    setState(() { _datesLoaded = true; });
    _loadUserDataAndFetchData();
  }

  Future<void> _saveDateRange(DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('order_list_start_date', start.toIso8601String());
    await prefs.setString('order_list_end_date', end.toIso8601String());
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
    List<dynamic> tempOrders = orders;
    // Apply text search filter
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      tempOrders = tempOrders.where((order) {
        return order.values.any((v) => v != null && v.toString().toLowerCase().contains(_searchQuery!.toLowerCase()));
      }).toList();
    }
    // Remove order status filter from here (handled by API)
    // Apply other filter screen filters (status, platform, courier, city)
    if (_activeFilters != null) {
      tempOrders = tempOrders.where((order) {
        // Multi-select: Status
        if (_activeFilters!['status'] != null && (_activeFilters!['status'] as List).isNotEmpty) {
          final status = order['status']?.toString() ?? '';
          if (!(_activeFilters!['status'] as List).contains(status)) {
            return false;
          }
        }
        // Multi-select: Platform
        if (_activeFilters!['platform'] != null && (_activeFilters!['platform'] as List).isNotEmpty) {
          final store = order['store_name']?.toString() ?? '';
          if (!(_activeFilters!['platform'] as List).contains(store)) {
            return false;
          }
        }
        // Multi-select: Courier
        if (_activeFilters!['courier'] != null && (_activeFilters!['courier'] as List).isNotEmpty) {
          final courier = order['courier_name']?.toString() ?? '';
          if (!(_activeFilters!['courier'] as List).contains(courier)) {
            return false;
          }
        }
        // Multi-select: City
        if (_activeFilters!['city'] != null && (_activeFilters!['city'] as List).isNotEmpty) {
          final city = order['city_name']?.toString() ?? '';
          if (!(_activeFilters!['city'] as List).contains(city)) {
            return false;
          }
        }
        return true;
      }).toList();
    }
    _filteredOrders = tempOrders;
  }

  Future<void> fetchReportSummary() async {
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        // Handle error - user not logged in
        return;
      }

      final summary = await OrderService.fetchReportSummary(
        acno: acno,
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
        endLimit = pageSize;
        hasMore = true;
      });
    }
    if (!hasMore) return;
    setState(() => isLoading = true);
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() => isLoading = false);
        return;
      }
      // Prepare filter param
      Map<String, dynamic> extraParams = {};
      if (_activeFilters != null && _activeFilters!['order'] != null) {
        if (_activeFilters!['order'] == 'Booked') {
          extraParams['filter_orders'] = '1';
        } else if (_activeFilters!['order'] == 'Unbooked') {
          extraParams['filter_orders'] = '0';
        }
      }
      final data = await OrderService.fetchOrders(
        startLimit: startLimit,
        endLimit: endLimit,
        acno: acno,
        startDate: _startDate.toIso8601String().split('T')[0],
        endDate: _endDate.toIso8601String().split('T')[0],
        extraParams: extraParams,
      );
      final List<dynamic> newOrders = data['data'] ?? [];
      setState(() {
        orders.addAll(newOrders);
        // Remove descending sort
        startLimit = endLimit + 1;
        endLimit += pageSize;
        hasMore = newOrders.length == pageSize;
        _applySearch();
      });
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteOrder(String orderId, {dynamic order}) async {
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        customSnackBar('Error', 'User not logged in');
        return;
      }
      // If is_shipment == 1, use cancelshipments API
      if (order != null && (order['is_shipment'] == 1 || order['is_shipment'] == '1')) {
        final dio = Dio();
        final response = await dio.post(
          'https://oms.getorio.com/api/cancelshipments',
          data: {
            "acno": acno,
            "order_id": orderId,
          },
          options: Options(headers: {'Content-Type': 'application/json'}),
        );
        if (response.statusCode == 200 && (response.data['status'] == 1 || response.data['success'] == true)) {
          customSnackBar('Success', 'Shipment cancelled successfully!');
          await fetchOrders(reset: true);
        } else {
          customSnackBar('Error', response.data['message'] ?? 'Failed to cancel shipment');
        }
        return;
      }
      // Otherwise, use the existing delete logic
      final dio = Dio();
      final response = await dio.post(
        'https://stagingoms.orio.digital/api/order/update',
        data: {
          "acno": acno,
          "orders": [orderId],
          "status": "inactive",
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer QoVDWMtOU9sUzi543rtAVcaeAiEoDH/lQMmuxj4JbjO54gmraIr8QwAloW2F8KEM4PEU9zibMkdCp5RMU3LFqg==',
          },
        ),
      );
      if (response.statusCode == 200 && (response.data['status'] == 1 || response.data['success'] == true)) {
        customSnackBar('Success', 'Order deleted successfully!');
        await fetchOrders(reset: true);
      } else {
        customSnackBar('Error', response.data['message'] ?? 'Failed to delete order');
      }
    } catch (e) {
      customSnackBar('Error', 'Failed to delete order:  e.toString()}');
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
                  child: Icon(Icons.delete_rounded, size: 56, color: Color(0xFF007AFF)),
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
                        onPressed: () => Get.back(result: false),
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
                          Get.back(result: true);
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

  void _showTrackingDialog(BuildContext context, dynamic order) {
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
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Get.back(),
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

  String _getCourierLogoUrl(String courierName) {
    if (courierName.isEmpty) return '';
    final encodedName = Uri.encodeComponent(courierName.trim());
    return 'https://oms.getorio.com/assets/img/shipping-icons/$encodedName.svg';
  }

  String _getOrderListFilterSummary() {
    if (_activeFilters == null) return '';
    final summary = <String>[];
    if (_activeFilters!['order'] != null) summary.add('Order: ${_activeFilters!['order']}');
    if (_activeFilters!['status'] != null && (_activeFilters!['status'] as List).isNotEmpty) summary.add('Status: ${(_activeFilters!['status'] as List).join(", ")}');
    if (_activeFilters!['platform'] != null && (_activeFilters!['platform'] as List).isNotEmpty) summary.add('Platform: ${(_activeFilters!['platform'] as List).join(", ")}');
    if (_activeFilters!['courier'] != null && (_activeFilters!['courier'] as List).isNotEmpty) summary.add('Courier: ${(_activeFilters!['courier'] as List).join(", ")}');
    if (_activeFilters!['city'] != null && (_activeFilters!['city'] as List).isNotEmpty) summary.add('City: ${(_activeFilters!['city'] as List).join(", ")}');
    return summary.join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    if (!_datesLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Get.offAllNamed('/dashboard'),
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
              icon: const Icon(Icons.clear_rounded, color: Colors.grey),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = null;
                  _applySearch();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
            onPressed: () async {
              final result = await Get.to<Map<String, dynamic>>(() => const FilterScreen());
              if (result != null) {
                setState(() {
                  _activeFilters = result;
                });
                await fetchOrders(reset: true); // Ensure API is called again after filter
                customSnackBar('Success', 'Filter applied'); // Show snackbar at bottom
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF007AFF)),
            onPressed: () async {
              final picked = await showDialog<DateTimeRange>(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                      maxHeight: MediaQuery.of(context).size.height * 0.7,
                    ),
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
                await _saveDateRange(_startDate, _endDate);
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
            // Show selected date range above search bar
            Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 8),
              child: Text(
                _getDateRangeText(),
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
            // --- Search Bar ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by any field',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                ),
              ),
            ),
            // --- End Search Bar ---
            // Filter Summary
            if (_activeFilters != null && _activeFilters!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list_rounded, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getOrderListFilterSummary(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _activeFilters = null;
                        });
                        await fetchOrders(reset: true); // Call API again after clearing filter
                        _applySearch();
                        customSnackBar('Success', 'Filters cleared');
                      },
                      child: Icon(Icons.clear_rounded, size: 16, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 1),
            // --- Order Status Dropdown ---
            // (Removed Order Status Dropdown as per user request)
            // --- End Order Status Dropdown ---
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
                  value: selectAll,
                  onChanged: (val) {
                    setState(() {
                      selectAll = val ?? false;
                      final currentList = (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredOrders : orders);
                      if (val == true) {
                        selectedOrders.clear();
                        for (int i = 0; i < currentList.length; i++) {
                          selectedOrders.add(i);
                        }
                      } else {
                        selectedOrders.clear();
                      }
                    });
                  },
                  activeColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                const Text('Select All', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15)),
                const Spacer(),
                if (selectedOrders.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () {
                      // Prevent CN creation if filter is set to Booked
                      if (_activeFilters != null && _activeFilters!['order'] == 'Booked') {
                        customSnackBar('Error', 'This order is already booked, please try another.');
                        return;
                      }
                      final list = ((_searchQuery != null && _searchQuery!.isNotEmpty) || _activeFilters != null ? _filteredOrders : orders);
                      bool anyBooked = selectedOrders.any((idx) =>
                        (list[idx]['status']?.toString().toLowerCase() == 'booked')
                      );
                      if (anyBooked) {
                        customSnackBar('Error', 'The order is already booked, please try another CN.');
                        return;
                      }
                      // Pass all selected orders to CreateCnScreen
                      final selectedOrdersList = selectedOrders.map((i) => list[i]).toList();
                      Get.to(() => CreateCnScreen(orders: selectedOrdersList));
                    },
                    child: const Text('Create CN', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF007AFF), decoration: TextDecoration.underline)),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      final list = ((_searchQuery != null && _searchQuery!.isNotEmpty) || _activeFilters != null ? _filteredOrders : orders);
                      final selectedList = selectedOrders.map((idx) => list[idx]).toList();
                      final orderIds = selectedList.map((order) => order['id']?.toString() ?? '').where((id) => id.isNotEmpty).join(',');
                      final consignmentNos = selectedList.map((order) => order['consigment_no']?.toString() ?? '').where((cn) => cn.isNotEmpty).join(',');
                      final acno = _authService.getCurrentAcno();
                      if (acno == null || acno.isEmpty) {
                        customSnackBar('Error', 'Account number not found. Please log in again.');
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BulkTrackingScreen(
                            acno: acno,
                            orderIds: orderIds,
                            consignmentNos: consignmentNos,
                          ),
                        ),
                      );
                    },
                    child: const Text('Bulk Tracking', style: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w500, fontSize: 15, color: Color(0xFF007AFF), decoration: TextDecoration.underline)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 1),
            // Orders List
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: ((_searchQuery != null && _searchQuery!.isNotEmpty) || _activeFilters != null ? _filteredOrders.length : orders.length) + (isLoading ? 1 : 0),
                separatorBuilder: (context, i) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final list = ((_searchQuery != null && _searchQuery!.isNotEmpty) || _activeFilters != null ? _filteredOrders : orders);
                  if (i >= list.length) {
                    return Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final order = list[i];
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: selectedOrders.contains(i),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedOrders.add(i);
                                  } else {
                                    selectedOrders.remove(i);
                                  }
                                });
                              },
                              activeColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Order ID: ${order['id'] ?? ''}',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: (order['status']?.toString().toLowerCase() == 'booked')
                                    ? const Color(0xFF1DA1F2)
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order['status']?.toString().capitalize ?? '',
                                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Table(
                                columnWidths: const {
                                  0: FixedColumnWidth(80),
                                  1: FlexColumnWidth(),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: [
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Name:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    Center(
                                      child: Text(order['consignee_name'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Courier:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: order['courier_name'] != null && order['courier_name'].toString().isNotEmpty
                                          ? CourierLogoWidget(
                                              logoUrl: _getCourierLogoUrl(order['courier_name']),
                                              width: 64,
                                              height: 32,
                                              fit: BoxFit.contain,
                                            )
                                          : const SizedBox(height: 24),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('City:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(order['destination_city'] ?? '', style: GoogleFonts.inter(fontWeight: FontWeight.w400)),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text('Actions:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Get.to(() => const QuickEditScreen());
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.edit_rounded, color: Color(0xFF007AFF), size: 20),
                                                  const SizedBox(width: 4),
                                                  Text('Edit', style: GoogleFonts.inter(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 24),
                                            GestureDetector(
                                              onTap: () async {
                                                final confirmed = await showModalBottomSheet<bool>(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => _DeleteConfirmationBottomSheet(),
                                                );
                                                if (confirmed == true) {
                                                  await _deleteOrder(order['id'].toString(), order: order);
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.delete_rounded, color: Color(0xFF007AFF), size: 20),
                                                  const SizedBox(width: 4),
                                                  Text('Delete', style: GoogleFonts.inter(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            _showOrderDetailsBottomSheet(context, order);
                          },
                          child: Text(
                            'View Details',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF007AFF),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
              bottomNavigationBar: const AppBottomBar(selectedIndex: 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.offAll(() => create_order.CreateOrderScreen());
        },
        backgroundColor: const Color(0xFF0A253B),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  void _showOrderDetailsBottomSheet(BuildContext context, dynamic order) {
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          fontFamily: 'SF Pro Display',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Replace multiple _orderDetailRow calls with a Table for perfect alignment
                  Table(
                    columnWidths: const {
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(children: [
                        Text('Order ID', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['id']?.toString() ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Name', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['consignee_name'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Contact', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['consignee_contact'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Address', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['consignee_address'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('CN', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['consigment_no'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Order Amount', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['order_amount'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Status', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['status'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Booking Date', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['booking_date'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Store Name', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['store_name'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Courier Name', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['courier_name'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Payment Type', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['payment_type'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                      TableRow(children: [
                        Text('Tags', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(order['tags_name'] ?? '', textAlign: TextAlign.center, style: GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 15)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 180, // or double.infinity for full width, or adjust as needed
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF007AFF), // Blue color
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          String? acno = Get.find<AuthService>().getCurrentAcno();
                          if (acno == null || acno.isEmpty) {
                            customSnackBar('Error', 'Account number not found. Please log in again.');
                            return;
                          }
                          final int orderId = int.tryParse(order['id']?.toString() ?? '') ?? 0;
                          final String consignmentNo = order['consigment_no']?.toString() ?? '';
                          if (orderId == 0) {
                            customSnackBar('Error', 'Order ID not found.');
                            return;
                          }
                          if (consignmentNo.isEmpty) {
                            customSnackBar('Error', 'Consignment No not found.');
                            return;
                          }
                          final orderService = OrderService();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => Center(child: CircularProgressIndicator()),
                          );
                          try {
                            final payload = await orderService.fetchTrackingDetails(
                              acno: acno,
                              orderId: orderId,
                              consignmentNo: consignmentNo,
                            );
                            Navigator.pop(context); // Remove loading
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                insetPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 400), // Match order details dialog size
                                  child: TrackingDetailsDialog(payload: payload!),
                                ),
                              ),
                            );
                          } catch (e) {
                            Navigator.pop(context); // Remove loading
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Error'),
                                content: Text(e.toString()),
                              ),
                            );
                          }
                        },
                        child: Text('Tracking'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _orderDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 24), // Increased spacing
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.center, // Center the value
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeText() {
    final days = _endDate.difference(_startDate).inDays;
    final start = '${_startDate.day.toString().padLeft(2, '0')}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.year}';
    final end = '${_endDate.day.toString().padLeft(2, '0')}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.year}';
    return ' $start to $end';
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
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back(),
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

class _DeleteConfirmationBottomSheet extends StatelessWidget {
  const _DeleteConfirmationBottomSheet({Key? key}) : super(key: key);

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
                color: const Color(0xFFE6F0FF),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(32),
              child: const Icon(Icons.delete_rounded, color: Color(0xFF007AFF), size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Are you Sure',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'You want to delete this order',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3F4F6),
                      foregroundColor: const Color(0xFF111827),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TrackingDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> payload;
  const TrackingDetailsDialog({required this.payload});

  @override
  Widget build(BuildContext context) {
    final details = payload['detail'] as List<dynamic>? ?? [];
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400), // Match order details dialog size
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Tracking Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007AFF),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _infoRow('Order ID', payload['order_id']?.toString() ?? ''),
              _infoRow('Status', payload['status']?.toString() ?? ''),
              _infoRow('Courier', payload['courier_name']?.toString() ?? ''),
              _infoRow('Consignee', payload['consignee_name']?.toString() ?? ''),
              _infoRow('COD', payload['cod_amount']?.toString() ?? ''),
              _infoRow('Origin', payload['origin']?.toString() ?? ''),
              _infoRow('Destination', payload['destination']?.toString() ?? ''),
              const SizedBox(height: 16),
              Text(
                'History:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF007AFF),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...details.map((d) => Card(
                color: Color(0xFFEAF3FF),
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  title: Text(
                    d['status'] ?? '',
                    style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    d['dateTime'] ?? '',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              )),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF007AFF),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 