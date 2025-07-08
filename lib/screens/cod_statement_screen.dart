import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'report.dart' as report;

class CODStatement {
  final String refNo;
  final String date;
  final String accountNo;
  final int shipments;
  final String codAmount;
  final String courier;
  CODStatement({required this.refNo, required this.date, required this.accountNo, required this.shipments, required this.codAmount, required this.courier});

  factory CODStatement.fromJson(Map<String, dynamic> json) {
    return CODStatement(
      refNo: json['ref_no']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      accountNo: json['account_no']?.toString() ?? '',
      shipments: int.tryParse(json['shipments']?.toString() ?? '0') ?? 0,
      codAmount: json['cod_amount']?.toString() ?? '',
      courier: json['courier']?.toString() ?? '',
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
  @override
  void initState() {
    super.initState();
    fetchStatements();
  }

  Future<void> fetchStatements() async {
    setState(() => isLoading = true);
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://oms.getorio.com/api/statement/index',
        data: {
          'acno': 'OR-00009',
          'start_date': '2025-02-20',
          'end_date': '2025-03-21',
        },
      );
      if (response.data['status'] == 1 && response.data['payload'] is List) {
        statements = (response.data['payload'] as List)
            .map((e) => CODStatement.fromJson(e))
            .toList();
      } else {
        statements = [];
      }
    } catch (e) {
      statements = [];
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Total Statements: ${statements.length.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                                        Image.asset('assets/icon/bluex.jpeg', height: 24, width: 60, fit: BoxFit.contain),
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
        onReportsTap: () {},
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