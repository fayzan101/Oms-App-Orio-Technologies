import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'search_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../widgets/custom_date_selector.dart';
import '../services/auth_service.dart';

class CODStatement {
  final String refNo;
  final String date;
  final String accountNo;
  final int shipments;
  final String codAmount;
  final String courier;

  CODStatement({
    required this.refNo,
    required this.date,
    required this.accountNo,
    required this.shipments,
    required this.codAmount,
    required this.courier,
  });

  factory CODStatement.fromJson(Map<String, dynamic> json) {
    return CODStatement(
      refNo: json['invoice_no']?.toString() ?? '',
      date: json['invoice_date']?.toString() ?? '',
      accountNo: json['acno']?.toString() ?? '',
      shipments: int.tryParse(json['total_shipments']?.toString() ?? '0') ?? 0,
      codAmount: json['total_amount']?.toString() ?? '',
      courier: json['courier_name']?.toString() ?? '',
    );
  }
}

class CODStatementScreen extends StatefulWidget {
  const CODStatementScreen({Key? key}) : super(key: key);
  @override
  State<CODStatementScreen> createState() => _CODStatementScreenState();
}

class _CODStatementScreenState extends State<CODStatementScreen> {
  List<CODStatement> statements = [];
  bool isLoading = true;
  String? error;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  // Search state
  String? _searchQuery;
  List<CODStatement> _filteredStatements = [];
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchStatements();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadUserDataAndFetchStatements() async {
    // Load user data if not already loaded
    if (_authService.currentUser.value == null) {
      await _authService.loadUserData();
    }
    await fetchStatements();
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

  Future<void> fetchStatements() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final acno = _authService.getCurrentAcno();
      if (acno == null) {
        setState(() {
          error = 'User not logged in';
          isLoading = false;
        });
        return;
      }

      final response = await GetConnect().post(
        'https://oms.getorio.com/api/statement/index',
        {
          'acno': acno,
          'start_date': _startDate.toIso8601String().split('T')[0],
          'end_date': _endDate.toIso8601String().split('T')[0],
        },
      );
      if (response.body['status'] == 1 && response.body['payload'] is List) {
        statements = (response.body['payload'] as List)
            .map((e) => CODStatement.fromJson(e))
            .toList();
        _applySearch();
      } else {
        statements = [];
      }
    } catch (e) {
      statements = [];
      error = e.toString();
    }
    setState(() => isLoading = false);
  }

  void _applySearch() {
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredStatements = statements.where((s) {
        return s.refNo.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
               s.date.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
               s.accountNo.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
               s.codAmount.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
               s.courier.toLowerCase().contains(_searchQuery!.toLowerCase());
      }).toList();
    } else {
      _filteredStatements = statements;
    }
  }

  String _getDateRangeText() {
    final now = DateTime.now();
    final difference = now.difference(_startDate).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Last 1 day';
    } else if (difference <= 7) {
      return 'Last $difference days';
    } else if (difference <= 30) {
      final weeks = (difference / 7).round();
      return 'Last $weeks week${weeks > 1 ? 's' : ''}';
    } else if (difference <= 365) {
      final months = (difference / 30).round();
      return 'Last $months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference / 365).round();
      return 'Last $years year${years > 1 ? 's' : ''}';
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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'COD Statements',
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
                await fetchStatements();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getDateRangeText(),
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredStatements : statements).isEmpty
                            ? const Center(child: Text('No COD statements found.'))
                            : ListView.separated(
                                itemCount: (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredStatements : statements).length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final s = (_searchQuery != null && _searchQuery!.isNotEmpty ? _filteredStatements : statements)[i];
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _CODRow(label: 'Ref. No', value: s.refNo),
                                        _CODRow(label: 'Date', value: s.date),
                                        _CODRow(label: 'Account No', value: s.accountNo),
                                        _CODRow(label: 'Shipments', value: s.shipments.toString()),
                                        _CODRow(label: 'COD Amount', value: s.codAmount),
                                        Row(
                                          children: [
                                            const Text('Courier', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 15)),
                                            const SizedBox(width: 8),
                                            _courierLogoOrText(s.courier),
                                          ],
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
              bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
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

class _CODRow extends StatelessWidget {
  final String label;
  final String value;
  const _CODRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'SF Pro Display', fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'SF Pro Display', fontSize: 15))),
        ],
      ),
    );
  }
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
      padding: const EdgeInsets.only(right: 8),
      child: Image.asset(asset, height: 24, width: 60, fit: BoxFit.contain),
    );
  }
  return Text(courierName, style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'SF Pro Display', fontSize: 15));
} 