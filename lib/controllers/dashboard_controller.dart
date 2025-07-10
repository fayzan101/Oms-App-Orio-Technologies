import 'package:get/get.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_reporting_model.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

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
      final data = await _dashboardService.getDashboardReporting(
        startDate: startDate,
        endDate: endDate,
        acno: acno,
      );
      
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
      startDate: DateTime.now().subtract(const Duration(days: 6)).toIso8601String().split('T')[0],
      endDate: DateTime.now().toIso8601String().split('T')[0],
    );
    selectedDays.value = 'Last 7 Days';
  }

  Future<void> fetchCurrentMonthData() async {
    final now = DateTime.now();
    await fetchDashboardData(
      startDate: DateTime(now.year, now.month, 1).toIso8601String().split('T')[0],
      endDate: now.toIso8601String().split('T')[0],
    );
    selectedDays.value = 'Current Month';
  }

  Future<void> fetchCustomDateRangeData(DateTime startDate, DateTime endDate) async {
    await fetchDashboardData(
      startDate: startDate.toIso8601String().split('T')[0],
      endDate: endDate.toIso8601String().split('T')[0],
    );
    final days = endDate.difference(startDate).inDays + 1;
    selectedDays.value = 'Last $days Days';
  }

  void _updateObservables(DashboardReportingModel data) {
    outstandingAmount.value = data.totalOutstanding;
    orders.value = data.orders;
    revenue.value = data.sales;
    productsSold.value = data.productsold;
    customers.value = data.customers;
    totalOutstanding.value = data.totalOutstanding;
    totalCurrentOutstanding.value = data.totalCurrentOutstanding;
    
    // Update graph data
    orderGraph.value = data.orderGraphAsNumbers;
    revenueGraph.value = data.revenueGraphAsNumbers;
    productsoldGraph.value = data.productsoldGraphAsNumbers;
    customerGraph.value = data.customerGraphAsNumbers;
    outstandingGraph.value = data.outstandingGraphAsNumbers;
    currentOutstandingGraph.value = data.currentOutstandingGraphAsNumbers;
  }
} 