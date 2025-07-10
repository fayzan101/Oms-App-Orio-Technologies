import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'search_screen.dart';
import '../utils/Layout/app_bottom_bar.dart';
import '../widgets/custom_date_selector.dart';

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

  @override
  void initState() {
    super.initState();
    fetchStatements();
  }

  Future<void> fetchStatements() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final response = await GetConnect().post(
        'https://oms.getorio.com/api/statement/index',
        {
          'acno': 'OR-00009',
          'start_date': _startDate.toIso8601String().split('T')[0],
          'end_date': _endDate.toIso8601String().split('T')[0],
        },
      );
      if (response.body['status'] == 1 && response.body['payload'] is List) {
        statements = (response.body['payload'] as List)
            .map((e) => CODStatement.fromJson(e))
            .toList();
      } else {
        statements = [];
      }
    } catch (e) {
      statements = [];
      error = e.toString();
    }
    setState(() => isLoading = false);
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 22),
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
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
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
                  insetPadding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.white,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                        ),
                        child: CustomDateSelector(
                          initialStartDate: _startDate,
                          initialEndDate: _endDate,
                        ),
                      ),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_startDate.toIso8601String().split('T')[0]} to ${_endDate.toIso8601String().split('T')[0]}',
                          style: const TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: statements.isEmpty
                            ? const Center(child: Text('No COD statements found.'))
                            : ListView.separated(
                                itemCount: statements.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final s = statements[i];
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
      bottomNavigationBar: const AppBottomBar(currentTab: 2),
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