import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/dashboard_controller.dart';
import 'menu.dart';
import 'report.dart';
import 'package:fl_chart/fl_chart.dart';
import 'create_order.dart';
import 'order_list_screen.dart';
import 'notification_screen.dart';
import 'dashboard_notification_screen.dart';
import 'search_screen.dart';
import 'calendar_screen.dart'; // Import the new CalendarScreen
import '../utils/Layout/app_bottom_bar.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.find<DashboardController>();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
   
     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
      extendBody: false,
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: SvgPicture.asset(
          'assets/frame.svg',
          width: 50,
          height: 30,
          color: Color(0xFF007AFF),
        ),
        actions: [
                        IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DashboardNotificationScreen()),
                            );
                          },
                        ),
                       IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
                        IconButton(
              icon: const Icon(Icons.calendar_today_outlined, color: Color(0xFF007AFF)),
              onPressed: () async {
                final picked = await Get.to(() => const CalendarScreen());
                if (picked != null && picked is DateTime) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: SizedBox.shrink(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Dashboard Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                      Text(
                      'Dashboard',
                        style: TextStyle(
                        fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                    ),
                  ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Obx(() => Text(
                          controller.selectedDays.value,
                          style: TextStyle(
                            color: Color(0xFF007AFF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Total Amount Outstanding Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Amount Outstanding',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                          ),
                              ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() => Text(
                              'PKR ${controller.totalCurrentOutstanding.value.toStringAsFixed(0)}',
                              style: TextStyle(
                                    fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                  ),
                            )),
                            // Simple chart representation
                      Image.asset(
                              'assets/icon/graph.png',
                              width: 100,
                              height: 50,
                        fit: BoxFit.contain,
                            ),
                          ],
                      ),
                    ],
                  ),
                ),
                  SizedBox(height: 20),

                  // Metrics Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                'Orders',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '8,487',
                                style: TextStyle(
                                    fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                  ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                'Revenue',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'PKR 46,553',
                                style: TextStyle(
                                    fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                  ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                'Product Sold',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '6,342',
                                style: TextStyle(
                                    fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                  SizedBox(height: 20),

                  // Pending Payment Cards
                  PaymentCard(
                    title: 'Pending Payment',
                    amount: 'Rs. 12,340',
                    shipment: '47',
                    logoAsset: 'assets/icon/tcs.png',
                  ),
                  SizedBox(height: 16),
                  PaymentCard(
                    title: 'Pending Payment',
                    amount: 'Rs. 20,247',
                    shipment: '68',
                    logoAsset: 'assets/icon/bluex.jpeg',
                  ),
                  SizedBox(height: 20),

                  // Order Status Section
                  Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                      color: Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Ratio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w500,
                        ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '12:1',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    sectionsSpace: 0,
                                    centerSpaceRadius: 54,
                                    startDegreeOffset: -90,
                                    sections: [
                                      PieChartSectionData(
                                        color: Color(0xFF007AFF),
                                        value: 952,
                                        radius: 24,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        color: Color(0xFFC6C6F8),
                                        value: 840,
                                        radius: 24,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        color: Color(0xFFD1B6D6),
                                        value: 659,
                                        radius: 24,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        color: Color(0xFFD6E36B),
                                        value: 645,
                                        radius: 24,
                                        showTitle: false,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'New Order',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '952',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Vertical list for statuses
                        Column(
                          children: [
                            _StatusRow(
                              color: Color(0xFF007AFF),
                              label: 'New Order',
                              value: '952',
                            ),
                            SizedBox(height: 8),
                            _StatusRow(
                              color: Color(0xFFC6C6F8),
                              label: 'Arrived',
                              value: '840',
                            ),
                            SizedBox(height: 8),
                            _StatusRow(
                              color: Color(0xFFD1B6D6),
                              label: 'In Transit',
                              value: '659',
                            ),
                            SizedBox(height: 8),
                            _StatusRow(
                              color: Color(0xFFD6E36B),
                              label: 'Delivered',
                              value: '645',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Order Status Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                        ..._orderStatusSummaryList.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _OrderStatusSummaryRow(
                            label: item['label'],
                            progress: item['progress'],
                            amount: item['amount'],
                            count: item['count'],
                          ),
                                      )),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Orders:',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '2,673',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                        fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '32,789',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Failed Attempt',
                    style: TextStyle(
                    fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
              Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                      color: Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._failedAttemptList.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _FailedAttemptRow(
                            label: item['label'],
                            progress: item['progress'],
                            amount: item['amount'],
                            count: item['count'],
                    ),
                        )),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Failed Attempt:',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '2,673',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8E8E93),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '32,789',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
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
      ),
        ),
        bottomNavigationBar: const AppBottomBar(currentTab: 0),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => const CreateOrderScreen());
          },
          backgroundColor: const Color(0xFF0A253B),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentCard extends StatelessWidget {
  final String title;
  final String amount;
  final String shipment;
  final String logoAsset;

  const PaymentCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.shipment,
    required this.logoAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
        ),
                ],
              ),
              Image.asset(
                logoAsset,
                width: 64,
                height: 40,
                fit: BoxFit.contain,
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            height: 1,
            color: Color(0xFFE0E0E0),
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          Row(
            children: [
              Text(
                'Shipment: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                shipment,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF007AFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Simple line chart simulation
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.6),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width, size.height * 0.4),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
    
    // Draw dots
    final dotPaint = Paint()
      ..color = Color(0xFF007AFF)
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onMenuTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onReportsTap;
  final VoidCallback? onOrderListTap;
  const CustomBottomNavBar({Key? key, required this.selectedIndex, this.onMenuTap, this.onHomeTap, this.onReportsTap, this.onOrderListTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Stack(
        children: [
          // The border line
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Color(0xFFB0B0B0), // bold grey
              // Add a subtle shadow below the line
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000), // subtle grey shadow
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The actual BottomAppBar
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            elevation: 0,
            color: Colors.white,
            child: SizedBox(
              height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
                  _NavBarItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: onHomeTap ?? () {},
                  ),
                  _NavBarItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Order List',
                    selected: selectedIndex == 1,
                    onTap: onOrderListTap ?? () {},
                  ),
                  const SizedBox(width: 56), // Space for FAB
                  _NavBarItem(
                    icon: Icons.tune_outlined,
                    label: 'Reports',
                    selected: selectedIndex == 2,
                    onTap: onReportsTap ?? () {},
                  ),
                  _NavBarItem(
                    icon: Icons.menu,
                    label: 'Menu',
                    selected: selectedIndex == 4,
                    onTap: onMenuTap ?? () {},
                    selectedColor: const Color(0xFF007AFF),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? selectedColor;

  const _NavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? (selectedColor ?? const Color(0xFF007AFF))
        : const Color(0xFF222222);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

const TextStyle _legendTextStyle = TextStyle(
  fontSize: 14,
  color: Colors.black,
  fontWeight: FontWeight.w400,
);
const TextStyle _legendValueStyle = TextStyle(
  fontSize: 14,
  color: Colors.black,
  fontWeight: FontWeight.w700,
);

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
} 

class _StatusRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _StatusRow({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendDot(color: color),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
} 

final List<Map<String, dynamic>> _orderStatusSummaryList = [
  {'label': 'New', 'progress': 0.7, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'On Hold', 'progress': 0.3, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Confirmed', 'progress': 0.6, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Booked', 'progress': 0.8, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'In Transit', 'progress': 0.5, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Delivered', 'progress': 0.4, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Call Attempt', 'progress': 0.6, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Ready for Dispatch', 'progress': 0.2, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Cancelled', 'progress': 0.1, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Arrived', 'progress': 0.7, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'On Route', 'progress': 0.5, 'amount': 'Rs. 12,900', 'count': '128'},
  {'label': 'Return to Shipper', 'progress': 1.0, 'amount': 'Rs. 12,900', 'count': '128'},
];

class _OrderStatusSummaryRow extends StatelessWidget {
  final String label;
  final double progress;
  final String amount;
  final String count;

  const _OrderStatusSummaryRow({
    required this.label,
    required this.progress,
    required this.amount,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF007AFF)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 

final List<Map<String, dynamic>> _failedAttemptList = [
  {'label': 'Incomplete Address', 'progress': 0.4, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'Address Untraceable', 'progress': 0.3, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'Refused to accept', 'progress': 0.2, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'Customer not available', 'progress': 0.5, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'Address Closed', 'progress': 0.6, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'No Such Customer / Office', 'progress': 0.0, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'Customer Not Answering', 'progress': 0.0, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'Area Closed', 'progress': 0.0, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'CNIC Not Available', 'progress': 0.2, 'amount': 'Rs. 650', 'count': '13'},
  {'label': 'Ready for Return', 'progress': 0.7, 'amount': 'Rs. 650', 'count': '13'},
];

class _FailedAttemptRow extends StatelessWidget {
  final String label;
  final double progress;
  final String amount;
  final String count;

  const _FailedAttemptRow({
    required this.label,
    required this.progress,
    required this.amount,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        Text(
          label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5A5F)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 