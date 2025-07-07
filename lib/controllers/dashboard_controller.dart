import 'package:get/get.dart';
import '../network/api_service.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observables for dashboard data
  var outstandingAmount = 235461.obs;
  var orders = 8487.obs;
  var revenue = 46553.obs;
  var productsSold = 6342.obs;
  var pendingPayments = [
    {
      'amount': 12340,
      'shipments': 47,
      'courier': 'TCS',
      'logo': 'assets/icon/tcs.png',
    },
    {
      'amount': 20247,
      'shipments': 68,
      'courier': 'blueEX',
      'logo': 'assets/icon/blueex.png',
    },
  ].obs;
  var isLoading = false.obs;
  var selectedDays = 'Last 3 Days'.obs;

  @override
  void onInit() {
    super.onInit();
    // Replace with actual values or get from user/session
    fetchDashboardData(
      acno: 'OR-00364',
      startDate: '2024-11-12',
      endDate: '2024-11-15',
    );
  }

  Future<void> fetchDashboardData({
    required String acno,
    required String startDate,
    required String endDate,
  }) async {
    isLoading.value = true;
    try {
      final response = await _apiService.post(
        'dashboard-reporting',
        data: {
          'acno': acno,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      final data = response.data;
      outstandingAmount.value = data['total_outstanding'] ?? 0;
      orders.value = data['orders'] ?? 0;
      revenue.value = data['revenue'] ?? 0;
      productsSold.value = data['products_sold'] ?? 0;
      pendingPayments.value = data['pending_payments'] ?? [];
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data');
    } finally {
      isLoading.value = false;
    }
  }
} 