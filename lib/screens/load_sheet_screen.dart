import 'package:flutter/material.dart';
import 'report.dart' as report;
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'order_list_screen.dart' as order_list;

class LoadSheetScreen extends StatelessWidget {
  const LoadSheetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final List<Map<String, dynamic>> loadSheets = [
      {
        'sno': '01',
        'sheetNo': '5606',
        'date': '3-2-2025',
        'shipments': '20',
        'account': 'Account 9',
        'courier': 'bluex',
      },
      {
        'sno': '02',
        'sheetNo': '5606',
        'date': '3-2-2025',
        'shipments': '20',
        'account': 'Account 9',
        'courier': 'bluex',
      },
      // Add more mock entries as needed
    ];

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
          'Load Sheet',
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 90), // Extra space for bottom nav and FAB
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Total Load Sheet: 06',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: loadSheets.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final sheet = loadSheets[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _row('S.No', sheet['sno']),
                          _row('Sheet No', sheet['sheetNo']),
                          _row('Date', sheet['date']),
                          _row('Shipments', sheet['shipments']),
                          _row('Account', sheet['account']),
                          Row(
                            children: [
                              const Text('Courier', style: _labelStyle),
                              const SizedBox(width: 32),
                              Image.asset(
                                'assets/icon/bluex.jpeg',
                                width: 48,
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Action', style: _labelStyle),
                              const SizedBox(width: 32),
                              Icon(Icons.edit, color: Color(0xFF007AFF)),
                              const SizedBox(width: 4),
                              const Text('Edit', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: dash.CustomBottomNavBar(
        selectedIndex: 2, // Reports tab
        onHomeTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => dash.DashboardScreen()),
          );
        },
        onOrderListTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => order_list.OrderListScreen()),
          );
        },
        onReportsTap: () {},
        onMenuTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => menu.MenuScreen()),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF0A253B),
        child: const Icon(Icons.edit, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(width: 32),
          Text(value, style: _valueStyle),
        ],
      ),
    );
  }
}

const _labelStyle = TextStyle(
  fontFamily: 'SF Pro Display',
  fontWeight: FontWeight.w500,
  fontSize: 14,
  color: Colors.black,
);

const _valueStyle = TextStyle(
  fontFamily: 'SF Pro Display',
  fontWeight: FontWeight.w400,
  fontSize: 14,
  color: Colors.black,
); 