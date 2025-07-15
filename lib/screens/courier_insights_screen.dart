import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../network/order_service.dart';
import '../services/auth_service.dart';
import 'filter_screen.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;
import 'search_screen.dart';
import 'calendar_screen.dart';
import '../widgets/custom_date_selector.dart';
import 'courier_insights_filter_screen.dart';
import '../utils/custom_snackbar.dart';

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
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  // Search state
  String? _searchQuery;
  List<Map<String, dynamic>> _filteredReports = [];
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  // Multi-select filter state
  List<String> filterStatuses = [];
  List<String> filterCouriers = [];
  List<String> filterCities = [];
  String? filterPaymentMethod;
  String? filterPaymentStatus;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchInsights();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadUserDataAndFetchInsights() async {
    // Load user data if not already loaded
    if (_authService.currentUser.value == null) {
      await _authService.loadUserData();
    }
    await fetchCourierInsights();
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

  Future<void> fetchCourierInsights() async {
    setState(() {
      isLoading = true;
    });
    
    final acno = _authService.getCurrentAcno();
    if (acno == null) {
      setState(() => isLoading = false);
      return;
    }
    
    final startDateStr = _startDate.toIso8601String().split('T')[0];
    final endDateStr = _endDate.toIso8601String().split('T')[0];
    try {
      final data = await OrderService.fetchCourierInsights(
        acno: acno,
        startLimit: 1,
        endLimit: 50000,
        startDate: startDateStr,
        endDate: endDateStr,
      );
      
      // Apply client-side filtering if API doesn't support server-side filtering
      List<Map<String, dynamic>> filteredData = data;
      
      // Multi-select: Status
      if (filterStatuses.isNotEmpty) {
        filteredData = filteredData.where((report) =>
          filterStatuses.contains(report['status_name']?.toString() ?? '')
        ).toList();
      }
      // Multi-select: Courier
      if (filterCouriers.isNotEmpty) {
        filteredData = filteredData.where((report) =>
          filterCouriers.contains(report['courier_name']?.toString() ?? '')
        ).toList();
      }
      // Multi-select: City
      if (filterCities.isNotEmpty) {
        filteredData = filteredData.where((report) =>
          filterCities.contains(report['origin_city']?.toString() ?? '') ||
          filterCities.contains(report['destination_city']?.toString() ?? '')
        ).toList();
      }
      // Single-select: Payment Method
      if (filterPaymentMethod != null) {
        filteredData = filteredData.where((report) =>
          report['payment_type']?.toString().toLowerCase() == filterPaymentMethod!.toLowerCase()
        ).toList();
      }
      // Single-select: Payment Status
      if (filterPaymentStatus != null) {
        filteredData = filteredData.where((report) =>
          (filterPaymentStatus!.toLowerCase() == 'paid' && report['payment_status'] == '1') ||
          (filterPaymentStatus!.toLowerCase() == 'unpaid' && report['payment_status'] == '0') ||
          (filterPaymentStatus!.toLowerCase() == 'partial' && report['payment_status'] == '2')
        ).toList();
      }
      
      setState(() {
        reports = filteredData;
        totalReports = filteredData.length;
        _applySearch();
      });
    } catch (e) {
      // Optionally show error
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _applySearch() {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredReports = reports.where((report) {
        return report.values.any((v) => v != null && v.toString().toLowerCase().contains(_searchQuery!.toLowerCase()));
      }).toList();
    } else {
      _filteredReports = reports;
    }
  }

  void _showTrackingDialog(BuildContext context, Map<String, dynamic> report) {
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
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _trackingDetailRow('Status', report['status_name'] ?? '-'),
                _trackingDetailRow('CN#', report['consigment_no'] ?? '-'),
                _trackingDetailRow('Date', _formatDate(report['created_date'])),
                _trackingDetailRow('Customer', report['consignee_name'] ?? '-'),
                _trackingDetailRow('COD', report['order_amount'] ?? '-'),
                _trackingDetailRow('From To', '${report['origin_city'] ?? '-'}   ${report['destination_city'] ?? '-'}'),
                const SizedBox(height: 12),
                Text(
                  'Courier Shipping Label: ${report['consigment_no'] ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'SF Pro Display'),
                ),
                const SizedBox(height: 4),
                Text(
                  report['tracking_remarks'] ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 13, fontFamily: 'SF Pro Display', color: Color(0xFF6B7280)),
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
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Courier Insights',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        titleSpacing: 0,
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.filter_list_rounded, color: Colors.black),
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CourierInsightsFilterScreen(
                      onApply: (filters) {
                        setState(() {
                          filterStatuses = List<String>.from(filters['status'] ?? []);
                          filterCouriers = List<String>.from(filters['courier'] ?? []);
                          filterCities = List<String>.from(filters['city'] ?? []);
                          filterPaymentMethod = filters['paymentMethod'];
                          filterPaymentStatus = filters['paymentStatus'];
                        });
                        fetchCourierInsights();
                        customSnackBar('Success', 'Filters applied successfully');
                      },
                      onReset: () {
                        setState(() {
                          filterStatuses = [];
                          filterCouriers = [];
                          filterCities = [];
                          filterPaymentMethod = null;
                          filterPaymentStatus = null;
                        });
                        fetchCourierInsights();
                        customSnackBar('Success', 'Filters reset successfully');
                      },
                    ),
                  ),
                );
              },
            ),
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
                await fetchCourierInsights();
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
            const SizedBox(height: 16),
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
            Text(
              'Total Courier Insights Reports: ${_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredReports.length : totalReports}',
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
                  : (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredReports : reports).isEmpty
                      ? const Center(child: Text('No courier insights found.'))
                      : ListView.separated(
                          itemCount: (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredReports : reports).length,
                          separatorBuilder: (context, i) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final report = (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredReports : reports)[i];
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
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Text('Order ID', style: TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 6),
                                          Text(report['id']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      trailing: Icon(isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                    ),
                                    if (isExpanded)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _insightDetailRow('Order ID', report['id']?.toString() ?? ''),
                                            _insightDetailRow('Name', report['consignee_name'] ?? ''),
                                            _insightDetailRow('Contact', report['contact'] ?? ''),
                                            _insightDetailRow('Date', _formatDate(report['created_date'])),
                                            _insightDetailRow('Booking Date', _formatDate(report['booking_date'])),
                                            _insightDetailRow('City', report['origin_city'] ?? ''),
                                            _insightDetailRow('Web Order ID', report['order_ref'] ?? ''),
                                            _insightDetailRow('Net Payable', '-'),
                                            _insightDetailRow('Payment Type', report['payment_type'] ?? ''),
                                            _insightDetailRow('Amount', report['order_amount'] ?? ''),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 120,
                                                  child: Text('Courier', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 15)),
                                                ),
                                                _courierLogoOrText(report['courier_name'] ?? ''),
                                              ],
                                            ),
                                            _insightDetailRow('Account', report['account_title'] ?? ''),
                                            _insightDetailRow('CN', report['consigment_no'] ?? ''),
                                            _insightDetailRow('No of Days', report['deliverytime'] ?? ''),
                                            _insightDetailRow('Status', report['status_name'] ?? ''),
                                            _insightDetailRow('Last Mile Date', _formatDate(report['delivered_date'])),
                                            _insightDetailRow('Payment Status', report['payment_status'] == '1' ? 'Paid' : 'Unpaid'),
                                            _insightDetailRow('Invoice No', report['invoice_no'] ?? ''),
                                            _insightDetailRow('Invoice Date', _formatDate(report['settlement_date'])),
                                            _insightDetailRow('Charges', report['charges'] ?? '-'),
                                            _insightDetailRow('Tags', report['tags_name'] ?? ''),
                                            const SizedBox(height: 10),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text('Action:', style: TextStyle(fontWeight: FontWeight.w700)),
                                                const SizedBox(width: 32),
                                                GestureDetector(
                                                  onTap: () {
                                                    _showTrackingDialog(context, report);
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
              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
            )
          : null,
    );
  }
}

Widget _insightDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 15)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w400, fontFamily: 'SF Pro Display', fontSize: 15)),
        ),
      ],
    ),
  );
}

Widget _courierLogoOrText(String courierName) {
  final normalized = courierName.trim().toLowerCase().replaceAll(' ', '').replaceAll('-', '').replaceAll('_', '');
  final assetMap = {
    'blueex': 'assets/icon/bluex.jpeg',
    'tcs': 'assets/icon/tcs.png',
    // Add more mappings as needed
  };
  final asset = assetMap[normalized];
  if (asset != null) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Image.asset(asset, height: 24, width: 60, fit: BoxFit.contain),
    );
  }
  return Text(courierName, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'SF Pro Display', fontSize: 15));
}

String _formatDate(dynamic dateString) {
  if (dateString == null || dateString.toString().isEmpty || dateString == '--') return '-';
  try {
    final date = DateTime.parse(dateString.toString().split(' ')[0]);
    return '${date.day}-${date.month}-${date.year}';
  } catch (e) {
    return dateString.toString();
  }
} 