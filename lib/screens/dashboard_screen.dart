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

import '../widgets/courier_logo_widget.dart';
import '../widgets/custom_date_selector.dart';
import '../widgets/snake_graph_widget.dart';
import '../models/courier_model.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = Get.find<DashboardController>();
  final Rx<DateTimeRange> _currentDateRange = Rx<DateTimeRange>(
    DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    ),
  );



  @override
  void initState() {
    super.initState();
    print('DashboardScreen initState');
    
    // Fetch dashboard data on screen load
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // Use static date range - last 30 days
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    
    await _fetchDashboardDataWithRange(startDate, endDate);
  }

  Future<void> _fetchDashboardDataWithRange(DateTime startDate, DateTime endDate) async {
    final startStr = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endStr = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    print('Dashboard fetch dates - Start: $startStr, End: $endStr');
    
    // Update the current date range
    _currentDateRange.value = DateTimeRange(start: startDate, end: endDate);
    
    await controller.fetchDashboardData(startDate: startStr, endDate: endStr);
  }

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
              icon: Icon(Icons.notifications_rounded, color: Colors.black),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => DashboardNotificationScreen()),
                            );
                          },
                        ),
                       IconButton(
              icon: Icon(Icons.search_rounded, color: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
                        IconButton(
              icon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF007AFF)),
              onPressed: () async {
                // Show custom date selector as centered dialog
                final result = await showDialog<DateTimeRange>(
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
                        initialStartDate: _currentDateRange.value.start,
                        initialEndDate: _currentDateRange.value.end,
                      ),
                    ),
                  ),
                );
                
                if (result != null) {
                  print('Dashboard: Date range selected - Start: ${result.start}, End: ${result.end}');
                  await _fetchDashboardDataWithRange(result.start, result.end);
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
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load dashboard data',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.error.value,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchDashboardData,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
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
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Obx(() {
                        final range = _currentDateRange.value;
                        final days = range.end.difference(range.start).inDays;
                        String displayText = 'Last $days Days';
                        
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F4FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            displayText,
                            style: TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
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
                          style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
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
                              Obx(() => Text(
                                controller.orders.value.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )),
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
                              Obx(() => Text(
                                'PKR ${controller.revenue.value.toString()}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )),
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
                              Obx(() => Text(
                                controller.productsSold.value.toString(),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Pending Payment Cards
                  Obx(() {
                    final courierPaymentData = controller.courierPaymentData;
                    final isLoading = controller.isLoading.value;
                    print('Dashboard UI: Courier payment data count: ${courierPaymentData.length}, Loading: $isLoading');
                    
                    // Show loading state while data is being fetched
                    if (isLoading) {
                      return Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
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
                                      Container(
                                        width: 100,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 80,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 64,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(16),
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
                                      Container(
                                        width: 100,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 80,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 64,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    
                    if (courierPaymentData.isEmpty) {
                      print('Dashboard UI: No courier payment data, showing fallback cards');
                      return Column(
                        children: [
                          PaymentCard(
                            title: 'Pending Payment',
                            amount: 'Rs. 0',
                            shipment: '0',
                          ),
                          SizedBox(height: 16),
                          PaymentCard(
                            title: 'Pending Payment',
                            amount: 'Rs. 0',
                            shipment: '0',
                          ),
                        ],
                      );
                    }
                    
                    print('Dashboard UI: Rendering ${courierPaymentData.length} courier cards');
                    return Column(
                      children: courierPaymentData.map((courier) {
                        print('Dashboard UI: Rendering courier: "${courier.courierName}"');
                        print('  Logo URL: "${courier.logo}"');
                        print('  PNG URL: "${courier.png}"');
                        print('  Pending Payment: ${courier.pendingPayment}');
                        print('  Shipments: ${courier.shipments}');
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: PaymentCard(
                            title: 'Pending Payment',
                            amount: 'Rs. ${courier.pendingPayment}',
                            shipment: '${courier.shipments}',
                            logoUrl: courier.logo,
                            pngUrl: courier.png,
                            courierName: courier.courierName,
                          ),
                        );
                      }).toList(),
                    );
                  }),
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
                        Obx(() => Text(
                          '${controller.totalOrders.value}:1',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        )),
                        SizedBox(height: 12),
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: Obx(() {
                              final statusData = controller.orderStatusSummary;
                              print('Dashboard UI: Pie chart - Order status count: ${statusData.length}');
                              
                              if (statusData.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No Data',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      '0',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                );
                              }
                              
                              // Define colors for different statuses
                              final List<Color> colors = [
                                Color(0xFF007AFF), // Blue
                                Color(0xFFC6C6F8), // Light Purple
                                Color(0xFFD1B6D6), // Pink
                                Color(0xFFD6E36B), // Light Green
                                Color(0xFFFF9500), // Orange
                                Color(0xFFFF3B30), // Red
                                Color(0xFF34C759), // Green
                                Color(0xFFAF52DE), // Purple
                                Color(0xFF5856D6), // Indigo
                                Color(0xFFFF2D92), // Pink
                              ];
                              
                              // Create pie chart sections from real data
                              final sections = <PieChartSectionData>[];
                              for (int i = 0; i < statusData.length && i < colors.length; i++) {
                                final item = statusData[i];
                                final color = colors[i % colors.length];
                                sections.add(
                                  PieChartSectionData(
                                    color: color,
                                    value: item.quantity.toDouble(),
                                    radius: 24,
                                    showTitle: false,
                                  ),
                                );
                                print('Dashboard UI: Pie chart section - ${item.name}: ${item.quantity} (color: $color)');
                              }
                              
                              // Find the status with highest quantity for center display
                              final maxQuantityStatus = statusData.isNotEmpty 
                                  ? statusData.reduce((a, b) => a.quantity > b.quantity ? a : b)
                                  : null;
                              
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 54,
                                      startDegreeOffset: -90,
                                      sections: sections,
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        maxQuantityStatus?.name ?? 'No Data',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8E8E93),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        '${maxQuantityStatus?.quantity ?? 0}',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Vertical list for statuses
                        Obx(() {
                          final statusData = controller.orderStatusSummary;
                          
                          if (statusData.isEmpty) {
                            return Column(
                              children: [
                                _StatusRow(
                                  color: Color(0xFF007AFF),
                                  label: 'No Data',
                                  value: '0',
                                ),
                              ],
                            );
                          }
                          
                          // Define colors for different statuses
                          final List<Color> colors = [
                            Color(0xFF007AFF), // Blue
                            Color(0xFFC6C6F8), // Light Purple
                            Color(0xFFD1B6D6), // Pink
                            Color(0xFFD6E36B), // Light Green
                            Color(0xFFFF9500), // Orange
                            Color(0xFFFF3B30), // Red
                            Color(0xFF34C759), // Green
                            Color(0xFFAF52DE), // Purple
                            Color(0xFF5856D6), // Indigo
                            Color(0xFFFF2D92), // Pink
                          ];
                          
                          return Column(
                            children: statusData.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final color = colors[index % colors.length];
                              
                              return Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: _StatusRow(
                                  color: color,
                                  label: item.name,
                                  value: '${item.quantity}',
                                ),
                              );
                            }).toList(),
                          );
                        }),
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
                        Obx(() {
                          final statusData = controller.orderStatusSummary;
                          print('Dashboard UI: Order status summary count: ${statusData.length}');
                          
                          if (statusData.isEmpty) {
                            return Column(
                              children: [
                                Text('No order status data available'),
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
                                      '0',
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
                                      '0',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }
                          
                          return Column(
                            children: [
                              ...statusData.map((item) {
                                final progress = controller.totalOrders.value > 0 
                                    ? item.quantity / controller.totalOrders.value 
                                    : 0.0;
                                print('Dashboard UI: Rendering status item: ${item.name}, Quantity: ${item.quantity}, Amount: ${item.amount}, Progress: $progress');
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _OrderStatusSummaryRow(
                                    label: item.name,
                                    progress: progress,
                                    amount: 'Rs. ${item.amount}',
                                    count: '${item.quantity}',
                                  ),
                                );
                              }),
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
                                  Obx(() => Text(
                                    '${controller.totalOrders.value}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
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
                                  Obx(() => Text(
                                    '${controller.totalAmount.value}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          );
                        }),
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
                        Obx(() {
                          final failedData = controller.failedStatusSummary;
                          print('Dashboard UI: Failed status summary count: ${failedData.length}');
                          
                          if (failedData.isEmpty) {
                            return Column(
                              children: [
                                Text('No failed attempt data available'),
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
                                    Obx(() => Text(
                                      '${controller.totalFailedOrders.value}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )),
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
                                    Obx(() => Text(
                                      '${controller.totalFailedAmount.value}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )),
                                  ],
                                ),
                              ],
                            );
                          }
                          
                          return Column(
                            children: [
                              ...failedData.map((item) {
                                final progress = controller.totalFailedOrders.value > 0 
                                    ? item.quantity / controller.totalFailedOrders.value 
                                    : 0.0;
                                print('Dashboard UI: Rendering failed attempt item: ${item.name}, Quantity: ${item.quantity}, Amount: ${item.amount}, Progress: $progress');
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _FailedAttemptRow(
                                    label: item.name,
                                    progress: progress,
                                    amount: 'Rs. ${item.amount}',
                                    count: '${item.quantity}',
                                  ),
                                );
                              }),
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
                                  Obx(() => Text(
                                    '${controller.totalFailedOrders.value}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
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
                                  Obx(() => Text(
                                    '${controller.totalFailedAmount.value}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                                ],
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Weekly Report Heading
                  const Text(
                    'Weekly Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Snake Graph Section
                  Obx(() {
                    final snakeGraphData = controller.dashboardData.value?.snakeGraph;
                    
                    if (snakeGraphData == null) {
                      return Container(
                        height: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Weekly order status data not available',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    return SnakeGraphWidget(
                      snakeGraphData: snakeGraphData,
                      height: 300,
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0,
        onHomeTap: () {
          // Already on home, do nothing
        },
        onOrderListTap: () {
          Get.to(() => const OrderListScreen());
        },
        onReportsTap: () {
          Get.to(() => const ReportsScreen());
        },
        onMenuTap: () {
          Get.to(() => const MenuScreen());
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CreateOrderScreen());
        },
        backgroundColor: const Color(0xFF0A253B),
        elevation: 4,
        shape: const CircleBorder(),
                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
      ),
    ));
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
  final String? logoUrl;
  final String? pngUrl;
  final String? courierName;

  const PaymentCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.shipment,
    this.logoUrl,
    this.pngUrl,
    this.courierName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      fontWeight: FontWeight.w500,
                    ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                  ),
                  SizedBox(height: 4),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
        ),
                ],
              ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: CourierLogoWidget(
                      logoUrl: logoUrl,
                      pngUrl: pngUrl,
                      width: 96,
                      height: 60,
                    ),
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
              Expanded(
                child: Text(
                shipment,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
                    icon: Icons.home_rounded,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: onHomeTap ?? () {},
                  ),
                  _NavBarItem(
                    icon: Icons.shopping_bag_rounded,
                    label: 'Order List',
                    selected: selectedIndex == 1,
                    onTap: onOrderListTap ?? () {},
                  ),
                  const SizedBox(width: 56), // Space for FAB
                  _NavBarItem(
                    icon: Icons.tune_rounded,
                    label: 'Reports',
                    selected: selectedIndex == 2,
                    onTap: onReportsTap ?? () {},
                  ),
                  _NavBarItem(
                    icon: Icons.menu_rounded,
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
