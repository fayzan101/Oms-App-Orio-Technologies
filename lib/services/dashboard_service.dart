import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_reporting_model.dart';
import '../network/api_service.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class DashboardService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  Future<DashboardReportingModel> getDashboardReporting({
    required String startDate,
    required String endDate,
    String? acno,
  }) async {
    try {
      // Get authentication token
      final apiKey = await _authService.getApiKey();
      
      // Get account number from current user or stored preferences
      String accountNumber = acno ?? '';
      if (accountNumber.isEmpty) {
        final user = _authService.currentUser.value;
        if (user?.acno != null && user!.acno.isNotEmpty) {
          accountNumber = user.acno;
        } else {
          // Fallback to getting from stored preferences
          final prefs = await SharedPreferences.getInstance();
          accountNumber = prefs.getString('acno') ?? '';
        }
      }
      
      print('Dashboard reporting acno: $accountNumber');
      
      // Validate account number
      if (accountNumber.isEmpty) {
        throw Exception('Account number is required but not available');
      }
      
      // Validate dates
      if (startDate.isEmpty || endDate.isEmpty) {
        throw Exception('Start date and end date are required');
      }
      
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'acno': accountNumber,
        'start_date': startDate,
        'end_date': endDate,
      };

      print('Dashboard reporting request data: $requestData');

      // Add authentication header
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (apiKey.isNotEmpty) {
        headers['Authorization'] = 'Bearer $apiKey';
      }

      print('Dashboard reporting headers: $headers');

      final response = await _apiService.post(
        ApiConfig.dashboardEndpoint,
        data: requestData,
        headers: headers,
      );

      print('Dashboard reporting response status: ${response.statusCode}');
      print('Dashboard reporting response data: ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == 1) {
        return DashboardReportingModel.fromJson(response.data['payload']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load dashboard reporting data');
      }
    } on DioException catch (e) {
      print('Dashboard reporting DioException: ${e.message}');
      print('Dashboard reporting DioException status: ${e.response?.statusCode}');
      print('Dashboard reporting DioException response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Dashboard reporting error: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Helper method to get current date range (last 7 days)
  Future<DashboardReportingModel> getCurrentWeekReporting({String? acno}) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 6)).toIso8601String().split('T')[0];
    final endDate = now.toIso8601String().split('T')[0];
    
    return getDashboardReporting(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
    );
  }

  // Helper method to get current month reporting
  Future<DashboardReportingModel> getCurrentMonthReporting({String? acno}) async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1).toIso8601String().split('T')[0];
    final endDate = now.toIso8601String().split('T')[0];
    
    return getDashboardReporting(
      startDate: startDate,
      endDate: endDate,
      acno: acno,
    );
  }

  // Helper method to get custom date range reporting
  Future<DashboardReportingModel> getCustomDateRangeReporting({
    required DateTime startDate,
    required DateTime endDate,
    String? acno,
  }) async {
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    
    return getDashboardReporting(
      startDate: startDateStr,
      endDate: endDateStr,
      acno: acno,
    );
  }
} 