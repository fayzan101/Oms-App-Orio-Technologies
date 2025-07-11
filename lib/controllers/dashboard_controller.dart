import 'package:get/get.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_reporting_model.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

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
  var selectedDays = 'Last 3 Days'.obs;
  var error = ''.obs;
  var courierPaymentData = <CourierPaymentData>[].obs;
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
      
      final data = await _dashboardService.getDashboardReporting(
        startDate: startDate,
        endDate: endDate,
        acno: acno,
      );
      
      print('DashboardController: Received data: $data');
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
      
      dashboardData.value = data;
      _updateObservables(data);
      
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
    selectedDays.value = 'Last 7 Days';
  }

  Future<void> fetchCurrentMonthData() async {
    final now = DateTime.now();
    await fetchDashboardData(
      startDate: _formatDateToISO(DateTime(now.year, now.month, 1)),
      endDate: _formatDateToISO(now),
    );
    selectedDays.value = 'Current Month';
  }

  Future<void> fetchCustomDateRangeData(DateTime startDate, DateTime endDate) async {
    await fetchDashboardData(
      startDate: _formatDateToISO(startDate),
      endDate: _formatDateToISO(endDate),
    );
    final days = endDate.difference(startDate).inDays + 1;
    if (days == 1) {
      selectedDays.value = 'Today';
    } else if (days == 7) {
      selectedDays.value = 'Last 7 Days';
    } else if (days == 30) {
      selectedDays.value = 'Last 30 Days';
    } else {
      selectedDays.value = 'Last $days Days';
    }
  }

  void _updateObservables(DashboardReportingModel data) {
    outstandingAmount.value = data.totalOutstanding;
    orders.value = data.orders;
    revenue.value = data.sales;
    productsSold.value = data.productsold;
    customers.value = data.customers;
    totalOutstanding.value = data.totalOutstanding;
    totalCurrentOutstanding.value = data.totalCurrentOutstanding;
    courierPaymentData.value = data.paymentCourierPayment;
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