import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Example reactive variables (replace with real data/fetch logic)
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
  var selectedDays = 'Last 3 Days'.obs;
  // Add more fields as needed
} 