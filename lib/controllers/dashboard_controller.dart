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
      
      
      // Fetch dashboard data first (this is required)
      final data = await _dashboardService.getDashboardReporting(
        startDate: startDate,
        endDate: endDate,
        acno: acno,
      );
      
     
      
      // Dashboard API already includes courier data with logos, no need for separate API call
      
      dashboardData.value = data;
      _updateObservables(data);
      
      
     
      
    } catch (e) {
      error.value = e.toString();
      
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

  void _updateObservables(DashboardReportingModel data) {
    outstandingAmount.value = data.totalOutstanding;
    orders.value = data.orders;
    revenue.value = data.sales;
    productsSold.value = data.productsold;
    customers.value = data.customers;
    totalOutstanding.value = data.totalOutstanding;
    totalCurrentOutstanding.value = data.totalCurrentOutstanding;
    courierPaymentData.value = data.paymentCourierPayment; // This already includes logo URLs
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