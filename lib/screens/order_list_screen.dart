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
import '../services/auth_service.dart';
import '../utils/custom_snackbar.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/courier_logo_widget.dart';

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
        // Sort orders in descending order by 'id' (assuming 'id' is numeric and higher means newer)
        orders.sort((a, b) {
          final aId = int.tryParse(a['id']?.toString() ?? '') ?? 0;
          final bId = int.tryParse(b['id']?.toString() ?? '') ?? 0;
          return bId.compareTo(aId);
        });
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

  Future<void> _deleteOrder(String orderId) async {
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        customSnackBar('Error', 'User not logged in');
        return;
      }
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
                _applySearch();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded, color: Colors.black),
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
                      onTap: () {
                        setState(() {
                          _activeFilters = null;
                        });
                        _applySearch();
                        customSnackBar('Success', 'Filters cleared');
                      },
                      child: Icon(Icons.clear_rounded, size: 16, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
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
                GestureDetector(
                  onTap: () {
                    Get.to(() => const CreateCnScreen());
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
                itemCount: ((_searchQuery != null && _searchQuery!.isNotEmpty) || _activeFilters != null ? _filteredOrders.length : orders.length) + (isLoading ? 1 : 0),
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final list = ((_searchQuery != null && _searchQuery!.isNotEmpty) || _activeFilters != null ? _filteredOrders : orders);
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
                            leading: Checkbox(
                              value: selectedOrders.contains(i),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedOrders.add(i);
                                  } else {
                                    selectedOrders.remove(i);
                                  }
                                  // Update select all state
                                  final currentList = (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredOrders : orders);
                                  selectAll = selectedOrders.length == currentList.length;
                                });
                              },
                              activeColor: const Color(0xFF007AFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            title: Text('Order ID:  ${order['id'] ?? ''}'),
                            trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name:  ${order['consignee_name'] ?? ''}'),
                                  Text('Contact:  ${order['consignee_contact'] ?? ''}'),
                                  Text('City:  ${order['city_name'] ?? ''}'),
                                  Text('Web Order ID:  ${order['web_order_id'] ?? order['order_ref'] ?? ''}'),
                                  Text('Store:  ${order['store_name'] ?? ''}'),
                                  Text('Payment Type:  ${order['payment_type'] ?? ''}'),
                                  Text('COD Amount:  ${order['cod_amount'] ?? order['order_amount'] ?? ''}'),
                                  Row(
                                    children: [
                                      const Text('Courier:', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: CourierLogoWidget(
                                          logoUrl: _getCourierLogoUrl(order['courier_name'] ?? ''),
                                          width: 48,
                                          height: 24,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text('Account:  ${order['account_title'] ?? ''}'),
                                  Text('CN:  ${order['consigment_no'] ?? ''}'),
                                  Text('Tags:  ${order['tags'] ?? ''}'),
                                  Text('Status:  ${order['status'] ?? ''}'),
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
                                            onTap: () async {
                                              final confirmed = await showModalBottomSheet<bool>(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor: Colors.transparent,
                                                builder: (context) => _DeleteConfirmationBottomSheet(),
                                              );
                                              if (confirmed == true) {
                                                await _deleteOrder(order['id'].toString());
                                              }
                                            },
                                            child: Row(
                                              children: const [
                                                Icon(Icons.delete_rounded, color: Color(0xFF007AFF)),
                                                SizedBox(width: 4),
                                                Text('Delete', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              Get.to(() => const QuickEditScreen());
                                            },
                                            child: Row(
                                              children: const [
                                                Icon(Icons.edit_rounded, color: Color(0xFF007AFF)),
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
                                                Icon(Icons.place_rounded, color: Color(0xFF007AFF)),
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