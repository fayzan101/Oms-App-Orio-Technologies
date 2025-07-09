import 'package:flutter/material.dart';
import 'report.dart' as report;
import 'dashboard_screen.dart' as dash;
import 'menu.dart' as menu;
import 'order_list_screen.dart' as order_list;
import 'search_screen.dart';
import '../widgets/custom_nav_bar.dart';

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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
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
                          Table(
                            columnWidths: const {
                              0: FixedColumnWidth(100), // Adjust width as needed
                              1: FlexColumnWidth(),
                            },
                            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                            children: [
                              TableRow(children: [
                                Text('S.No', style: _labelStyle),
                                Text(sheet['sno'], style: _valueStyle),
                              ]),
                              TableRow(children: [
                                Text('Sheet No', style: _labelStyle),
                                Text(sheet['sheetNo'], style: _valueStyle),
                              ]),
                              TableRow(children: [
                                Text('Date', style: _labelStyle),
                                Text(sheet['date'], style: _valueStyle),
                              ]),
                              TableRow(children: [
                                Text('Shipments', style: _labelStyle),
                                Text(sheet['shipments'], style: _valueStyle),
                              ]),
                              TableRow(children: [
                                Text('Account', style: _labelStyle),
                                Text(sheet['account'], style: _valueStyle),
                              ]),
                              TableRow(children: [
                                Text('Courier', style: _labelStyle),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Image.asset(
                                    'assets/icon/bluex.jpeg',
                                    width: 48,
                                    height: 20,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ]),
                              TableRow(children: [
                                Text('Action', style: _labelStyle),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                      ),
                                      builder: (context) {
                                        return _LoadsheetDetailsBottomSheet(
                                          orderId: '677878',
                                          cn: '5034831671',
                                          status: 'Pickup Ready',
                                          onDelete: () {
                                            Navigator.of(context).pop();
                                            // Add delete logic here
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: const [
                                      Icon(Icons.edit, color: Color(0xFF007AFF)),
                                      SizedBox(width: 4),
                                      Text('Edit', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ),
                              ]),
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
      bottomNavigationBar: CustomNavBar(
        selectedIndex: 2,
        onTabSelected: (index) {
          // Handle navigation based on index
          if (index == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => dash.DashboardScreen()),
            );
          } else if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => order_list.OrderListScreen()),
            );
          } else if (index == 2) {
            // Already on Reports tab
          } else if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => menu.MenuScreen()),
            );
          }
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

class _LoadsheetDetailsBottomSheet extends StatelessWidget {
  final String orderId;
  final String cn;
  final String status;
  final VoidCallback onDelete;

  const _LoadsheetDetailsBottomSheet({
    Key? key,
    required this.orderId,
    required this.cn,
    required this.status,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Loadsheet Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
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
          _detailRow('Order ID', orderId),
          _detailRow('CN#', cn),
          _detailRow('Status', status),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Action', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  final confirmed = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _DeleteConfirmationBottomSheet(),
                  );
                  if (confirmed == true) {
                    Navigator.of(context).pop(); // Close the details bottom sheet
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _DeleteSuccessBottomSheet(),
                    );
                    // Add delete logic here if needed
                  }
                },
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline, color: Color(0xFF007AFF)),
                    SizedBox(width: 4),
                    Text('Delete', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: 'SF Pro Display',
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: 'SF Pro Display',
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmationBottomSheet extends StatelessWidget {
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
              'You want to delete this load sheet',
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
                    onPressed: () => Navigator.of(context).pop(true),
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
  }
}

class _DeleteSuccessBottomSheet extends StatelessWidget {
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
              child: const Icon(Icons.check, color: Color(0xFF007AFF), size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'You have successfully deleted load sheet',
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF8E8E93)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Ok', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 