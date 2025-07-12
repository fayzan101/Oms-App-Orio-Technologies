import 'package:get/get.dart';
import '../services/dashboard_service.dart';
import '../services/courier_payment_service.dart';
import '../models/dashboard_reporting_model.dart';
import '../models/courier_model.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();
  final CourierPaymentService _courierPaymentService = CourierPaymentService();

  // Helper function to format date in proper ISO 8601 format (YYYY-MM-DD)
  String _formatDateToISO(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Observables for dashboard data
  var dashboardData = Rxn<DashboardReportingModel>();
  var outstandingAmount = 0.obs;
  var orders = 0.obs;
  var revenue = 0.obs;
  var productsSold = 0.obs;
  var customers = 0.obs;
  var totalOutstanding = 0.obs;
  var totalCurrentOutstanding = 0.obs;
  var isLoading = false.obs;
  var error = ''.obs;
  var courierPaymentData = <CourierPaymentData>[].obs;
  var courierData = <Courier>[].obs; // New observable for courier data with logos
  var mergedCourierData = <Map<String, dynamic>>[].obs; // Combined data with logos and payment info
  var accountNumber = ''.obs;
  var orderStatusSummary = <OrderStatusDetail>[].obs;
  var totalOrders = 0.obs;
  var totalAmount = 0.obs;
  var failedStatusSummary = <OrderStatusDetail>[].obs;
  var totalFailedOrders = 0.obs;
  var totalFailedAmount = 0.obs;

  // Graph data
  var orderGraph = <double>[].obs;
  var revenueGraph = <double>[].obs;
  var productsoldGraph = <double>[].obs;
  var customerGraph = <double>[].obs;
  var outstandingGraph = <double>[].obs;
  var currentOutstandingGraph = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load current week data by default
    fetchCurrentWeekData();
  }

  Future<void> fetchDashboardData({
    required String startDate,
    required String endDate,
    String? acno,
  }) async {
    isLoading.value = true;
    error.value = '';
    
    try {
      print('DashboardController: Fetching data with dates - Start: $startDate, End: $endDate');
      print('DashboardController: AC number: $acno');
      
      // Fetch dashboard data first (this is required)
      final data = await _dashboardService.getDashboardReporting(
        startDate: startDate,
        endDate: endDate,
        acno: acno,
      );
      
      print('DashboardController: Received dashboard data: $data');
      print('DashboardController: Orders: ${data.orders}');
      print('DashboardController: Sales: ${data.sales}');
      print('DashboardController: Total Current Outstanding: ${data.totalCurrentOutstanding}');
      print('DashboardController: Account Number from API: ${data.acno}');
      print('DashboardController: Status Summary - Total Orders: ${data.statusSummary.orderStatusSummary.totalOrders}');
      print('DashboardController: Status Summary - Total Amount: ${data.statusSummary.orderStatusSummary.totalAmount}');
      print('DashboardController: Status Summary - Detail Count: ${data.statusSummary.orderStatusSummary.detail.length}');
      print('DashboardController: Failed Status Summary - Total Orders: ${data.statusSummary.failedStatusSummary.totalOrders}');
      print('DashboardController: Failed Status Summary - Total Amount: ${data.statusSummary.failedStatusSummary.totalAmount}');
      print('DashboardController: Failed Status Summary - Detail Count: ${data.statusSummary.failedStatusSummary.detail.length}');
      
      // Try to fetch courier data (this is optional)
      CourierPaymentResponse courierResponse;
      try {
        courierResponse = await _courierPaymentService.getCourierPaymentData(
          startDate: startDate,
          endDate: endDate,
          acno: acno,
        );
        print('DashboardController: Received courier data: ${courierResponse.paymentCourierPayment.length} couriers');
        for (final courier in courierResponse.paymentCourierPayment) {
          print('DashboardController: Courier: ${courier.courierName} - Logo: ${courier.logo} - PNG: ${courier.png}');
        }
      } catch (courierError) {
        print('DashboardController: Courier API failed, using empty response: $courierError');
        courierResponse = CourierPaymentResponse(paymentCourierPayment: []);
      }
      
      dashboardData.value = data;
      _updateObservables(data, courierResponse);
      
      print('DashboardController: Updated observables - Orders: ${orders.value}');
      print('DashboardController: Updated observables - Sales: ${revenue.value}');
      print('DashboardController: Updated observables - Total Current Outstanding: ${totalCurrentOutstanding.value}');
      print('DashboardController: Updated observables - Account Number: ${accountNumber.value}');
      print('DashboardController: Updated observables - Order Status Summary Count: ${orderStatusSummary.value.length}');
      print('DashboardController: Updated observables - Total Orders: ${totalOrders.value}');
      print('DashboardController: Updated observables - Total Amount: ${totalAmount.value}');
      print('DashboardController: Updated observables - Failed Status Summary Count: ${failedStatusSummary.value.length}');
      print('DashboardController: Updated observables - Total Failed Orders: ${totalFailedOrders.value}');
      print('DashboardController: Updated observables - Total Failed Amount: ${totalFailedAmount.value}');
      print('DashboardController: Updated observables - Courier Data Count: ${courierData.value.length}');
      print('DashboardController: Updated observables - Merged Courier Data Count: ${mergedCourierData.value.length}');
      
    } catch (e) {
      error.value = e.toString();
      print('DashboardController: Error occurred: $e');
      Get.snackbar('Error', 'Failed to load dashboard data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCurrentWeekData() async {
    await fetchDashboardData(
      startDate: _formatDateToISO(DateTime.now().subtract(const Duration(days: 6))),
      endDate: _formatDateToISO(DateTime.now()),
    );
  }

  Future<void> fetchCurrentMonthData() async {
    final now = DateTime.now();
    await fetchDashboardData(
      startDate: _formatDateToISO(DateTime(now.year, now.month, 1)),
      endDate: _formatDateToISO(now),
    );
  }

  Future<void> fetchCustomDateRangeData(DateTime startDate, DateTime endDate) async {
    await fetchDashboardData(
      startDate: _formatDateToISO(startDate),
      endDate: _formatDateToISO(endDate),
    );
  }

  void _updateObservables(DashboardReportingModel data, CourierPaymentResponse courierResponse) {
    outstandingAmount.value = data.totalOutstanding;
    orders.value = data.orders;
    revenue.value = data.sales;
    productsSold.value = data.productsold;
    customers.value = data.customers;
    totalOutstanding.value = data.totalOutstanding;
    totalCurrentOutstanding.value = data.totalCurrentOutstanding;
    courierPaymentData.value = data.paymentCourierPayment;
    courierData.value = courierResponse.paymentCourierPayment; // Update courier data with logos
    
    // Merge courier data with payment data
    final mergedData = <Map<String, dynamic>>[];
    final courierMap = <String, Courier>{};
    
    print('DashboardController: Starting merge - Courier count: ${courierResponse.paymentCourierPayment.length}, Payment count: ${data.paymentCourierPayment.length}');
    
    try {
      // Create a map of courier data by name
      for (final courier in courierResponse.paymentCourierPayment) {
        if (courier.courierName.isNotEmpty) {
          courierMap[courier.courierName.toLowerCase()] = courier;
          print('DashboardController: Added courier to map: ${courier.courierName.toLowerCase()}');
        }
      }
      
      // Merge with payment data
      for (final payment in data.paymentCourierPayment) {
        if (payment.courierName.isNotEmpty) {
          final courierName = payment.courierName.toLowerCase();
          final courier = courierMap[courierName];
          
          print('DashboardController: Processing payment for: $courierName, Found courier: ${courier != null}');
          
          mergedData.add({
            'courierName': payment.courierName,
            'pendingPayment': payment.pendingPayment,
            'shipments': payment.shipments,
            'logoUrl': courier?.logo,
            'pngUrl': courier?.png,
            'status': courier?.status ?? 'active',
          });
        }
      }
      
      // Add couriers that don't have payment data
      for (final courier in courierResponse.paymentCourierPayment) {
        if (courier.courierName.isNotEmpty) {
          final hasPaymentData = data.paymentCourierPayment.any(
            (payment) => payment.courierName.toLowerCase() == courier.courierName.toLowerCase()
          );
          
          print('DashboardController: Checking courier ${courier.courierName} - Has payment data: $hasPaymentData');
          
          if (!hasPaymentData) {
            mergedData.add({
              'courierName': courier.courierName,
              'pendingPayment': 0,
              'shipments': 0,
              'logoUrl': courier.logo,
              'pngUrl': courier.png,
              'status': courier.status,
            });
            print('DashboardController: Added courier without payment data: ${courier.courierName}');
          }
        }
      }
      
      print('DashboardController: Final merged data count: ${mergedData.length}');
    } catch (e) {
      print('DashboardController: Error merging courier data: $e');
      // If merging fails, use empty data
      mergedData.clear();
    }
    
    mergedCourierData.value = mergedData;
    accountNumber.value = data.acno;
    
    // Update status summary data
    orderStatusSummary.value = data.statusSummary.orderStatusSummary.detail;
    totalOrders.value = data.statusSummary.orderStatusSummary.totalOrders;
    totalAmount.value = data.statusSummary.orderStatusSummary.totalAmount;
    failedStatusSummary.value = data.statusSummary.failedStatusSummary.detail;
    totalFailedOrders.value = data.statusSummary.failedStatusSummary.totalOrders;
    totalFailedAmount.value = data.statusSummary.failedStatusSummary.totalAmount;
    
    // Update graph data
    orderGraph.value = data.orderGraphAsNumbers;
    revenueGraph.value = data.revenueGraphAsNumbers;
    productsoldGraph.value = data.productsoldGraphAsNumbers;
    customerGraph.value = data.customerGraphAsNumbers;
    outstandingGraph.value = data.outstandingGraphAsNumbers;
    currentOutstandingGraph.value = data.currentOutstandingGraphAsNumbers;
  }
} 